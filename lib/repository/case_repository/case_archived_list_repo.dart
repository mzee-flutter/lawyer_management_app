import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';
import 'package:right_case/resources/URLs/client_urls.dart';

class CaseArchivedListRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<CaseModel>> fetchArchivedCases({
    required int page,
    required int size,
    // optional sort
  }) async {
    try {
      final archivedCasesUrl =
          StringBuffer("${CaseUrls.archivedCases}?page=$page&size=$size");

      final response = await _services.getGetApiRequest(
        archivedCasesUrl.toString(),
        CaseUrls.headers,
      );

      final data = response as List<dynamic>;
      final cases = data.map((c) => CaseModel.fromJson(c)).toList();
      return cases;
    } catch (e) {
      debugPrint("Error in CaseArchivedListRepo: $e");
      rethrow;
    }
  }
}
