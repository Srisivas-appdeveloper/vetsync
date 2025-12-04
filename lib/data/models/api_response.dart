// lib/data/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final ApiMetadata metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      metadata: ApiMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

class ApiMetadata {
  final DateTime timestamp;
  final String requestId;

  ApiMetadata({required this.timestamp, required this.requestId});

  factory ApiMetadata.fromJson(Map<String, dynamic> json) {
    return ApiMetadata(
      timestamp: DateTime.parse(json['timestamp'] as String),
      requestId: json['request_id'] as String,
    );
  }
}
