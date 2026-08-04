class MessageResponseModel {
  final String message;

  MessageResponseModel({required this.message});

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      message: json['message'] as String? ?? '',
    );
  }
}
