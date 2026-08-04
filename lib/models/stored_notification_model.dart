import 'dart:convert';

import 'package:right_case/models/notification_payload.dart';

class StoredNotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationPayload payload;
  final DateTime timestamp;
  bool isRead;

  StoredNotificationModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.payload,
      required this.timestamp,
      this.isRead = false});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "payload": {
        "case_id": payload.caseId,
        "hearing_id": payload.hearingId,
      },
      "timestamp": timestamp.toIso8601String(),
      "isRead": isRead,
    };
  }

  factory StoredNotificationModel.fromMap(Map<String, dynamic> map) {
    return StoredNotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      payload: NotificationPayload.fromMap(
        Map<String, dynamic>.from(map['payload'] ?? {}),
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory StoredNotificationModel.fromJson(String source) =>
      StoredNotificationModel.fromMap(
        json.decode(source),
      );
}
