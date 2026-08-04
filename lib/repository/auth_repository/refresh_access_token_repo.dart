import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../view_model/services/auth_token_presistance.dart';

class RefreshAccessTokenRepo {
  final BaseApiServices _services;

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

      // Was previously extracted manually into three local variables and
      // saved via a local TokenStorageService field -- same pattern
      // duplicated in LoginRepository/RegisterRepository. Now shared.
      await AuthTokenPersistence.save(
        accessToken: response["access_token"],
        refreshToken: response["refresh_token"],
        accessTokenExpiry: response["expire_at"],
      );
    } catch (e) {
      debugPrint("RefreshAccessTokenRepo: $e");
      rethrow;
    }
  }
}
