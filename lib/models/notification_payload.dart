class NotificationPayload {
  final String caseId;
  final String? hearingId;

  NotificationPayload({
    required this.caseId,
    this.hearingId,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      caseId: map['case_id'],
      hearingId: map['hearing_id'],
    );
  }
}
