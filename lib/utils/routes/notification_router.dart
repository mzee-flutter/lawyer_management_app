import 'package:all/all.dart';

import '../../models/notification_payload.dart';

class NotificationRouter {
  NotificationRouter._();
  // no more `static late final GoRouter router` — use AppRouter.router directly

  static String? _lastHandledMessageId;
  static DateTime? _lastHandledAt;

  static String _hearingLocation(NotificationPayload payload) {
    return Uri(
      path: '/hearing/${payload.caseId}',
      queryParameters: {
        if (payload.hearingId != null) 'hearingId': payload.hearingId!,
      },
    ).toString();
  }

  static void handle(NotificationPayload? payload) {
    if (payload == null || !payload.isValid) return;
    final now = DateTime.now();
    final isRecentDuplicate = payload.messageId != null &&
        payload.messageId == _lastHandledMessageId &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(seconds: 3);
    if (isRecentDuplicate) return;
    _lastHandledMessageId = payload.messageId;
    _lastHandledAt = now;
    AppRouter.router.push(_hearingLocation(payload));
  }

  static void goToHearing(BuildContext context, NotificationPayload payload) {
    if (!payload.isValid) return;
    context.push(_hearingLocation(payload));
  }
}
