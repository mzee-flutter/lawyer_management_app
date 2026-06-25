import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:intl/intl.dart';

class HearingInfoCard extends StatelessWidget {
  final String judgeName;
  final String courtName;
  final bool isHighLighted;
  final HearingPublicModel hearing;
  final VoidCallback onManage;
  final VoidCallback onEdit;
  final VoidCallback? onDeleteHearing;

  const HearingInfoCard({
    super.key,
    required this.judgeName,
    required this.courtName,
    required this.isHighLighted,
    required this.hearing,
    required this.onManage,
    required this.onEdit,
    required this.onDeleteHearing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      elevation: 0.8,
      color: isHighLighted ? Colors.grey.shade200 : Colors.grey.shade300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: isHighLighted
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 5.h,
              right: 5.h,
              top: 5.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBadge(date: hearing.hearingDateTime),
                SizedBox(width: 8.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              hearing.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _HearingStatusBadge(status: hearing.status),
                        ],
                      ),
                      Text(
                        "$courtName • Judge: $judgeName",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "Created at: ${DateFormat('dd MMM, yyyy').format(hearing.createdAt)}",
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 5.r),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ActionIcon(
                            icon: Icons.settings_outlined,
                            color: Colors.blueGrey,
                            onTap: onManage,
                          ),
                          SizedBox(width: 10.w),
                          _ActionIcon(
                            icon: Icons.edit_outlined,
                            color: Colors.orange,
                            onTap: onEdit,
                          ),
                          SizedBox(width: 10.w),
                          _ActionIcon(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () => _showRemoveDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          ExpansionTile(
            title: Text(
              "Hearing Notes",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            minTileHeight: 1,
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
            collapsedBackgroundColor: Colors.blue.withValues(alpha: 0.2),
            iconColor: Colors.black,
            collapsedIconColor: Colors.black,
            collapsedShape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
              ),
            ),
            shape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
              ),
            ),
            tilePadding: EdgeInsets.symmetric(horizontal: 5.r),
            childrenPadding: EdgeInsets.only(
              left: 12.w,
              right: 5.w,
              bottom: 5.h,
            ),
            children: [
              Center(
                child: Text(hearing.notes ?? "No description"),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade300,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remove Hearing',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Are you sure want to delete this hearing?',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(
                  title: 'Cancel',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(width: 10.w),
                _actionButton(
                  title: 'Remove',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    onDeleteHearing?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: 90.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.w,
      padding: EdgeInsets.symmetric(vertical: 8.r),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('dd').format(date),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HearingStatusBadge extends StatelessWidget {
  final String status;

  const _HearingStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;

    switch (status.toLowerCase()) {
      case "scheduled":
        color = Colors.blue;
        break;
      case "completed":
        color = Colors.green;
        break;
      case "adjourned":
        color = Colors.orange;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
