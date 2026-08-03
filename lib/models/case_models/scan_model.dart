// lib/models/case_models/scan_models.dart

class ScanCaseCandidateModel {
  final String caseId;
  final String caseNumber;
  final String firstPartyName;
  final String? oppositePartyName;
  final double matchScore;

  const ScanCaseCandidateModel({
    required this.caseId,
    required this.caseNumber,
    required this.firstPartyName,
    this.oppositePartyName,
    required this.matchScore,
  });

  factory ScanCaseCandidateModel.fromJson(Map<String, dynamic> json) {
    return ScanCaseCandidateModel(
      caseId: json['case_id'] as String,
      caseNumber: json['case_number'] as String,
      firstPartyName: json['first_party_name'] as String,
      oppositePartyName: json['opposite_party_name'] as String?,
      matchScore: (json['match_score'] as num).toDouble(),
    );
  }

  /// "Kamran Khan vs Tariq Mehmood" — falls back gracefully if the
  /// opposite party wasn't recorded on the case.
  String get displayTitle => '$firstPartyName vs ${oppositePartyName ?? "—"}';
}

class ScanExtractionModel {
  final String scanId;

  final String? extractedCaseNumber;
  final String? extractedCaseTitle;
  final String? extractedCourtName;
  final String? extractedJudgeName;
  final String? extractedHearingDate; // "YYYY-MM-DD"
  final String? extractedHearingTime; // "HH:MM" or null
  final String extractionConfidence; // high | medium | low

  final String matchStatus; // matched | ambiguous | unmatched
  final ScanCaseCandidateModel? matchedCase;
  final List<ScanCaseCandidateModel> candidateCases;

  final String imageUrl;

  const ScanExtractionModel({
    required this.scanId,
    this.extractedCaseNumber,
    this.extractedCaseTitle,
    this.extractedCourtName,
    this.extractedJudgeName,
    this.extractedHearingDate,
    this.extractedHearingTime,
    required this.extractionConfidence,
    required this.matchStatus,
    this.matchedCase,
    this.candidateCases = const [],
    required this.imageUrl,
  });

  factory ScanExtractionModel.fromJson(Map<String, dynamic> json) {
    return ScanExtractionModel(
      scanId: json['scan_id'] as String,
      extractedCaseNumber: json['extracted_case_number'] as String?,
      extractedCaseTitle: json['extracted_case_title'] as String?,
      extractedCourtName: json['extracted_court_name'] as String?,
      extractedJudgeName: json['extracted_judge_name'] as String?,
      extractedHearingDate: json['extracted_hearing_date'] as String?,
      extractedHearingTime: json['extracted_hearing_time'] as String?,
      extractionConfidence: json['extraction_confidence'] as String? ?? 'low',
      matchStatus: json['match_status'] as String? ?? 'unmatched',
      matchedCase: json['matched_case'] != null
          ? ScanCaseCandidateModel.fromJson(
              json['matched_case'] as Map<String, dynamic>)
          : null,
      candidateCases: (json['candidate_cases'] as List<dynamic>? ?? [])
          .map(
              (e) => ScanCaseCandidateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image_url'] as String,
    );
  }

  bool get isHighConfidence => extractionConfidence == 'high';
  bool get isLowConfidence => extractionConfidence == 'low';
}
