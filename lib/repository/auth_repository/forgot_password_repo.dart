import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../models/auth_models/message_response_model.dart';

class ForgotPasswordRepo {
  final BaseApiServices _apiServices;

  ForgotPasswordRepo(this._apiServices);

  Future<MessageResponseModel> requestOtp(String email) async {
    final response = await _apiServices.getPostApiRequest(
      "${AuthURL.baseURl}/forgot-password",
      {"Content-Type": "application/json"},
      {"email": email},
    );
    return MessageResponseModel.fromJson(response);
  }
}
