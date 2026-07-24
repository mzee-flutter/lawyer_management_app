import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/stored_notification_model.dart';

class NotificationStorageService {
  // Real key becomes this + userId, e.g. "in_app_notifications_key_3f9b...".
  // Two lawyers on the same device now read from two separate entries,
  // not one shared list.
  static const String _storageKeyPrefix = "in_app_notifications_key";

  // The OLD, pre-fix, unscoped key. Never read from this for real data —
  // it may hold notifications belonging to whichever user was logged in
  // before this fix shipped, with no reliable way to attribute them.
  static const String _legacyStorageKey = "in_app_notifications_key";

  static String _keyFor(String userId) => "${_storageKeyPrefix}_$userId";

  /// Call ONCE at app startup, in main(), before runApp(). Deletes the
  /// old unscoped key so stale, mixed-owner data can never leak into a
  /// freshly-scoped session. Intentionally destructive — mixed data
  /// under the old key can't be safely attributed to one user.
  static Future<void> migrateLegacyDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_legacyStorageKey)) {
      await prefs.remove(_legacyStorageKey);
    }
  }

  static Future<void> saveNotification(
    StoredNotificationModel notification,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(userId);
    final List<String> currentList = prefs.getStringList(key) ?? [];

    currentList.insert(0, notification.toJson());
    if (currentList.length > 100) {
      currentList.removeLast();
    }

    await prefs.setStringList(key, currentList);
  }

  static Future<List<StoredNotificationModel>> getAllNotification(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyFor(userId)) ?? [];

    return jsonList.map((n) => StoredNotificationModel.fromJson(n)).toList();
  }

  static Future<void> markAsRead(String id, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(userId);
    final all = await getAllNotification(userId);

    final index = all.indexWhere((item) => item.id == id);
    if (index != -1) {
      all[index].isRead = true;
      final updated = all.map((item) => item.toJson()).toList();
      await prefs.setStringList(key, updated);
    }
  }

  static Future<void> deleteNotification(String id, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(userId);
    final all = await getAllNotification(userId);

    all.removeWhere((n) => n.id == id);

    final updated = all.map((item) => item.toJson()).toList();
    await prefs.setStringList(key, updated);
  }

  static Future<int> unReadNotificationsCount(String userId) async {
    final all = await getAllNotification(userId);
    return all.where((item) => item.isRead == false).length;
  }

  static Future<void> autoRemoveNotificationFromLocal(
    String notificationId,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final all = await getAllNotification(userId);
      all.removeWhere((item) => item.id == notificationId);
      final updated = all.map((item) => item.toJson()).toList();
      await prefs.setStringList(_keyFor(userId), updated);
    } catch (e) {
      debugPrint(
          "Failed to auto-heal local notifications for user $userId: $e");
    }
  }

  /// Wipes all locally-stored notifications for one user. Call on
  /// account deletion — never on regular logout, since the same lawyer
  /// logging back in later should still see their history.
  static Future<void> clearAllForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
  }

  // Add to NotificationStorageService — dev/debug only, not part of the
// leak fix itself, just visibility into current on-device state.
//   static Future<void> debugPrintAllStoredKeys() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys().where((k) => k.startsWith(_storageKeyPrefix));
//     for (final k in keys) {
//       final list = prefs.getStringList(k) ?? [];
//       debugPrint('$k → ${list.length} notification(s)');
//     }
//   }
}
