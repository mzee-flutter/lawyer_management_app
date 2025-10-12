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
  final String name;
  final String email;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: json['created_at'],
    );
  }
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
