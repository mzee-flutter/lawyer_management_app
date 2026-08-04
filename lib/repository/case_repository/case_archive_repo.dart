import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseArchiveRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<CaseModel> archiveCase(String id) async {
    try {
      final response = await _services.getDeleteApiRequest(
          CaseUrls.archiveCase(id), CaseUrls.headers);

      final caseData = CaseModel.fromJson(response);
      return caseData;
    } catch (e) {
      debugPrint("Error in CaseArchiveRepo: $e");
      rethrow;
    }
  }
}
