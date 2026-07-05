import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:right_case/models/case_models/hearing_models.dart';

import '../system_design/rc_theme.dart';
import '../system_design/rc_widgets.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: isHighLighted ? RC.goldLight : RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: isHighLighted ? RC.gold : RC.divider,
            width: isHighLighted ? 1.4 : 1),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBadge(date: hearing.hearingDateTime),
                SizedBox(width: 10.w),
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
                              style: RC.body().copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5.sp),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _hearingStatusPill(hearing.status),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: 12.sp, color: RC.textTertiary),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '$courtName · Judge: $judgeName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RC.caption(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined,
                              size: 12.sp, color: RC.textTertiary),
                          SizedBox(width: 4.w),
                          Text(
                              'Created ${DateFormat('dd MMM, yyyy').format(hearing.createdAt)}',
                              style: RC.caption(color: RC.textTertiary)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ActionIcon(
                              icon: Icons.settings_outlined,
                              color: RC.textSecondary,
                              onTap: onManage),
                          SizedBox(width: 8.w),
                          _ActionIcon(
                              icon: Icons.edit_outlined,
                              color: RC.gold,
                              onTap: onEdit),
                          SizedBox(width: 8.w),
                          _ActionIcon(
                            icon: Icons.delete_outline_rounded,
                            color: RC.danger,
                            onTap: onDeleteHearing == null
                                ? null
                                : () => _confirmRemove(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
              childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              minTileHeight: 1,
              backgroundColor: RC.background,
              collapsedBackgroundColor: RC.background,
              iconColor: RC.textSecondary,
              collapsedIconColor: RC.textSecondary,
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r)),
              ),
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r)),
              ),
              title: Text('Hearing Notes',
                  style: RC.label().copyWith(
                      fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (hearing.notes?.trim().isNotEmpty ?? false)
                        ? hearing.notes!
                        : 'No notes added for this hearing.',
                    style: RC.body(color: RC.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hearingStatusPill(String status) {
    final (color, surface) = _statusColors(status);
    return RCStatusPill(label: status, color: color, surface: surface);
  }

  (Color, Color) _statusColors(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return (RC.infoText, RC.infoSurface);
      case 'completed':
        return (RC.successText, RC.successSurface);
      case 'adjourned':
        return (RC.warningText, RC.warningSurface);
      case 'cancelled':
        return (RC.danger, RC.dangerSurface);
      default:
        return (RC.textSecondary, RC.background);
    }
  }

  void _confirmRemove(BuildContext context) {
    RCConfirmDialog.show(
      context: context,
      icon: Icons.event_busy_outlined,
      iconColor: RC.danger,
      iconSurface: RC.dangerSurface,
      title: 'Remove Hearing?',
      message:
          'This hearing will be permanently removed from the case timeline.',
      confirmLabel: 'Remove',
      confirmColor: RC.danger,
      confirmSurface: RC.dangerSurface,
      confirmBorder: RC.dangerBorder,
      onConfirm: () async => onDeleteHearing?.call(),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
          color: RC.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          Text(DateFormat('dd').format(date),
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: RC.navy)),
          Text(DateFormat('MMM').format(date).toUpperCase(),
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: RC.gold)),
          SizedBox(height: 1.h),
          Text(DateFormat('yyyy').format(date),
              style: RC
                  .caption(color: RC.textTertiary)
                  .copyWith(fontSize: 9.5.sp)),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionIcon(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: (disabled ? RC.textTertiary : color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child:
            Icon(icon, size: 16.sp, color: disabled ? RC.textTertiary : color),
      ),
    );
  }
}
