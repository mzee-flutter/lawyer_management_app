import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/client_model.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class ClientListRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<List<ClientModel>> fetchClientList() async {
    try {
      final response = await _services.getGetApiRequest(
          ClientURl.baseUrl, ClientURl.headers);

      final data = response as List<dynamic>;
      final clients =
          data.map((client) => ClientModel.fromJson(client)).toList();
      return clients;
    } catch (e) {
      debugPrint("Error in ClientListRepo: $e");
      rethrow;
    }
  }
}
