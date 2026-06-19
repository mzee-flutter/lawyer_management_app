class HearingPublicModel {
  final String id;
  final String caseId;
  final String title;
  final DateTime hearingDateTime;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HearingPublicModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.hearingDateTime,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HearingPublicModel.fromJson(Map<String, dynamic> json) {
    return HearingPublicModel(
      id: json["id"] as String,
      caseId: json["case_id"] as String,
      title: json["title"] as String,
      hearingDateTime: DateTime.parse(json["hearing_datetime"]),
      notes: json["notes"],
      status: json["status"] as String,
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }
}

class HearingCreateModel {
  final String title;
  final DateTime hearingDateTime;
  final String? notes;
  final String? status;

  const HearingCreateModel({
    required this.title,
    required this.hearingDateTime,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "hearing_datetime": hearingDateTime.toIso8601String(),
      if (notes != null) "notes": notes,
      if (status != null) "status": status,
    };
  }
}
