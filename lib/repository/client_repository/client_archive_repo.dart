import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';

import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class ClientArchiveRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<ClientModel> archiveClient(String id) async {
    try {
      final response = await _services.getDeleteApiRequest(
          "${ClientURl.baseUrl}$id", ClientURl.headers);

      final clients = ClientModel.fromJson(response);
      return clients;
    } catch (e) {
      debugPrint("Error in ClientArchiveRepo: $e");
      rethrow;
    }
  }
}
