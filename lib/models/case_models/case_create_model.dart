class CaseCreateModel {
  final String caseNumber;
  final DateTime registrationDate;

  final String? courtName;
  final String? judgeName;

  final String firstPartyName;
  final String oppositePartyName;

  final String courtCategoryId;
  final String caseTypeId;
  final String caseStageId;
  final String caseStatusId;

  final String? caseNotes;
  final List<dynamic>? relatedFiles;
  final double? legalFees;
  final String? status;

  CaseCreateModel({
    required this.caseNumber,
    required this.registrationDate,
    this.courtName,
    this.judgeName,
    required this.firstPartyName,
    required this.oppositePartyName,
    required this.courtCategoryId,
    required this.caseTypeId,
    required this.caseStageId,
    required this.caseStatusId,
    this.caseNotes,
    this.relatedFiles,
    this.legalFees,
    this.status = "active",
  });

  Map<String, dynamic> toJson() {
    return {
      "case_number": caseNumber,
      "registration_date": registrationDate.toIso8601String(),
      "court_name": courtName,
      "judge_name": judgeName,
      "first_party_name": firstPartyName,
      "opposite_party_name": oppositePartyName,
      "court_category_id": courtCategoryId,
      "case_type_id": caseTypeId,
      "case_stage_id": caseStageId,
      "case_status_id": caseStatusId,
      "case_notes": caseNotes,
      "related_files": relatedFiles,
      "legal_fees": legalFees,
      "status": status,
    };
  }
}
