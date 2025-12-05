import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseStatusRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<CaseStatusModel>> fetchCaseStatuses() async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getAllCaseStatuses,
        CaseUrls.headers,
      );
      final data = response as List<dynamic>;
      final caseStatusList =
          data.map((type) => CaseStatusModel.fromJson(type)).toList();
      return caseStatusList;
    } catch (e) {
      debugPrint("Error in CaseStatusRepo:${e.toString()}");
      rethrow;
    }
  }
}
