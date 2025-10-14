/// ✅ Root model for a Case (matches `CasePublic`)
class CaseModel {
  final String id;
  final String caseNumber;
  final DateTime registrationDate;
  final String? courtName;
  final String? judgeName;
  final String firstPartyId;
  final String secondPartyId;
  final String? oppositePartyName;
  final String courtCategoryId;
  final String caseTypeId;
  final String caseStageId;
  final String caseStatusId;
  final String? caseNotes;
  final List<dynamic>? relatedFiles;
  final double? legalFees;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  final CourtCategoryModel? courtCategory;
  final CaseTypeModel? caseType;
  final CaseStageModel? caseStage;
  final CaseStatusModel? caseStatus;
  final List<CaseFileModel>? files;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.registrationDate,
    this.courtName,
    this.judgeName,
    required this.firstPartyId,
    required this.secondPartyId,
    this.oppositePartyName,
    required this.courtCategoryId,
    required this.caseTypeId,
    required this.caseStageId,
    required this.caseStatusId,
    this.caseNotes,
    this.relatedFiles,
    this.legalFees,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
    this.courtCategory,
    this.caseType,
    this.caseStage,
    this.caseStatus,
    this.files,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json["id"],
      caseNumber: json["case_number"],
      registrationDate: DateTime.parse(json["registration_date"]),
      courtName: json["court_name"],
      judgeName: json["judge_name"],
      firstPartyId: json["first_party_id"],
      secondPartyId: json["second_party_id"],
      oppositePartyName: json["opposite_party_name"],
      courtCategoryId: json["court_category_id"],
      caseTypeId: json["case_type_id"],
      caseStageId: json["case_stage_id"],
      caseStatusId: json["case_status_id"],
      caseNotes: json["case_notes"],
      relatedFiles: json["related_files"],
      legalFees: (json["legal_fees"] != null)
          ? (json["legal_fees"] as num).toDouble()
          : null,
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
      archivedAt: json["archived_at"] != null
          ? DateTime.parse(json["archived_at"])
          : null,
      courtCategory: json["court_category"] != null
          ? CourtCategoryModel.fromJson(json["court_category"])
          : null,
      caseType: json["case_type"] != null
          ? CaseTypeModel.fromJson(json["case_type"])
          : null,
      caseStage: json["case_stage"] != null
          ? CaseStageModel.fromJson(json["case_stage"])
          : null,
      caseStatus: json["case_status"] != null
          ? CaseStatusModel.fromJson(json["case_status"])
          : null,
      files: json["files"] != null
          ? List<CaseFileModel>.from(
              json["files"].map((x) => CaseFileModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "case_number": caseNumber,
        "registration_date": registrationDate.toIso8601String(),
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "archived_at": archivedAt?.toIso8601String(),
        "court_category": courtCategory?.toJson(),
        "case_type": caseType?.toJson(),
        "case_stage": caseStage?.toJson(),
        "case_status": caseStatus?.toJson(),
        "files": files?.map((x) => x.toJson()).toList(),
      };

  static List<CaseModel> listFromJson(List<dynamic> data) =>
      data.map((e) => CaseModel.fromJson(e)).toList();
}

/// ✅ Court Category
class CourtCategoryModel {
  final String id;
  final String name;
  final String? parentId;
  final List<CourtCategoryModel>? subcategories;

  CourtCategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.subcategories,
  });

  factory CourtCategoryModel.fromJson(Map<String, dynamic> json) =>
      CourtCategoryModel(
        id: json["id"],
        name: json["name"],
        parentId: json["parent_id"],
        subcategories: json["subcategories"] != null
            ? List<CourtCategoryModel>.from(json["subcategories"]
                .map((x) => CourtCategoryModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "parent_id": parentId,
        "subcategories": subcategories?.map((x) => x.toJson()).toList(),
      };
}

/// ✅ Case Type
class CaseTypeModel {
  final String id;
  final String name;

  CaseTypeModel({required this.id, required this.name});

  factory CaseTypeModel.fromJson(Map<String, dynamic> json) =>
      CaseTypeModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

/// ✅ Case Stage
class CaseStageModel {
  final String id;
  final String name;

  CaseStageModel({required this.id, required this.name});

  factory CaseStageModel.fromJson(Map<String, dynamic> json) =>
      CaseStageModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

/// ✅ Case Status
class CaseStatusModel {
  final String id;
  final String name;

  CaseStatusModel({required this.id, required this.name});

  factory CaseStatusModel.fromJson(Map<String, dynamic> json) =>
      CaseStatusModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

/// ✅ Case File
class CaseFileModel {
  final String id;
  final String caseId;
  final String filename;
  final String fileUrl;
  final DateTime uploadedAt;

  CaseFileModel({
    required this.id,
    required this.caseId,
    required this.filename,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory CaseFileModel.fromJson(Map<String, dynamic> json) => CaseFileModel(
        id: json["id"],
        caseId: json["case_id"],
        filename: json["filename"],
        fileUrl: json["file_url"],
        uploadedAt: DateTime.parse(json["uploaded_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "case_id": caseId,
        "filename": filename,
        "file_url": fileUrl,
        "uploaded_at": uploadedAt.toIso8601String(),
      };
}
