import 'package:right_case/models/client_models/client_model.dart';

class CaseModel {
  final String id;
  final String caseNumber;
  final DateTime registrationDate;
  final String? courtName;
  final String? judgeName;

  final String firstPartyName;
  final String? oppositePartyName;

  final String courtCategoryId;
  final String caseTypeId;
  final String caseStageId;
  final String caseStatusId;

  final String? caseNotes;
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
  final List<RelatedClientModel>? relatedClients;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.registrationDate,
    this.courtName,
    this.judgeName,
    required this.firstPartyName,
    this.oppositePartyName,
    required this.courtCategoryId,
    required this.caseTypeId,
    required this.caseStageId,
    required this.caseStatusId,
    this.caseNotes,
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
    this.relatedClients,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json["id"],
      caseNumber: json["case_number"],
      registrationDate: DateTime.parse(json["registration_date"]),
      courtName: json["court_name"],
      judgeName: json["judge_name"],
      firstPartyName: json["first_party_name"],
      oppositePartyName: json["opposite_party_name"],
      courtCategoryId: json["court_category_id"],
      caseTypeId: json["case_type_id"],
      caseStageId: json["case_stage_id"],
      caseStatusId: json["case_status_id"],
      caseNotes: json["case_notes"],
      legalFees: json["legal_fees"] != null
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
      relatedClients: json["related_clients"] != null
          ? List<RelatedClientModel>.from(json["related_clients"]
              .map((x) => RelatedClientModel.fromJson(x)))
          : null,
    );
  }
  CaseModel copyWith({
    String? id,
    String? caseNumber,
    DateTime? registrationDate,
    String? courtName,
    String? judgeName,
    String? firstPartyName,
    String? oppositePartyName,
    String? courtCategoryId,
    String? caseTypeId,
    String? caseStageId,
    String? caseStatusId,
    String? caseNotes,
    double? legalFees,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    CourtCategoryModel? courtCategory,
    CaseTypeModel? caseType,
    CaseStageModel? caseStage,
    CaseStatusModel? caseStatus,
    List<CaseFileModel>? files,
    List<RelatedClientModel>? relatedClients,
  }) {
    return CaseModel(
      id: id ?? this.id,
      caseNumber: caseNumber ?? this.caseNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      courtName: courtName ?? this.courtName,
      judgeName: judgeName ?? this.judgeName,
      firstPartyName: firstPartyName ?? this.firstPartyName,
      oppositePartyName: oppositePartyName ?? this.oppositePartyName,
      courtCategoryId: courtCategoryId ?? this.courtCategoryId,
      caseTypeId: caseTypeId ?? this.caseTypeId,
      caseStageId: caseStageId ?? this.caseStageId,
      caseStatusId: caseStatusId ?? this.caseStatusId,
      caseNotes: caseNotes ?? this.caseNotes,
      legalFees: legalFees ?? this.legalFees,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      courtCategory: courtCategory ?? this.courtCategory,
      caseType: caseType ?? this.caseType,
      caseStage: caseStage ?? this.caseStage,
      caseStatus: caseStatus ?? this.caseStatus,
      files: files ?? this.files,
      relatedClients: relatedClients ?? this.relatedClients,
    );
  }
}

///--------------------------
class RelatedClientModel {
  final String id;
  final ClientModel client;
  final String role;
  final bool isSynced;

  RelatedClientModel({
    required this.id,
    required this.client,
    required this.role,
    required this.isSynced,
  });

  factory RelatedClientModel.fromJson(Map<String, dynamic> json) {
    return RelatedClientModel(
      id: json["id"],
      client: ClientModel.fromJson(json["client"]),
      role: json["role"],
      isSynced: true, // server data is ALWAYS synced
    );
  }

  RelatedClientModel copyWith({
    String? id,
    ClientModel? client,
    String? role,
    bool? isSynced,
  }) {
    return RelatedClientModel(
      id: id ?? this.id,
      client: client ?? this.client,
      role: role ?? this.role,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class RelatedClientRequestModel {
  final String clientId;
  final String role;
  RelatedClientRequestModel({
    required this.clientId,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "role": role,
      };
}

///----------------------------------
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

class CaseTypeModel {
  final String id;
  final String name;

  CaseTypeModel({required this.id, required this.name});

  factory CaseTypeModel.fromJson(Map<String, dynamic> json) =>
      CaseTypeModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class CaseStageModel {
  final String id;
  final String name;

  CaseStageModel({required this.id, required this.name});

  factory CaseStageModel.fromJson(Map<String, dynamic> json) =>
      CaseStageModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class CaseStatusModel {
  final String id;
  final String name;

  CaseStatusModel({required this.id, required this.name});

  factory CaseStatusModel.fromJson(Map<String, dynamic> json) =>
      CaseStatusModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

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
