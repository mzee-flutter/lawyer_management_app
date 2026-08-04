import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_create_model.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseUpdateRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<CaseModel> caseUpdate(CaseCreateModel caseData, String id) async {
    final requestBody = caseData.toJson();
    try {
      final response = await _services.getPatchApiRequest(
        CaseUrls.updateCase(id),
        CaseUrls.headers,
        requestBody,
      );

      final dbCase = CaseModel.fromJson(response);
      return dbCase;
    } catch (e) {
      debugPrint("Error in CaseUpdateRepo: $e");
      rethrow;
    }
  }
}
