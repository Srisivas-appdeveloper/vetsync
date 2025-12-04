import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../core/constants/app_config.dart';
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled.', statusCode: 0);

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );

      default:
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

    // Try to extract error message from response
    String message = 'An error occurred.';

    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String? ??
          message;
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
    print('🌐 REQUEST[${options.method}] => ${options.uri}');
    if (options.data != null) {
      print('📤 Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
    );
    print('📥 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
    print('💥 Message: ${err.message}');
    if (err.response?.data != null) {
      print('📥 Error Data: ${err.response?.data}');
    }
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
