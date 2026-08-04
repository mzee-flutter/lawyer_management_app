// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:right_case/models/case_models/case_model.dart';
// import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';
//
// import '../system_design/rc_theme.dart';
//
// class CaseInfoCard extends StatelessWidget {
//   final CaseModel caseData;
//   final DateTime? nextHearingDate;
//   final VoidCallback onView;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const CaseInfoCard({
//     super.key,
//     required this.caseData,
//     required this.onView,
//     required this.onEdit,
//     required this.onDelete,
//     this.nextHearingDate,
//   });
//
//   String get _title =>
//       '${caseData.firstPartyName} vs. ${caseData.oppositePartyName ?? 'Unknown Party'}';
//
//   @override
//   Widget build(BuildContext context) {
//     final statusName = caseData.caseStatus?.name ?? 'Unspecified';
//     final (statusColor, statusSurface) = _statusColors(statusName);
//
//     return Container(
//       height: 140.h,
//       margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: RC.surface, // Clean white background
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: RC.divider, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onView,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ── 1. LEFT VERTICAL STATUS LINE ────────────────
//               Container(width: 4.w, color: statusColor),
//
//               // ── 2. CARD CONTENT ─────────────────────────────
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- TOP SECTION (Padding applied) ---
//                     Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header Row: Status Badge & Overflow
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 _PremiumStatusBadge(
//                                   name: statusName,
//                                   color: statusColor,
//                                   surface: statusSurface,
//                                 ),
//                                 const Spacer(),
//                                 _OverflowDot(
//                                   onEdit: onEdit,
//                                   onDelete: onDelete,
//                                   onManageHearings: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => HearingListScreenView(
//                                           caseId: caseData.id,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 6.h),
//
//                             // Case Title
//                             Text(
//                               _title,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: RC.display().copyWith(
//                                     fontSize: 15.sp,
//                                     fontWeight: FontWeight.w700,
//                                     color: RC.textPrimary,
//                                     letterSpacing: -0.2,
//                                   ),
//                             ),
//                             SizedBox(height: 8.h),
//
//                             // Meta Data Row (Judge & Type/Stage)
//                             Row(
//                               children: [
//                                 // Left: Court / Judge
//                                 Expanded(
//                                   flex: 5,
//                                   child: _MetaIconText(
//                                     icon: Icons.account_balance_outlined,
//                                     text: caseData.judgeName ??
//                                         'No Judge Assigned',
//                                   ),
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 // Right: Case Type / Stage
//                                 Expanded(
//                                   flex: 4,
//                                   child: _MetaIconText(
//                                     icon: Icons.account_tree_outlined,
//                                     text: caseData.caseStage?.name ??
//                                         caseData.caseType?.name ??
//                                         'Uncategorized',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // --- BOTTOM ACTIONABLE FOOTER ---
//                     _ActionableHearingFooter(
//                       date: nextHearingDate,
//                       statusColor: statusColor,
//                       caseId: caseData.id,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   (Color, Color) _statusColors(String? status) {
//     switch ((status ?? '').toLowerCase()) {
//       case 'running':
//       case 'active':
//         return (RC.infoText, RC.infoSurface);
//       case 'decided':
//       case 'closed':
//         return (RC.successText, RC.successSurface);
//       case 'abandoned':
//       case 'cancelled':
//         return (RC.danger, RC.dangerSurface);
//       case 'pending':
//       case 'date awaited':
//         return (RC.warningText, RC.warningSurface);
//       default:
//         return (RC.textTertiary, RC.background);
//     }
//   }
// }
//
// // ── SUB-COMPONENTS ─────────────────────────────────────────────
//
// class _PremiumStatusBadge extends StatelessWidget {
//   final String name;
//   final Color color;
//   final Color surface;
//
//   const _PremiumStatusBadge({
//     required this.name,
//     required this.color,
//     required this.surface,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: surface,
//         borderRadius:
//             BorderRadius.circular(6.r), // Slightly boxy for enterprise feel
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 5.w,
//             height: 5.w,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           SizedBox(width: 5.w),
//           Text(
//             name.toUpperCase(),
//             style: TextStyle(
//               fontSize: 9.sp,
//               fontWeight: FontWeight.w800,
//               color: color,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _MetaIconText extends StatelessWidget {
//   final IconData icon;
//   final String text;
//
//   const _MetaIconText({required this.icon, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 13.sp, color: RC.textTertiary),
//         SizedBox(width: 4.w),
//         Expanded(
//           child: Text(
//             text,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: RC.caption().copyWith(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w500,
//                   color: RC.textSecondary,
//                 ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _ActionableHearingFooter extends StatelessWidget {
//   final DateTime? date;
//   final Color statusColor;
//   final String caseId;
//
//   const _ActionableHearingFooter({
//     required this.date,
//     required this.statusColor,
//     required this.caseId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine texts and colors based on date
//     String label = "No hearing scheduled";
//     Color textColor = RC.textSecondary;
//     Color iconColor = RC.textTertiary;
//     bool isUrgent = false;
//
//     if (date != null) {
//       final now = DateTime.now();
//       final target = DateTime(date!.year, date!.month, date!.day);
//       final today = DateTime(now.year, now.month, now.day);
//       final diff = target.difference(today).inDays;
//
//       if (diff < 0) {
//         label = 'Overdue • ${DateFormat('dd MMM yyyy').format(date!)}';
//         textColor = RC.danger;
//         iconColor = RC.danger;
//         isUrgent = true;
//       } else if (diff == 0) {
//         label = 'Today • ${DateFormat('hh:mm a').format(date!)}';
//         textColor = RC.danger;
//         iconColor = RC.danger;
//         isUrgent = true;
//       } else if (diff == 1) {
//         label = 'Tomorrow • ${DateFormat('hh:mm a').format(date!)}';
//         textColor = RC.warningText;
//         iconColor = RC.warningText;
//       } else {
//         label = DateFormat('EEEE, dd MMM yyyy').format(date!);
//         textColor = statusColor; // Inherits the card's theme color
//         iconColor = statusColor;
//       }
//     }
//
//     return Material(
//       color: statusColor.withValues(alpha: 0.04), // Beautiful tinted background
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => HearingListScreenView(caseId: caseId),
//             ),
//           );
//         },
//         child: Container(
//           height: 38.h, // Fixed height for the footer
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             border: Border(
//                 top: BorderSide(color: statusColor.withValues(alpha: 0.1))),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.calendar_month_rounded, size: 14.sp, color: iconColor),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: Text(
//                   label,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: RC.body().copyWith(
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w600,
//                         color: textColor,
//                       ),
//                 ),
//               ),
//               if (isUrgent) ...[
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//                   decoration: BoxDecoration(
//                     color: RC.danger.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(4.r),
//                   ),
//                   child: Text(
//                     'ACTION REQUIRED',
//                     style: TextStyle(
//                       fontSize: 8.sp,
//                       fontWeight: FontWeight.w800,
//                       color: RC.danger,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//               ],
//               Icon(Icons.arrow_forward_ios_rounded,
//                   size: 12.sp, color: iconColor.withValues(alpha: 0.6)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _OverflowDot extends StatelessWidget {
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onManageHearings;
//
//   const _OverflowDot({
//     required this.onEdit,
//     required this.onDelete,
//     required this.onManageHearings,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       padding: EdgeInsets.zero,
//       iconSize: 20.sp, // Slightly larger tap target
//       splashRadius: 18.r,
//       icon: Icon(Icons.more_vert_rounded, color: RC.textTertiary),
//       color: RC.surface,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       offset: Offset(0, 10.h),
//       itemBuilder: (_) => [
//         _item('edit', Icons.edit_outlined, 'Edit case', RC.gold),
//         _item('hearings', Icons.event_available_outlined, 'Manage hearings',
//             RC.navy),
//         const PopupMenuDivider(),
//         _item('delete', Icons.delete_outline_rounded, 'Delete', RC.danger),
//       ],
//       onSelected: (v) {
//         switch (v) {
//           case 'edit':
//             return onEdit();
//           case 'hearings':
//             return onManageHearings();
//           case 'delete':
//             return onDelete();
//         }
//       },
//     );
//   }
//
//   PopupMenuItem<String> _item(
//       String value, IconData icon, String label, Color color) {
//     return PopupMenuItem(
//       value: value,
//       height: 40.h,
//       child: Row(
//         children: [
//           Icon(icon, size: 16.sp, color: color),
//           SizedBox(width: 10.w),
//           Text(
//             label,
//             style: (value == 'delete' ? RC.body(color: RC.danger) : RC.body())
//                 .copyWith(
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';

import '../system_design/rc_theme.dart';

class CaseInfoCard extends StatelessWidget {
  final CaseModel caseData;
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
    final statusName = caseData.caseStatus?.name ?? 'Unspecified';
    final (statusColor, statusSurface) = _statusColors(statusName);
    final stageOrType = caseData.caseStage?.name ?? caseData.caseType?.name;

    return Container(
      height: 140.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: RC.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onView,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status strip
              Container(width: 4.w, color: statusColor),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP CONTENT — sized to its own content only.
                    // mainAxisSize.min is what makes the "invisible gap"
                    // bug impossible: this block can never be taller than
                    // its children actually need.
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 9.h, 8.w, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: status badge + overflow menu
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _PremiumStatusBadge(
                                name: statusName,
                                color: statusColor,
                                surface: statusSurface,
                              ),
                              const Spacer(),
                              _OverflowDot(
                                onEdit: onEdit,
                                onDelete: onDelete,
                                onManageHearings: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HearingListScreenView(
                                      caseId: caseData.id,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),

                          // Case title — first party vs. opposite party
                          _PartyNamesLine(
                            firstParty: caseData.firstPartyName,
                            oppositeParty: caseData.oppositePartyName,
                          ),
                          SizedBox(height: 6.h),

                          // Court + Judge — the two named entities, one row

                          _MetaIconText(
                            icon: Icons.account_balance_outlined,
                            text: caseData.courtName ?? 'No court assigned',
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _MetaIconText(
                                  icon: Icons.gavel_rounded,
                                  text: caseData.judgeName != null
                                      ? 'Judge ${caseData.judgeName}'
                                      : 'No judge assigned',
                                ),
                              ),

                              // Case stage — categorical marker, distinct pill
                              // treatment so it's never mistaken for a name.
                              if (stageOrType != null) ...[
                                SizedBox(height: 5.h),
                                _StagePill(label: stageOrType),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Spacer is the ONLY place leftover height can go —
                    // deliberately placed here so it never separates two
                    // rows that should read as connected.
                    const Spacer(),

                    _ActionableHearingFooter(
                      date: nextHearingDate,
                      statusColor: statusColor,
                      caseId: caseData.id,
                    ),
                  ],
                ),
              ),
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

// ── SUB-COMPONENTS ─────────────────────────────────────────────

class _PremiumStatusBadge extends StatelessWidget {
  final String name;
  final Color color;
  final Color surface;

  const _PremiumStatusBadge({
    required this.name,
    required this.color,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// "FirstParty   v.   OppositeParty" — one line, deliberate typographic
/// hierarchy instead of one flat style. Bold dark for the primary party,
/// small muted italic "v." (actual legal-citation convention, not just
/// decoration), medium-gray for the opposing party.
class _PartyNamesLine extends StatelessWidget {
  final String firstParty;
  final String? oppositeParty;

  const _PartyNamesLine({
    required this.firstParty,
    required this.oppositeParty,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: firstParty,
            style: RC.display().copyWith(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: RC.textPrimary,
                  letterSpacing: -0.1,
                ),
          ),
          TextSpan(
            text: '   v.   ',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: RC.textTertiary,
            ),
          ),
          TextSpan(
            text: oppositeParty ?? 'Unknown Party',
            style: RC.body(color: RC.textSecondary).copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MetaIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: RC.textTertiary),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RC.caption().copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: RC.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

/// Distinct bordered pill — deliberately styled differently from
/// _MetaIconText (which is plain icon+text for named entities like
/// Court/Judge). This visual difference is the actual signal that tells
/// the reader "this is a state/category, not somebody's name" — the
/// same convention the status badge already uses at the top of the card.
class _StagePill extends StatelessWidget {
  final String label;
  const _StagePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: RC.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: RC.navy.withValues(alpha: 0.14), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 11.sp, color: RC.navy),
          SizedBox(width: 5.w),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: RC.navy,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionableHearingFooter extends StatelessWidget {
  final DateTime? date;
  final Color statusColor;
  final String caseId;

  const _ActionableHearingFooter({
    required this.date,
    required this.statusColor,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    String label = "Hearings";
    Color textColor = RC.textSecondary;
    Color iconColor = RC.textTertiary;
    bool isUrgent = false;

    if (date != null) {
      final now = DateTime.now();
      final target = DateTime(date!.year, date!.month, date!.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = target.difference(today).inDays;

      if (diff < 0) {
        label = 'Overdue • ${DateFormat('dd MMM yyyy').format(date!)}';
        textColor = RC.danger;
        iconColor = RC.danger;
        isUrgent = true;
      } else if (diff == 0) {
        label = 'Today • ${DateFormat('hh:mm a').format(date!)}';
        textColor = RC.danger;
        iconColor = RC.danger;
        isUrgent = true;
      } else if (diff == 1) {
        label = 'Tomorrow • ${DateFormat('hh:mm a').format(date!)}';
        textColor = RC.warningText;
        iconColor = RC.warningText;
      } else {
        label = DateFormat('EEEE, dd MMM yyyy').format(date!);
        textColor = statusColor;
        iconColor = statusColor;
      }
    }

    return Material(
      color: statusColor.withValues(alpha: 0.04),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HearingListScreenView(caseId: caseId),
          ),
        ),
        child: Container(
          height: 38.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: statusColor.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14.sp, color: iconColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC.body().copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
              ),
              if (isUrgent) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: RC.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'ACTION REQUIRED',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: RC.danger,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12.sp, color: iconColor.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverflowDot extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageHearings;

  const _OverflowDot({
    required this.onEdit,
    required this.onDelete,
    required this.onManageHearings,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // `child:` instead of `icon:` — this is the actual fix for the
      // "gap between rows" bug. `icon:` wraps the icon in a Material
      // IconButton, which enforces a 48dp minimum touch target no
      // matter what padding/iconSize you pass it. `child:` wraps
      // whatever you give it in a plain InkWell instead, so the
      // button's real footprint is just the Padding+Icon below it —
      // nothing hidden inflating the row.
      padding: EdgeInsets.zero,
      splashRadius: 14.r,
      color: RC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      offset: Offset(0, 8.h),
      itemBuilder: (_) => [
        _item('edit', Icons.edit_outlined, 'Edit case', RC.gold),
        _item('hearings', Icons.event_available_outlined, 'Manage hearings',
            RC.navy),
        const PopupMenuDivider(),
        _item('delete', Icons.delete_outline_rounded, 'Delete', RC.danger),
      ],
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
          case 'hearings':
            onManageHearings();
          case 'delete':
            onDelete();
        }
      },
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child:
            Icon(Icons.more_vert_rounded, size: 15.sp, color: RC.textTertiary),
      ),
    );
  }

  PopupMenuItem<String> _item(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      height: 40.h,
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 10.w),
          Text(
            label,
            style: (value == 'delete' ? RC.body(color: RC.danger) : RC.body())
                .copyWith(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
