// lib/models/court_portal/court_portal_models.dart
//
// Maps 1:1 to backend schemas in court_portal_schemas.py
// All display helpers live here — ViewModels and widgets stay dumb.

// ─────────────────────────────────────────────
// Status enum — drives stepper colours
// ─────────────────────────────────────────────
enum CopyStatus { applied, processing, ready }

extension CopyStatusX on CopyStatus {
  String get label {
    switch (this) {
      case CopyStatus.applied:
        return 'Applied';
      case CopyStatus.processing:
        return 'Processing';
      case CopyStatus.ready:
        return 'Ready';
    }
  }

  /// Next valid status in the state machine — null if terminal
  CopyStatus? get next {
    switch (this) {
      case CopyStatus.applied:
        return CopyStatus.processing;
      case CopyStatus.processing:
        return CopyStatus.ready;
      case CopyStatus.ready:
        return null;
    }
  }

  static CopyStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'processing':
        return CopyStatus.processing;
      case 'ready':
        return CopyStatus.ready;
      default:
        return CopyStatus.applied;
    }
  }
}

// ─────────────────────────────────────────────
// Certified Copy — maps to CertifiedCopyPublic
// ─────────────────────────────────────────────
class CertifiedCopyModel {
  final String id;
  final String caseId;
  final String referenceNumber;
  final String? description;
  final CopyStatus status;

  final DateTime? appliedAt;
  final DateTime? processingAt;
  final DateTime? readyAt;

  final DateTime createdAt;
  final DateTime? updatedAt;

  // Denormalised from Case
  final String caseNumber;
  final String firstPartyName;
  final String? oppositePartyName;
  final String? courtName;

  const CertifiedCopyModel({
    required this.id,
    required this.caseId,
    required this.referenceNumber,
    this.description,
    required this.status,
    this.appliedAt,
    this.processingAt,
    this.readyAt,
    required this.createdAt,
    this.updatedAt,
    required this.caseNumber,
    required this.firstPartyName,
    this.oppositePartyName,
    this.courtName,
  });

  factory CertifiedCopyModel.fromJson(Map<String, dynamic> json) {
    return CertifiedCopyModel(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      referenceNumber: json['reference_number'] as String,
      description: json['description'] as String?,
      status: CopyStatusX.fromString(json['status'] as String),
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'] as String)
          : null,
      processingAt: json['processing_at'] != null
          ? DateTime.parse(json['processing_at'] as String)
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.parse(json['ready_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      caseNumber: json['case_number'] as String,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      courtName: json['court_name'] as String?,
    );
  }

  // ── Display helpers ──────────────────────────────────────────

  String get caseTitle {
    if (oppositePartyName != null && oppositePartyName!.isNotEmpty) {
      return '$firstPartyName vs. $oppositePartyName';
    }
    return firstPartyName;
  }

  /// Timestamp for the currently active stage
  DateTime? get currentStageTimestamp {
    switch (status) {
      case CopyStatus.applied:
        return appliedAt;
      case CopyStatus.processing:
        return processingAt;
      case CopyStatus.ready:
        return readyAt;
    }
  }

  /// True if this copy is in its terminal state
  bool get isComplete => status == CopyStatus.ready;

  /// True if user can advance this copy to the next stage
  bool get canAdvance => status.next != null;

  /// True if this copy can be deleted (only in applied state)
  bool get canDelete => status == CopyStatus.applied;

  String get formattedDate {
    final dt = createdAt;
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─────────────────────────────────────────────
// Roster models — maps to BenchRosterResponse
// ─────────────────────────────────────────────
class RosterCaseItem {
  final String caseId;
  final String caseNumber;
  final String firstPartyName;
  final String? oppositePartyName;
  final String? caseStageName;
  final DateTime? nextHearingAt;

  const RosterCaseItem({
    required this.caseId,
    required this.caseNumber,
    required this.firstPartyName,
    this.oppositePartyName,
    this.caseStageName,
    this.nextHearingAt,
  });

  factory RosterCaseItem.fromJson(Map<String, dynamic> json) {
    return RosterCaseItem(
      caseId: json['case_id'] as String,
      caseNumber: json['case_number'] as String,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      caseStageName: json['case_stage_name'] as String?,
      nextHearingAt: json['next_hearing_at'] != null
          ? DateTime.parse(json['next_hearing_at'] as String)
          : null,
    );
  }

  String get caseTitle {
    if (oppositePartyName != null && oppositePartyName!.isNotEmpty) {
      return '$firstPartyName vs. $oppositePartyName';
    }
    return firstPartyName;
  }

  String? get formattedNextHearing {
    if (nextHearingAt == null) return null;
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
    final h = nextHearingAt!.hour;
    final m = nextHearingAt!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '${nextHearingAt!.day} ${months[nextHearingAt!.month - 1]} · $displayH:$m $period';
  }
}

class BenchCardModel {
  final String courtName;
  final String? judgeName;
  final int caseCount;
  final List<RosterCaseItem> cases;

  const BenchCardModel({
    required this.courtName,
    this.judgeName,
    required this.caseCount,
    required this.cases,
  });

  factory BenchCardModel.fromJson(Map<String, dynamic> json) {
    return BenchCardModel(
      courtName: json['court_name'] as String,
      judgeName: json['judge_name'] as String?,
      caseCount: json['case_count'] as int,
      cases: (json['cases'] as List<dynamic>)
          .map((c) => RosterCaseItem.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasJudge => judgeName != null && judgeName!.isNotEmpty;
}

class BenchRosterModel {
  final List<BenchCardModel> benches;
  final int totalCases;

  const BenchRosterModel({
    required this.benches,
    required this.totalCases,
  });

  factory BenchRosterModel.fromJson(Map<String, dynamic> json) {
    return BenchRosterModel(
      benches: (json['benches'] as List<dynamic>)
          .map((b) => BenchCardModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      totalCases: json['total_cases'] as int,
    );
  }
}
