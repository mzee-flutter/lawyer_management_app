import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

class RefreshAccessTokenRepo {
  final BaseApiServices _services;

  final TokenStorageService _tokenStorage = TokenStorageService();

  RefreshAccessTokenRepo(this._services);

  Future<void> getFreshAccessToken(String? token) async {
    final headers = {"Content-Type": "application/json"};

    final requestBody = {"refresh_token": token};

    try {
      final response = await _services.getPostApiRequest(
        "${AuthURL.baseURl}/refresh",
        headers,
        requestBody,
      );

      final accessToken = response["access_token"];
      final refreshToken = response["refresh_token"];
      final accessTokenExpiry = response["expire_at"];

      await _tokenStorage.saveToken(
        accessToken,
        refreshToken,
        accessTokenExpiry,
      );
    } catch (e) {
      debugPrint("RefreshAccessTokenRepo: $e");
      rethrow;
    }
  }
}
