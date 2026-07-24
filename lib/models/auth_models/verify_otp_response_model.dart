class VerifyOtpResponseModel {
  final String resetToken;
  final int expiresIn; // seconds

  VerifyOtpResponseModel({
    required this.resetToken,
    required this.expiresIn,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      resetToken: json['reset_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}
