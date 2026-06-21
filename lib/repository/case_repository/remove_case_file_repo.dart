import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class RemoveCaseFileRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<CaseFileModel> removeFileFromCase(String fileId) async {
    try {
      final response = await _services.getDeleteApiRequest(
        CaseUrls.deleteCaseFile(fileId),
        {},
      );

      final caseFile = CaseFileModel.fromJson(response);
      return caseFile;
    } catch (e) {
      debugPrint("Error in RemoveCaseFileRepo: $e");
      rethrow;
    }
  }
}
