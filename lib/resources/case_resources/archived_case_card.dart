import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_restore_view_model.dart';

class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const goldLight = Color(0xFFFAEDD4);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F5F1);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const warningText = Color(0xFF92400E);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );
}

class ArchivedCaseCard extends StatelessWidget {
  final CaseModel caseData;
  const ArchivedCaseCard({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gold accent bar = archived/paused state
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _RC.gold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _RC.gold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '#${caseData.caseNumber}',
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _RC.gold),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _RC.goldLight,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Archived',
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _RC.warningText),
                          ),
                        ),
                        const Spacer(),
                        Consumer<CaseRestoreViewModel>(
                          builder: (_, vm, __) => _RestoreButton(
                            onTap: () => vm.restoreCase(context, caseData.id),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Party names
                    Text(
                      caseData.firstPartyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: _RC.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'vs. ${caseData.oppositePartyName ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 13.sp, color: _RC.textSecondary),
                    ),
                    SizedBox(height: 12.h),

                    // Info chips row
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBlock(
                            icon: Icons.account_balance_outlined,
                            label: 'Court',
                            value: caseData.courtName ?? '—',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBlock(
                            icon: Icons.timeline_outlined,
                            label: 'Stage',
                            value: caseData.caseStage?.name ?? '—',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBlock(
                            icon: Icons.flag_outlined,
                            label: 'Status',
                            value: caseData.caseStatus?.name ?? '—',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Footer
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 12.sp, color: _RC.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          'Registered ${_fmt(caseData.registrationDate)}',
                          style: TextStyle(
                              fontSize: 11.sp, color: _RC.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

class _RestoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RestoreButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _RC.navy,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore_rounded, size: 12.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              'Restore',
              style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBlock(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: _RC.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 11.sp, color: _RC.textSecondary),
            SizedBox(width: 3.w),
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: _RC.textSecondary)),
          ]),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _RC.textPrimary),
          ),
        ],
      ),
    );
  }
}
