// notification_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/notification_payload.dart';
import 'app_router.dart';

class NotificationRouter {
  NotificationRouter._();

  static String? _lastHandledMessageId;
  static DateTime? _lastHandledAt;

  /// Set the moment a push() gets redirected away before it can land
  /// (cold start, status still initial/loading). AppRouter's redirect
  /// consumes and clears this once a session is actually established —
  /// see _handleAuthRedirect below.
  static String? pendingLocation;

  static String _hearingLocation(NotificationPayload payload) {
    return Uri(
      path: '/hearing/${payload.caseId}',
      queryParameters: {
        if (payload.hearingId != null) 'hearingId': payload.hearingId!,
      },
    ).toString();
  }

  static void handle(NotificationPayload? payload) {
    debugPrint('NotificationRouter.handle: caseId=${payload?.caseId} '
        'hearingId=${payload?.hearingId} messageId=${payload?.messageId}');

    if (payload == null || !payload.isValid) {
      debugPrint(
          'NotificationRouter.handle: DROPPED — null or invalid payload');
      return;
    }

    final now = DateTime.now();
    final isRecentDuplicate = payload.messageId != null &&
        payload.messageId == _lastHandledMessageId &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(seconds: 3);
    if (isRecentDuplicate) {
      debugPrint(
          'NotificationRouter.handle: DROPPED — duplicate (${payload.messageId})');
      return;
    }
    _lastHandledMessageId = payload.messageId;
    _lastHandledAt = now;

    final location = _hearingLocation(payload);
    pendingLocation = location;
    debugPrint('NotificationRouter.handle: pushing $location');
    AppRouter.router.push(location);
  }

  static void goToHearing(BuildContext context, NotificationPayload payload) {
    if (!payload.isValid) return;
    context.push(_hearingLocation(payload));
  }
}
