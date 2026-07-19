import 'package:all/all.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

import '../../../models/case_models/calendar_hearing_model.dart';

class CalendarRepository {
  final BaseApiServices _services = NetworkApiServices();

  // ──────────────────────────────────────────────────────────────
  // GET /hearings/calendar?year=&month=
  // ──────────────────────────────────────────────────────────────
  Future<CalendarMonthModel> getCalendarMonth({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getCalendarHearings(year: year, month: month),
        CaseUrls.headers,
      );

      return CalendarMonthModel.fromJson(response);
    } catch (e) {
      debugPrint("Error in CalendarRepository:${e.toString()}");
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // GET /cases/{case_id}/hearings/adjournments
  // ──────────────────────────────────────────────────────────────
  Future<AdjournmentHistoryModel> getAdjournmentHistory({
    required String caseId,
  }) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getHearingAdjournments(caseId),
        CaseUrls.headers,
      );

      return AdjournmentHistoryModel.fromJson(response);
    } catch (e) {
      debugPrint("Error in CalendarRepository: ${e.toString()}");
      rethrow;
    }
  }
}
