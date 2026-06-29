import 'package:flutter/material.dart';
import 'package:right_case/models/notification_payload.dart';

import '../../view/cases_screen_view/hearing_list_screen_view.dart';
import '../navigation/navigation_service.dart';

class NotificationRouter {
  static NotificationPayload? pendingPayload;

  /// Simply caches the payload during a cold start
  static void setPending(NotificationPayload payload) {
    pendingPayload = payload;
  }

  /// Direct routing for active Foreground/Background tray clicks
  static void navigateToHearing(NotificationPayload payload) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HearingListScreenView(
            caseId: payload.caseId,
            hearingId: payload.hearingId,
          ),
        ),
      );
    });
  }
}
