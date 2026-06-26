class NotificationPayload {
  final String caseId;
  final String? hearingId;

  NotificationPayload({
    required this.caseId,
    this.hearingId,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      caseId: (map['caseId'] ?? map['case_id'] ?? '').toString(),
      hearingId: map['hearingId']?.toString() ?? map['hearing_id']?.toString(),
    );
  }
}
