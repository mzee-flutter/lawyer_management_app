import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../models/auth_models/message_response_model.dart';

class ResetPasswordRepo {
  final BaseApiServices _apiServices;

  ResetPasswordRepo(this._apiServices);

  Future<MessageResponseModel> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await _apiServices.getPostApiRequest(
      AuthURL.resetPassword,
      {"Content-Type": "application/json"},
      {"reset_token": resetToken, "new_password": newPassword},
    );
    return MessageResponseModel.fromJson(response);
  }
}
