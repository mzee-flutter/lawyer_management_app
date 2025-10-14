import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';

import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class CasesListRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<List<CaseModel>> fetchCaseList({
    required int page,
    required int size,
  }) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.listCases,
        CaseUrls.headers,
      );

      final data = response as List<dynamic>;
      final cases = data.map((client) => CaseModel.fromJson(client)).toList();
      return cases;
    } catch (e) {
      debugPrint("Error in CasesListRepo: $e");
      rethrow;
    }
  }
}
