import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

import '../../../data/api_exception.dart';

class HearingListRepo {
  final BaseApiServices _services = NetworkApiServices();
  Future<List<HearingPublicModel>> fetchHearingList(String caseId) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getCaseHearings(caseId),
        CaseUrls.headers,
      );

      final data = response as List<dynamic>;
      final dbHearing =
          data.map((hearing) => HearingPublicModel.fromJson(hearing)).toList();
      return dbHearing;
    } catch (e) {
      debugPrint("Error in HearingListRepo: $e");
      rethrow;
    }
  }

  Future<bool?> verifyingHearingExist(String id) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getHearingById(id),
        CaseUrls.headers,
      );
      if (response != null) {
        return true;
      }
      return false;
    } on NotFoundException {
      return false;
    } catch (e) {
      debugPrint(
        "Network or server connection issue caught in HearingListRepo: $e",
      );
      return null;
    }
  }
}
