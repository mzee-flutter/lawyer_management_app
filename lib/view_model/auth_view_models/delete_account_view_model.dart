import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/auth_event_bus.dart';
import 'package:right_case/view_model/services/notification_history_view_model.dart';
import 'package:right_case/view_model/services/notification_storage_service.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

import '../../repository/auth_repository/detele_account_repo.dart';

class DeleteAccountResult {
  const DeleteAccountResult.success(this.message) : success = true;
  const DeleteAccountResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

class DeleteAccountViewModel extends ChangeNotifier {
  final DeleteAccountRepo _deleteAccountRepo;
  final CurrentUserViewModel _currentUserVM;
  final NotificationHistoryViewModel _notificationHistoryVM;
  final TokenStorageService _tokenStorage;

  DeleteAccountViewModel({
    required DeleteAccountRepo deleteAccountRepo,
    required CurrentUserViewModel currentUserVM,
    required NotificationHistoryViewModel notificationHistoryVM,
    TokenStorageService? tokenStorage,
  })  : _deleteAccountRepo = deleteAccountRepo,
        _currentUserVM = currentUserVM,
        _notificationHistoryVM = notificationHistoryVM,
        _tokenStorage = tokenStorage ?? TokenStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Inline error state -- replaces relying on a toast for this. A toast
  /// shown from a modal bottom sheet's own context resolves to whatever
  /// Scaffold is nearest in the ancestor tree, which is the Home screen's
  /// Scaffold underneath this modal route -- so it rendered behind the
  /// sheet instead of on top of it. Surfacing the error as sheet state
  /// instead sidesteps that entirely: the View reads it directly, no
  /// cross-route context lookup involved.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Bumped every time a new error is set. Lets the View key its error
  /// banner off this and replay its entrance animation even when two
  /// consecutive failures produce the identical message (e.g. wrong
  /// password twice in a row) -- a key derived from the message text alone
  /// wouldn't register that as "changed."
  int _errorVersion = 0;
  int get errorVersion => _errorVersion;

  void _setError(String message) {
    _errorMessage = message;
    _errorVersion++;
  }

  /// Call when the user edits a field after a failed attempt, so a stale
  /// error doesn't linger once they've started correcting it.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<DeleteAccountResult> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null; // clear any stale banner the moment a retry starts
    notifyListeners();

    try {
      // Captured before the account (and thus this id) is gone.
      final userId = _currentUserVM.user?.id;

      final result = await _deleteAccountRepo.deleteAccount(
        password: password,
        confirmation: confirmation,
      );

      // From this point the account is already gone server-side, so this
      // action has already succeeded from the user's perspective. Local
      // cleanup failures below must NOT be reported as a delete failure --
      // that would tell the user "please try again" for an account that no
      // longer exists, and a retry would just hit a 401/404 against a
      // deleted account. Cleanup errors are logged and swallowed only.
      try {
        if (userId != null) {
          await NotificationStorageService.clearAllForUser(userId);
        }
        _notificationHistoryVM.reset();
        await _tokenStorage.clearTokens();
      } catch (e, stack) {
        debugPrint('Non-fatal cleanup error after account deletion: $e');
        debugPrint(stack.toString());
      }

      AuthEventBus.instance.fireForceLogout();

      return DeleteAccountResult.success(result.message);
    } on SocketException catch (e, stack) {
      debugPrint('Error in DeleteAccountViewModel (SocketException): $e');
      debugPrint(stack.toString());
      const msg =
          'No internet connection. Please check your network and try again.';
      _setError(msg);
      return const DeleteAccountResult.failure(msg);
    } on TimeoutException catch (e, stack) {
      debugPrint('Error in DeleteAccountViewModel (TimeoutException): $e');
      debugPrint(stack.toString());
      const msg = 'The request timed out. Please try again.';
      _setError(msg);
      return const DeleteAccountResult.failure(msg);
    } on ApiException catch (e, stack) {
      debugPrint('Error in DeleteAccountViewModel (ApiException): $e');
      debugPrint(stack.toString());
      final msg = e.message.isNotEmpty
          ? e.message
          : 'Incorrect password. Please check it and try again.';
      _setError(msg);
      return DeleteAccountResult.failure(msg);
    } catch (e, stack) {
      debugPrint('Error in DeleteAccountViewModel: $e');
      debugPrint(stack.toString());
      const msg =
          'Something went wrong. Please check your connection and try again.';
      _setError(msg);
      return const DeleteAccountResult.failure(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
