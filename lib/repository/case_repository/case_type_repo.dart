import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseTypeRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<CaseTypeModel>> fetchCaseTypes() async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getAllCaseTypes,
        CaseUrls.headers,
      );
      final data = response as List<dynamic>;
      final caseTypeList =
          data.map((type) => CaseTypeModel.fromJson(type)).toList();
      return caseTypeList;
    } catch (e) {
      debugPrint("Error in CaseTypeRepo:${e.toString()}");
      rethrow;
    }
  }
}
