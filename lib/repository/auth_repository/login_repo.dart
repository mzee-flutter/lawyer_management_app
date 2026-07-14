import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../view_model/services/auth_token_presistance.dart';

class LoginRepository {
  final BaseApiServices _services = NetworkApiServices();

  Future<AuthModel> loginUser(LoginRequestModel user) async {
    final header = {'Content-Type': 'application/json'};
    final requestBody = user.toJson();
    try {
      final response = await _services.getPostApiRequest(
        "${AuthURL.baseURl}/login",
        header,
        requestBody,
      );
      final authResponse = AuthModel.fromJson(response);

      // Was previously done inline here with a local TokenStorageService
      // field -- same three lines duplicated in RegisterRepository and
      // RefreshAccessTokenRepo. Now shared in one place.
      await AuthTokenPersistence.save(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
        accessTokenExpiry: authResponse.tokens.expireAt,
      );

      return authResponse;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
