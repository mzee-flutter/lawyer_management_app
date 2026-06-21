import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class AddRelatedClientRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<RelatedClientModel>> addRelatedClients(
    String caseId,
    List<RelatedClientRequestModel> relatedClients,
  ) async {
    try {
      final requestBody = {
        "items": relatedClients.map((rc) => rc.toJson()).toList()
      };
      final response = await _services.getPostApiRequest(
        CaseUrls.addClientToCase(caseId),
        CaseUrls.headers,
        requestBody,
      );
      final data = response as List<dynamic>;

      final addedClients =
          data.map((client) => RelatedClientModel.fromJson(client)).toList();
      return addedClients;
    } catch (e) {
      debugPrint("Error in AddRelatedClientRepo:${e.toString()}");
      rethrow;
    }
  }
}
