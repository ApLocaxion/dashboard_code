class ErrorApiDTO {
  final String errorCode; // Assuming ErrorCode is a string enum in API
  final String? message;

  ErrorApiDTO({required this.errorCode, this.message});

  factory ErrorApiDTO.fromJson(Map<String, dynamic> json) {
    return ErrorApiDTO(
      errorCode: json['errorCode'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'errorCode': errorCode, 'message': message};
  }
}
