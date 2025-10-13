class AuthModel {
  final User user;
  final Tokens tokens;

  AuthModel({required this.user, required this.tokens});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: User.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
    );
  }
}

class User {
  final String id;
  final String? name; // nullable because backend might not send it on login
  final String email;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? json['full_name'], // handles both name or full_name
      email: json['email'] ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'created_at': createdAt,
      };
}

class Tokens {
  final String accessToken;
  final String tokenType;
  final String refreshToken;
  final int expireAt;

  Tokens({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.expireAt,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      refreshToken: json['refresh_token'],
      expireAt: json['expire_at'],
    );
  }
}
