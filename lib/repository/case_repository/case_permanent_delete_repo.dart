import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CasePermanentDeleteRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<CaseModel> deleteCase(String id) async {
    try {
      final response = await _services.getDeleteApiRequest(
          CaseUrls.deleteCasePermanently(id), CaseUrls.headers);

      final caseData = CaseModel.fromJson(response);
      return caseData;
    } catch (e) {
      debugPrint("Error in CasePermanentDeleteRepo: $e");
      rethrow;
    }
  }
}
