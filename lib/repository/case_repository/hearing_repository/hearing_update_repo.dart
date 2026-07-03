import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class HearingUpdateRepo {
  final BaseApiServices _services = NetworkApiServices();

  // Now takes HearingUpdateModel instead of HearingCreateModel
  Future<HearingPublicModel> updateHearing(
    HearingUpdateModel hearing,
    String hearingId,
  ) async {
    final requestBody = hearing.toJson();
    try {
      final response = await _services.getPatchApiRequest(
        CaseUrls.updateHearing(hearingId),
        CaseUrls.headers,
        requestBody,
      );
      return HearingPublicModel.fromJson(response);
    } catch (e) {
      debugPrint('Error in HearingUpdateRepo: $e');
      rethrow;
    }
  }
}
