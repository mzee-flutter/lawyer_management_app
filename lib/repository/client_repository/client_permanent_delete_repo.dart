import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';

import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class ClientPermanentDeleteRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<ClientModel> deleteClient(String id) async {
    try {
      final response = await _services.getDeleteApiRequest(
          "${ClientURl.baseUrl}$id/permanent", ClientURl.headers);

      final client = ClientModel.fromJson(response);
      return client;
    } catch (e) {
      debugPrint("Error in ClientPermanentDeleteRepo: $e");
      rethrow;
    }
  }
}
