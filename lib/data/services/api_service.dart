import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../core/constants/app_config.dart';
import '../models/vitals.dart';
import 'storage_service.dart';

/// API service for handling HTTP requests
class ApiService extends GetxService {
  late final Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  /// Initialize Dio with interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload vitals batch
  Future<Response> uploadVitalsBatch(
    String sessionId,
    List<Vitals> vitals,
  ) async {
    // =========================================================================
    // FIX-006: PRE-TRANSMISSION VALIDATION (Authoritative Spec)
    // =========================================================================
    for (final vital in vitals) {
      // Validate HR/confidence pair
      if (vital.heartRateBpm > 0 && vital.hrConfidence == null) {
        throw StateError(
          'API validation failed: heartRateBpm present but hrConfidence missing. '
          'This indicates a BCG processor bug.',
        );
      }
      // Validate RR/confidence pair
      if (vital.respiratoryRateBpm > 0 && vital.rrConfidence == null) {
        throw StateError(
          'API validation failed: respiratoryRateBpm present but rrConfidence missing. '
          'This indicates a BCG processor bug.',
        );
      }
    }

    return post(
      '/sessions/$sessionId/vitals/batch',
      data: vitals.map((v) => v.toJson()).toList(),
    );
  }

  /// Upload raw collar data chunk (MessagePack to S3)
  Future<Response> uploadRawCollarData({
    required String sessionId,
    required Map<String, String> headers,
    required Uint8List data,
  }) async {
    return post(
      '/sessions/$sessionId/raw-collar-data/upload',
      data: data,
      options: Options(
        headers: {
          ...headers,
          'Content-Type': 'application/x-msgpack',
        },
      ),
    );
  }

  /// Upload raw data chunk (legacy - for offline queue)
  Future<Response> uploadRawDataChunk({
    required String sessionId,
    required Map<String, String> headers,
    required dynamic data,
  }) async {
    // Assuming binary upload or multipart
    return post(
      '/sessions/$sessionId/raw-data',
      data: data,
      options: Options(headers: headers),
    );
  }

  /// Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  ApiException _handleError(DioException error) {
    print('[ApiService] ========================================');
    print('[ApiService] 🔍 ${error.requestOptions.method} ERROR CATEGORIZATION');
    print('[ApiService] ========================================');
    print('[ApiService] Request: ${error.requestOptions.method} ${error.requestOptions.uri}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('[ApiService] 📱 FRONTEND ERROR: Network timeout');
        print('[ApiService] Cause: Request took too long');
        return ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        print('[ApiService] 🖥️ BACKEND ERROR: Server returned error response');
        print('[ApiService] Status Code: ${error.response?.statusCode}');
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        print('[ApiService] 📱 FRONTEND ERROR: Request cancelled by user');
        return ApiException(message: 'Request cancelled.', statusCode: 0);

      case DioExceptionType.connectionError:
        print('[ApiService] 📱 FRONTEND ERROR: Network connection issue');
        print('[ApiService] Cause: No internet connection or network unreachable');
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );

      default:
        print('[ApiService] ⚠️ UNKNOWN ERROR: ${error.type}');
        print('[ApiService] This might be a frontend validation or unexpected error');
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: 0,
        );
    }
  }

  /// Handle HTTP response errors
  ApiException _handleResponseError(Response? response) {
    if (response == null) {
      return ApiException(message: 'No response from server.', statusCode: 0);
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Log the raw error response for debugging
    print('[ApiService] ⚠️ Server error response:');
    print('[ApiService] Status code: $statusCode');
    print('[ApiService] Response data type: ${data.runtimeType}');
    print('[ApiService] Response data: $data');

    // Try to extract error message from response
    String message = 'An error occurred.';

    try {
      if (data is Map<String, dynamic>) {
        // Handle both string and nested object error formats
        final messageField = data['message'];
        final errorField = data['error'];
        final detailField = data['detail'];

        print('[ApiService] Message field type: ${messageField.runtimeType}, value: $messageField');
        print('[ApiService] Error field type: ${errorField.runtimeType}, value: $errorField');
        print('[ApiService] Detail field type: ${detailField.runtimeType}, value: $detailField');

        if (messageField is String) {
          message = messageField;
        } else if (errorField is String) {
          message = errorField;
        } else if (detailField is String) {
          message = detailField;
        } else if (errorField is Map<String, dynamic>) {
          // Handle nested error object: { "error": { "message": "..." } }
          message = errorField['message']?.toString() ?? message;
        } else if (messageField is Map<String, dynamic>) {
          message = messageField['message']?.toString() ?? message;
        } else {
          // If we can't extract a specific message, convert the whole data to string
          message = data.toString();
        }
      } else if (data is String) {
        message = data;
      } else {
        message = data.toString();
      }

      print('[ApiService] Extracted error message: $message');
    } catch (e) {
      print('[ApiService] ❌ Error parsing error response: $e');
      message = 'Server error (could not parse response)';
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: statusCode);
      case 401:
        return ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          message: 'Access forbidden.',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(
          message: 'Resource not found.',
          statusCode: statusCode,
        );
      case 500:
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }
}

/// Authentication interceptor - adds token to requests
class _AuthInterceptor extends Interceptor {
  final StorageService _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    // Add authorization header
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// Logging interceptor - logs requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Don't log successful requests - only errors
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Don't log successful responses - only errors
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only log errors

    print('[ApiService] ========================================');
    print('[ApiService] ❌ ${err.requestOptions.method} ERROR - ${err.response?.statusCode ?? "No Response"}');
    print('[ApiService] ========================================');
    print('[ApiService] Method: ${err.requestOptions.method}');
    print('[ApiService] Error Type: ${err.type}');
    print('[ApiService] URL: ${err.requestOptions.uri}');
    print('[ApiService] Status Code: ${err.response?.statusCode}');
    print('[ApiService] Error Message: ${err.message}');

    // Log request that caused the error
    if (err.requestOptions.data != null) {
      print('[ApiService] Failed Request Body:');
      try {
        if (err.requestOptions.data is Map || err.requestOptions.data is List) {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(err.requestOptions.data);
          print('[ApiService]   $prettyJson');
        } else {
          print('[ApiService]   ${err.requestOptions.data}');
        }
      } catch (e) {
        print('[ApiService]   [Could not format: $e]');
        print('[ApiService]   Raw: ${err.requestOptions.data}');
      }
    }

    // Log error response
    if (err.response?.data != null) {
      print('[ApiService] Error Response Body:');
      try {
        if (err.response!.data is Map || err.response!.data is List) {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(err.response!.data);
          print('[ApiService]   $prettyJson');
        } else {
          print('[ApiService]   ${err.response!.data}');
        }
      } catch (e) {
        print('[ApiService]   [Could not format: $e]');
        print('[ApiService]   Raw: ${err.response!.data}');
      }
    }

    // Log stack trace
    print('[ApiService] Stack Trace:');
    print('[ApiService]   ${err.stackTrace}');

    print('[ApiService] ========================================');

    handler.next(err);
  }
}

/// Error interceptor - handles token refresh on 401
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Could implement token refresh logic here
      // For now, just pass through
    }

    handler.next(err);
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
