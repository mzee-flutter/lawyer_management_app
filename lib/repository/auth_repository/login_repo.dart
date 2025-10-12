import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

class LoginRepository {
  final BaseApiServices _services = NetworkApiServices();
  final TokenStorageService _tokenStorage = TokenStorageService();

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
      final accessToken = authResponse.tokens.accessToken;
      final refreshToken = authResponse.tokens.refreshToken;
      final accessTokenExpiry = authResponse.tokens.expireAt;

      await _tokenStorage.saveToken(
        accessToken,
        refreshToken,
        accessTokenExpiry,
      );

      return authResponse;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
