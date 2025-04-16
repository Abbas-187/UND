import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../di/app_providers.dart';
import '../exceptions/app_exception.dart';

/// HTTP API client for making REST API calls
class ApiClient {
  final String baseUrl;
  final Logger logger;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    required this.logger,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
    this.timeout = const Duration(seconds: 30),
  });

  /// Add authorization token to headers
  Map<String, String> _addAuthHeader(
      Map<String, String>? headers, String? token) {
    final allHeaders = Map<String, String>.from(defaultHeaders);

    if (headers != null) {
      allHeaders.addAll(headers);
    }

    if (token != null) {
      allHeaders['Authorization'] = 'Bearer $token';
    }

    return allHeaders;
  }

  /// Handle HTTP response and extract data or throw appropriate exception
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    logger.d(
        'Response: $statusCode - ${responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody}');

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      if (responseBody.isEmpty) {
        return ApiResponse(null, statusCode);
      }

      try {
        final data = jsonDecode(responseBody);
        return ApiResponse(data, statusCode);
      } catch (e) {
        logger.e('Error decoding JSON response: $e');
        throw AppException(
          message: 'Invalid response format',
          statusCode: statusCode,
        );
      }
    } else {
      // Error response
      try {
        final errorData =
            responseBody.isNotEmpty ? jsonDecode(responseBody) : null;
        final errorMessage =
            errorData?['message'] ?? 'Request failed with status: $statusCode';

        switch (statusCode) {
          case 400:
            throw AppException(
              message: errorMessage,
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.badRequest,
            );
          case 401:
            throw AppException(
              message: 'Unauthorized: $errorMessage',
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.unauthorized,
            );
          case 403:
            throw AppException(
              message: 'Forbidden: $errorMessage',
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.forbidden,
            );
          case 404:
            throw AppException(
              message: 'Not found: $errorMessage',
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.notFound,
            );
          case 409:
            throw AppException(
              message: 'Conflict: $errorMessage',
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.conflict,
            );
          case 500:
          case 501:
          case 502:
          case 503:
            throw AppException(
              message: 'Server error: $errorMessage',
              statusCode: statusCode,
              data: errorData,
              type: AppExceptionType.serverError,
            );
          default:
            throw AppException(
              message: 'API Error: $errorMessage',
              statusCode: statusCode,
              data: errorData,
            );
        }
      } catch (e) {
        if (e is AppException) {
          throw e;
        }

        throw AppException(
          message: 'Error processing response: ${e.toString()}',
          statusCode: statusCode,
        );
      }
    }
  }

  /// GET request
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );

      logger.d('GET $uri');

      final response = await http
          .get(
            uri,
            headers: _addAuthHeader(headers, token),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException(
        message: 'No internet connection',
        type: AppExceptionType.network,
      );
    } on TimeoutException {
      throw const AppException(
        message: 'Request timeout',
        type: AppExceptionType.timeout,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      logger.e('GET request error: $e');
      throw AppException(
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// POST request
  Future<ApiResponse> post(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      logger.d('POST $uri with data: $data');

      final response = await http
          .post(
            uri,
            headers: _addAuthHeader(headers, token),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException(
        message: 'No internet connection',
        type: AppExceptionType.network,
      );
    } on TimeoutException {
      throw const AppException(
        message: 'Request timeout',
        type: AppExceptionType.timeout,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      logger.e('POST request error: $e');
      throw AppException(
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// PUT request
  Future<ApiResponse> put(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      logger.d('PUT $uri with data: $data');

      final response = await http
          .put(
            uri,
            headers: _addAuthHeader(headers, token),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException(
        message: 'No internet connection',
        type: AppExceptionType.network,
      );
    } on TimeoutException {
      throw const AppException(
        message: 'Request timeout',
        type: AppExceptionType.timeout,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      logger.e('PUT request error: $e');
      throw AppException(
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// PATCH request
  Future<ApiResponse> patch(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      logger.d('PATCH $uri with data: $data');

      final response = await http
          .patch(
            uri,
            headers: _addAuthHeader(headers, token),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException(
        message: 'No internet connection',
        type: AppExceptionType.network,
      );
    } on TimeoutException {
      throw const AppException(
        message: 'Request timeout',
        type: AppExceptionType.timeout,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      logger.e('PATCH request error: $e');
      throw AppException(
        message: 'Request failed: ${e.toString()}',
      );
    }
  }

  /// DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      logger.d('DELETE $uri');

      final response = await http
          .delete(
            uri,
            headers: _addAuthHeader(headers, token),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException(
        message: 'No internet connection',
        type: AppExceptionType.network,
      );
    } on TimeoutException {
      throw const AppException(
        message: 'Request timeout',
        type: AppExceptionType.timeout,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      logger.e('DELETE request error: $e');
      throw AppException(
        message: 'Request failed: ${e.toString()}',
      );
    }
  }
}

/// API response model
class ApiResponse {
  final dynamic data;
  final int statusCode;

  ApiResponse(this.data, this.statusCode);
}

/// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final logger = ref.watch(loggerProvider);
  final appConfig = AppConfig();

  return ApiClient(
    baseUrl: appConfig.apiBaseUrl,
    logger: logger,
  );
});
