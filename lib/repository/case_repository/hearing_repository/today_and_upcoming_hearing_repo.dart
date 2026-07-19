import 'package:all/all.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

import '../../../models/case_models/today_hearing_model.dart';

class AgendaRepository {
  final BaseApiServices _services = NetworkApiServices();

  /// Computed fresh from the actual device timezone, not hardcoded — the
  /// backend uses this only to know what "today" means for this user when
  /// bucketing hearings, so it must reflect the real device offset.
  int get _utcOffsetHours => DateTime.now().timeZoneOffset.inHours;

  Future<List<TodayHearingModel>> getTodayHearings() async {
    try {
      final response = await _services.getGetApiRequest(
        "${CaseUrls.getTodayHearings}?utc_offset_hours=$_utcOffsetHours",
        CaseUrls.headers,
      );

      final data = response as List<dynamic>;
      return data
          .map((hearing) => TodayHearingModel.fromJson(hearing))
          .toList();
    } catch (e) {
      debugPrint("Error in AgendaRepository:${e.toString()}");
      rethrow;
    }
  }

  // ----------------------------------------------------------------
  // Fetch upcoming deadline cards (next N days)
  // Default: 7 days ahead — shows the red/amber warning cards
  // ----------------------------------------------------------------
  Future<List<TodayHearingModel>> getUpcomingDeadlines({
    int daysAhead = 7,
  }) async {
    try {
      final response = await _services.getGetApiRequest(
          "${CaseUrls.getUpcomingHearingDeadlines(daysAhead: daysAhead)}&utc_offset_hours=$_utcOffsetHours",
          CaseUrls.headers);
      final data = response as List<dynamic>;
      return data
          .map((hearing) => TodayHearingModel.fromJson(hearing))
          .toList();
    } catch (e) {
      debugPrint("Error In AgendaRepository: ${e.toString()}");

      rethrow;
    }
  }
}
