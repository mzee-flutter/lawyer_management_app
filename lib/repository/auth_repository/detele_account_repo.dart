import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../models/auth_models/message_response_model.dart';

class DeleteAccountRepo {
  final BaseApiServices _apiServices;

  DeleteAccountRepo(this._apiServices);

  // NetworkApiServices.getDeleteApiRequest only takes (url, body) -- unlike
  // the other verbs it doesn't accept a separate headers argument, since
  // it never forwards customHeaders internally. Auth + Content-Type are
  // still attached automatically, same as every other request.
  Future<MessageResponseModel> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    final response = await _apiServices.getDeleteApiRequest(
      AuthURL.deleteAccount,
      {"password": password, "confirmation": confirmation},
    );
    return MessageResponseModel.fromJson(response);
  }
}
