import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';

import 'package:right_case/models/client_models/client_create_model.dart';
import 'package:right_case/models/client_models/client_model.dart';

import 'package:right_case/resources/URLs/client_urls.dart';

class ClientUpdateRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<ClientModel> clientUpdate(ClientCreateModel client, String id) async {
    final requestBody = client.toJson();
    try {
      final response = await _services.getPatchApiRequest(
          "${ClientURl.baseUrl}$id", ClientURl.headers, requestBody);
      final dbClient = ClientModel.fromJson(response);
      return dbClient;
    } catch (e) {
      debugPrint("Error in ClientCreateRepo: $e");
      rethrow;
    }
  }
}
