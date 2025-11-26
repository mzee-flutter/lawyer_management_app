import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_create_model.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseCreateRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<CaseModel> createCase(CaseCreateModel createCase) async {
    final requestBody = createCase.toJson();
    try {
      final response = await _services.getPostApiRequest(
          CaseUrls.createCase, CaseUrls.headers, requestBody);
      final createdCase = CaseModel.fromJson(response);
      return createdCase;
    } catch (e) {
      debugPrint("Error in CaseCreateRepo:${e.toString()}");
      rethrow;
    }
  }
}
