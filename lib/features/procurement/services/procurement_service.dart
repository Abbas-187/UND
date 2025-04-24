import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../order_management/models/order.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/procurement_request.dart';
import '../models/procurement_status.dart';

/// Service for handling procurement requests and integration with the ordering system
class ProcurementService {
  final http.Client _httpClient;
  final DefaultCacheManager _cacheManager;

  ProcurementService({
    http.Client? httpClient,
    DefaultCacheManager? cacheManager,
  })  : _httpClient = httpClient ?? http.Client(),
        _cacheManager = cacheManager ?? DefaultCacheManager();

  /// Creates a procurement request for items needed for an order
  Future<String> createProcurementRequest(
    String orderId,
    List<OrderItem> items,
    String location,
  ) async {
    try {
      final Uri uri = Uri.parse('${ApiEndpoints.procurement}/requests');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'orderId': orderId,
        'location': location,
        'items': items
            .map((item) => {
                  'name': item.name,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'productId': item.productId,
                })
            .toList(),
        'requestedBy': 'system', // In a real app, would be the current user
        'requestDate': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      // Make API call
      final response = await _httpClient
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while creating procurement request');
        },
      );

      // Handle response
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String requestId = responseData['id'];

        // Cache the procurement request
        final String cacheKey = 'procurement_request_$requestId';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 7), // Cache for a week
        );

        return requestId;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to create procurement request');
      } else {
        throw ApiException(
          'Failed to create procurement request: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to create procurement request: ${e.toString()}');
    }
  }

  /// Updates the status of a procurement request
  Future<void> updateProcurementRequestStatus(String requestId, String status,
      {String? notes}) async {
    try {
      final Uri uri =
          Uri.parse('${ApiEndpoints.procurement}/requests/$requestId/status');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        requestBody['notes'] = notes;
      }

      // Make API call
      final response = await _httpClient
          .put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while updating procurement status');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        // Invalidate cache for this request
        await _cacheManager.removeFile('procurement_request_$requestId');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to update procurement status');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Procurement request not found');
      } else {
        throw ApiException(
          'Failed to update procurement status: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to update procurement status: ${e.toString()}');
    }
  }

  /// Cancels a procurement request
  Future<void> cancelProcurementRequest(
    String orderId,
    String reason,
  ) async {
    try {
      // First, get the procurement request ID for this order
      final requestId = await _getProcurementRequestIdForOrder(orderId);

      if (requestId == null) {
        throw NotFoundException(
            'No procurement request found for order $orderId');
      }

      final Uri uri =
          Uri.parse('${ApiEndpoints.procurement}/requests/$requestId/cancel');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'reason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
        'cancelledBy': 'system', // In a real app, would be the current user
      };

      // Make API call
      final response = await _httpClient
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while cancelling procurement');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        // Invalidate cache for this request
        await _cacheManager.removeFile('procurement_request_$requestId');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to cancel procurement request');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Procurement request not found');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Cannot cancel procurement request in its current state');
      } else {
        throw ApiException(
          'Failed to cancel procurement request: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ConflictException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to cancel procurement request: ${e.toString()}');
    }
  }

  /// Marks a procurement request as fulfilled
  Future<void> markProcurementRequestFulfilled(String requestId,
      {Map<String, double>? actualQuantities}) async {
    try {
      final Uri uri =
          Uri.parse('${ApiEndpoints.procurement}/requests/$requestId/fulfill');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'fulfilledAt': DateTime.now().toIso8601String(),
        'fulfilledBy': 'system', // In a real app, would be the current user
      };

      if (actualQuantities != null) {
        requestBody['actualQuantities'] = actualQuantities;
      }

      // Make API call
      final response = await _httpClient
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while fulfilling procurement');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        // Invalidate cache for this request
        await _cacheManager.removeFile('procurement_request_$requestId');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to fulfill procurement request');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Procurement request not found');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Cannot fulfill procurement request in its current state');
      } else {
        throw ApiException(
          'Failed to fulfill procurement request: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ConflictException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to fulfill procurement request: ${e.toString()}');
    }
  }

  /// Gets the status of a procurement request
  Future<ProcurementRequest> getProcurementRequestStatus(
      String requestId) async {
    try {
      // Try to get from cache first
      final String cacheKey = 'procurement_request_$requestId';
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          final String cacheData = await cacheFile.file.readAsString();
          return ProcurementRequest.fromJson(json.decode(cacheData));
        }
      } catch (e) {
        // Cache error, continue to API call
        print('Cache error: $e');
      }

      // Make API call
      final Uri uri =
          Uri.parse('${ApiEndpoints.procurement}/requests/$requestId');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while fetching procurement status');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final procurementRequest = ProcurementRequest.fromJson(responseData);

        // Cache the response
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(hours: 1), // Cache for 1 hour
        );

        return procurementRequest;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to view procurement request');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Procurement request not found');
      } else {
        throw ApiException(
          'Failed to get procurement request: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to get procurement request status: ${e.toString()}');
    }
  }

  /// Gets all procurement requests, optionally filtered by status
  Future<List<ProcurementRequest>> getProcurementRequests({
    ProcurementRequestStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? location,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status.toString();
      if (fromDate != null)
        queryParams['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['toDate'] = toDate.toIso8601String();
      if (location != null) queryParams['location'] = location;

      // Create cache key based on query parameters
      final String cacheKey = 'procurement_requests_${queryParams.toString()}';

      // Try to get from cache first if not specifically requesting current data
      if (queryParams.isEmpty || fromDate != null || toDate != null) {
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final List<dynamic> decodedData = json.decode(cacheData);
            return decodedData
                .map((data) => ProcurementRequest.fromJson(data))
                .toList();
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error: $e');
        }
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.procurement}/requests')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while fetching procurement requests');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final requests = responseData
            .map((data) => ProcurementRequest.fromJson(data))
            .toList();

        // Cache the response if it's not a real-time query
        if (queryParams.isEmpty || fromDate != null || toDate != null) {
          await _cacheManager.putFile(
            cacheKey,
            utf8.encode(response.body),
            fileExtension: 'json',
            maxAge: const Duration(minutes: 30), // Cache for 30 minutes
          );
        }

        return requests;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to list procurement requests');
      } else {
        throw ApiException(
          'Failed to list procurement requests: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ApiException) {
        rethrow;
      }
      throw ProcurementException(
          'Failed to list procurement requests: ${e.toString()}');
    }
  }

  /// Helper method to get a procurement request ID for an order
  Future<String?> _getProcurementRequestIdForOrder(String orderId) async {
    try {
      final Uri uri = Uri.parse('${ApiEndpoints.procurement}/requests')
          .replace(queryParameters: {'orderId': orderId});

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw RequestTimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          return responseData.first['id'];
        }
        return null; // No procurement request for this order
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to access procurement requests');
      } else {
        return null; // Treat other errors as "not found" in this context
      }
    } catch (e) {
      print('Error finding procurement request for order: $e');
      return null;
    }
  }

  /// Helper method to get the authentication token
  Future<String> _getAuthToken() async {
    // In a real app, this would retrieve the token from secure storage
    return 'mock_auth_token';
  }
}

/// Exception specifically for procurement-related errors
class ProcurementException implements Exception {
  final String message;

  ProcurementException(this.message);

  @override
  String toString() => 'ProcurementException: $message';
}

// Provider for the ProcurementService
final procurementServiceProvider = Provider<ProcurementService>((ref) {
  return ProcurementService();
});
