import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../resources/system_design/rc_theme.dart';
import '../resources/system_design/rc_widgets.dart';
import '../utils/snakebars_and_popUps/snake_bars.dart';
import '../view_model/services/notification_history_view_model.dart';

class NotificationHistoryScreenView extends StatefulWidget {
  const NotificationHistoryScreenView({super.key});

  @override
  State<NotificationHistoryScreenView> createState() =>
      _NotificationHistoryScreenViewState();
}

class _NotificationHistoryScreenViewState
    extends State<NotificationHistoryScreenView> {
  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationHistoryViewModel>().fetchInboxNotification();
    });
  }

  // The old VM had no bulk endpoint — this loops the existing single-item
  // mark-as-read call rather than inventing a new backend method.
  Future<void> _markAllRead(NotificationHistoryViewModel vm) async {
    final unread = vm.notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty || _markingAll) return;

    setState(() => _markingAll = true);
    try {
      for (final n in unread) {
        await vm.markNotificationAsRead(n.id);
      }
      if (mounted) {
        SnakeBars.scaffoldMessenger('All notifications marked as read', context,
            type: SnackType.success);
      }
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationHistoryViewModel>();
    final hasUnread = vm.notifications.any((n) => !n.isRead);

    // Fixed: old code could show the empty state AND a loading overlay
    // simultaneously on first load. States are now mutually exclusive.
    final isInitialLoad = vm.isLoading && vm.notifications.isEmpty;
    final isEmpty = !vm.isLoading && vm.notifications.isEmpty;

    return Scaffold(
      backgroundColor: RC.background,
      appBar: _buildAppBar(vm, hasUnread),
      body: isInitialLoad
          ? const _NotificationSkeleton()
          : isEmpty
              ? const RCEmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Your Inbox is Clear',
                  message:
                      'Reminders for upcoming hearings and case updates will appear here.',
                )
              : RefreshIndicator(
                  color: RC.navy,
                  backgroundColor: RC.surface,
                  onRefresh: () => vm.fetchInboxNotification(),
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vm.notifications.length,
                    itemBuilder: (context, index) {
                      final item = vm.notifications[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () async {
                          await vm.handleNotificationTap(
                              context, item.payload, item.id);
                          await vm.markNotificationAsRead(item.id);
                        },
                        onDismiss: () async {
                          await vm.deleteNotification(item.id);
                          if (context.mounted) {
                            SnakeBars.scaffoldMessenger(
                                'Notification deleted', context,
                                type: SnackType.success);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      NotificationHistoryViewModel vm, bool hasUnread) {
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: RC.textOnDark),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Notifications',
              style: TextStyle(
                  color: RC.textOnDark,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700)),
          Text(
            vm.notifications.isEmpty
                ? 'No activity yet'
                : '${vm.notifications.length} total',
            style: TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp),
          ),
        ],
      ),
      actions: [
        if (hasUnread)
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton(
              onPressed: _markingAll ? null : () => _markAllRead(vm),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10.w)),
              child: _markingAll
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: RC.gold))
                  : Text('Mark all read',
                      style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: RC.gold)),
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic
      item; // StoredNotificationModel — kept dynamic to match existing VM shape
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard(
      {required this.item, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final bool isRead = item.isRead as bool;
    final Color accent = isRead ? RC.textTertiary : RC.infoText;
    final Color surface = isRead ? RC.surface : RC.infoSurface;
    final Color border =
        isRead ? RC.divider : RC.infoText.withValues(alpha: 0.25);

    return Dismissible(
      key: Key(item.id as String),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
            color: RC.dangerSurface, borderRadius: BorderRadius.circular(14.r)),
        child:
            Icon(Icons.delete_outline_rounded, color: RC.danger, size: 20.sp),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: border, width: 1),
                // Fixed: original shadow used a raw dark colour with no
                // alpha, producing a heavy near-opaque smear. RC.cardShadow
                // is the same soft elevation used everywhere else.
                boxShadow: [RC.cardShadow],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r)),
                    child:
                        Icon(Icons.balance_rounded, size: 17.sp, color: accent),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RC.body().copyWith(
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                      fontSize: 13.5.sp,
                                      color: isRead
                                          ? RC.textSecondary
                                          : RC.textPrimary,
                                    ),
                              ),
                            ),
                            if (!isRead) ...[
                              SizedBox(width: 6.w),
                              Container(
                                width: 7.w,
                                height: 7.w,
                                margin: EdgeInsets.only(top: 4.h),
                                decoration: BoxDecoration(
                                    color: RC.infoText, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          item.body as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RC
                              .caption(
                                  color: isRead
                                      ? RC.textTertiary
                                      : RC.textSecondary)
                              .copyWith(fontSize: 12.sp, height: 1.35),
                        ),
                        SizedBox(height: 7.h),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11.sp, color: RC.textTertiary),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat('dd MMM yyyy · hh:mm a')
                                  .format(item.timestamp as DateTime),
                              style: RC
                                  .caption(color: RC.textTertiary)
                                  .copyWith(fontSize: 10.5.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 92.h,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
            color: RC.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: RC.divider)),
      ),
    );
  }
}
