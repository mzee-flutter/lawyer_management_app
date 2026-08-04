import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../models/auth_models/verify_otp_response_model.dart';

class VerifyOtpRepo {
  final BaseApiServices _apiServices;

  VerifyOtpRepo(this._apiServices);

  Future<VerifyOtpResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiServices.getPostApiRequest(
      "${AuthURL.baseURl}/verify-otp",
      {"Content-Type": "application/json"},
      {"email": email, "otp": otp},
    );
    return VerifyOtpResponseModel.fromJson(response);
  }
}
