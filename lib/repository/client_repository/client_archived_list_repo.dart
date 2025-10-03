import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class ClientArchivedListRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<ClientModel>> fetchArchivedClients({
    required int page,
    required int size,
    // optional sort
  }) async {
    try {
      final url =
          StringBuffer("${ClientURl.baseUrl}archived?page=$page&size=$size");

      final response = await _services.getGetApiRequest(
        url.toString(),
        ClientURl.headers,
      );

      final data = response as List<dynamic>;
      final clients = data.map((c) => ClientModel.fromJson(c)).toList();
      return clients;
    } catch (e) {
      debugPrint("Error in ClientArchivedListRepo: $e");
      rethrow;
    }
  }
}
