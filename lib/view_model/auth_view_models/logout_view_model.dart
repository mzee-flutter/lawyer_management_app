import 'package:flutter/foundation.dart';
import 'package:right_case/repository/auth_repository/logout_repo.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class LogoutViewModel with ChangeNotifier {
  LogoutViewModel(this._currentUserVM);

  final CurrentUserViewModel _currentUserVM;
  final LogoutRepo _logoutRepo = LogoutRepo();
  final TokenStorageService _tokenStorage = TokenStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// No BuildContext, no Navigator. clearSession() on CurrentUserViewModel
  /// flips status to unauthenticated (AuthGate reacts) and pops the stack
  /// back to root via NavigationService — so this works correctly even if
  /// the user was five screens deep when they hit "Log out".
  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logoutRepo.logoutUser(await _tokenStorage.getRefreshToken());
    } catch (e) {
      debugPrint('Error in LogoutViewModel: $e');
      // A failed server call doesn't change the outcome — leaving the
      // client "logged in" because the server request failed is worse
      // than a phantom session on the server.
    } finally {
      await _currentUserVM.clearSession();
      _isLoading = false;
      notifyListeners();
    }
  }
}
