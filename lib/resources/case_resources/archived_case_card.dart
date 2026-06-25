import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_restore_view_model.dart';

class ArchivedCaseCard extends StatelessWidget {
  final CaseModel caseData;

  const ArchivedCaseCard({
    super.key,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        height: 190.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🔹 Left Accent Bar
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header
                    Row(
                      children: [
                        Icon(
                          Icons.balance_rounded,
                          size: 18.sp,
                          color: Colors.grey.shade800,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Case #${caseData.caseNumber}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Consumer<CaseRestoreViewModel>(
                          builder: (context, caseRestoreVM, child) {
                            return _restoreButton(
                              onTap: () {
                                caseRestoreVM.restoreCase(context, caseData.id);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade500),

                    // 🔹 Parties (Main focus)
                    Text(
                      caseData.firstPartyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "vs ${caseData.oppositePartyName ?? '—'}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 🔹 Info Grid with Icons
                    Row(
                      children: [
                        Expanded(
                          child: _infoBlock(
                            icon: Icons.account_balance,
                            title: "Court",
                            value: caseData.courtName ?? "—",
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _infoBlock(
                            icon: Icons.timeline,
                            title: "Stage",
                            value: caseData.caseStage?.name ?? "—",
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _infoBlock(
                            icon: Icons.flag,
                            title: "Status",
                            value: caseData.caseStatus?.name ?? "—",
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // 🔹 Footer
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Registered on ${_formatDate(caseData.registrationDate)}",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade700,
                          ),
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

  // ================= COMPONENTS =================

  Widget _restoreButton({required void Function() onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          "Restore",
          style: TextStyle(
            fontSize: 12.5.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _infoBlock({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: Colors.grey.shade800,
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
