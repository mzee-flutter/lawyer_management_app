import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../models/auth_models/change_password_response_model.dart';
import '../../view_model/services/auth_token_presistance.dart';

class ChangePasswordRepo {
  final BaseApiServices _apiServices;

  ChangePasswordRepo(this._apiServices);

  Future<ChangePasswordResponseModel> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiServices.getPatchApiRequest(
      "${AuthURL.baseURl}/change-password",
      {"Content-Type": "application/json"},
      {"current_password": currentPassword, "new_password": newPassword},
    );
    final result = ChangePasswordResponseModel.fromJson(response);

    // Backend revokes every refresh token for this user (including this
    // device's) and issues a fresh pair in the same response -- saved here
    // at the repo layer, matching how Login/Register/Refresh all persist
    // tokens as a side effect of their network call, not in the ViewModel.
    await AuthTokenPersistence.save(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      accessTokenExpiry: result.expireAt,
    );

    return result;
  }
}
