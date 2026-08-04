import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class RemoveRelatedClientRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<RelatedClientModel> removeRelatedClient(String relatedClientId) async {
    try {
      final response = await _services.getDeleteApiRequest(
        CaseUrls.removeRelatedClientFromCase(relatedClientId),
        {},
      );

      final relatedClient = RelatedClientModel.fromJson(response);
      return relatedClient;
    } catch (e) {
      debugPrint("Error in RemoveRelatedClientRepo: $e");
      rethrow;
    }
  }
}
