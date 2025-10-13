import 'package:flutter/cupertino.dart';
import 'package:right_case/repository/auth_repository/logout_repo.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class LogoutViewModel with ChangeNotifier {
  final LogoutRepo _logoutRepo = LogoutRepo();
  final TokenStorageService _tokenStorage = TokenStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> logoutUser(context) async {
    _toggleLoading(true);
    try {
      final isUserLoggedOut = await _logoutRepo.logoutUser(
        await _tokenStorage.getRefreshToken(),
      );

      _toggleLoading(false);
      if (isUserLoggedOut) {
        Navigator.pushReplacementNamed(context, RoutesName.signInScreen);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
      }
    } catch (e) {
      debugPrint("Error in the LogoutViewModel: $e");
    } finally {
      _toggleLoading(false);
    }
  }
}
