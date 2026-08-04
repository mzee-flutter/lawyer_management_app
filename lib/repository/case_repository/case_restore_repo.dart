import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CaseRestoreRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<CaseModel> restoreCase(String id) async {
    try {
      final response = await _services.getPutApiRequest(
        CaseUrls.restoreCase(id),
        CaseUrls.headers,
        {},
      );

      final dbCase = CaseModel.fromJson(response);
      return dbCase;
    } catch (e) {
      debugPrint("Error in CaseRestoreRepo: $e");
      rethrow;
    }
  }
}
