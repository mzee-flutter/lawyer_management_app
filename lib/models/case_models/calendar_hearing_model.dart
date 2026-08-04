enum CalendarDayType {
  conflict, // red  — ≥2 scheduled hearings overlap
  hearing, // blue — normal scheduled hearing(s)
  adjourned, // amber — all/some hearings adjourned
  empty, // no hearings
}

class CalendarHearingItem {
  final String id;
  final String caseId;
  final String title;
  final DateTime hearingDateTime;
  final bool hasSpecificTime;
  final String status;
  final String? notes;
  final String? courtName;
  final String? judgeName;
  final String firstPartyName;
  final String? oppositePartyName;
  final String? caseStageName;
  final String caseNumber;

  const CalendarHearingItem({
    required this.id,
    required this.caseId,
    required this.title,
    required this.hearingDateTime,
    required this.hasSpecificTime,
    required this.status,
    this.notes,
    this.courtName,
    this.judgeName,
    required this.firstPartyName,
    this.oppositePartyName,
    this.caseStageName,
    required this.caseNumber,
  });

  factory CalendarHearingItem.fromJson(Map<String, dynamic> json) {
    return CalendarHearingItem(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      title: json['title'] as String,
      hearingDateTime:
          DateTime.parse(json['hearing_datetime'] as String).toLocal(),
      hasSpecificTime: json['has_specific_time'] as bool? ?? false,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      courtName: json['court_name'] as String?,
      judgeName: json['judge_name'] as String?,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      caseStageName: json['case_stage_name'] as String?,
      caseNumber: json['case_number'] as String,
    );
  }

  // ── Display helpers ─────────────────────────────────────────
  String get caseTitle {
    if (oppositePartyName != null && oppositePartyName!.isNotEmpty) {
      return '$firstPartyName vs. $oppositePartyName';
    }
    return firstPartyName;
  }

  /// Returns null when no specific time was given — most hearings are
  /// cause-list date entries, so the UI should show nothing rather than a
  /// fabricated clock reading. Widgets should check this before rendering
  /// a time chip/label.
  String? get formattedTime {
    if (!hasSpecificTime) return null;
    final h = hearingDateTime.hour;
    final m = hearingDateTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$displayH:$m $period';
  }

  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isAdjourned => status.toLowerCase() == 'adjourned';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
}

// ─────────────────────────────────────────────
// One day's data — maps to CalendarDayResponse
// ─────────────────────────────────────────────
class CalendarDayModel {
  final DateTime date;
  final List<CalendarHearingItem> hearings;
  final bool hasConflict;
  // True when the day carries a "soft" risk — an untimed overlap, or a
  // heavy same-day workload — but no hard time-overlap. Never true at the
  // same time as hasConflict; the backend classifier treats hard as
  // strictly higher priority for a given day.
  final bool hasSoftConflict;
  // Short human-readable reasons the day was flagged soft, e.g.
  // ["2 hearings without a specific time"]. Empty when not soft-flagged.
  final List<String> conflictReasons;
  final bool hasAdjourned;
  final int hearingCount;

  const CalendarDayModel({
    required this.date,
    required this.hearings,
    required this.hasConflict,
    required this.hasSoftConflict,
    required this.conflictReasons,
    required this.hasAdjourned,
    required this.hearingCount,
  });

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayModel(
      date: DateTime.parse(json['date'] as String),
      hearings: (json['hearings'] as List<dynamic>)
          .map((h) => CalendarHearingItem.fromJson(h as Map<String, dynamic>))
          .toList(),
      hasConflict: json['has_conflict'] as bool,
      hasSoftConflict: json['has_soft_conflict'] as bool? ?? false,
      conflictReasons: (json['conflict_reasons'] as List<dynamic>? ?? [])
          .map((r) => r as String)
          .toList(),
      hasAdjourned: json['has_adjourned'] as bool,
      hearingCount: json['hearing_count'] as int,
    );
  }

  // ── Computed display type ───────────────────────────────────
  // Priority: conflict > normal hearing > adjourned
  // Deliberately unchanged — soft conflicts are surfaced via the
  // dedicated fields above, not via a new dot colour, so the calendar
  // grid's visual language stays exactly as it was.
  CalendarDayType get dayType {
    if (hasConflict) return CalendarDayType.conflict;
    if (hearings.any((h) => h.isScheduled)) return CalendarDayType.hearing;
    if (hasAdjourned) return CalendarDayType.adjourned;
    return CalendarDayType.empty;
  }

  // Scheduled-only hearings — for the detail panel main list
  List<CalendarHearingItem> get scheduledHearings =>
      hearings.where((h) => h.isScheduled).toList();

  // Adjourned hearings — shown separately in detail panel
  List<CalendarHearingItem> get adjournedHearings =>
      hearings.where((h) => h.isAdjourned).toList();
}

