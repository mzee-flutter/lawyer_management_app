import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../repository/auth_repository/notification_token_repo.dart';
import 'firebase_notification_service.dart';

/// Single, app-lifetime owner of push-token registration and the
/// onTokenRefresh subscription. Login and Register previously each
/// implemented this separately, and neither ever cancelled its listener
/// on logout/re-login — so repeated login/logout cycles accumulated
/// listeners bound to whichever user was logged in when each one was
/// created. A stale listener firing after a DIFFERENT user has since
/// logged in on the same device would register that new device token
/// under the OLD user's account — a real cross-account leak, not just
/// duplicate network calls.
///
/// This class guarantees exactly one active subscription at a time by
/// always cancelling the previous one before creating a new one.
class PushTokenService {
  PushTokenService._();
  static final PushTokenService instance = PushTokenService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationTokenRepo _repo =
      NotificationTokenRepo(); // ADJUST if this needs constructor args in your codebase

  StreamSubscription<String>? _refreshSub;

  /// Call once, right after a successful login OR registration —
  /// wherever `currentUserVM.setAuthenticatedUser(authModel)` is called.
  Future<void> registerForUser(String userId) async {
    try {
      final token = await FirebaseNotificationService().getAndRegisterToken();
      if (token != null) {
        await _repo.registerFCMToken(userId, token);
      }
    } catch (e) {
      debugPrint('FCM registration failed (non-fatal): $e');
    }
    _bindRefreshListener(userId);
  }

  void _bindRefreshListener(String userId) {
    // Cancel whatever was there before — covers both "same user logged
    // in twice" (would've double-printed) and "different user logged in
    // after a previous one" (would've cross-registered A's token to B).
    _refreshSub?.cancel();
    _refreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      try {
        await _repo.registerFCMToken(userId, newToken);
      } catch (e) {
        debugPrint('FCM token refresh registration failed (non-fatal): $e');
      }
    });
  }

  /// Call from CurrentUserViewModel.clearSession() — the one shared
  /// teardown point for logout, delete-account, and forced logout.
  /// Stops this device from registering ANY further token against
  /// whichever user was just logged out.
  Future<void> unbind() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }
}
