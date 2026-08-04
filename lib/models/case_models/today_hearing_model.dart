enum DeadlineUrgency {
  overdue, // days_until_hearing < 0
  critical, // 0 or 1 day left
  warning, // 2–3 days left
  upcoming, // 4–7 days left
  normal, // > 7 days
}

class TodayHearingModel {
  final String id;
  final String caseId;
  final String title;
  final DateTime hearingDateTime;
  final bool hasSpecificTime;
  // "none" | "soft" | "hard" — computed server-side per calendar day, not
  // per hearing in isolation. See HearingService._classify_day.
  final String conflictLevel;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? courtName;
  final String? judgeName;
  final String firstPartyName;
  final String? oppositePartyName;
  final String? caseStageName;
  final String caseNumber;

  // Computed by the server — days from today to the hearing
  final int daysUntilHearing;

  const TodayHearingModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.hearingDateTime,
    required this.hasSpecificTime,
    required this.conflictLevel,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.courtName,
    this.judgeName,
    required this.firstPartyName,
    this.oppositePartyName,
    this.caseStageName,
    required this.caseNumber,
    required this.daysUntilHearing,
  });

  factory TodayHearingModel.fromJson(Map<String, dynamic> json) {
    return TodayHearingModel(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      title: json['title'] as String,
      hearingDateTime:
          DateTime.parse(json['hearing_datetime'] as String).toLocal(),
      hasSpecificTime: json['has_specific_time'] as bool? ?? false,
      conflictLevel: json['conflict_level'] as String? ?? 'none',
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
      courtName: json['court_name'] as String?,
      judgeName: json['judge_name'] as String?,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      caseStageName: json['case_stage_name'] as String? ?? " No Stage Assigned",
      caseNumber: json['case_number'] as String,
      daysUntilHearing: json['days_until_hearing'] as int,
    );
  }

  // ----------------------------------------------------------------
  // Computed helpers used directly by the ViewModel and widgets
  // ----------------------------------------------------------------

  /// Formatted time string for the docket/deadline card — e.g. "9:30 AM".
  /// Returns null when no specific time was given — most hearings are
  /// date-only cause-list entries, so the UI should omit a clock reading
  /// rather than show a fabricated default-anchor time.
  String? get formattedTime {
    if (!hasSpecificTime) return null;
    final hour = hearingDateTime.hour;
    final minute = hearingDateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  /// True if this hearing falls on a day flagged as a hard (physically
  /// double-booked) conflict.
  bool get hasHardConflict => conflictLevel == 'hard';

  /// True if this hearing falls on a day flagged as a soft (potential —
  /// untimed overlap or heavy same-day load) conflict.
  bool get hasSoftConflict => conflictLevel == 'soft';

  /// Display name for the agenda card — "Shah vs. State"
  String get caseTitle {
    if (oppositePartyName != null && oppositePartyName!.isNotEmpty) {
      return '$firstPartyName vs. $oppositePartyName';
    }
    return firstPartyName;
  }

  /// Human-readable deadline label for the countdown card
  /// e.g. "Today", "Tomorrow", "2 days left", "Overdue by 1 day"
  String get deadlineLabel {
    if (daysUntilHearing < 0) {
      final overdue = daysUntilHearing.abs();
      return 'Overdue by $overdue ${overdue == 1 ? 'day' : 'days'}';
    }
    if (daysUntilHearing == 0) return 'Today';
    if (daysUntilHearing == 1) return 'Tomorrow';
    return '$daysUntilHearing days left';
  }

  /// Urgency bucket — drives card colour in the UI
  DeadlineUrgency get urgency {
    if (daysUntilHearing < 0) return DeadlineUrgency.overdue;
    if (daysUntilHearing <= 1) return DeadlineUrgency.critical;
    if (daysUntilHearing <= 3) return DeadlineUrgency.warning;
    if (daysUntilHearing <= 7) return DeadlineUrgency.upcoming;
    return DeadlineUrgency.normal;
  }

  /// Whether this hearing qualifies as a deadline warning card
  /// (shown in the DEADLINES section of the dashboard)
  bool get isDeadlineCard => daysUntilHearing <= 3;
}
