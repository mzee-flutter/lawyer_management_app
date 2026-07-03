// lib/models/case_models/hearing_models.dart

class HearingPublicModel {
  final String id;
  final String caseId;
  final String title;
  final DateTime hearingDateTime;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── NEW: adjournment fields ──────────────────────────────
  final String? adjournmentReason;
  final DateTime? adjournmentDate;
  // ────────────────────────────────────────────────────────

  const HearingPublicModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.hearingDateTime,
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
      hearingDateTime: DateTime.parse(json['hearing_datetime'] as String),
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // ── NEW ─────────────────────────────────────────────
      adjournmentReason: json['adjournment_reason'] as String?,
      adjournmentDate: json['adjournment_date'] != null
          ? DateTime.parse(json['adjournment_date'] as String)
          : null,
      // ────────────────────────────────────────────────────
    );
  }

  // ── Display helpers ──────────────────────────────────────
  bool get isAdjourned => status.toLowerCase() == 'adjourned';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

// ─────────────────────────────────────────────────────────────
// HearingCreateModel — used for POST /hearings only
// No adjournment fields — hearings always start as "scheduled"
// ─────────────────────────────────────────────────────────────
class HearingCreateModel {
  final String title;
  final DateTime hearingDateTime;
  final String? notes;

  const HearingCreateModel({
    required this.title,
    required this.hearingDateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hearing_datetime': hearingDateTime.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }
}

// ─────────────────────────────────────────────────────────────
// HearingUpdateModel — used for PATCH /hearings/{id}
// Separate from HearingCreateModel because update has more fields.
// All fields are optional — only send what changed.
// ─────────────────────────────────────────────────────────────
class HearingUpdateModel {
  final String? title;
  final DateTime? hearingDateTime;
  final String? notes;
  final String? status;

  // Only populated when status = "adjourned"
  final String? adjournmentReason;
  final DateTime? adjournmentDate; // auto-set to today by backend if null

  const HearingUpdateModel({
    this.title,
    this.hearingDateTime,
    this.notes,
    this.status,
    this.adjournmentReason,
    this.adjournmentDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (hearingDateTime != null)
        'hearing_datetime': hearingDateTime!.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (adjournmentReason != null) 'adjournment_reason': adjournmentReason,
      // adjournment_date intentionally omitted — backend auto-stamps today
      // Only send it if the lawyer manually picked a different date
      if (adjournmentDate != null)
        'adjournment_date': '${adjournmentDate!.year}-'
            '${adjournmentDate!.month.toString().padLeft(2, '0')}-'
            '${adjournmentDate!.day.toString().padLeft(2, '0')}',
    };
  }
}
