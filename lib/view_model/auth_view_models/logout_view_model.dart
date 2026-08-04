import 'package:flutter/foundation.dart';
import 'package:right_case/repository/auth_repository/logout_repo.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/notification_history_view_model.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class LogoutViewModel with ChangeNotifier {
  LogoutViewModel(this._currentUserVM, this._notificationHistoryVM);

  CurrentUserViewModel _currentUserVM;
  NotificationHistoryViewModel _notificationHistoryVM;
  final LogoutRepo _logoutRepo = LogoutRepo();
  final TokenStorageService _tokenStorage = TokenStorageService();

  void updateDependencies(
    CurrentUserViewModel currentUserVM,
    NotificationHistoryViewModel notificationVM,
  ) {
    _currentUserVM = currentUserVM;
    _notificationHistoryVM = notificationVM;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// No BuildContext, no Navigator. clearSession() flips status to
  /// unauthenticated (AuthGate reacts), pops back to root, AND clears
  /// this device's FCM token (see clearSession() for why that lives
  /// there) — so this works correctly even five screens deep.
  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logoutRepo.logoutUser(await _tokenStorage.getRefreshToken());
    } catch (e) {
      debugPrint('Error in LogoutViewModel: $e');
      // A failed server call doesn't change the outcome — leaving the
      // client "logged in" because the request failed is worse than a
      // phantom session on the server.
    } finally {
      // Drop the in-memory notification list and unbind the user id so
      // nothing from this account is visible, even for a frame, before
      // the next login calls bindUser() again.
      _notificationHistoryVM.reset();

      await _currentUserVM.clearSession();
      _isLoading = false;
      notifyListeners();
    }
  }
}
