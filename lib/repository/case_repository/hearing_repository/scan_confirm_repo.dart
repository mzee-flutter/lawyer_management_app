import 'package:flutter/material.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class ScanConfirmRepo {
  final BaseApiServices _services = NetworkApiServices();

  /// Sends the lawyer-confirmed (and possibly edited) fields to the
  /// backend, which creates the actual Hearing via the same
  /// HearingService used by manual hearing creation.
  Future<HearingPublicModel> confirmScan({
    required String scanId,
    required String caseId,
    required DateTime hearingDate,
    TimeOfDay? hearingTime,
    String? title,
    String? notes,
  }) async {
    final dateStr = '${hearingDate.year}-'
        '${hearingDate.month.toString().padLeft(2, '0')}-'
        '${hearingDate.day.toString().padLeft(2, '0')}';

    final body = {
      'case_id': caseId,
      'hearing_date': dateStr,
      if (hearingTime != null)
        'hearing_time':
            '${hearingTime.hour.toString().padLeft(2, '0')}:${hearingTime.minute.toString().padLeft(2, '0')}',
      if (title != null && title.isNotEmpty) 'title': title,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    try {
      final response = await _services.getPostApiRequest(
        CaseUrls.confirmScan(scanId),
        CaseUrls.headers,
        body,
      );
      return HearingPublicModel.fromJson(response);
    } catch (e) {
      debugPrint("Error in ScanConfirmRepo.confirmScan: ${e.toString()}");
      rethrow;
    }
  }

  /// Lets the lawyer discard a scan they don't want to act on (bad photo,
  /// wrong document) without leaving it stuck in a pending state.
  Future<void> discardScan(String scanId) async {
    try {
      await _services.getPostApiRequest(
        CaseUrls.discardScan(scanId),
        CaseUrls.headers,
        {},
      );
    } catch (e) {
      debugPrint("Error in ScanConfirmRepo.discardScan: ${e.toString()}");
      rethrow;
    }
  }
}
