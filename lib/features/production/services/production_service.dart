import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/exceptions.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/production_job.dart';

/// Service for handling production operations with API integration
class ProductionService {

  ProductionService({
    http.Client? httpClient,
    DefaultCacheManager? cacheManager,
  })  : _httpClient = httpClient ?? http.Client(),
        _cacheManager = cacheManager ?? DefaultCacheManager();
  final http.Client _httpClient;
  final DefaultCacheManager _cacheManager;

  /// Start production for an order
  Future<ProductionJob> startProduction(
    String orderId, {
    String? location,
    ProductionPriority? priority,
    String? assignedTo,
    DateTime? scheduledStartTime,
  }) async {
    try {
      // Set default values if not provided
      final startTime = scheduledStartTime ?? DateTime.now();
      final estimatedEndTime =
          startTime.add(const Duration(hours: 2)); // Default to 2 hours
      final productionPriority = priority ?? ProductionPriority.medium;

      // Build the request body
      final Map<String, dynamic> requestBody = {
        'orderId': orderId,
        'location': location ?? 'main-production',
        'startTime': startTime.toIso8601String(),
        'estimatedEndTime': estimatedEndTime.toIso8601String(),
        'status': 'scheduled',
        'priority': productionPriority.toString(),
      };

      if (assignedTo != null) {
        requestBody['assignedTo'] = assignedTo;
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/jobs');

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
              'Request timed out while starting production');
        },
      );

      // Handle response
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ProductionJob job = ProductionJob.fromJson(responseData);

