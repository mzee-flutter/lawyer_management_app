import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

class LoginRepository {
  final BaseApiServices _services = NetworkApiServices();
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<bool> loginUser(LoginRequestModel user) async {
    final header = {'Content-Type': 'application/json'};
    final requestBody = user.toJson();
    try {
      final response = await _services.getPostApiRequest(
        "${AuthURL.baseURl}/login",
        header,
        requestBody,
      );

      final accessToken = response["access_token"] as String;
      final refreshToken = response["refresh_token"] as String;
      final accessTokenExpiry = response["expire_at"] as int;

      await _tokenStorage.saveToken(
        accessToken,
        refreshToken,
        accessTokenExpiry,
      );

      // final user = TokenModel.fromJson(response);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
