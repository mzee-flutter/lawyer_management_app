import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

class LoginUserInfoRepository {
  final BaseApiServices _services = NetworkApiServices();

  Future<AuthModel> fetchLoginUserInfo(String? token) async {
    final header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    try {
      final response = await _services.getGetApiRequest(
        "${AuthURL.baseURl}/me",
        header,
      );

      final user = AuthModel.fromJson(response);

      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
