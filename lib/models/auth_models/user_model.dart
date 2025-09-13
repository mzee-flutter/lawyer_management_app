class UserModel {
  int id;
  String name;
  String email;
  String role;
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        isActive: json["is_active"]);
  }
}
