import '../models/dairy_quality_parameters_model.dart';
import 'package:und_app/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository for managing dairy quality parameters
class QualityParametersRepository {
  QualityParametersRepository(this._apiClient);
  final ApiClient _apiClient;

  /// Get quality parameters for a specific inventory item
  Stream<List<DairyQualityParametersModel>> getQualityParametersForItem(
      String inventoryItemId) async* {
    try {
      final response =
          await _apiClient.get('api/quality/item/$inventoryItemId');
      final List<dynamic> data = response.data as List<dynamic>;
      yield data
          .map((item) => DairyQualityParametersModel.fromJson(item))
          .toList();
    } catch (e) {
      // Return empty list on error and log the exception
      print('Failed to load quality parameters for item: $e');
      yield [];
    }
  }

  /// Get quality parameters for a specific batch
  Stream<List<DairyQualityParametersModel>> getQualityParametersForBatch(
      String batchNumber) async* {
    try {
      final response = await _apiClient.get('api/quality/batch/$batchNumber');
      final List<dynamic> data = response.data as List<dynamic>;
      yield data
          .map((item) => DairyQualityParametersModel.fromJson(item))
          .toList();
    } catch (e) {
      // Return empty list on error and log the exception
      print('Failed to load quality parameters for batch: $e');
      yield [];
    }
  }

  /// Get pending quality tests
  Stream<List<DairyQualityParametersModel>> getPendingQualityTests() async* {
    try {
      final response = await _apiClient.get('api/quality/pending');
      final List<dynamic> data = response.data as List<dynamic>;
      yield data
          .map((item) => DairyQualityParametersModel.fromJson(item))
          .toList();
    } catch (e) {
      // Return empty list on error and log the exception
      print('Failed to load pending quality tests: $e');
      yield [];
    }
  }

  /// Save quality parameters
  Future<String> saveQualityParameters(
      DairyQualityParametersModel parameters) async {
    try {
      final response =
          await _apiClient.post('api/quality', data: parameters.toJson());
      return response.data['id'] as String;
    } catch (e) {
      throw Exception('Failed to save quality parameters: $e');
    }
  }

  /// Approve quality parameters
  Future<void> approveQualityParameters(String parametersId) async {
    try {
      await _apiClient
          .patch('api/quality/$parametersId/approve', data: {'approved': true});
    } catch (e) {
      throw Exception('Failed to approve quality parameters: $e');
    }
  }

  /// Reject quality parameters
  Future<void> rejectQualityParameters(
      String parametersId, String rejectionReason) async {
    try {
      await _apiClient.patch('api/quality/$parametersId/reject',
          data: {'rejectionReason': rejectionReason});
    } catch (e) {
      throw Exception('Failed to reject quality parameters: $e');
    }
  }

  /// Get a single quality parameter by ID
  Future<DairyQualityParametersModel> getQualityParametersById(
      String id) async {
    try {
      final response = await _apiClient.get('api/quality/$id');
      return DairyQualityParametersModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load quality parameters: $e');
    }
  }
}

/// Provider for quality parameters repository
final qualityParametersRepositoryProvider =
    Provider<QualityParametersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QualityParametersRepository(apiClient);
});
