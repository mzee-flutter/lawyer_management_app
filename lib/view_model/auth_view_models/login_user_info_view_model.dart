import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/repository/auth_repository/login_user_info_repo.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class LoginUserInfoViewModel with ChangeNotifier {
  final _loggedInUserRepo = LoginUserInfoRepository();
  final TokenStorageService _tokenStorage = TokenStorageService();

  AuthModel? _loggedInUserInfo;
  AuthModel? get loggedInUserInfo => _loggedInUserInfo;

  Future<void> fetchLoggedInUserInfo() async {
    try {
      final user = await _loggedInUserRepo.fetchLoginUserInfo(
        await _tokenStorage.getAccessToken(),
      );
      _loggedInUserInfo = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error in LoginUserInfoViewModel: ${e.toString()}');
    }
  }
}
