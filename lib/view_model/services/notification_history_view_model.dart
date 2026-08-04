// lib/view_model/services/notification_history_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:right_case/models/notification_payload.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_list_repo.dart';

import '../../models/stored_notification_model.dart';
import 'notification_storage_service.dart';

/// What actually happened when a notification was tapped. The ViewModel
/// never touches BuildContext, SnackBars, or navigation — it only reports
/// outcomes. The View decides what to show and where to go, based on this
/// result. This is what makes `handleNotificationTap` testable with a
/// plain `expect(await vm.handleNotificationTap(...), someResult)` and
/// no widget tree required at all.
enum NotificationTapResult {
  /// Hearing exists — notification is now marked read. The View should
  /// navigate using the same [NotificationPayload] it already passed in.
  navigated,

  /// Hearing no longer exists. Storage removal and in-memory removal
  /// already happened inside the VM — nothing left to mark. The View
  /// should just inform the user.
  hearingRemoved,

  /// The existence check came back ambiguous (repo returned null rather
  /// than true/false). Notification is left untouched — unread, still in
  /// the list, still tappable — so the user can retry.
  networkError,

  /// An exception was thrown during the check, or the payload itself was
  /// malformed (missing hearingId). Also leaves the notification
  /// untouched, same reasoning as [networkError].
  unexpectedError,

  /// A check for this exact notification is already running — returned
  /// instead of firing a duplicate network call or double-navigating.
  alreadyInProgress,
}

class NotificationHistoryViewModel with ChangeNotifier {
  final HearingListRepo _hearingListRepo;

  NotificationHistoryViewModel({HearingListRepo? hearingListRepo})
      : _hearingListRepo = hearingListRepo ?? HearingListRepo();

  String? _userId;

  List<StoredNotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isMarkingAllRead = false;
  final Set<String> _checkingIds = {};

  List<StoredNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  bool get isLoading => _isLoading;
  bool get isMarkingAllRead => _isMarkingAllRead;
  bool isCheckingHearing(String notificationId) =>
      _checkingIds.contains(notificationId);

  /// Call this once, right after AuthGate confirms a session — before
  /// fetchInboxNotification() is ever called. Every storage read/write
  /// below requires a bound user id, so this ViewModel simply cannot
  /// touch notification data for the wrong account.
  void bindUser(String userId) {
    _userId = userId;
  }

  /// Call this on logout (wire it to AuthEventBus, same as the rest of
  /// your auth-driven state resets). Clears the in-memory list so a
  /// stale screen never flashes the previous user's data for a frame
  /// before the next bindUser() call lands, and unbinds so any call
  /// made between logout and the next login fails loudly instead of
  /// silently hitting the wrong key.
  void reset() {
    _notifications = [];
    _userId = null;
    _checkingIds.clear();
    notifyListeners();
  }

  String get _requireUserId {
    final id = _userId;
    if (id == null) {
      throw StateError(
        'NotificationHistoryViewModel used before bindUser() was called.',
      );
    }
    return id;
  }

  Future<void> fetchInboxNotification() async {
    _isLoading = true;
    notifyListeners();
    _notifications =
        await NotificationStorageService.getAllNotification(_requireUserId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    await NotificationStorageService.markAsRead(id, _requireUserId);
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  Future<bool> markAllNotificationsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty || _isMarkingAllRead) return false;

    _isMarkingAllRead = true;
    notifyListeners();
    try {
      for (final n in unread) {
        await markNotificationAsRead(n.id);
      }
      return true;
    } finally {
      _isMarkingAllRead = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    await NotificationStorageService.deleteNotification(id, _requireUserId);
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addInComingNotification(StoredNotificationModel item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  Future<NotificationTapResult> handleNotificationTap(
    NotificationPayload notification,
    String notificationId,
  ) async {
    if (_checkingIds.contains(notificationId)) {
      return NotificationTapResult.alreadyInProgress;
    }
    if (notification.hearingId == null) {
      return NotificationTapResult.unexpectedError;
    }

    _checkingIds.add(notificationId);
    notifyListeners();

    try {
      final bool? hearingExists =
          await _hearingListRepo.verifyingHearingExist(notification.hearingId!);

      if (hearingExists == true) {
        await markNotificationAsRead(notificationId);
        return NotificationTapResult.navigated;
      }

      if (hearingExists == false) {
        await NotificationStorageService.autoRemoveNotificationFromLocal(
          notificationId,
          _requireUserId,
        );
        _notifications.removeWhere((item) => item.id == notificationId);
        notifyListeners();
        return NotificationTapResult.hearingRemoved;
      }

      return NotificationTapResult.networkError;
    } catch (e) {
      debugPrint('Pre-flight navigation execution pipeline failed: $e');
      return NotificationTapResult.unexpectedError;
    } finally {
      _checkingIds.remove(notificationId);
      notifyListeners();
    }
  }
}
