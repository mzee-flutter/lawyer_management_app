import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseStageRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<CaseStageModel>> fetchCaseStages() async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getAllCaseStages,
        CaseUrls.headers,
      );
      final data = response as List<dynamic>;
      final caseStageList =
          data.map((type) => CaseStageModel.fromJson(type)).toList();
      return caseStageList;
    } catch (e) {
      debugPrint("Error in CaseStageRepo:${e.toString()}");
      rethrow;
    }
  }
}
