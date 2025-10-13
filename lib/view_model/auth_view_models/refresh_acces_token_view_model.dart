import 'package:flutter/cupertino.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/repository/auth_repository/refresh_access_token_repo.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class RefreshAccessTokenViewModel with ChangeNotifier {
  final RefreshAccessTokenRepo _accessTokenRepo = RefreshAccessTokenRepo(
    NetworkApiServices(),
  );
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<void> getFreshAccessToken() async {
    try {
      await _accessTokenRepo.getFreshAccessToken(
        await _tokenStorage.getRefreshToken(),
      );
    } catch (e) {
      debugPrint("Error from RefreshAccessTokenViewModel: $e");
    }
  }
}
