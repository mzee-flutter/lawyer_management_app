// // lib/screens/calendar/calendar_screen.dart
// //
// // Full Smart Legal Diary screen.
// // Uses the same _RC design tokens as your home_screen.dart
// // No external calendar package needed — custom grid for full control.
// //
// // Register in your routes:
// //   RoutesName.calendarScreen → CalendarScreen()
//
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/case_models/calendar_hearing_model.dart';
// import '../../view_model/calendar_view_model/calendar_view_model.dart';
//
// // ─────────────────────────────────────────────
// // Design tokens — identical to home_screen.dart
// // ─────────────────────────────────────────────
// class _RC {
//   static const navy = Color(0xFF1A2744);
//   static const navyLight = Color(0xFF243356);
//   static const gold = Color(0xFFC8952A);
//   static const goldLight = Color(0xFFFAEDD4);
//
//   static const background = Color(0xFFF7F5F1);
//   static const surface = Color(0xFFFFFFFF);
//   static const surfaceMuted = Color(0xFFF0EEE9);
//
//   static const textPrimary = Color(0xFF111827);
//   static const textSecondary = Color(0xFF6B7280);
//   static const textTertiary = Color(0xFF9CA3AF);
//
//   static const danger = Color(0xFFB91C1C);
//   static const dangerSurface = Color(0xFFFEF2F2);
//   static const dangerBorder = Color(0xFFFECACA);
//   static const dangerText = Color(0xFF991B1B);
//
//   static const warning = Color(0xFFC8952A);
//   static const warningSurface = Color(0xFFFFFBEB);
//   static const warningBorder = Color(0xFFFDE68A);
//   static const warningText = Color(0xFF92400E);
//
//   static const infoSurface = Color(0xFFEFF6FF);
//   static const infoBorder = Color(0xFFBFDBFE);
//   static const infoText = Color(0xFF1E40AF);
//
//   static const divider = Color(0xFFE5E1D8);
//
//   static BoxShadow get card => BoxShadow(
//         color: Colors.black.withValues(alpha: 0.055),
//         blurRadius: 10,
//         offset: const Offset(0, 3),
//       );
// }
//
// // ─────────────────────────────────────────────
// // Calendar Screen
// // ─────────────────────────────────────────────
// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});
//
//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CalendarViewModel>().initialLoad();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _RC.background,
//       appBar: _buildAppBar(),
//       body: Consumer<CalendarViewModel>(
//         builder: (context, vm, _) {
//           return RefreshIndicator(
//             color: _RC.navy,
//             onRefresh: vm.refreshCurrentMonth,
//             child: CustomScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               slivers: [
//                 // Calendar grid
//                 SliverToBoxAdapter(child: _CalendarCard(vm: vm)),
//
//                 // Legend
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   sliver: SliverToBoxAdapter(child: _Legend()),
//                 ),
//
//                 SliverToBoxAdapter(child: SizedBox(height: 12.h)),
//
//                 // Day detail panel (slides in when day is selected)
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   sliver: SliverToBoxAdapter(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 250),
//                       child: vm.selectedDay != null
//                           ? _DayDetailPanel(vm: vm)
//                           : _NoSelectionHint(),
//                     ),
//                   ),
//                 ),
//
//                 SliverToBoxAdapter(child: SizedBox(height: 24.h)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: _RC.navy,
//       elevation: 0,
//       iconTheme: const IconThemeData(color: Colors.white),
//       title: Consumer<CalendarViewModel>(
//         builder: (_, vm, __) => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Smart legal diary',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             Text(
//               vm.focusedMonthLabel,
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: Colors.white.withValues(alpha: 0.6),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Calendar card — month header + grid
// // ─────────────────────────────────────────────
// class _CalendarCard extends StatelessWidget {
//   final CalendarViewModel vm;
//   const _CalendarCard({required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: _RC.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [_RC.card],
//       ),
//       child: Column(
//         children: [
//           _MonthHeader(vm: vm),
//           _WeekDayLabels(),
//           if (vm.isMonthLoading)
//             _CalendarSkeleton()
//           else if (vm.monthError != null)
//             _CalendarError(
//                 message: vm.monthError!, onRetry: vm.refreshCurrentMonth)
//           else
//             _CalendarGrid(vm: vm),
//           SizedBox(height: 8.h),
//         ],
//       ),
//     );
//   }
// }
//
// // Month navigation header
// class _MonthHeader extends StatelessWidget {
//   final CalendarViewModel vm;
//   const _MonthHeader({required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
//       child: Row(
//         children: [
//           // Today button
//           GestureDetector(
//             onTap: () => vm.goToMonth(DateTime.now()),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: _RC.navy.withValues(alpha: 0.07),
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Text(
//                 'Today',
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w500,
//                   color: _RC.navy,
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           // Month label
//           Text(
//             vm.focusedMonthLabel,
//             style: TextStyle(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.w600,
//               color: _RC.textPrimary,
//             ),
//           ),
//           const Spacer(),
//           // Prev / Next arrows
//           _NavArrow(
//             icon: Icons.chevron_left_rounded,
//             enabled: vm.canGoBack,
//             onTap: vm.goToPreviousMonth,
//           ),
//           SizedBox(width: 4.w),
//           _NavArrow(
//             icon: Icons.chevron_right_rounded,
//             enabled: vm.canGoForward,
//             onTap: vm.goToNextMonth,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NavArrow extends StatelessWidget {
//   final IconData icon;
//   final bool enabled;
//   final VoidCallback onTap;
//   const _NavArrow(
//       {required this.icon, required this.enabled, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         width: 30.w,
//         height: 30.w,
//         decoration: BoxDecoration(
//           color:
//               enabled ? _RC.navy.withValues(alpha: 0.07) : Colors.transparent,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(
//           icon,
//           size: 20.sp,
//           color: enabled ? _RC.navy : _RC.textTertiary,
//         ),
//       ),
//     );
//   }
// }
//
// // Day-of-week header row
// class _WeekDayLabels extends StatelessWidget {
//   static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       child: Row(
//         children: _days
//             .map(
//               (d) => Expanded(
//                 child: Center(
//                   child: Text(
//                     d,
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w500,
//                       color: _RC.textSecondary,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Calendar grid — custom, no package needed
// // ─────────────────────────────────────────────
// class _CalendarGrid extends StatelessWidget {
//   final CalendarViewModel vm;
//   const _CalendarGrid({required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     final firstDay = DateTime(vm.focusedMonth.year, vm.focusedMonth.month, 1);
//     final daysInMonth =
//         DateTime(vm.focusedMonth.year, vm.focusedMonth.month + 1, 0).day;
//
//     // Monday = 1, so offset = weekday - 1
//     final startOffset = firstDay.weekday - 1;
//     final totalCells = startOffset + daysInMonth;
//     final rows = (totalCells / 7).ceil();
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.w),
//       child: Column(
//         children: List.generate(rows, (row) {
//           return Row(
//             children: List.generate(7, (col) {
//               final cellIndex = row * 7 + col;
//               final dayNum = cellIndex - startOffset + 1;
//
//               if (dayNum < 1 || dayNum > daysInMonth) {
//                 return const Expanded(child: SizedBox());
//               }
//
//               final date = DateTime(
//                 vm.focusedMonth.year,
//                 vm.focusedMonth.month,
//                 dayNum,
//               );
//               final dayData = vm.dayData(date);
//               final isToday = _isToday(date);
//               final isSelected = _isSelected(vm, date);
//
//               return Expanded(
//                 child: _DayCell(
//                   day: dayNum,
//                   date: date,
//                   dayData: dayData,
//                   isToday: isToday,
//                   isSelected: isSelected,
//                   onTap: () => vm.selectDay(date),
//                 ),
//               );
//             }),
//           );
//         }),
//       ),
//     );
//   }
//
//   bool _isToday(DateTime date) {
//     final now = DateTime.now();
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }
//
//   bool _isSelected(CalendarViewModel vm, DateTime date) {
//     final s = vm.selectedDay;
//     return s != null &&
//         s.year == date.year &&
//         s.month == date.month &&
//         s.day == date.day;
//   }
// }
//
// // ─────────────────────────────────────────────
// // Individual day cell
// // ─────────────────────────────────────────────
// class _DayCell extends StatelessWidget {
//   final int day;
//   final DateTime date;
//   final CalendarDayModel? dayData;
//   final bool isToday;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _DayCell({
//     required this.day,
//     required this.date,
//     required this.dayData,
//     required this.isToday,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final type = dayData?.dayType ?? CalendarDayType.empty;
//     final bgColor = _cellBg(type, isToday, isSelected);
//     final textColor = _textColor(type, isToday, isSelected);
//     final dotColor = _dotColor(type);
//
//     return GestureDetector(
//       onTap: dayData != null ? onTap : null,
//       child: Container(
//         height: 44.h,
//         margin: EdgeInsets.all(2.w),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(10.r),
//           border: isSelected
//               ? Border.all(color: _RC.navy, width: 1.5)
//               : isToday
//                   ? Border.all(color: _RC.gold, width: 1.5)
//                   : null,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '$day',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight:
//                     isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
//                 color: textColor,
//               ),
//             ),
//             if (dotColor != null) ...[
//               SizedBox(height: 3.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: _buildDots(dayData!),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildDots(CalendarDayModel data) {
//     // Show up to 3 dots: one per hearing type present
//     final dots = <Widget>[];
//
//     if (data.hasConflict) {
//       dots.add(_Dot(color: _RC.danger));
//     } else if (data.scheduledHearings.isNotEmpty) {
//       dots.add(_Dot(color: _RC.navy));
//     }
//     if (data.hasAdjourned) {
//       dots.add(_Dot(color: _RC.warning));
//     }
//
//     return dots
//         .take(3)
//         .map((d) =>
//             Padding(padding: EdgeInsets.symmetric(horizontal: 1.5.w), child: d))
//         .toList();
//   }
//
//   Color? _cellBg(CalendarDayType type, bool isToday, bool isSelected) {
//     if (isSelected) return _RC.navy.withValues(alpha: 0.08);
//     if (isToday) return _RC.gold.withValues(alpha: 0.08);
//     switch (type) {
//       case CalendarDayType.conflict:
//         return _RC.dangerSurface;
//       case CalendarDayType.adjourned:
//         return _RC.warningSurface;
//       case CalendarDayType.hearing:
//         return _RC.infoSurface;
//       case CalendarDayType.empty:
//         return null;
//     }
//   }
//
//   Color _textColor(CalendarDayType type, bool isToday, bool isSelected) {
//     if (isSelected) return _RC.navy;
//     if (isToday) return _RC.gold;
//     switch (type) {
//       case CalendarDayType.conflict:
//         return _RC.dangerText;
//       case CalendarDayType.adjourned:
//         return _RC.warningText;
//       case CalendarDayType.hearing:
//         return _RC.infoText;
//       case CalendarDayType.empty:
//         return _RC.textPrimary;
//     }
//   }
//
//   Color? _dotColor(CalendarDayType type) {
//     switch (type) {
//       case CalendarDayType.conflict:
//         return _RC.danger;
//       case CalendarDayType.hearing:
//         return _RC.navy;
//       case CalendarDayType.adjourned:
//         return _RC.warning;
//       case CalendarDayType.empty:
//         return null;
//     }
//   }
// }
//
// class _Dot extends StatelessWidget {
//   final Color color;
//   const _Dot({required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 5.w,
//       height: 5.w,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Legend
// // ─────────────────────────────────────────────
// class _Legend extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _LegendItem(color: _RC.navy, label: 'Hearing'),
//         SizedBox(width: 16.w),
//         _LegendItem(color: _RC.danger, label: 'Conflict'),
//         SizedBox(width: 16.w),
//         _LegendItem(color: _RC.warning, label: 'Adjourned'),
//       ],
//     );
//   }
// }
//
// class _LegendItem extends StatelessWidget {
//   final Color color;
//   final String label;
//   const _LegendItem({required this.color, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 8.w,
//           height: 8.w,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         SizedBox(width: 5.w),
//         Text(
//           label,
//           style: TextStyle(fontSize: 11.sp, color: _RC.textSecondary),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Day detail panel — slides in below calendar
// // ─────────────────────────────────────────────
// class _DayDetailPanel extends StatelessWidget {
//   final CalendarViewModel vm;
//   const _DayDetailPanel({required this.vm});
//
//   String _dayLabel(DateTime day) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dayData = vm.selectedDayData;
//     final day = vm.selectedDay!;
//
//     return Container(
//       key: ValueKey(day),
//       decoration: BoxDecoration(
//         color: _RC.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [_RC.card],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Panel header
//           _PanelHeader(
//             label: _dayLabel(day),
//             onClose: vm.clearSelection,
//           ),
//
//           if (dayData == null) ...[
//             _EmptyDayContent(),
//           ] else ...[
//             // Conflict banner
//             if (dayData.hasConflict)
//               _ConflictBanner(hearings: dayData.scheduledHearings),
//
//             // Scheduled hearings
//             if (dayData.scheduledHearings.isNotEmpty) ...[
//               _PanelSection(label: 'Hearings'),
//               ...dayData.scheduledHearings
//                   .map((h) => _HearingDetailRow(hearing: h, vm: vm)),
//             ],
//
//             // Adjourned hearings
//             if (dayData.adjournedHearings.isNotEmpty) ...[
//               _PanelSection(label: 'Adjourned'),
//               ...dayData.adjournedHearings
//                   .map((h) => _AdjournedRow(hearing: h, vm: vm)),
//             ],
//
//             SizedBox(height: 12.h),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _PanelHeader extends StatelessWidget {
//   final String label;
//   final VoidCallback onClose;
//   const _PanelHeader({required this.label, required this.onClose});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(14.w, 13.h, 8.w, 13.h),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: _RC.divider, width: 0.5)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 3,
//             height: 16,
//             decoration: BoxDecoration(
//               color: _RC.gold,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: _RC.textPrimary,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.close_rounded,
//                 size: 18.sp, color: _RC.textSecondary),
//             onPressed: onClose,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           SizedBox(width: 8.w),
//         ],
//       ),
//     );
//   }
// }
//
// class _PanelSection extends StatelessWidget {
//   final String label;
//   const _PanelSection({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
//       child: Text(
//         label.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10.sp,
//           fontWeight: FontWeight.w600,
//           color: _RC.textSecondary,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }
// }
//
// class _HearingDetailRow extends StatelessWidget {
//   final CalendarHearingItem hearing;
//   final CalendarViewModel vm;
//   const _HearingDetailRow({required this.hearing, required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     final String? time = hearing.formattedTime;
//
//     return Container(
//       margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
//       decoration: BoxDecoration(
//         color: _RC.background,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _RC.divider, width: 0.5),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Time — was hearing.formattedTime! (forced unwrap), which would
//           // crash here for any date-only hearing. Most hearings are
//           // date-only, so this now shows an honest fallback instead.
//           Text(
//             time ?? 'No time',
//             style: TextStyle(
//               fontSize: 11.sp,
//               fontWeight: FontWeight.w600,
//               color: time != null ? _RC.navy : _RC.textTertiary,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           // Case info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   hearing.caseTitle,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w500,
//                     color: _RC.textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Wrap(spacing: 6, runSpacing: 4, children: [
//                   if (hearing.courtName != null)
//                     _Chip(
//                       icon: Icons.location_on_outlined,
//                       label: hearing.courtName!,
//                       color: _RC.textSecondary,
//                     ),
//                   if (hearing.caseStageName != null)
//                     _Chip(
//                       icon: Icons.gavel_outlined,
//                       label: hearing.caseStageName!,
//                       color: _RC.infoText,
//                       bg: _RC.infoSurface,
//                     ),
//                 ]),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AdjournedRow extends StatelessWidget {
//   final CalendarHearingItem hearing;
//   final CalendarViewModel vm;
//   const _AdjournedRow({required this.hearing, required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
//       decoration: BoxDecoration(
//         color: _RC.warningSurface,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _RC.warningBorder, width: 0.5),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.schedule_outlined, size: 14.sp, color: _RC.warningText),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: Text(
//               hearing.caseTitle,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w500,
//                 color: _RC.warningText,
//               ),
//             ),
//           ),
//           // Tap to see full adjournment history for this case
//           GestureDetector(
//             onTap: () {
//               vm.loadAdjournmentHistory(hearing.caseId);
//               _showAdjournmentSheet(context, hearing.caseId);
//             },
//             child: Text(
//               'History',
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w500,
//                 color: _RC.navy,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAdjournmentSheet(BuildContext context, String caseId) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => ChangeNotifierProvider.value(
//         value: context.read<CalendarViewModel>(),
//         child: _AdjournmentHistorySheet(caseId: caseId),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Adjournment history bottom sheet
// // ─────────────────────────────────────────────
// class _AdjournmentHistorySheet extends StatelessWidget {
//   final String caseId;
//   const _AdjournmentHistorySheet({required this.caseId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CalendarViewModel>(
//       builder: (_, calendarVM, __) {
//         final history = calendarVM.adjournmentHistory(caseId);
//
//         return DraggableScrollableSheet(
//           initialChildSize: 0.55,
//           maxChildSize: 0.9,
//           minChildSize: 0.35,
//           builder: (_, scrollCtrl) => Container(
//             decoration: BoxDecoration(
//               color: _RC.surface,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//             ),
//             child: Column(
//               children: [
//                 // Handle
//                 Container(
//                   width: 36.w,
//                   height: 4,
//                   margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
//                   decoration: BoxDecoration(
//                     color: _RC.divider,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//
//                 // Header
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   child: Row(
//                     children: [
//                       Text(
//                         'Adjournment history',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w600,
//                           color: _RC.textPrimary,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (history != null)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 8.w, vertical: 3.h),
//                           decoration: BoxDecoration(
//                             color: _RC.warningSurface,
//                             borderRadius: BorderRadius.circular(8.r),
//                             border: Border.all(color: _RC.warningBorder),
//                           ),
//                           child: Text(
//                             '${history.totalAdjournments} adj.',
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w500,
//                               color: _RC.warningText,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//
//                 if (history != null) ...[
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
//                     child: Text(
//                       history.caseTitle,
//                       style:
//                           TextStyle(fontSize: 12.sp, color: _RC.textSecondary),
//                     ),
//                   ),
//                 ],
//
//                 Divider(color: _RC.divider, height: 1),
//
//                 // Content
//                 Expanded(
//                   child: calendarVM.isAdjournmentLoading
//                       ? const Center(
//                           child: CircularProgressIndicator(color: _RC.navy))
//                       : calendarVM.adjournmentError != null
//                           ? Center(
//                               child: Text(calendarVM.adjournmentError!,
//                                   style: TextStyle(color: _RC.danger)))
//                           : history == null
//                               ? const Center(child: SizedBox())
//                               : history.adjournments.isEmpty
//                                   ? _AdjournmentEmpty()
//                                   : ListView.separated(
//                                       controller: scrollCtrl,
//                                       padding: EdgeInsets.all(16.w),
//                                       itemCount: history.adjournments.length,
//                                       separatorBuilder: (_, __) =>
//                                           SizedBox(height: 10.h),
//                                       itemBuilder: (_, i) =>
//                                           _AdjournmentEntryCard(
//                                         entry: history.adjournments[i],
//                                         index: i + 1,
//                                         total: history.totalAdjournments,
//                                       ),
//                                     ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _AdjournmentEntryCard extends StatelessWidget {
//   final AdjournmentEntry entry;
//   final int index;
//   final int total;
//   const _AdjournmentEntryCard(
//       {required this.entry, required this.index, required this.total});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Timeline indicator
//         Column(
//           children: [
//             Container(
//               width: 28.w,
//               height: 28.w,
//               decoration: BoxDecoration(
//                 color: _RC.warningSurface,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: _RC.warningBorder),
//               ),
//               child: Center(
//                 child: Text(
//                   '$index',
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w600,
//                     color: _RC.warningText,
//                   ),
//                 ),
//               ),
//             ),
//             if (index < total)
//               Container(
//                 width: 1.5,
//                 height: 32.h,
//                 color: _RC.warningBorder,
//                 margin: EdgeInsets.only(top: 4.h),
//               ),
//           ],
//         ),
//         SizedBox(width: 12.w),
//         // Content
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 entry.formattedDate,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w600,
//                   color: _RC.textPrimary,
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 entry.adjournmentReason ?? 'No reason recorded',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: entry.adjournmentReason != null
//                       ? _RC.textSecondary
//                       : _RC.textTertiary,
//                   fontStyle: entry.adjournmentReason == null
//                       ? FontStyle.italic
//                       : FontStyle.normal,
//                 ),
//               ),
//               SizedBox(height: 16.h),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _AdjournmentEmpty extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.check_circle_outline,
//               size: 36.sp, color: _RC.textTertiary),
//           SizedBox(height: 10.h),
//           Text(
//             'No adjournments recorded',
//             style: TextStyle(fontSize: 13.sp, color: _RC.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Shared small widgets
// // ─────────────────────────────────────────────
// class _ConflictBanner extends StatelessWidget {
//   final List<CalendarHearingItem> hearings;
//   const _ConflictBanner({required this.hearings});
//
//   @override
//   Widget build(BuildContext context) {
//     final a = hearings.isNotEmpty ? hearings[0] : null;
//     final b = hearings.length > 1 ? hearings[1] : null;
//     return Container(
//       margin: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: _RC.dangerSurface,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _RC.dangerBorder, width: 0.5),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, size: 16.sp, color: _RC.danger),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: Text(
//               a != null && b != null
//                   ? 'Conflict: ${a.courtName ?? a.caseTitle} at ${a.formattedTime ?? "an unspecified time"} '
//                       'overlaps with ${b.courtName ?? b.caseTitle}'
//                   : 'Scheduling conflict detected on this day',
//               style: TextStyle(fontSize: 11.sp, color: _RC.dangerText),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Chip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final Color? bg;
//   const _Chip(
//       {required this.icon, required this.label, required this.color, this.bg});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
//       decoration: bg != null
//           ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5.r))
//           : null,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10.sp, color: color),
//           SizedBox(width: 3.w),
//           Text(
//             label,
//             style: TextStyle(
//                 fontSize: 10.sp,
//                 color: color,
//                 fontWeight: bg != null ? FontWeight.w500 : FontWeight.normal),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NoSelectionHint extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       key: const ValueKey('hint'),
//       padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
//       decoration: BoxDecoration(
//         color: _RC.navy.withValues(alpha: 0.04),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: _RC.divider),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.touch_app_outlined, size: 16.sp, color: _RC.textTertiary),
//           SizedBox(width: 10.w),
//           Text(
//             'Tap a highlighted day to see hearing details',
//             style: TextStyle(fontSize: 12.sp, color: _RC.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyDayContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
//       child: Text(
//         'No hearings on this day.',
//         style: TextStyle(fontSize: 13.sp, color: _RC.textSecondary),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Loading skeleton
// // ─────────────────────────────────────────────
// class _CalendarSkeleton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       child: Column(
//         children: List.generate(
//           5,
//           (_) => Row(
//             children: List.generate(
//               7,
//               (_) => Expanded(
//                 child: Container(
//                   height: 40.h,
//                   margin: EdgeInsets.all(2.w),
//                   decoration: BoxDecoration(
//                     color: _RC.divider.withValues(alpha: 0.5),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Error state
// // ─────────────────────────────────────────────
// class _CalendarError extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   final String? title;
//
//   const _CalendarError({
//     required this.message,
//     required this.onRetry,
//     this.title,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 52.w,
//               height: 52.w,
//               decoration: BoxDecoration(
//                 color: _RC.danger.withValues(alpha: 0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.cloud_off_rounded,
//                 color: _RC.danger.withValues(alpha: 0.9),
//                 size: 24.sp,
//               ),
//             ).animate().scale(
//                   duration: 400.ms,
//                   curve: Curves.easeOutBack,
//                 ),
//             SizedBox(height: 16.h),
//             Text(
//               title ?? 'Couldn\'t load data',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//                 color: _RC.textPrimary,
//                 letterSpacing: -0.2,
//               ),
//             )
//                 .animate()
//                 .fadeIn(delay: 100.ms, duration: 300.ms)
//                 .slideY(begin: 0.1, end: 0),
//             SizedBox(height: 6.h),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: _RC.textSecondary,
//                 height: 1.4,
//               ),
//             )
//                 .animate()
//                 .fadeIn(delay: 150.ms, duration: 300.ms)
//                 .slideY(begin: 0.1, end: 0),
//             SizedBox(height: 16.h),
//             TextButton.icon(
//               onPressed: onRetry,
//               style: TextButton.styleFrom(
//                 foregroundColor: _RC.navy,
//                 backgroundColor: _RC.navy.withValues(alpha: 0.06),
//                 elevation: 0,
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//               ),
//               icon: Icon(Icons.refresh_rounded, size: 16.sp),
//               label: Text(
//                 'Try again',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.1,
//                 ),
//               ),
//             )
//                 .animate()
//                 .fadeIn(delay: 200.ms, duration: 300.ms)
//                 .slideY(begin: 0.1, end: 0),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';

import '../../models/case_models/calendar_hearing_model.dart';
import '../../view_model/calendar_view_model/calendar_view_model.dart';

// ─────────────────────────────────────────────
// Calendar Screen
// ─────────────────────────────────────────────
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().initialLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.background,
      appBar: _buildAppBar(),
      body: Consumer<CalendarViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            color: RC.navy,
            onRefresh: vm.refreshCurrentMonth,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Calendar grid
                SliverToBoxAdapter(child: _CalendarCard(vm: vm)),

                // Legend
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverToBoxAdapter(child: _Legend()),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                // Day detail panel (slides in when day is selected)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: vm.selectedDay != null
                          ? _DayDetailPanel(vm: vm)
                          : _NoSelectionHint(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Consumer<CalendarViewModel>(
        builder: (_, vm, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart legal diary',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              vm.focusedMonthLabel,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Calendar card — month header + grid
// ─────────────────────────────────────────────
class _CalendarCard extends StatelessWidget {
  final CalendarViewModel vm;
  const _CalendarCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        children: [
          _MonthHeader(vm: vm),
          _WeekDayLabels(),
          if (vm.isMonthLoading)
            _CalendarSkeleton()
          else if (vm.monthError != null)
            _CalendarError(
                message: vm.monthError!, onRetry: vm.refreshCurrentMonth)
          else
            _CalendarGrid(vm: vm),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

// Month navigation header
class _MonthHeader extends StatelessWidget {
  final CalendarViewModel vm;
  const _MonthHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          // Today button
          GestureDetector(
            onTap: () => vm.goToMonth(DateTime.now()),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: RC.navy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: RC.navy,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Month label
          Text(
            vm.focusedMonthLabel,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary,
            ),
          ),
          const Spacer(),
          // Prev / Next arrows
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            enabled: vm.canGoBack,
            onTap: vm.goToPreviousMonth,
          ),
          SizedBox(width: 4.w),
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            enabled: vm.canGoForward,
            onTap: vm.goToNextMonth,
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavArrow(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: enabled ? RC.navy.withValues(alpha: 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: enabled ? RC.navy : RC.textTertiary,
        ),
      ),
    );
  }
}

// Day-of-week header row
class _WeekDayLabels extends StatelessWidget {
  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: _days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: RC.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Calendar grid — custom, no package needed
// ─────────────────────────────────────────────
class _CalendarGrid extends StatelessWidget {
  final CalendarViewModel vm;
  const _CalendarGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(vm.focusedMonth.year, vm.focusedMonth.month, 1);
    final daysInMonth =
        DateTime(vm.focusedMonth.year, vm.focusedMonth.month + 1, 0).day;

    // Monday = 1, so offset = weekday - 1
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(
                vm.focusedMonth.year,
                vm.focusedMonth.month,
                dayNum,
              );
              final dayData = vm.dayData(date);
              final isToday = _isToday(date);
              final isSelected = _isSelected(vm, date);

              return Expanded(
                child: _DayCell(
                  day: dayNum,
                  date: date,
                  dayData: dayData,
                  isToday: isToday,
                  isSelected: isSelected,
                  onTap: () => vm.selectDay(date),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(CalendarViewModel vm, DateTime date) {
    final s = vm.selectedDay;
    return s != null &&
        s.year == date.year &&
        s.month == date.month &&
        s.day == date.day;
  }
}

// ─────────────────────────────────────────────
// Individual day cell
// ─────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final CalendarDayModel? dayData;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.date,
    required this.dayData,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = dayData?.dayType ?? CalendarDayType.empty;
    final bgColor = _cellBg(type, isToday, isSelected);
    final textColor = _textColor(type, isToday, isSelected);
    final dotColor = _dotColor(type);

    return GestureDetector(
      onTap: dayData != null ? onTap : null,
      child: Container(
        height: 44.h,
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected
              ? Border.all(color: RC.navy, width: 1.5)
              : isToday
                  ? Border.all(color: RC.gold, width: 1.5)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight:
                    isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
            if (dotColor != null) ...[
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDots(dayData!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDots(CalendarDayModel data) {
    // Show up to 3 dots: one per hearing type present.
    // Unchanged — soft conflicts deliberately do not get a dot colour of
    // their own; they're surfaced in the day-detail panel instead, since
    // amber is already spoken for by "adjourned" on this grid.
    final dots = <Widget>[];

    if (data.hasConflict) {
      dots.add(_Dot(color: RC.danger));
    } else if (data.scheduledHearings.isNotEmpty) {
      dots.add(_Dot(color: RC.navy));
    }
    if (data.hasAdjourned) {
      dots.add(_Dot(color: RC.warning));
    }

    return dots
        .take(3)
        .map((d) =>
            Padding(padding: EdgeInsets.symmetric(horizontal: 1.5.w), child: d))
        .toList();
  }

  Color? _cellBg(CalendarDayType type, bool isToday, bool isSelected) {
    if (isSelected) return RC.navy.withValues(alpha: 0.08);
    if (isToday) return RC.gold.withValues(alpha: 0.08);
    switch (type) {
      case CalendarDayType.conflict:
        return RC.dangerSurface;
      case CalendarDayType.adjourned:
        return RC.warningSurface;
      case CalendarDayType.hearing:
        return RC.infoSurface;
      case CalendarDayType.empty:
        return null;
    }
  }

  Color _textColor(CalendarDayType type, bool isToday, bool isSelected) {
    if (isSelected) return RC.navy;
    if (isToday) return RC.gold;
    switch (type) {
      case CalendarDayType.conflict:
        return RC.dangerText;
      case CalendarDayType.adjourned:
        return RC.warningText;
      case CalendarDayType.hearing:
        return RC.infoText;
      case CalendarDayType.empty:
        return RC.textPrimary;
    }
  }

  Color? _dotColor(CalendarDayType type) {
    switch (type) {
      case CalendarDayType.conflict:
        return RC.danger;
      case CalendarDayType.hearing:
        return RC.navy;
      case CalendarDayType.adjourned:
        return RC.warning;
      case CalendarDayType.empty:
        return null;
    }
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.w,
      height: 5.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: RC.navy, label: 'Hearing'),
        SizedBox(width: 16.w),
        _LegendItem(color: RC.danger, label: 'Conflict'),
        SizedBox(width: 16.w),
        _LegendItem(color: RC.warning, label: 'Adjourned'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: RC.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Day detail panel — slides in below calendar
// ─────────────────────────────────────────────
class _DayDetailPanel extends StatelessWidget {
  final CalendarViewModel vm;
  const _DayDetailPanel({required this.vm});

  String _dayLabel(DateTime day) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final dayData = vm.selectedDayData;
    final day = vm.selectedDay!;

    return Container(
      key: ValueKey(day),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          _PanelHeader(
            label: _dayLabel(day),
            onClose: vm.clearSelection,
          ),

          if (dayData == null) ...[
            _EmptyDayContent(),
          ] else ...[
            // Hard conflict banner takes priority — a day is never both.
            if (dayData.hasConflict)
              _ConflictBanner(hearings: dayData.scheduledHearings)
            else if (dayData.hasSoftConflict)
              _SoftConflictCard(reasons: dayData.conflictReasons),

            // Scheduled hearings
            if (dayData.scheduledHearings.isNotEmpty) ...[
              _PanelSection(label: 'Hearings'),
              ...dayData.scheduledHearings
                  .map((h) => _HearingDetailRow(hearing: h, vm: vm)),
            ],

            // Adjourned hearings
            if (dayData.adjournedHearings.isNotEmpty) ...[
              _PanelSection(label: 'Adjourned'),
              ...dayData.adjournedHearings
                  .map((h) => _AdjournedRow(hearing: h, vm: vm)),
            ],

            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String label;
  final VoidCallback onClose;
  const _PanelHeader({required this.label, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 8.w, 13.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: RC.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: RC.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon:
                Icon(Icons.close_rounded, size: 18.sp, color: RC.textSecondary),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

class _PanelSection extends StatelessWidget {
  final String label;
  const _PanelSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: RC.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HearingDetailRow extends StatelessWidget {
  final CalendarHearingItem hearing;
  final CalendarViewModel vm;
  const _HearingDetailRow({required this.hearing, required this.vm});

  @override
  Widget build(BuildContext context) {
    final String? time = hearing.formattedTime;

    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: RC.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.divider, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time ?? 'No time',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: time != null ? RC.navy : RC.textTertiary,
            ),
          ),
          SizedBox(width: 12.w),
          // Case info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hearing.caseTitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: RC.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (hearing.courtName != null)
                    _Chip(
                      icon: Icons.location_on_outlined,
                      label: hearing.courtName!,
                      color: RC.textSecondary,
                    ),
                  if (hearing.caseStageName != null)
                    _Chip(
                      icon: Icons.gavel_outlined,
                      label: hearing.caseStageName!,
                      color: RC.infoText,
                      bg: RC.infoSurface,
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjournedRow extends StatelessWidget {
  final CalendarHearingItem hearing;
  final CalendarViewModel vm;
  const _AdjournedRow({required this.hearing, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: RC.warningSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.warningBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, size: 14.sp, color: RC.warningText),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              hearing.caseTitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: RC.warningText,
              ),
            ),
          ),
          // Tap to see full adjournment history for this case
          GestureDetector(
            onTap: () {
              vm.loadAdjournmentHistory(hearing.caseId);
              _showAdjournmentSheet(context, hearing.caseId);
            },
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: RC.navy,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjournmentSheet(BuildContext context, String caseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CalendarViewModel>(),
        child: _AdjournmentHistorySheet(caseId: caseId),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Adjournment history bottom sheet
// ─────────────────────────────────────────────
class _AdjournmentHistorySheet extends StatelessWidget {
  final String caseId;
  const _AdjournmentHistorySheet({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (_, calendarVM, __) {
        final history = calendarVM.adjournmentHistory(caseId);

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.35,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: RC.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 36.w,
                  height: 4,
                  margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                  decoration: BoxDecoration(
                    color: RC.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        'Adjournment history',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: RC.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (history != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: RC.warningSurface,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: RC.warningBorder),
                          ),
                          child: Text(
                            '${history.totalAdjournments} adj.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: RC.warningText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (history != null) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                    child: Text(
                      history.caseTitle,
                      style:
                          TextStyle(fontSize: 12.sp, color: RC.textSecondary),
                    ),
                  ),
                ],

                Divider(color: RC.divider, height: 1),

                // Content
                Expanded(
                  child: calendarVM.isAdjournmentLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: RC.navy))
                      : calendarVM.adjournmentError != null
                          ? Center(
                              child: Text(calendarVM.adjournmentError!,
                                  style: TextStyle(color: RC.danger)))
                          : history == null
                              ? const Center(child: SizedBox())
                              : history.adjournments.isEmpty
                                  ? _AdjournmentEmpty()
                                  : ListView.separated(
                                      controller: scrollCtrl,
                                      padding: EdgeInsets.all(16.w),
                                      itemCount: history.adjournments.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 10.h),
                                      itemBuilder: (_, i) =>
                                          _AdjournmentEntryCard(
                                        entry: history.adjournments[i],
                                        index: i + 1,
                                        total: history.totalAdjournments,
                                      ),
                                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdjournmentEntryCard extends StatelessWidget {
  final AdjournmentEntry entry;
  final int index;
  final int total;
  const _AdjournmentEntryCard(
      {required this.entry, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: RC.warningSurface,
                shape: BoxShape.circle,
                border: Border.all(color: RC.warningBorder),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.warningText,
                  ),
                ),
              ),
            ),
            if (index < total)
              Container(
                width: 1.5,
                height: 32.h,
                color: RC.warningBorder,
                margin: EdgeInsets.only(top: 4.h),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.formattedDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: RC.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                entry.adjournmentReason ?? 'No reason recorded',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: entry.adjournmentReason != null
                      ? RC.textSecondary
                      : RC.textTertiary,
                  fontStyle: entry.adjournmentReason == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdjournmentEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 36.sp, color: RC.textTertiary),
          SizedBox(height: 10.h),
          Text(
            'No adjournments recorded',
            style: TextStyle(fontSize: 13.sp, color: RC.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────
class _ConflictBanner extends StatelessWidget {
  final List<CalendarHearingItem> hearings;
  const _ConflictBanner({required this.hearings});

  @override
  Widget build(BuildContext context) {
    final a = hearings.isNotEmpty ? hearings[0] : null;
    final b = hearings.length > 1 ? hearings[1] : null;
    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RC.dangerSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.dangerBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16.sp, color: RC.danger),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              a != null && b != null
                  ? 'Conflict: ${a.courtName ?? a.caseTitle} at ${a.formattedTime ?? "an unspecified time"} '
                      'overlaps with ${b.courtName ?? b.caseTitle}'
                  : 'Scheduling conflict detected on this day',
              style: TextStyle(fontSize: 11.sp, color: RC.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Soft conflict card — new. Shown in the day-detail panel when a day
// carries a potential (not hard) risk: an untimed overlap, or a heavy
// same-day hearing load. Reuses the same warning tokens already used for
// adjourned hearings elsewhere on this screen.
// ─────────────────────────────────────────────
class _SoftConflictCard extends StatelessWidget {
  final List<String> reasons;
  const _SoftConflictCard({required this.reasons});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RC.warningSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.warningBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16.sp, color: RC.warningText),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible conflict',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.warningText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  reasons.isNotEmpty
                      ? reasons.join(' · ')
                      : 'Timing for this day isn\'t fully confirmed yet.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: RC.warningText.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? bg;
  const _Chip(
      {required this.icon, required this.label, required this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: bg != null
          ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5.r))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: bg != null ? FontWeight.w500 : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class _NoSelectionHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('hint'),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: RC.navy.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: RC.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, size: 16.sp, color: RC.textTertiary),
          SizedBox(width: 10.w),
          Text(
            'Tap a highlighted day to see hearing details',
            style: TextStyle(fontSize: 12.sp, color: RC.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
      child: Text(
        'No hearings on this day.',
        style: TextStyle(fontSize: 13.sp, color: RC.textSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading skeleton
// ─────────────────────────────────────────────
class _CalendarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Column(
        children: List.generate(
          5,
          (_) => Row(
            children: List.generate(
              7,
              (_) => Expanded(
                child: Container(
                  height: 40.h,
                  margin: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: RC.divider.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────
class _CalendarError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? title;

  const _CalendarError({
    required this.message,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: RC.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: RC.danger.withValues(alpha: 0.9),
                size: 24.sp,
              ),
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),
            SizedBox(height: 16.h),
            Text(
              title ?? 'Couldn\'t load data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: RC.textPrimary,
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: RC.textSecondary,
                height: 1.4,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: RC.navy,
                backgroundColor: RC.navy.withValues(alpha: 0.06),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
