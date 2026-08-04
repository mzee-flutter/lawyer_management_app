import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../view_model/services/auth_token_presistance.dart';

// RECONSTRUCTED to mirror LoginRepository's exact structure, since you
// confirmed your real RegisterRepository already saves tokens the same way
// LoginRepository does. I don't have your actual file, so merge this
// against it if there's extra logic in yours I haven't seen -- the
// register endpoint, model names, and token-saving call are the parts
// that matter and should be accurate.
class RegisterRepository {
  final BaseApiServices _services = NetworkApiServices();

  Future<AuthModel> registerUser(RegisterRequestModel user) async {
    final header = {'Content-Type': 'application/json'};
    final requestBody = user.toJson();
    try {
      final response = await _services.getPostApiRequest(
        "${AuthURL.baseURl}/register",
        header,
        requestBody,
      );
      final authResponse = AuthModel.fromJson(response);

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