// ─────────────────────────────────────────────
// Full month response — maps to CalendarMonthResponse
// ─────────────────────────────────────────────
class CalendarMonthModel {
  final int year;
  final int month;
  final List<CalendarDayModel> days;

  const CalendarMonthModel({
    required this.year,
    required this.month,
    required this.days,
  });

  factory CalendarMonthModel.fromJson(Map<String, dynamic> json) {
    return CalendarMonthModel(
      year: json['year'] as int,
      month: json['month'] as int,
      days: (json['days'] as List<dynamic>)
          .map((d) => CalendarDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Lookup helpers used by the ViewModel ───────────────────

  /// O(1) lookup of a day by date — ViewModel builds this map on load
  Map<DateTime, CalendarDayModel> get dayMap {
    return {
      for (final day in days)
        DateTime(day.date.year, day.date.month, day.date.day): day
    };
  }
}

// ─────────────────────────────────────────────
// Adjournment entry — maps to AdjournmentEntry
// ─────────────────────────────────────────────
class AdjournmentEntry {
  final String id;
  final String caseId;
  final String title;
  final DateTime? adjournmentDate;
  final String? adjournmentReason;
  final DateTime hearingDateTime;
  final DateTime? rescheduledTo;

  const AdjournmentEntry({
    required this.id,
    required this.caseId,
    required this.title,
    this.adjournmentDate,
    this.adjournmentReason,
    required this.hearingDateTime,
    this.rescheduledTo,
  });

  factory AdjournmentEntry.fromJson(Map<String, dynamic> json) {
    return AdjournmentEntry(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      title: json['title'] as String,
      adjournmentDate: json['adjournment_date'] != null
          ? DateTime.parse(json['adjournment_date'] as String).toLocal()
          : null,
      adjournmentReason: json['adjournment_reason'] as String?,
      hearingDateTime:
          DateTime.parse(json['hearing_datetime'] as String).toLocal(),
      rescheduledTo: json['rescheduled_to'] != null
          ? DateTime.parse(json['rescheduled_to'] as String).toLocal()
          : null,
    );
  }

  String get formattedDate {
    if (adjournmentDate == null) return 'Date unknown';
    const months = [
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
    return '${adjournmentDate!.day} ${months[adjournmentDate!.month - 1]} ${adjournmentDate!.year}';
  }
}

// ─────────────────────────────────────────────
// Adjournment history — maps to AdjournmentHistoryResponse
// ─────────────────────────────────────────────
class AdjournmentHistoryModel {
  final String caseId;
  final String caseNumber;
  final String firstPartyName;
  final String? oppositePartyName;
  final int totalAdjournments;
  final List<AdjournmentEntry> adjournments;

  const AdjournmentHistoryModel({
    required this.caseId,
    required this.caseNumber,
    required this.firstPartyName,
    this.oppositePartyName,
    required this.totalAdjournments,
    required this.adjournments,
  });

  factory AdjournmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return AdjournmentHistoryModel(
      caseId: json['case_id'] as String,
      caseNumber: json['case_number'] as String,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      totalAdjournments: json['total_adjournments'] as int,
      adjournments: (json['adjournments'] as List<dynamic>)
          .map((e) => AdjournmentEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get caseTitle {
    if (oppositePartyName != null && oppositePartyName!.isNotEmpty) {
      return '$firstPartyName vs. $oppositePartyName';
    }
    return firstPartyName;
  }
}
