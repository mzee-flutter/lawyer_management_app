import 'package:flutter/foundation.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/models/auth_models/user_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

class RegisterRepository {
  final BaseApiServices _services = NetworkApiServices();

  Future<UserModel> registerUser(RegisterRequestModel user) async {
    final header = {
      'accept': "application/json",
      'Content-Type': 'application/json',
    };

    final requestBody = user.toJson();

    try {
      final response = await _services.getPostApiRequest(
        "${AuthURL.baseURl}/register",
        header,
        requestBody,
      );

      final user = UserModel.fromJson(response);

      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
