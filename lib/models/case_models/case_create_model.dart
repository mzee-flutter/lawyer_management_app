class CaseCreateModel {
  String? caseNumber;
  DateTime? registrationDate;
  String? courtName;
  String? judgeName;
  String? firstPartyId;
  String? secondPartyId;
  String? oppositePartyName;
  String? courtCategoryId;
  String? caseTypeId;
  String? caseStageId;
  String? caseStatusId;
  String? caseNotes;
  List<dynamic>? relatedFiles;
  double? legalFees;
  String? status;

  CaseCreateModel({
    this.caseNumber,
    this.registrationDate,
    this.courtName,
    this.judgeName,
    this.firstPartyId,
    this.secondPartyId,
    this.oppositePartyName,
    this.courtCategoryId,
    this.caseTypeId,
    this.caseStageId,
    this.caseStatusId,
    this.caseNotes,
    this.relatedFiles,
    this.legalFees,
    this.status = "active",
  });

  Map<String, dynamic> toJson() {
    return {
      "case_number": caseNumber,
      "registration_date": registrationDate?.toIso8601String(),
      "court_name": courtName,
      "judge_name": judgeName,
      "first_party_id": firstPartyId,
      "second_party_id": secondPartyId,
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
