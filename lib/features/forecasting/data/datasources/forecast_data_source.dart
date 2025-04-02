import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/time_series_point.dart';
import '../models/forecast_model.dart';

/// Handles all data operations for forecasts
class ForecastDataSource {
  ForecastDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Gets the collection reference for forecasts
  CollectionReference get _forecastsCollection =>
      _firestore.collection('forecasts');

  /// Creates a new forecast
  Future<String> createForecast(ForecastModel forecast) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add the forecast to Firestore
      final docRef = await _forecastsCollection.add(forecast.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create forecast: $e');
    }
  }

  /// Updates an existing forecast
  Future<void> updateForecast(String id, ForecastModel forecast) async {
    try {
      await _forecastsCollection.doc(id).update(forecast.toJson());
    } catch (e) {
      throw Exception('Failed to update forecast: $e');
    }
  }

  /// Gets a forecast by ID
  Future<ForecastModel> getForecastById(String id) async {
    try {
      final doc = await _forecastsCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Forecast not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return ForecastModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get forecast: $e');
    }
  }

  /// Gets all forecasts
  Future<List<ForecastModel>> getForecasts() async {
    try {
      final snapshot = await _forecastsCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ForecastModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get forecasts: $e');
    }
  }

  /// Gets historical time series data for forecasting
  Future<List<TimeSeriesPoint>> getHistoricalData({
    required List<String> productIds,
    String? categoryId,
    String? warehouseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _forecastsCollection
          .where('productIds', arrayContainsAny: productIds)
          .where('createdDate', isGreaterThanOrEqualTo: startDate)
          .where('createdDate', isLessThanOrEqualTo: endDate)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TimeSeriesPoint.fromJson({...data});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get historical data: $e');
    }
  }

  /// Deletes a forecast
  Future<void> deleteForecast(String id) async {
    try {
      await _forecastsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete forecast: $e');
    }
  }
}
