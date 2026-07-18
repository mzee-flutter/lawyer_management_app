import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/repository/auth_repository/login_user_info_repo.dart';
import 'package:right_case/view_model/services/push_token_service.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

import '../../data/api_exception.dart';
import '../services/auth_event_bus.dart';

enum SessionStatus {
  /// App just launched — we haven't checked for a stored session yet.
  initial,

  /// A network/token check is currently in flight.
  loading,

  /// A verified user is available. `user` is guaranteed non-null.
  authenticated,

  /// No valid session — either no token was stored, or it was rejected.
  unauthenticated,

  /// Bootstrap failed for a reason that ISN'T "you're logged out"
  /// (e.g. no internet). Distinct from unauthenticated on purpose —
  /// we don't want a network blip to silently log someone out.
  error,
}

/// The single source of truth for "who is the current user" across
/// the whole app. Login/Register/Logout/Delete-account/Drawer/Profile
/// all read or write through this ONE object — never through a
/// feature-specific viewmodel's leftover `dbUser` field.
class CurrentUserViewModel with ChangeNotifier {
  final LoginUserInfoRepository _repo;
  final TokenStorageService _tokenStorage;

  CurrentUserViewModel({
    LoginUserInfoRepository? repository,
    TokenStorageService? tokenStorage,
  })  : _repo = repository ?? LoginUserInfoRepository(),
        _tokenStorage = tokenStorage ?? TokenStorageService() {
    // A 401 discovered deep inside some unrelated API call (loading a case
    // file, creating a hearing, etc.) still has to end up here, or the UI
    // and the real session state drift apart. This is what NetworkApiServices
    // fires after a refresh-token failure, from anywhere in the app.
    AuthEventBus.instance.onForceLogout.listen((_) => clearSession());
  }

  SessionStatus _status = SessionStatus.initial;
  User? _user;
  String? _lastErrorMessage;

  SessionStatus get status => _status;
  User? get user => _user;
  String? get lastErrorMessage => _lastErrorMessage;

  bool get isAuthenticated =>
      _status == SessionStatus.authenticated && _user != null;
  bool get isLoading => _status == SessionStatus.loading;

  // ────────────────────────────────────────────────────────────
  // COLD START — call this ONCE, kicked off from the CurrentUserViewModel
  // provider in main.dart (`create: (_) => CurrentUserViewModel()..bootstrapSession()`).
  // AuthGate watches `status` and renders Splash/Home/SignIn/Error accordingly.
  // ────────────────────────────────────────────────────────────

  Future<void> bootstrapSession() async {
    _status = SessionStatus.loading;
    notifyListeners();

    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      _status = SessionStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final fetchedUser = await _repo.fetchLoginUserInfo(token);
      _user = fetchedUser;
      _status = SessionStatus.authenticated;
      _lastErrorMessage = null;
    } on UnauthorizedRequestException {
      // This is the exception NetworkApiServices actually throws once a
      // 401 survives a refresh attempt (see api_exception.dart). The old
      // code caught a different, unrelated `UnauthorizedException` class
      // defined in login_user_info_repo.dart — that catch could never
      // match a real server rejection, so every expired/revoked token
      // fell through to the generic `catch` below and landed on `error`
      // instead of `unauthenticated`. That mismatch was the whole "restart
      // sends me to the wrong screen" bug.
      await _tokenStorage.clearTokens();
      _user = null;
      _status = SessionStatus.unauthenticated;
    } catch (e) {
      // Network failure, server down, etc. Deliberately NOT unauthenticated
      // — we don't want a dropped connection to boot a legitimately
      // logged-in lawyer out of their cases. The token stays stored; call
      // retryBootstrap() to try again.
      _lastErrorMessage = e.toString();
      _status = SessionStatus.error;
    }

    notifyListeners();
  }

  Future<void> retryBootstrap() => bootstrapSession();

  // ────────────────────────────────────────────────────────────
  // CHEAP PATH — Login/Register call this the moment they succeed.
  // No extra network round-trip; we already have the AuthModel.
  // ────────────────────────────────────────────────────────────
  void setAuthenticatedUser(AuthModel user) {
    _user = user.user;
    _status = SessionStatus.authenticated;
    _lastErrorMessage = null;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────
  // Manual refresh — e.g. a profile screen's pull-to-refresh, or
  // after an "edit profile" save, to re-sync from the server.
  // ────────────────────────────────────────────────────────────
  Future<void> refreshUser() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;
    try {
      _user = await _repo.fetchLoginUserInfo(token);
      notifyListeners();
    } catch (e) {
      debugPrint('CurrentUserViewModel.refreshUser failed: $e');
      // Deliberately silent on failure — a failed background refresh
      // shouldn't rip a valid cached user off the screen.
    }
  }

  // ────────────────────────────────────────────────────────────
  // Called by LogoutViewModel, the Delete-Account flow, AND the
  // AuthEventBus forced-logout listener above. This is the ONLY
  // place session state gets torn down.
  // ────────────────────────────────────────────────────────────
  Future<void> clearSession() async {
    await _tokenStorage.clearTokens();

    _user = null;
    _status = SessionStatus.unauthenticated;
    _lastErrorMessage = null;
    notifyListeners();

    unawaited(PushTokenService.instance.unbind());
    unawaited(
      FirebaseMessaging.instance.deleteToken().catchError((e) {
        debugPrint(
            'Failed to delete FCM token during clearSession (non-fatal): $e');
      }),
    );
  }
}
