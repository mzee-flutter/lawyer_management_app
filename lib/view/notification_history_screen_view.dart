import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../view_model/services/notification_history_view_model.dart';

class NotificationHistoryScreenView extends StatefulWidget {
  const NotificationHistoryScreenView({super.key});

  @override
  State<NotificationHistoryScreenView> createState() =>
      _NotificationHistoryScreenViewState();
}

class _NotificationHistoryScreenViewState
    extends State<NotificationHistoryScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationHistoryViewModel>().fetchInboxNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxNotificationVM = context.watch<NotificationHistoryViewModel>();

    return Scaffold(
      // Clean, flat, elegant Scaffold background matching executive themes
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        title: Text(
          "Notification Inbox",
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Premium UX Touch: Quick utility button to mark all as read
          if (inboxNotificationVM.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                // Future extension placeholder: inboxNotificationVM.markAllAsRead();
              },
              child: Text(
                "Mark all read",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          inboxNotificationVM.notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: inboxNotificationVM.notifications.length,
                  itemBuilder: (context, index) {
                    final item = inboxNotificationVM.notifications[index];

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await inboxNotificationVM.deleteNotification(item.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text("Notification deleted"),
                              ),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                            ),
                          );
                        }
                      },
                      background: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade900,
                          size: 22.r,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (!context.mounted) return;
                              await inboxNotificationVM.handleNotificationTap(
                                  context, item.payload, item.id);
                              await inboxNotificationVM
                                  .markNotificationAsRead(item.id);
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: item.isRead
                                    ? Colors.grey.shade300
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: item.isRead
                                      ? Colors.grey.shade100
                                      : Colors.blue.shade100,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.isRead
                                        ? Colors.grey.shade900
                                        : Colors.blue.shade900,
                                    // color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Leading Visual Element Circle Container
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.balance_rounded,
                                      size: 18.r,
                                      color: item.isRead
                                          ? Colors.grey.shade500
                                          : Colors.blue.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),

                                  // Core Notification Content Layout
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: item.isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.w700,
                                                  color: item.isRead
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade900,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            // Modern Aesthetic Unread Dot Indicator
                                            if (!item.isRead)
                                              Container(
                                                width: 8.r,
                                                height: 8.r,
                                                margin:
                                                    EdgeInsets.only(top: 4.h),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade600,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item.body,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            height: 1.3,
                                            fontWeight: FontWeight.w400,
                                            color: item.isRead
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        // Metadata Row containing human-readable timestamp
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 12.r,
                                              color: Colors.grey.shade400,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              DateFormat(
                                                      'dd MMM yyyy • hh:mm a')
                                                  .format(item.timestamp),
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                  },
                ),
          if (inboxNotificationVM.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10.r,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 18.r,
                        width: 18.r,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Verifying hearing records...",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  /// Premium, beautifully designed empty state with high visual design standards
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 40.r,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Your Inbox is Clear",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "When you receive reminders for upcoming court hearings or case updates, they'll show up here beautifully organized.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
