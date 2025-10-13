class CaseModel {
  final String id;

  final String title;

  final String description;

  final String clientId;

  final String status;

  final DateTime createdAt;

  CaseModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.clientId,
      required this.status,
      required this.createdAt});
}
