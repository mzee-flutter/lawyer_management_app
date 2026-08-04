class ChangePasswordResponseModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final int expireAt;

  ChangePasswordResponseModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.expireAt,
  });

  // NOTE: backend revokes every refresh token for this user (including the
  // current device's) and issues a brand new pair in the same response, so
  // the caller MUST persist accessToken/refreshToken immediately or the
  // next API call on this device will 401.
  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>;
    return ChangePasswordResponseModel(
      message: json['message'] as String? ?? '',
      accessToken: tokens['access_token'] as String,
      refreshToken: tokens['refresh_token'] as String,
      expireAt: tokens['expire_at'] as int,
    );
  }
}
