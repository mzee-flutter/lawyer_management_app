class ClientCreateModel {
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String address;
  final String notes;

  ClientCreateModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "cnic": cnic,
      "address": address,
      "notes": notes,
    };
  }
}
