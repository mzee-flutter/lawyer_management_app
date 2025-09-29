class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'],
      phone: json['phone'],
      cnic: json['cnic'],
      address: json['address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updated_at']) : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'])
          : null,
    );
  }
}
