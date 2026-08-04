class NotificationPayload {
  final String? messageId;
  final String caseId;
  final String? hearingId;

  const NotificationPayload({
    this.messageId,
    required this.caseId,
    this.hearingId,
  });

  /// Gate used before navigating — NOT used before storing to history,
  /// since a caseId-less push might still be worth keeping in the inbox.
  bool get isValid => caseId.isNotEmpty;

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      messageId: map['messageId']?.toString() ?? map['message_id']?.toString(),
      caseId: (map['caseId'] ?? map['case_id'] ?? '').toString(),
      hearingId: map['hearingId']?.toString() ?? map['hearing_id']?.toString(),
    );
  }
}
