import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/resources/system_design/rc_widgets.dart';

import '../utils/routes/routes_names.dart';
import '../view_model/calendar_view_model/calendar_view_model.dart';
import '../view_model/cases_view_model/hearing_create_view_model/today_and_upcoming_hearing_view_model.dart';

// ═════════════════════════════════════════════════════════════════════════════
// CHRONICLE — Final
// ═════════════════════════════════════════════════════════════════════════════
// Architecture:
//   1. Alert Banner   → Hard/soft conflict today (exact original design)
//   2. TODAY          → DocketTimeline, connected rail, one shared surface
//   3. THIS WEEK      → 7-day strip with subtle background highlight
//   4. UPCOMING       → 3-day edge cards, differentiated by urgency:
//                        Today/Tomorrow = filled + left-accent
//                        2–3 days       = outlined + ghosted
// ═════════════════════════════════════════════════════════════════════════════

class CriticalAgendaSection extends StatelessWidget {
  final AgendaViewModel viewModel;
  const CriticalAgendaSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) return const _ChronicleSkeleton();

    if (viewModel.errorMessage != null) {
      return Center(
        child: RCErrorState(
          message: viewModel.errorMessage!,
          onRetry: viewModel.loadAgenda,
        ),
      );
    }

    final hasToday = viewModel.todayHearings.isNotEmpty;
    final hasEdge = viewModel.deadlineCards.isNotEmpty; // already ≤3 days
    final hasWeekActivity = viewModel.weekOverview().any((d) => d.hasHearings);
    final hasAny = hasToday ||
        hasEdge ||
        hasWeekActivity ||
        viewModel.hasSchedulingConflict ||
        viewModel.hasSoftConflictToday;

    if (!hasAny) return const _EmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════════════════════
        // 1. ALERT BANNER — Today's existential threat (if any)
        // ═══════════════════════════════════════════════════════════════
        if (viewModel.hasSchedulingConflict) ...[
          _ConflictBanner(hearings: viewModel.conflictingHearings),
          SizedBox(height: 20.h),
        ] else if (viewModel.hasSoftConflictToday) ...[
          _SoftConflictBanner(message: viewModel.todaySoftConflictMessage),
          SizedBox(height: 16.h),
        ],

        // ═══════════════════════════════════════════════════════════════
        // 2. TODAY — The docket, connected timeline
        // ═══════════════════════════════════════════════════════════════
        if (hasToday) ...[
          const _SectionHeader(title: 'TODAY'),
          SizedBox(height: 5.h),
          _DocketTimeline(hearings: viewModel.todayHearings),
          SizedBox(height: 20.h),
        ],

        // ═══════════════════════════════════════════════════════════════
        // 3. THIS WEEK — Situational awareness strip
        // ═══════════════════════════════════════════════════════════════
        _WeekStrip(viewModel: viewModel),
        SizedBox(height: 16.h),

        // ═══════════════════════════════════════════════════════════════
        // 4. UPCOMING — The 3-day edge, urgency-differentiated cards
        // ═══════════════════════════════════════════════════════════════
        if (hasEdge) ...[
          const _SectionHeader(title: 'UPCOMING'),
          SizedBox(height: 5.h),
          ...viewModel.deadlineCards.asMap().entries.map((e) {
            final isLast = e.key == viewModel.deadlineCards.length - 1;
            return _EdgeCard(hearing: e.value, isLast: isLast);
          }),
          SizedBox(height: 16.h),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. ALERT BANNERS — Exact original design, rounded corners preserved
// ═════════════════════════════════════════════════════════════════════════════

class _ConflictBanner extends StatelessWidget {
  final List<dynamic> hearings;
  const _ConflictBanner({required this.hearings});

  @override
  Widget build(BuildContext context) {
    final a = hearings.isNotEmpty ? hearings[0] : null;
    final b = hearings.length > 1 ? hearings[1] : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: RC.dangerSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: RC.dangerBorder, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: RC.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded,
                size: 15.sp, color: RC.danger),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduling conflict',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.dangerText,
                  ),
                ),
                SizedBox(height: 4.h),
                if (a != null && b != null)
                  Text(
                    '${a.courtName ?? a.caseTitle} at ${a.formattedTime ?? "an unspecified time"} '
                    'overlaps with ${b.courtName ?? b.caseTitle} at ${b.formattedTime ?? "an unspecified time"}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: RC.dangerText.withValues(alpha: 0.85),
                      height: 1.45,
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

class _SoftConflictBanner extends StatelessWidget {
  final String message;
  const _SoftConflictBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: RC.warningSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: RC.warningBorder,
          width: 0.8.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: RC.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16.sp,
              color: RC.warningText,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible scheduling conflict',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.warningText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: RC.warningText.withValues(alpha: 0.9),
                    height: 1.45,
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

// ═════════════════════════════════════════════════════════════════════════════
// 2. DOCKET TIMELINE — Exact original design, one shared surface
// ═════════════════════════════════════════════════════════════════════════════

class _DocketTimeline extends StatelessWidget {
  final List<dynamic> hearings; // TodayHearingModel
  const _DocketTimeline({required this.hearings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        children: [
          for (int i = 0; i < hearings.length; i++)
            _DocketTimelineRow(
              hearing: hearings[i],
              isLast: i == hearings.length - 1,
            ),
        ],
      ),
    );
  }
}

class _DocketTimelineRow extends StatelessWidget {
  final dynamic hearing; // TodayHearingModel
  final bool isLast;
  const _DocketTimelineRow({required this.hearing, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentColor(hearing.urgency);
    final String? time = hearing.formattedTime;

    final String caseTitle = (hearing.caseTitle ?? 'Untitled Case').toString();
    final String? hearingTitle = hearing.title;
    final String? courtName = hearing.courtName;
    final String? caseStageName = hearing.caseStageName;

    final bool hasStage =
        caseStageName != null && caseStageName.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TIME COLUMN ───
            SizedBox(
              width: 54.w,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  time ?? 'No time',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: time != null ? accent : RC.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),

            // ─── 2. TIMELINE RAIL ───
            Column(
              children: [
                SizedBox(height: 14.h),
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: RC.divider.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // ─── 3. CONTENT AREA ───
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Headline: Primary Case Title
                    Text(
                      caseTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: RC.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ROW 1: Hearing Title • Location Icon + Court Name (Extracted)
                    _MetaData(
                      hearingTitle: hearingTitle,
                      courtName: courtName,
                    ),

                    // ROW 2: Case Stage Badge
                    if (hasStage) ...[
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: RC.infoSurface,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.file_open_rounded,
                              size: 11.sp,
                              color: RC.infoText,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                caseStageName,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: RC.infoText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(dynamic urgency) {
    switch (urgency.toString()) {
      case 'DeadlineUrgency.overdue':
      case 'DeadlineUrgency.critical':
        return RC.danger;
      case 'DeadlineUrgency.warning':
        return RC.gold;
      default:
        return RC.navy;
    }
  }
}

class _MetaData extends StatelessWidget {
  final String? hearingTitle;
  final String? courtName;

  const _MetaData({
    required this.hearingTitle,
    required this.courtName,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTitle =
        hearingTitle != null && hearingTitle!.trim().isNotEmpty;
    final bool hasCourt = courtName != null && courtName!.trim().isNotEmpty;

    // If both are missing, render nothing (avoids empty spaces)
    if (!hasTitle && !hasCourt) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTitle)
            Flexible(
              flex: 2,
              child: Text(
                hearingTitle!,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: RC.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Dot Separator
          if (hasTitle && hasCourt)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: RC.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          if (hasCourt) ...[
            Icon(
              Icons.location_on_outlined,
              size: 11.5.sp,
              color: RC.textTertiary,
            ),
            SizedBox(width: 2.w),
            Flexible(
              flex: 3,
              child: Text(
                courtName!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: RC.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. WEEK STRIP — Background highlight so it separates from scaffold
// ═════════════════════════════════════════════════════════════════════════════

class _WeekStrip extends StatelessWidget {
  final AgendaViewModel viewModel;
  const _WeekStrip({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final overview = viewModel.weekOverview();
    final flaggedCount =
        overview.where((d) => d.conflictLevel != 'none').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'THIS WEEK'),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: RC.navy.withValues(alpha: 0.069),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: RC.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (i) => _DayPill(day: overview[i], isToday: i == 0),
                ),
              ),
              if (flaggedCount > 0) ...[
                SizedBox(height: 10.h),
                Text(
                  flaggedCount == 1
                      ? '1 day this week needs a closer look — tap it above.'
                      : '$flaggedCount days this week need a closer look — tap one above.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: RC.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  final DayOverview day;
  final bool isToday;

  const _DayPill({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    Color dotColor;
    switch (day.conflictLevel) {
      case 'hard':
        dotColor = RC.danger;
      case 'soft':
        dotColor = RC.gold;
      default:
        dotColor = day.hasHearings
            ? RC.navy.withValues(alpha: 0.7)
            : Colors.transparent;
    }

    return GestureDetector(
      onTap: () => _goToDate(context),
      child: Column(
        children: [
          Text(
            labels[day.date.weekday - 1],
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isToday ? RC.navy : RC.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isToday ? RC.navy : RC.surface.withValues(alpha: 0.69),
              shape: BoxShape.circle,
              border: !isToday
                  ? Border.all(
                      color: RC.divider.withValues(alpha: 0.6),
                      width: 0.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.date.day}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isToday ? Colors.white : RC.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: dotColor == Colors.transparent ? 0 : 5.w,
            height: dotColor == Colors.transparent ? 0 : 5.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  void _goToDate(BuildContext context) {
    try {
      final calendarVM = context.read<CalendarViewModel>();
      calendarVM.goToMonth(day.date);
      calendarVM.selectDay(day.date);
    } catch (_) {
      // CalendarViewModel not reachable — still navigate
    }
    context.pushNamed(RoutesName.calendarScreen);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. EDGE CARDS — Urgency-differentiated: critical = filled + accent bar
// ═════════════════════════════════════════════════════════════════════════════

class _EdgeCard extends StatelessWidget {
  final dynamic hearing; // TodayHearingModel
  final bool isLast;

  const _EdgeCard({required this.hearing, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final int days = hearing.daysUntilHearing ?? 99;
    final bool isToday = days == 0;
    final bool isTomorrow = days == 1;
    final bool isCritical = isToday || isTomorrow;
    final bool isWarning = days <= 3 && !isCritical;

    final Color accent = isToday
        ? RC.danger
        : isTomorrow
            ? RC.gold
            : isWarning
                ? RC.navy.withValues(alpha: 0.7)
                : RC.navy.withValues(alpha: 0.5);

    final String badge = isToday
        ? 'TODAY'
        : isTomorrow
            ? 'TOMORROW'
            : 'IN $days DAYS';

    final bool hasHard = hearing.hasHardConflict as bool? ?? false;
    final bool hasSoft = hearing.hasSoftConflict as bool? ?? false;
    final String? time = hearing.formattedTime;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 8.h,
      ), // Tighter bottom margin
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isCritical
            ? (isToday
                ? RC.dangerSurface.withValues(alpha: 0.35)
                : RC.warningSurface)
            : RC.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isCritical
              ? (isToday
                  ? RC.dangerBorder.withValues(alpha: 0.5)
                  : RC.warning.withValues(alpha: 0.3))
              : RC.divider.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: isCritical ? [] : [RC.cardShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LEFT ACCENT BAR - Thinner for compact mode
            if (isCritical)
              Container(
                width: 3.w,
                color: accent,
              ),

            // MAIN CONTENT AREA - Aggressively reduced padding
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Hugs content tightly
                  children: [
                    // --- HEADER ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h), // Micro padding
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 8.5.sp, // Reduced
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (time != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule,
                                  size: 10.sp, color: RC.textTertiary),
                              SizedBox(width: 4.w),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 10.sp, // Reduced
                                  fontWeight: FontWeight.w600,
                                  color: RC.textSecondary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h), // 50% smaller spacer

                    // --- CONTENT BLOCK ---
                    Text(
                      hearing.caseTitle ?? 'Untitled matter',
                      style: TextStyle(
                        fontSize: 13.sp, // Scaled down
                        fontWeight: FontWeight.w600,
                        color: isToday ? RC.dangerText : RC.textPrimary,
                        height: 1.15, // Tighter line height
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h), // Micro spacer
                    Text(
                      hearing.title ?? '',
                      style: TextStyle(
                        fontSize: 11.5.sp, // Scaled down
                        color: RC.textSecondary,
                        height: 1.2,
                      ),
                      maxLines: 1, // STRICTLY 1 line to save vertical space
                      overflow: TextOverflow.ellipsis,
                    ),

                    // --- CONFLICT WARNINGS ---
                    if (hasHard || hasSoft) ...[
                      SizedBox(height: 5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: hasHard
                              ? RC.dangerSurface.withValues(alpha: 0.5)
                              : RC.warningSurface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: hasHard
                                ? RC.danger.withValues(alpha: 0.2)
                                : RC.gold.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasHard
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline_rounded,
                              size: 12.sp, // Smaller icon
                              color: hasHard ? RC.danger : RC.gold,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                hasHard
                                    ? 'Overlapping hearing time'
                                    : 'Timing unconfirmed — possible conflict', // Shortened copy
                                style: TextStyle(
                                  fontSize: 10.sp, // Smaller warning text
                                  fontWeight: FontWeight.w600,
                                  color:
                                      hasHard ? RC.dangerText : RC.warningText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 5. EMPTY STATE — Centered, no extra horizontal padding (parent handles it)
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Text(
            '${now.day}',
            style: TextStyle(
              fontSize: 72.sp,
              fontWeight: FontWeight.w200,
              color: RC.textTertiary.withValues(alpha: 0.25),
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            weekdays[now.weekday - 1],
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${months[now.month - 1]} ${now.year}',
            style: TextStyle(
              fontSize: 14.sp,
              color: RC.textSecondary,
            ),
          ),
          SizedBox(height: 36.h),
          Container(
            width: 40.w,
            height: 0.5,
            color: RC.divider,
          ),
          SizedBox(height: 36.h),
          Text(
            'Your docket is clear',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: RC.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'No hearings or deadlines require attention.',
            style: TextStyle(
              fontSize: 14.sp,
              color: RC.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GhostButton(
                label: 'View Cases',
                onTap: () => context.pushNamed(RoutesName.casesListScreen),
              ),
              SizedBox(width: 12.w),
              _GhostButton(
                label: 'Calendar',
                onTap: () => context.pushNamed(RoutesName.calendarScreen),
              ),
            ],
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: RC.divider.withValues(alpha: 0.8),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: RC.navy,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 6. SKELETON — Mirrors the actual layout exactly, no extra padding
// ═════════════════════════════════════════════════════════════════════════════
class _ChronicleSkeleton extends StatelessWidget {
  const _ChronicleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _SkeletonLine(height: 11, width: 50),
          SizedBox(height: 4.h),
          Divider(height: 0.5, color: RC.divider.withValues(alpha: 0.3)),
          SizedBox(height: 12.h),
          const _SkeletonHearingRow(),
          SizedBox(height: 14.h),
          const _SkeletonHearingRow(),
          SizedBox(height: 28.h),
          _SkeletonLine(height: 11.h, width: 70.w),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (_) => Column(
                children: [
                  _SkeletonLine(height: 10, width: 10),
                  SizedBox(height: 6.h),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: RC.textTertiary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 28.h),
          _SkeletonLine(height: 11.h, width: 80.w),
          SizedBox(height: 10.h),
          const _SkeletonEdgeRow(),
          SizedBox(height: 12.h),
          const _SkeletonEdgeRow(),
        ],
      ),
    );
  }
}

class _SkeletonHearingRow extends StatelessWidget {
  const _SkeletonHearingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonLine(height: 14.h, width: 42.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonLine(height: 16.h, width: double.infinity),
              SizedBox(height: 6.h),
              _SkeletonLine(height: 12.h, width: 140.w),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonEdgeRow extends StatelessWidget {
  const _SkeletonEdgeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: RC.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonLine(height: 15, width: double.infinity),
              SizedBox(height: 6.h),
              _SkeletonLine(height: 11.h, width: 100.w),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double height;
  final double? width;

  const _SkeletonLine({required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: width == double.infinity ? double.infinity : (width?.w),
      decoration: BoxDecoration(
        color: RC.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 7. SHARED HELPERS
// ═════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: RC.textTertiary,
            letterSpacing: 1.3,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 0.5,
          color: RC.divider.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
