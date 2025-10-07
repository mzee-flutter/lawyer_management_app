import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class LogoutRepo {
  final BaseApiServices _services = NetworkApiServices();
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<bool> logoutUser(String? refreshToken) async {
    final header = {"Content-Type": "application/json"};
    final requestBody = {"refresh_token": refreshToken};

    try {
      final response = await _services.getDeleteApiRequest(
        "${AuthURL.baseURl}/logout",
        requestBody,
      );

      await _tokenStorage.clearTokens();
      debugPrint(response.toString());

      return true;
    } catch (e) {
      debugPrint("Error in LogoutRepo: $e");
      rethrow;
    }
  }
}
