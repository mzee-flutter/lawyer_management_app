import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';

import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class HearingCreateRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<HearingPublicModel> createHearing({
    required String caseId,
    required HearingCreateModel hearing,
  }) async {
    final requestBody = hearing.toJson();
    try {
      final response = await _services.getPostApiRequest(
        CaseUrls.createHearing(caseId),
        CaseUrls.headers,
        requestBody,
      );
      final hearing = HearingPublicModel.fromJson(response);
      return hearing;
    } catch (e) {
      debugPrint("Error in HearingCreateRepo:${e.toString()}");
      rethrow;
    }
  }
}
