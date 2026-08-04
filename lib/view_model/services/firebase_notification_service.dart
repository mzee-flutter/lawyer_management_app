import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/app_router.dart';

import '../../models/notification_payload.dart';
import '../../models/stored_notification_model.dart';
import '../../utils/routes/notification_router.dart';
import '../auth_view_models/current_user_view_model.dart';
import 'notification_history_view_model.dart';
import 'notification_storage_service.dart';

class FirebaseNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();
    await initLocalNotifications();
    await _handleTerminatedState();
    _initForegroundListener();
    _initTapListener();
  }

  Future<void> _handleTerminatedState() async {
    final initialMessage = await _messaging.getInitialMessage();
    debugPrint('FirebaseNotificationService: getInitialMessage data='
        '${initialMessage?.data} messageId=${initialMessage?.messageId}');
    if (initialMessage == null) return;
    NotificationRouter.handle(NotificationPayload.fromMap(initialMessage.data));
  }

  void _initForegroundListener() {
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;

      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      final userId = context.read<CurrentUserViewModel>().user?.id;
      if (userId == null) {
        debugPrint('Foreground notification dropped: no active session.');
        return;
      }

      final payload = NotificationPayload.fromMap(message.data);
      final stored = StoredNotificationModel(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: payload,
        timestamp: DateTime.now(),
      );

      await NotificationStorageService.saveNotification(stored, userId);

      context
          .read<NotificationHistoryViewModel>()
          .addInComingNotification(stored);

      await _localNotifications.show(
        id: stored.id.hashCode, // stable per message, not per-second
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'hearing_channel',
            'Hearing Notifications',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
          ),
        ),
        payload: jsonEncode({...message.data, 'messageId': message.messageId}),
      );
    });
  }

  Future<void> initLocalNotifications() async {
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        final data = jsonDecode(response.payload!);
        NotificationRouter.handle(NotificationPayload.fromMap(data));
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (launchDetails?.didNotificationLaunchApp == true) {
      _handleLocalNotificationPayload(
          launchDetails?.notificationResponse?.payload);
    }
  }

  void _handleLocalNotificationPayload(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload);
      NotificationRouter.handle(NotificationPayload.fromMap(data));
    } catch (e) {
      debugPrint(
          'FirebaseNotificationService: bad local notification payload: $e');
    }
  }

  void _initTapListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationRouter.handle(NotificationPayload.fromMap(message.data));
    });
  }

  Future<String?> getAndRegisterToken() async {
    final token = await _messaging.getToken();
    debugPrint('🔥 FCM TOKEN: $token');
    return token;
  }
}