        // Cache the job
        final String cacheKey = 'production_job_${job.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1), // Cache for a day
        );

        return job;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to start production');
      } else if (response.statusCode == 400) {
        throw ValidationException(
            'Invalid production job data: ${response.body}');
      } else {
        throw ApiException(
          'Failed to start production: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException('Failed to start production: ${e.toString()}');
    }
  }

  /// Update production status for an order
  Future<ProductionJob> updateProductionStatus(
      String jobId, ProductionJobStatus status,
      {String? notes, double? percentComplete}) async {
    try {
      // Get the current production job first
      final currentJob = await getProductionJob(jobId);

      // Prepare the request body with updated fields
      final Map<String, dynamic> requestBody = {
        'status': status.toString(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        requestBody['notes'] = notes;
      }

      if (percentComplete != null) {
        requestBody['percentComplete'] = percentComplete;
      }

      // Additional fields based on status
      if (status == ProductionJobStatus.completed) {
        requestBody['completedAt'] = DateTime.now().toIso8601String();
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/jobs/$jobId');

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
              'Request timed out while updating production status');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ProductionJob updatedJob = ProductionJob.fromJson(responseData);

        // Update cache
        final String cacheKey = 'production_job_${updatedJob.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );

        // Also invalidate any schedule caches that might include this job
        await _invalidateScheduleCaches(updatedJob.location);

        return updatedJob;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to update production status');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Production job not found');
      } else if (response.statusCode == 400) {
        throw ValidationException(
            'Invalid production status update: ${response.body}');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Cannot update production job in its current state');
      } else {
        throw ApiException(
          'Failed to update production status: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is ConflictException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to update production status: ${e.toString()}');
    }
  }

  /// Mark production as complete with quality checks
  Future<ProductionJob> completeProduction(String jobId,
      {Map<String, bool>? qualityChecks}) async {
    try {
      // Get the current job
      final currentJob = await getProductionJob(jobId);

      if (currentJob.status == ProductionJobStatus.completed) {
        throw ValidationException('Production job is already completed');
      }

      if (currentJob.status == ProductionJobStatus.cancelled) {
        throw ValidationException('Cannot complete a cancelled production job');
      }

      // Prepare quality check list if provided
      List<Map<String, dynamic>>? qualityChecksList;

      if (qualityChecks != null && qualityChecks.isNotEmpty) {
        qualityChecksList = qualityChecks.entries.map((entry) {
          return {
            'id':
                'qc_${DateTime.now().millisecondsSinceEpoch}_${entry.key.hashCode}',
            'checkName': entry.key,
            'passed': entry.value,
            'timestamp': DateTime.now().toIso8601String(),
            'performedBy':
                'system', // In a real app, this would be the current user
          };
        }).toList();
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'status': ProductionJobStatus.completed.toString(),
        'completedAt': DateTime.now().toIso8601String(),
        'percentComplete': 100.0,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (qualityChecksList != null) {
        requestBody['qualityChecks'] = qualityChecksList;
      }

      // Make API call
      final Uri uri =
          Uri.parse('${ApiEndpoints.production}/jobs/$jobId/complete');

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
              'Request timed out while completing production');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ProductionJob completedJob = ProductionJob.fromJson(responseData);

        // Update cache
        final String cacheKey = 'production_job_${completedJob.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 7), // Cache completed jobs longer
        );

        // Also invalidate any schedule caches that might include this job
        await _invalidateScheduleCaches(completedJob.location);

        return completedJob;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to complete production');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Production job not found');
      } else if (response.statusCode == 400) {
        throw ValidationException(
            'Invalid production completion: ${response.body}');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Cannot complete production job in its current state');
      } else {
        throw ApiException(
          'Failed to complete production: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is ConflictException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to complete production: ${e.toString()}');
    }
  }

  /// Report a production issue
  Future<String> reportProductionIssue(
      String jobId, String description, String severity,
      {String? assignedTo}) async {
    try {
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'description': description,
        'severity': severity,
        'reportedAt': DateTime.now().toIso8601String(),
        'reportedBy': 'system', // In a real app, this would be the current user
        'resolved': false,
      };

      if (assignedTo != null) {
        requestBody['assignedTo'] = assignedTo;
      }

      // Make API call
      final Uri uri =
          Uri.parse('${ApiEndpoints.production}/jobs/$jobId/issues');

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
              'Request timed out while reporting production issue');
        },
      );

      // Handle response
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String issueId = responseData['id'];

        // Invalidate job cache since it now has a new issue
        await _cacheManager.removeFile('production_job_$jobId');

        return issueId;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to report production issue');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Production job not found');
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid production issue: ${response.body}');
      } else {
        throw ApiException(
          'Failed to report production issue: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to report production issue: ${e.toString()}');
    }
  }

  /// Get production schedule for a specific location and date
  Future<List<ProductionJob>> getProductionSchedule(
      String location, DateTime date) async {
    try {
      // Create a date-only string (without time) for the query and cache key
      final String dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Build query parameters
      final Map<String, String> queryParams = {
        'location': location,
        'date': dateStr,
      };

      // Create a cache key based on the query parameters
      final String cacheKey = 'production_schedule_${location}_$dateStr';

      // Try to get from cache first, but only if the date is not today or in the past
      // (we want fresh data for today and future dates)
      final DateTime today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final DateTime queryDate = DateTime(date.year, date.month, date.day);

      if (queryDate.isBefore(today)) {
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final List<dynamic> decodedData = json.decode(cacheData);
            return decodedData
                .map((data) => ProductionJob.fromJson(data))
                .toList();
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error: $e');
        }
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/schedule')
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
              'Request timed out while fetching production schedule');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final jobs =
            responseData.map((data) => ProductionJob.fromJson(data)).toList();

        // Cache the response for past dates
        if (queryDate.isBefore(today)) {
          await _cacheManager.putFile(
            cacheKey,
            utf8.encode(response.body),
            fileExtension: 'json',
            maxAge: const Duration(days: 30), // Cache past schedules for longer
          );
        } else if (queryDate.isAtSameMomentAs(today)) {
          // Only cache today's schedule for a shorter time
          await _cacheManager.putFile(
            cacheKey,
            utf8.encode(response.body),
            fileExtension: 'json',
            maxAge: const Duration(
                minutes: 15), // Only cache for 15 minutes for today's schedule
          );
        }

        return jobs;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to access production schedule');
      } else {
        throw ApiException(
          'Failed to fetch production schedule: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to fetch production schedule: ${e.toString()}');
    }
  }

  /// Get production capacity for a location
  Future<Map<String, dynamic>> getProductionCapacity(String location) async {
    try {
      // Create a cache key
      final String cacheKey = 'production_capacity_$location';

      // Try to get from cache first
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          // Only use cache if it's less than 30 minutes old
          // (capacity can change frequently)
          final DateTime cacheAge =
              cacheFile.validTill.subtract(const Duration(hours: 1));
          if (DateTime.now().difference(cacheAge) <
              const Duration(minutes: 30)) {
            final String cacheData = await cacheFile.file.readAsString();
            return json.decode(cacheData);
          }
        }
      } catch (e) {
        // Cache error, continue to API call
        print('Cache error: $e');
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/capacity')
          .replace(queryParameters: {'location': location});

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
              'Request timed out while fetching production capacity');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Cache the response
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(hours: 1), // Cache for 1 hour
        );

        return responseData;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to access production capacity');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Production location not found');
      } else {
        throw ApiException(
          'Failed to fetch production capacity: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to fetch production capacity: ${e.toString()}');
    }
  }

  /// Check if production can accept a new order
  Future<bool> canAcceptNewOrder(String location,
      double estimatedProductionHours, DateTime preferredDate) async {
    try {
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'location': location,
        'estimatedHours': estimatedProductionHours,
        'preferredDate': preferredDate.toIso8601String(),
      };

      // Make API call
      final Uri uri =
          Uri.parse('${ApiEndpoints.production}/check-availability');

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
              'Request timed out while checking production availability');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['available'] as bool;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            'Unauthorized to check production availability');
      } else if (response.statusCode == 400) {
        throw ValidationException(
            'Invalid availability request: ${response.body}');
      } else {
        throw ApiException(
          'Failed to check production availability: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to check production availability: ${e.toString()}');
    }
  }

  /// Get details of a specific production job
  Future<ProductionJob> getProductionJob(String jobId) async {
    try {
      // Try to get from cache first
      final String cacheKey = 'production_job_$jobId';
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          final String cacheData = await cacheFile.file.readAsString();
          return ProductionJob.fromJson(json.decode(cacheData));
        }
      } catch (e) {
        // Cache error, continue to API call
        print('Cache error: $e');
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/jobs/$jobId');

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
              'Request timed out while fetching production job');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final job = ProductionJob.fromJson(responseData);

        // Cache the response
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(hours: 2), // Cache for 2 hours
        );

        return job;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to access production job');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Production job not found');
      } else {
        throw ApiException(
          'Failed to fetch production job: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is NotFoundException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to fetch production job: ${e.toString()}');
    }
  }

  /// Get production jobs for an order
  Future<List<ProductionJob>> getProductionJobsForOrder(String orderId) async {
    try {
      // Create a cache key
      final String cacheKey = 'production_jobs_order_$orderId';

      // Try to get from cache first
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          final String cacheData = await cacheFile.file.readAsString();
          final List<dynamic> decodedData = json.decode(cacheData);
          return decodedData
              .map((data) => ProductionJob.fromJson(data))
              .toList();
        }
      } catch (e) {
        // Cache error, continue to API call
        print('Cache error: $e');
      }

      // Make API call
      final Uri uri = Uri.parse('${ApiEndpoints.production}/jobs')
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
          throw RequestTimeoutException(
              'Request timed out while fetching production jobs for order');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final jobs =
            responseData.map((data) => ProductionJob.fromJson(data)).toList();

        // Cache the response
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(hours: 1), // Cache for 1 hour
        );

        return jobs;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to access production jobs');
      } else {
        throw ApiException(
          'Failed to fetch production jobs: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is RequestTimeoutException ||
          e is UnauthorizedException ||
          e is ApiException) {
        rethrow;
      }
      throw ProductionException(
          'Failed to fetch production jobs for order: ${e.toString()}');
    }
  }

  /// Helper method to invalidate schedule caches for a location
  Future<void> _invalidateScheduleCaches(String location) async {
    try {
      // Invalidate today's schedule cache
      final DateTime today = DateTime.now();
      final String todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await _cacheManager
          .removeFile('production_schedule_${location}_$todayStr');

      // Also invalidate tomorrow's cache if it exists
      final DateTime tomorrow = today.add(const Duration(days: 1));
      final String tomorrowStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await _cacheManager
          .removeFile('production_schedule_${location}_$tomorrowStr');

      // Invalidate capacity cache as well
      await _cacheManager.removeFile('production_capacity_$location');
    } catch (e) {
      // Log error but continue - non-critical operation
      print('Error invalidating schedule caches: $e');
    }
  }

  /// Helper method to get the authentication token
  Future<String> _getAuthToken() async {
    // In a real app, this would retrieve the token from secure storage
    return 'mock_auth_token';
  }
}

/// Exception for production-related errors
class ProductionException implements Exception {

  ProductionException(this.message);
  final String message;

  @override
  String toString() => 'ProductionException: $message';
}

// Provider for the ProductionService
final productionServiceProvider = Provider<ProductionService>((ref) {
  return ProductionService();
});
