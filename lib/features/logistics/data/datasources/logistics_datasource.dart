import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/delivery_status.dart' as domain_delivery;
import '../../domain/entities/route_status.dart' as domain_route;
import '../models/delivery_item_model.dart' as delivery_items;
import '../models/delivery_model.dart';
import '../models/driver_model.dart';
import '../models/route_model.dart';
import '../models/temperature_log_model.dart';
import '../models/vehicle_model.dart';

/// Data source for all logistics operations
class LogisticsDataSource {
  LogisticsDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection references
  CollectionReference get _vehiclesCollection =>
      _firestore.collection('vehicles');
  CollectionReference get _deliveriesCollection =>
      _firestore.collection('deliveries');
  CollectionReference get _routesCollection => _firestore.collection('routes');
  CollectionReference get _temperatureLogsCollection =>
      _firestore.collection('temperatureLogs');
  CollectionReference get _driversCollection =>
      _firestore.collection('drivers');

  // Generic query helper method
  Future<List<T>> _getDocumentsByQuery<T>({
    required CollectionReference collection,
    required Query Function(CollectionReference) query,
    required T Function(Map<String, dynamic>, String) fromJson,
  }) async {
    try {
      final querySnapshot = await query(collection).get();
      return querySnapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching documents: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // VEHICLE METHODS
  //------------------------------------------------------------------------------

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final querySnapshot = await _vehiclesCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return VehicleModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching vehicles: ${e.toString()}');
    }
  }

