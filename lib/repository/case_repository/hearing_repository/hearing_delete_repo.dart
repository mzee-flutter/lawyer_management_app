import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class HearingDeleteRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<HearingPublicModel> deleteHearing(String hearingId) async {
    try {
      final response = await _services.getDeleteApiRequest(
          CaseUrls.deleteHearing(hearingId), CaseUrls.headers);

      final dbHearing = HearingPublicModel.fromJson(response);
      return dbHearing;
    } catch (e) {
      debugPrint("Error in : HearingDeleteRepo:$e");
      rethrow;
    }
  }
}
