import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/case_detail_info_screen_view.dart';

import 'package:right_case/view/cases_screen_view/case_edit_screen.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

class CaseInfoCard extends StatelessWidget {
  final CaseModel clientCase;

  const CaseInfoCard({super.key, required this.clientCase});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy').format(clientCase.registrationDate);

    return Consumer<CaseListViewModel>(
      builder: (context, caseVM, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaseDetailInfoScreenView(caseData: clientCase),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade900,
                      ),
                      children: [
                        TextSpan(text: clientCase.firstParty?.name),
                        TextSpan(
                            text: " v/s ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: Colors.black,
                            )),
                        TextSpan(text: clientCase.secondParty?.name),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Case #: ${clientCase.caseNumber}",
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black87),
                        ),

                        SizedBox(height: 6.h),
                        Text(
                          "Added At: $formattedDate",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // 🔹 Parties
                        Text(
                          "Parties: ${clientCase.oppositePartyName ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        if (clientCase.judgeName != null &&
                            clientCase.judgeName!.isNotEmpty)
                          Text(
                            "Judge: ${clientCase.judgeName}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),

                        SizedBox(height: 6.h),

                        // 🔹 Description (one-liner)
                        if (clientCase.caseNotes != null &&
                            clientCase.caseNotes!.isNotEmpty)
                          Container(
                            height: 18.h,
                            width: 245.w,
                            alignment: Alignment.center,
                            child: Text(
                              clientCase.caseNotes!,

                              // maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (clientCase.status != null &&
                        clientCase.status!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(clientCase.status!),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          clientCase.status!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                // 🔹 Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: Icons.visibility_outlined,
                      color: Colors.blueAccent,
                      onTap: () {
                        // View details
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailScreen(caseData: clientCase)));
                      },
                    ),
                    _actionButton(
                      icon: Icons.edit_outlined,
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditCaseScreen(clientCase: clientCase),
                          ),
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      onTap: () {
                        showDeleteCaseDialog(context, clientCase);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'running':
      case 'active':
        return Colors.green;
      case 'decided':
        return Colors.blue;
      case 'pending':
        return Colors.orangeAccent;
      case 'closed':
      case 'abandoned':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void showDeleteCaseDialog(BuildContext context, CaseModel clientCase) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text("Delete Case",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete this case?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // caseVM.removeCase(clientCase);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