  Future<List<VehicleModel>> getVehiclesByQuery({
    required Query Function(CollectionReference) query,
  }) async {
    return _getDocumentsByQuery<VehicleModel>(
      collection: _vehiclesCollection,
      query: query,
      fromJson: (data, id) => VehicleModel.fromJson({...data, 'id': id}),
    );
  }

  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final docSnapshot = await _vehiclesCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Vehicle not found');
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      return VehicleModel.fromJson({...data, 'id': id});
    } catch (e) {
      throw Exception('Error fetching vehicle: ${e.toString()}');
    }
  }

  Future<String> createVehicle(VehicleModel vehicle) async {
    try {
      final docRef =
          await _vehiclesCollection.add(vehicle.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating vehicle: ${e.toString()}');
    }
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      await _vehiclesCollection
          .doc(vehicle.id)
          .update(vehicle.toJson()..remove('id'));
    } catch (e) {
      throw Exception('Error updating vehicle: ${e.toString()}');
    }
  }

  Future<void> updateVehicleLocation({
    required String vehicleId,
    required double latitude,
    required double longitude,
    String? locationDescription,
  }) async {
    try {
      final updateData = {
        'lastLatitude': latitude,
        'lastLongitude': longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      };

      if (locationDescription != null) {
        updateData['currentLocationDescription'] = locationDescription;
      }

      await _vehiclesCollection.doc(vehicleId).update(updateData);
    } catch (e) {
      throw Exception('Error updating vehicle location: ${e.toString()}');
    }
  }

  Future<void> assignDriverToVehicle({
    required String vehicleId,
    required String driverId,
  }) async {
    try {
      await _vehiclesCollection.doc(vehicleId).update({
        'currentDriverId': driverId,
      });

      await _driversCollection.doc(driverId).update({
        'currentVehicleId': vehicleId,
        'isAvailable': false,
      });
    } catch (e) {
      throw Exception('Error assigning driver to vehicle: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // DELIVERY METHODS
  //------------------------------------------------------------------------------

  Future<List<DeliveryModel>> getDeliveries() async {
    try {
      final querySnapshot = await _deliveriesCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DeliveryModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching deliveries: ${e.toString()}');
    }
  }

  Future<List<DeliveryModel>> getDeliveriesByQuery({
    required Query Function(CollectionReference) query,
  }) async {
    return _getDocumentsByQuery<DeliveryModel>(
      collection: _deliveriesCollection,
      query: query,
      fromJson: (data, id) => DeliveryModel.fromJson({...data, 'id': id}),
    );
  }

  Future<DeliveryModel> getDeliveryById(String id) async {
    try {
      final docSnapshot = await _deliveriesCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Delivery not found');
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      return DeliveryModel.fromJson({...data, 'id': id});
    } catch (e) {
      throw Exception('Error fetching delivery: ${e.toString()}');
    }
  }

  Future<String> createDelivery(DeliveryModel delivery) async {
    try {
      final docRef =
          await _deliveriesCollection.add(delivery.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating delivery: ${e.toString()}');
    }
  }

  Future<void> updateDelivery(DeliveryModel delivery) async {
    try {
      await _deliveriesCollection
          .doc(delivery.id)
          .update(delivery.toJson()..remove('id'));
    } catch (e) {
      throw Exception('Error updating delivery: ${e.toString()}');
    }
  }

  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required domain_delivery.DeliveryStatus status,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _deliveriesCollection.doc(deliveryId).update(updateData);
    } catch (e) {
      throw Exception('Error updating delivery status: ${e.toString()}');
    }
  }

  Future<void> completeDelivery({
    required String deliveryId,
    required DateTime actualDeliveryTime,
    String? customerSignature,
    String? proofOfDeliveryImage,
    List<delivery_items.DeliveryItemModel>? updatedItems,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status':
            domain_delivery.DeliveryStatus.delivered.toString().split('.').last,
        'actualDeliveryTime': actualDeliveryTime.toIso8601String(),
      };

      if (customerSignature != null) {
        updateData['customerSignature'] = customerSignature;
      }

      if (proofOfDeliveryImage != null) {
        updateData['proofOfDeliveryImage'] = proofOfDeliveryImage;
      }

      if (updatedItems != null) {
        final List<Map<String, dynamic>> itemsData = updatedItems
            .map((item) => item.toJson() as Map<String, dynamic>)
            .toList();
        updateData['itemsData'] = itemsData;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _deliveriesCollection.doc(deliveryId).update(updateData);
    } catch (e) {
      throw Exception('Error completing delivery: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // ROUTE METHODS
  //------------------------------------------------------------------------------

  Future<List<RouteModel>> getRoutes() async {
    try {
      final querySnapshot = await _routesCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RouteModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching routes: ${e.toString()}');
    }
  }

  Future<List<RouteModel>> getRoutesByQuery({
    required Query Function(CollectionReference) query,
  }) async {
    return _getDocumentsByQuery<RouteModel>(
      collection: _routesCollection,
      query: query,
      fromJson: (data, id) => RouteModel.fromJson({...data, 'id': id}),
    );
  }

  Future<RouteModel> getRouteById(String id) async {
    try {
      final docSnapshot = await _routesCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Route not found');
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      return RouteModel.fromJson({...data, 'id': id});
    } catch (e) {
      throw Exception('Error fetching route: ${e.toString()}');
    }
  }

  Future<String> createRoute(RouteModel route) async {
    try {
      final docRef = await _routesCollection.add(route.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating route: ${e.toString()}');
    }
  }

  Future<void> updateRoute(RouteModel route) async {
    try {
      await _routesCollection
          .doc(route.id)
          .update(route.toJson()..remove('id'));
    } catch (e) {
      throw Exception('Error updating route: ${e.toString()}');
    }
  }

  Future<void> updateRouteStatus({
    required String routeId,
    required domain_route.RouteStatus status,
    DateTime? startTime,
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
      };

      if (startTime != null) {
        updateData['startTime'] = startTime.toIso8601String();
      }

      await _routesCollection.doc(routeId).update(updateData);
    } catch (e) {
      throw Exception('Error updating route status: ${e.toString()}');
    }
  }

  Future<void> completeRoute({
    required String routeId,
    required DateTime endTime,
    required double actualDistanceKm,
    required int actualDurationMinutes,
  }) async {
    try {
      await _routesCollection.doc(routeId).update({
        'status': domain_route.RouteStatus.completed.toString().split('.').last,
        'endTime': endTime.toIso8601String(),
        'actualDistanceKm': actualDistanceKm,
        'actualDurationMinutes': actualDurationMinutes,
      });
    } catch (e) {
      throw Exception('Error completing route: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // TEMPERATURE METHODS
  //------------------------------------------------------------------------------

  Future<List<TemperatureLogModel>> getTemperatureLogs() async {
    try {
      final querySnapshot = await _temperatureLogsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TemperatureLogModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching temperature logs: ${e.toString()}');
    }
  }

  Future<List<TemperatureLogModel>> getTemperatureLogsByQuery({
    required Query Function(CollectionReference) query,
  }) async {
    return _getDocumentsByQuery<TemperatureLogModel>(
      collection: _temperatureLogsCollection,
      query: query,
      fromJson: (data, id) => TemperatureLogModel.fromJson({...data, 'id': id}),
    );
  }

  Future<String> createTemperatureLog(TemperatureLogModel log) async {
    try {
      final docRef =
          await _temperatureLogsCollection.add(log.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating temperature log: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------
  // DRIVER METHODS
  //------------------------------------------------------------------------------

  Future<List<DriverModel>> getDrivers() async {
    try {
      final querySnapshot = await _driversCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DriverModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching drivers: ${e.toString()}');
    }
  }

  Future<List<DriverModel>> getDriversByQuery({
    required Query Function(CollectionReference) query,
  }) async {
    return _getDocumentsByQuery<DriverModel>(
      collection: _driversCollection,
      query: query,
      fromJson: (data, id) => DriverModel.fromJson({...data, 'id': id}),
    );
  }

  Future<DriverModel> getDriverById(String id) async {
    try {
      final docSnapshot = await _driversCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Driver not found');
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      return DriverModel.fromJson({...data, 'id': id});
    } catch (e) {
      throw Exception('Error fetching driver: ${e.toString()}');
    }
  }

  Future<String> createDriver(DriverModel driver) async {
    try {
      final docRef =
          await _driversCollection.add(driver.toJson()..remove('id'));
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating driver: ${e.toString()}');
    }
  }

  Future<void> updateDriver(DriverModel driver) async {
    try {
      await _driversCollection
          .doc(driver.id)
          .update(driver.toJson()..remove('id'));
    } catch (e) {
      throw Exception('Error updating driver: ${e.toString()}');
    }
  }

  Future<void> updateDriverAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {
    try {
      await _driversCollection.doc(driverId).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      throw Exception('Error updating driver availability: ${e.toString()}');
    }
  }

  Future<void> updateDriverRestBreak({
    required String driverId,
    required DateTime lastRestBreak,
    required int totalDrivingMinutesToday,
  }) async {
    try {
      await _driversCollection.doc(driverId).update({
        'lastRestBreak': lastRestBreak.toIso8601String(),
        'totalDrivingMinutesToday': totalDrivingMinutesToday,
      });
    } catch (e) {
      throw Exception('Error updating driver rest break: ${e.toString()}');
    }
  }
}
