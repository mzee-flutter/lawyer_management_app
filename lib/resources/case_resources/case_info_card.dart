import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view/cases_screen_view/case_detail_info_screen_view.dart';
import 'package:right_case/view/cases_screen_view/case_update_screen_view.dart';
import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_archive_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_permanent_delete_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';

// class CaseInfoCard extends StatelessWidget {
//   final CaseModel clientCase;
//
//   const CaseInfoCard({super.key, required this.clientCase});
//
//   @override
//   Widget build(BuildContext context) {
//     final formattedDate =
//         DateFormat('MMM dd, yyyy').format(clientCase.registrationDate);
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 CaseDetailInfoScreenWrapper(caseId: clientCase.id),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withValues(alpha: 0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: RichText(
//                 text: TextSpan(
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade900,
//                   ),
//                   children: [
//                     TextSpan(text: clientCase.firstPartyName),
//                     TextSpan(
//                       text: " v/s ",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20.sp,
//                         color: Colors.black,
//                       ),
//                     ),
//                     TextSpan(text: clientCase.oppositePartyName),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Case #: ${clientCase.caseNumber}",
//                       style: TextStyle(fontSize: 14.sp, color: Colors.black87),
//                     ),
//
//                     SizedBox(height: 6.h),
//                     Text(
//                       "Added At: $formattedDate",
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     SizedBox(height: 6.h),
//                     // 🔹 Parties
//                     Text(
//                       "Parties: ${clientCase.oppositePartyName ?? 'N/A'}",
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//
//                     SizedBox(height: 4.h),
//
//                     if (clientCase.judgeName != null &&
//                         clientCase.judgeName!.isNotEmpty)
//                       Text(
//                         "Judge: ${clientCase.judgeName}",
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//
//                     SizedBox(height: 6.h),
//
//                     // 🔹 Description (one-liner)
//                     if (clientCase.caseNotes != null &&
//                         clientCase.caseNotes!.isNotEmpty)
//                       SizedBox(
//                         height: 18.h,
//                         width: 245.w,
//                         child: Text(
//                           clientCase.caseNotes!,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 if (clientCase.status != null && clientCase.status!.isNotEmpty)
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(clientCase.status!),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Text(
//                       clientCase.status!,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             // 🔹 Action Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 _actionButton(
//                   icon: Icons.visibility_outlined,
//                   color: Colors.blueAccent,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             CaseDetailInfoScreenView(caseId: clientCase.id),
//                       ),
//                     );
//                   },
//                 ),
//                 _actionButton(
//                   icon: Icons.edit_outlined,
//                   color: Colors.orangeAccent,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             CaseUpdateScreenView(caseData: clientCase),
//                       ),
//                     );
//                   },
//                 ),
//                 _actionButton(
//                   icon: Icons.delete_outline,
//                   color: Colors.redAccent,
//                   onTap: () {
//                     showDeleteCaseDialog(
//                         context: context, caseData: clientCase);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _actionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         margin: EdgeInsets.only(left: 8.w),
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, color: color, size: 20.sp),
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'open':
//       case 'running':
//       case 'active':
//         return Colors.green;
//       case 'decided':
//         return Colors.blue;
//       case 'pending':
//         return Colors.orangeAccent;
//       case 'closed':
//       case 'abandoned':
//         return Colors.redAccent;
//       default:
//         return Colors.grey;
//     }
//   }
//

class CaseInfoCard extends StatelessWidget {
  final CaseModel caseData;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CaseInfoCard({
    super.key,
    required this.caseData,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = caseData.createdAt;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailInfoScreenWrapper(
              caseId: caseData.id,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: 5.h,
          horizontal: 8.w,
        ),
        elevation: 0.8,
        color: Colors.grey.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 7.h,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5.w, right: 5.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DATE COLUMN
                    _DateBadge(date: date),

                    SizedBox(width: 12.w),

                    /// MAIN CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade900,
                                ),
                                children: [
                                  TextSpan(text: caseData.firstPartyName),
                                  TextSpan(
                                    text: " v/s ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: caseData.oppositePartyName,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                          Row(
                            children: [
                              Text(
                                "Case #${caseData.caseNumber}",
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Spacer(),
                              _StatusBadge(status: caseData.status ?? "Status"),
                            ],
                          ),

                          /// META INFO
                          Text(
                            "${caseData.courtName} • Judge: ${caseData.judgeName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          SizedBox(height: 5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _ActionIcon(
                                icon: Icons.visibility_outlined,
                                color: Colors.blue,
                                onTap: onView,
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
                                onTap: onDelete,
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HearingListScreenView(
                        caseId: caseData.id,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    // borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Manage next hearing",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_circle_right,
                        color: Colors.blue,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.12),
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == "active";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 1)
            : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.grey.shade700,
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
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
