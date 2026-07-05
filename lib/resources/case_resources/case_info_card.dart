// v3 — structurally different from v2, not just re-styled:
//   • Full-width top status strip replaces the left accent bar
//   • Legal-caption title block: First Party / VS chip / Opposite Party
//   • Segmented stats footer (Stage · Type · Next Hearing) with hairline
//     dividers — reads as one connected data strip, not floating chips
//   • Zero navigation knowledge — delegates entirely to onView/onEdit/onDelete

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';

import '../system_design/rc_theme.dart';

class CaseInfoCard extends StatelessWidget {
  final CaseModel caseData;

  /// Optional — pass the case's nearest upcoming hearing if already
  /// joined elsewhere. Adds a third, urgency-coded footer segment.
  final DateTime? nextHearingDate;

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CaseInfoCard({
    super.key,
    required this.caseData,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.nextHearingDate,
  });

  @override
  Widget build(BuildContext context) {
    final statusName = caseData.caseStatus?.name;
    final (statusColor, _) = _statusColors(statusName);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: RC.divider, width: 1),
        boxShadow: [RC.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onView,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 3.h, width: double.infinity, color: statusColor),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 11.h, 8.w, 0),
                child: Row(
                  children: [
                    _StatusIndicator(name: statusName, color: statusColor),
                    const Spacer(),
                    _CaseNumberTag(caseData.caseNumber),
                    SizedBox(width: 2.w),
                    _ThreeDotMenu(
                      onView: onView,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onManageHearings: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HearingListScreenView(caseId: caseData.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData.firstPartyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RC.body().copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: RC.textPrimary,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _VsChip(),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            caseData.oppositePartyName ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RC.body(color: RC.textSecondary).copyWith(
                                fontWeight: FontWeight.w500, fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 9.h),
              if (caseData.courtName != null || caseData.judgeName != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_outlined,
                          size: 12.sp, color: RC.textTertiary),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          [
                            if (caseData.courtName != null) caseData.courtName!,
                            if (caseData.judgeName != null)
                              'Judge ${caseData.judgeName}',
                          ].join('   ·   '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RC.caption(color: RC.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 12.h),
              _StatsFooter(
                  caseData: caseData, nextHearingDate: nextHearingDate),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'running':
      case 'active':
        return (RC.infoText, RC.infoSurface);
      case 'decided':
      case 'closed':
        return (RC.successText, RC.successSurface);
      case 'abandoned':
      case 'cancelled':
        return (RC.danger, RC.dangerSurface);
      case 'pending':
      case 'date awaited':
        return (RC.warningText, RC.warningSurface);
      default:
        return (RC.textTertiary, RC.background);
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final String? name;
  final Color color;
  const _StatusIndicator({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          (name ?? 'Unspecified').toUpperCase(),
          style: RC.caption(color: color).copyWith(
              fontWeight: FontWeight.w700, fontSize: 10.sp, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _CaseNumberTag extends StatelessWidget {
  final String number;
  const _CaseNumberTag(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: RC.navy.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(6.r)),
      child: Text('#$number',
          style: RC
              .caption(color: RC.navy)
              .copyWith(fontWeight: FontWeight.w700, fontSize: 10.5.sp)),
    );
  }
}

class _VsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
          color: RC.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(4.r)),
      child: Text('VS',
          style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              color: RC.navy,
              letterSpacing: 0.4)),
    );
  }
}

class _ThreeDotMenu extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageHearings;

  const _ThreeDotMenu({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onManageHearings,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 19.sp,
      splashRadius: 18.r,
      icon: Icon(Icons.more_vert_rounded, color: RC.textTertiary),
      color: RC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (_) => [
        _item('view', Icons.visibility_outlined, 'View details', RC.navy),
        _item('edit', Icons.edit_outlined, 'Edit case', RC.gold),
        _item('hearings', Icons.event_available_outlined, 'Manage hearings',
            RC.navy),
        const PopupMenuDivider(),
        _item('delete', Icons.delete_outline_rounded, 'Delete', RC.danger),
      ],
      onSelected: (v) {
        switch (v) {
          case 'view':
            onView();
          case 'edit':
            onEdit();
          case 'hearings':
            onManageHearings();
          case 'delete':
            onDelete();
        }
      },
    );
  }

  PopupMenuItem<String> _item(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      height: 40.h,
      child: Row(children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 9.w),
        Text(label,
            style: (value == 'delete' ? RC.body(color: RC.danger) : RC.body())
                .copyWith(fontSize: 12.5.sp)),
      ]),
    );
  }
}

class _StatsFooter extends StatelessWidget {
  final CaseModel caseData;
  final DateTime? nextHearingDate;
  const _StatsFooter({required this.caseData, required this.nextHearingDate});

  @override
  Widget build(BuildContext context) {
    final stageName = caseData.caseStage?.name;
    final typeName = caseData.caseType?.name;

    final segments = <Widget>[
      if (stageName != null)
        _StatSegment(
            icon: Icons.layers_outlined, label: 'Stage', value: stageName),
      if (typeName != null)
        _StatSegment(
            icon: Icons.category_outlined, label: 'Type', value: typeName),
      if (nextHearingDate != null) _NextHearingSegment(date: nextHearingDate!),
    ];

    if (segments.isEmpty) return SizedBox(height: 12.h);

    return Container(
      decoration: BoxDecoration(
          color: RC.background,
          border: Border(top: BorderSide(color: RC.divider, width: 1))),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < segments.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: VerticalDivider(
                      color: RC.divider, width: 1, thickness: 1),
                ),
              Expanded(child: segments[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatSegment(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: RC.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: RC
                      .caption(color: RC.textTertiary)
                      .copyWith(fontSize: 9.sp)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC.caption(color: RC.textPrimary).copyWith(
                      fontWeight: FontWeight.w600, fontSize: 11.5.sp)),
            ],
          ),
        ),
      ],
    );
  }
}

/// The single most decision-critical field — always gets the rightmost,
/// most-scanned segment.
class _NextHearingSegment extends StatelessWidget {
  final DateTime date;
  const _NextHearingSegment({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final target = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = target.difference(today).inDays;

    final Color color;
    final String value;
    if (diff < 0) {
      color = RC.danger;
      value = 'Overdue';
    } else if (diff == 0) {
      color = RC.danger;
      value = 'Today';
    } else if (diff == 1) {
      color = RC.warningText;
      value = 'Tomorrow';
    } else if (diff <= 7) {
      color = RC.warningText;
      value = 'In $diff days';
    } else {
      color = RC.textPrimary;
      value = DateFormat('dd MMM').format(date);
    }

    return Row(
      children: [
        Icon(Icons.event_outlined, size: 13.sp, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Next hearing',
                  style: RC
                      .caption(color: RC.textTertiary)
                      .copyWith(fontSize: 9.sp)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC.caption(color: color).copyWith(
                      fontWeight: FontWeight.w700, fontSize: 11.5.sp)),
            ],
          ),
        ),
      ],
    );
  }
}
