// lib/models/case_models/hearing_models.dart

class HearingPublicModel {
  final String id;
  final String caseId;
  final String title;
  final DateTime hearingDateTime;
  final bool hasSpecificTime;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? adjournmentReason;
  final DateTime? adjournmentDate;

  const HearingPublicModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.hearingDateTime,
    required this.hasSpecificTime,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adjournmentReason,
    this.adjournmentDate,
  });

  factory HearingPublicModel.fromJson(Map<String, dynamic> json) {
    return HearingPublicModel(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      title: json['title'] as String,
      hearingDateTime:
          DateTime.parse(json['hearing_datetime'] as String).toLocal(),
      // Defaults to false if the backend hasn't been migrated yet, so this
      // stays backward-compatible until the column is added server-side.
      hasSpecificTime: json['has_specific_time'] as bool? ?? false,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
      adjournmentReason: json['adjournment_reason'] as String?,
      adjournmentDate: json['adjournment_date'] != null
          ? DateTime.parse(json['adjournment_date'] as String)
          : null,
    );
  }

  bool get isAdjourned => status.toLowerCase() == 'adjourned';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Human-readable date, with a clock time only if one was actually given.
  /// e.g. "21 Jul" or "21 Jul, 2:00 PM" — never a fabricated time.
  String get displayLabel {
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
    final datePart =
        '${hearingDateTime.day} ${months[hearingDateTime.month - 1]}';
    if (!hasSpecificTime) return datePart;

    final h = hearingDateTime.hour;
    final m = hearingDateTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$datePart, $displayH:$m $period';
  }
}

// ─────────────────────────────────────────────────────────────
// HearingCreateModel — used for POST /hearings only
// ─────────────────────────────────────────────────────────────
class HearingCreateModel {
  final String title;
  final DateTime hearingDateTime;

  /// True only if the lawyer explicitly picked a time in addition to the
  /// date. Most hearings are cause-list entries with a date only — this
  /// defaults to false, matching that reality. When false, the backend
  /// anchors the hearing to a fixed default local time itself; whatever
  /// time-of-day is attached to [hearingDateTime] here is ignored server
  /// side, so it's safe to leave it as midnight or whatever the date
  /// picker naturally produces.
  final bool hasSpecificTime;
  final String? notes;

  const HearingCreateModel({
    required this.title,
    required this.hearingDateTime,
    this.hasSpecificTime = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hearing_datetime': hearingDateTime.toUtc().toIso8601String(),
      'has_specific_time': hasSpecificTime,
      if (notes != null) 'notes': notes,
    };
  }
}

// ─────────────────────────────────────────────────────────────
// HearingUpdateModel — used for PATCH /hearings/{id}
// ─────────────────────────────────────────────────────────────
class HearingUpdateModel {
  final String? title;
  final DateTime? hearingDateTime;
  final bool? hasSpecificTime;
  final String? notes;
  final String? status;
  final String? adjournmentReason;
  final DateTime? adjournmentDate;

  const HearingUpdateModel({
    this.title,
    this.hearingDateTime,
    this.hasSpecificTime,
    this.notes,
    this.status,
    this.adjournmentReason,
    this.adjournmentDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (hearingDateTime != null)
        'hearing_datetime': hearingDateTime!.toUtc().toIso8601String(),
      if (hasSpecificTime != null) 'has_specific_time': hasSpecificTime,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (adjournmentReason != null) 'adjournment_reason': adjournmentReason,
      if (adjournmentDate != null)
        'adjournment_date': '${adjournmentDate!.year}-'
            '${adjournmentDate!.month.toString().padLeft(2, '0')}-'
            '${adjournmentDate!.day.toString().padLeft(2, '0')}',
    };
  }
}
