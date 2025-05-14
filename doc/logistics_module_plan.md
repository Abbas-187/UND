# Logistics Module Implementation Plan

## Overview

The logistics module will centralize all transportation, delivery, and route management for the UND dairy factory management system, enhancing the end-to-end supply chain and integrating with existing modules like Milk Reception, Inventory, and Production. This module is specifically designed for the Saudi Arabian market and recognizes the dual role of drivers as salesmen within the company's business model.

## Architecture

The logistics module will follow the established clean architecture pattern:

```
lib/features/logistics/
  ├── domain/          # Business rules and entities
  ├── data/            # Implementation of repositories
  └── presentation/    # UI components and state management
```

## Implementation Plan

### Phase 1: Foundation and Core Models

#### Domain Layer Setup

1. Define core entities:
   - `Vehicle` - Transportation assets
   - `DriverSalesman` - Personnel with dual role as driver and salesman
   - `Route` - Predefined delivery and sales routes
   - `Delivery` - Specific delivery instances
   - `ShippingDocument` - Documentation for deliveries
   - `SalesTransaction` - On-route sales transactions

2. Create repository interfaces:
   - `VehicleRepository`
   - `DriverSalesmanRepository`
   - `RouteRepository` 
   - `DeliveryRepository`
   - `ShippingDocumentRepository`
   - `SalesTransactionRepository`

3. Implement use cases:
   - `RegisterVehicleUseCase` - Add new vehicles to the fleet
   - `RegisterDriverSalesmanUseCase` - Add new driver/salesmen
   - `CreateRouteUseCase` - Define delivery routes
   - `ScheduleDeliveryUseCase` - Schedule new deliveries
   - `TrackDeliveryUseCase` - Update delivery status
   - `GenerateShippingDocumentsUseCase` - Create shipping documents
   - `RecordSaleUseCase` - Record sales made by driver/salesmen
   - `GetSalesPerformanceUseCase` - Retrieve sales performance metrics

#### Data Layer Implementation

1. Create data models:
   - `VehicleModel` - With fields for ID, type, plate number, capacity, status
   - `DriverSalesmanModel` - With fields combining driver and salesman attributes
   - `RouteModel` - With fields for ID, stops, distances, estimated times
   - `DeliveryModel` - With fields for ID, schedule, status, items, documents
   - `ShippingDocumentModel` - With fields for type, references, statuses
   - `SalesTransactionModel` - With fields for sales made during delivery routes

2. Implement repository interfaces with Firebase Firestore:
   - `VehicleRepositoryImpl`
   - `DriverSalesmanRepositoryImpl`
   - `RouteRepositoryImpl`
   - `DeliveryRepositoryImpl`
   - `ShippingDocumentRepositoryImpl`
   - `SalesTransactionRepositoryImpl`

3. Set up Firebase collections:
   - `vehicles` - Store vehicle information
   - `driver_salesmen` - Store driver/salesman information
   - `routes` - Store predefined routes
   - `deliveries` - Store delivery information
   - `shipping_documents` - Store shipping documentation
   - `sales_transactions` - Store on-route sales

### Phase 2: Fleet Management and Personnel

#### Fleet Management Features

1. Vehicle Management:
   - Registration and decommissioning
   - Maintenance scheduling and tracking
   - Capacity and capability tracking
   - Cost tracking (fuel, maintenance)
   - Arabic and English documentation support
   - GPS tracking and real-time location monitoring
   - Temperature monitoring for refrigerated vehicles
   - Geofencing capabilities for route compliance

2. Driver/Salesman Management:
   - Registration with Saudi ID and documentation
   - Saudi labor law compliance tracking
   - Sales territory assignment
   - Performance tracking (both driving and sales metrics)
   - Work hours compliance monitoring according to Saudi labor laws
   - Language preference settings (Arabic/English)
   - Iqama (residency permit) and driving license tracking
   - Commission and incentive management

#### UI Implementation for Fleet and Personnel Management

1. Screens:
   - `VehicleListScreen` - Overview of all vehicles
   - `VehicleDetailScreen` - Details of specific vehicle
   - `VehicleRegistrationScreen` - Add/edit vehicle information
   - `VehicleTrackingScreen` - Real-time GPS and temperature tracking
   - `TemperatureMonitoringDashboard` - Monitor all vehicle temperatures
   - `DriverSalesmanListScreen` - Overview of all driver/salesmen
   - `DriverSalesmanDetailScreen` - Details of specific driver/salesman
   - `DriverSalesmanRegistrationScreen` - Add/edit driver/salesman information
   - `SalesPerformanceScreen` - View sales performance by driver

2. Widgets:
   - `VehicleCard` - Summary card for vehicles
   - `MaintenanceScheduleWidget` - Display maintenance information
   - `VehicleTrackingMapWidget` - Shows real-time vehicle location
   - `TemperatureGraphWidget` - Displays temperature trends
   - `TemperatureAlertWidget` - Shows alerts for temperature violations
   - `DriverSalesmanCard` - Summary card for driver/salesmen
   - `DriverAvailabilityWidget` - Show driver availability
   - `VehicleStatusWidget` - Show vehicle operational status
   - `SalesPerformanceWidget` - Show sales performance

### Phase 3: Route Planning and Optimization

#### Route Management Features

1. Route Creation:
   - Manual route definition with Saudi geographic considerations
   - Route optimization suggestions considering Saudi traffic patterns
   - Distance and time calculation with local road conditions
   - Cost estimation with Saudi fuel prices
   - Geographic territory management for sales
   - Support for Saudi addressing system and landmarks

2. Route Analysis:
   - Route efficiency metrics
   - Historical performance analysis
   - Seasonal route adjustments (accounting for Ramadan, Hajj, etc.)
   - Heat mapping of sales performance by region

#### UI Implementation for Route Management

1. Screens:
   - `RouteListScreen` - Overview of defined routes
   - `RouteDetailScreen` - Details of specific route
   - `RouteCreationScreen` - Create/edit routes
   - `RouteAnalyticsScreen` - Route performance metrics

2. Widgets:
   - `RouteMapWidget` - Visual map of routes
   - `RouteStopListWidget` - List of stops in a route
   - `RoutePerformanceWidget` - Performance metrics visualization
   - `OptimizationSuggestionWidget` - Suggest route improvements

### Phase 4: Delivery and Sales Management

#### Delivery Management Features

1. Delivery Scheduling:
   - Create delivery schedules
   - Assign vehicles and driver/salesmen
   - Prioritize deliveries
   - Handle rescheduling
   - Coordinate with prayer times

2. Delivery Execution:
   - Track delivery status in real-time
   - Manage delivery exceptions
   - Capture proof of delivery
   - Update inventory on delivery completion
   - Record returns and exchanges on-site

3. On-route Sales Features:
   - Mobile point-of-sale functionality
   - Product catalog for driver/salesmen
   - Pricing and discount management
   - Customer account management
   - Mobile invoice generation
   - On-site payment collection (cash, card, digital)

4. Shipping Documentation:
   - Generate waybills and delivery notes
   - Track document status
   - Support digital signatures
   - Archive completed delivery documentation
   - Bilingual document support (utilizing existing i10n)
   - Compliance with Saudi commercial documentation requirements

#### UI Implementation for Delivery and Sales Management

1. Screens:
   - `DeliveryDashboardScreen` - Overview of active deliveries
   - `DeliverySchedulingScreen` - Schedule new deliveries
   - `DeliveryDetailScreen` - Details of specific delivery
   - `DocumentGenerationScreen` - Generate shipping documents
   - `MobileSalesScreen` - Interface for on-route sales
   - `CustomerVisitScreen` - Track customer visits and outcomes
   - `PaymentCollectionScreen` - Process payments on delivery

2. Widgets:
   - `DeliveryStatusCard` - Show delivery status
   - `DeliveryItemsWidget` - List items in a delivery
   - `DeliveryTimelineWidget` - Show delivery milestones
   - `DocumentPreviewWidget` - Preview shipping documents
   - `SalesOrderWidget` - Create sales orders on-route
   - `CustomerHistoryWidget` - View customer purchase history
   - `PaymentWidget` - Process and record payments

### Phase 5: Mobile Features for Driver/Salesmen

#### Driver/Salesman Mobile Application

1. Mobile Features:
   - Delivery assignment notifications
   - Turn-by-turn navigation optimized for Saudi roads
   - Delivery status updates
   - Digital proof of delivery
   - Communication with base
   - Mobile sales catalog
   - Customer information access
   - Order creation and fulfillment
   - Payment processing
   - Localized interface (utilizing existing i10n)
   - Prayer time notifications and breaks
   - Real-time temperature monitoring alerts on mobile
   - Vehicle tracking status reporting

2. Offline Support:
   - Cache delivery information
   - Store status updates locally
   - Sync when connectivity is restored
   - Access to necessary documentation offline
   - Offline sales processing
   - Local customer data storage

#### UI Implementation for Mobile

1. Screens:
   - `DriverSalesmanHomeScreen` - Daily schedule and metrics
   - `DeliveryNavigationScreen` - Navigation to stops
   - `DeliveryConfirmationScreen` - Confirm delivery completion
   - `DriverMessageScreen` - Communication with logistics team
   - `SalesEntryScreen` - Record new sales transactions
   - `CustomerDetailScreen` - View and update customer information
   - `DailySummaryScreen` - End-of-day reporting

2. Widgets:
   - `UpcomingDeliveryCard` - Show upcoming assignments
   - `NavigationMapWidget` - Show route to destination
   - `DeliveryChecklistWidget` - Items to be delivered
   - `SignatureWidget` - Capture recipient signature
   - `ProductCatalogWidget` - Browse and select products for sale
   - `QuotaProgressWidget` - Show progress toward sales targets
   - `CashCollectionWidget` - Track cash collected during route

### Phase 6: Integration with Existing Modules

#### Integration Points

1. CRM Integration:
   - Synchronize driver/salesman data with CRM module
   - Share customer visit information
   - Update customer records with delivery preferences
   - Track sales opportunities identified during deliveries
   - Coordinate promotions and special offers

2. Inventory Integration:
   - Update inventory when deliveries are completed
   - Reserve inventory items for scheduled deliveries
   - Trigger alerts for delivery-ready inventory
   - Track product returns and exchanges from delivery routes
   - Manage vehicle stock levels for on-route sales

3. Production Integration:
   - Coordinate deliveries with production schedules
   - Prioritize deliveries based on production needs
   - Track product-specific transportation requirements
   - Provide feedback on product issues observed during delivery

4. Order Management Integration:
   - Connect customer orders to deliveries
   - Update order status based on delivery status
   - Provide delivery estimates to customers
   - Process new orders generated during delivery routes
   - Track partial deliveries and backorders

#### Implementation

1. Create integration services:
   - `LogisticsInventoryService` - Bridge logistics and inventory
   - `LogisticsProductionService` - Bridge logistics and production
   - `LogisticsCrmService` - Bridge logistics and CRM
   - `LogisticsOrderService` - Bridge logistics and order management

2. Implement notification systems:
   - Delivery scheduling notifications
   - Delivery completion notifications
   - Delivery exception alerts
   - Sales target achievement notifications
   - New order notifications
   - Stock level alerts for vehicle inventory

### Phase 7: Analytics and Reporting

#### Analytics Features

1. Performance Metrics:
   - On-time delivery rate
   - Vehicle utilization
   - Driver/salesman performance (driving metrics)
   - Sales performance by driver/salesman
   - Route efficiency
   - Delivery cost analysis
   - Customer visit effectiveness
   - Product return rates during delivery

2. Reporting:
   - Daily delivery and sales summary
   - Vehicle maintenance schedule
   - Route performance comparison
   - Delivery exception reports
   - Sales performance by region
   - Sales performance by product
   - Customer visit reports
   - Cost and efficiency trends
   - Vehicle stock reconciliation reports
   - Commission calculation reports

#### UI Implementation for Analytics

1. Screens:
   - `LogisticsAnalyticsDashboard` - Overview of key metrics
   - `DeliveryPerformanceScreen` - Detailed delivery metrics
   - `VehicleUtilizationScreen` - Vehicle usage analytics
   - `CostAnalysisScreen` - Financial metrics
   - `SalesPerformanceScreen` - Sales metrics by driver/salesman
   - `CustomerVisitAnalyticsScreen` - Customer visit effectiveness

2. Widgets:
   - `DeliveryPerformanceChart` - Visualize delivery performance
   - `RouteEfficiencyWidget` - Compare route efficiencies
   - `CostTrendWidget` - Show cost trends
   - `ExceptionRateWidget` - Display delivery exceptions
   - `SalesPerformanceChart` - Visualize sales performance
   - `CustomerVisitChart` - Analyze customer visit outcomes

### Phase 8: Testing and Documentation

#### Testing Strategy

1. Unit Tests:
   - Test all use cases
   - Test repository implementations
   - Test data model validations

2. Widget Tests:
   - Test UI components
   - Test form validations
   - Test interactive elements

3. Integration Tests:
   - Test full delivery workflow
   - Test Firebase integration
   - Test integration with other modules

#### Documentation

1. Code Documentation:
   - Document all public APIs
   - Document integration points
   - Document data models

2. User Documentation:
   - Create user guides for logistics features
   - Document workflow procedures
   - Create training materials

3. Architecture Documentation:
   - Document design decisions
   - Document module structure
   - Document future expansion points

## Detailed Model Specifications

### Vehicle Model

```dart
class VehicleModel {
  final String id;
  final String plateNumber;
  final String type; // truck, van, etc.
  final double capacity; // in volume or weight
  final String capacityUnit; // liters, kg, etc.
  final VehicleStatus status; // active, maintenance, retired
  final DateTime registrationDate;
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final Map<String, dynamic> specifications; // flexible field for vehicle specs
  final double fuelEfficiency; // km per liter
  final List<String> features; // refrigeration, etc.
  
  // Tracking-specific fields
  final GeoPoint currentLocation;
  final DateTime lastLocationUpdate;
  final double currentSpeed;
  final String currentAddress;
  final bool isInMotion;
  final List<GeoFence> assignedGeofences;
  
  // Temperature monitoring fields
  final bool hasTemperatureMonitoring;
  final List<TemperatureSensor> temperatureSensors;
  final double currentTemperature;
  final double minRequiredTemperature;
  final double maxRequiredTemperature;
  final DateTime lastTemperatureUpdate;
  final List<TemperatureAlert> temperatureAlerts;
  
  // Methods for calculating availability, maintenance status, etc.
}

class TemperatureSensor {
  final String id;
  final String name;
  final String location; // e.g., "front", "rear", "middle"
  final double currentReading;
  final DateTime lastUpdated;
  final bool isWorking;
  final List<TemperatureReading> recentReadings; // Last 24 hours of readings
}

class TemperatureReading {
  final DateTime timestamp;
  final double temperature;
  final String sensorId;
}

class TemperatureAlert {
  final String id;
  final DateTime timestamp;
  final String sensorId;
  final double temperature;
  final double threshold;
  final TemperatureAlertType type; // above_max, below_min
  final bool acknowledged;
  final String acknowledgedBy;
  final DateTime acknowledgedAt;
}

class GeoFence {
  final String id;
  final String name;
  final GeoFenceType type; // circle, polygon
  final List<GeoPoint> coordinates;
  final double radius; // for circle type
  final GeoFenceAlert entryAlert;
  final GeoFenceAlert exitAlert;
}
```

### VehicleTracking Model

```dart
class VehicleTrackingModel {
  final String id;
  final String vehicleId;
  final DateTime timestamp;
  final GeoPoint location;
  final double speed;
  final double heading;
  final double fuelLevel;
  final EngineStatus engineStatus;
  final Map<String, double> temperatureReadings; // Key: sensorId, Value: temperature
  final Map<String, dynamic> diagnostics; // Engine diagnostics
  final String driverSalesmanId;
  final DeliveryStatus deliveryStatus;
  final String currentRouteId;
  final String currentStopId;
  final Map<String, dynamic> customFields;
  
  // Methods for calculating ETA, temperature compliance, etc.
}
```

### DriverSalesman Model

```dart
class DriverSalesmanModel {
  final String id;
  final String name;
  final String saudiId; // Saudi ID number or Iqama
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final List<String> qualifications; // hazmat, refrigerated, etc.
  final DriverStatus status; // available, on-route, off-duty
  final DateTime employmentStartDate;
  final Map<String, dynamic> contactInfo;
  final List<String> assignedVehicleIds;
  final WorkSchedule schedule;
  
  // Salesman-specific fields
  final String employeeId; // Employee ID in the company
  final List<String> salesTerritories; // Assigned sales territories
  final double monthlySalesTarget; // Sales target
  final double commissionRate; // Commission percentage
  final Map<String, double> productSpecificCommissions; // Product-specific commission rates
  final Map<String, dynamic> salesPerformance; // Historical sales performance data
  final String salesManagerId; // Reporting manager
  final List<String> customerAccounts; // Assigned customers
  
  // Methods for calculating availability, license validity, sales performance, etc.
}
```

### Route Model

```dart
class RouteModel {
  final String id;
  final String name;
  final List<LocationStop> stops;
  final double totalDistance; // in km
  final Duration estimatedDuration;
  final Map<String, dynamic> restrictions; // weight, height, etc.
  final RouteType type; // regular, special, etc.
  final Map<String, double> costFactors; // tolls, fuel, etc.
  
  // Saudi-specific fields
  final List<PrayerTimeAdjustment> prayerTimeAdjustments; // Adjustments for prayer times
  final List<String> salesTerritories; // Associated sales territories
  final Map<String, String> landmarks; // Saudi landmarks for easier navigation
  
  // Methods for calculating estimates, optimizations, etc.
}
```

### Delivery Model

```dart
class DeliveryModel {
  final String id;
  final String routeId;
  final String vehicleId;
  final String driverSalesmanId;
  final DeliveryStatus status;
  final DateTime scheduledDeparture;
  final DateTime actualDeparture;
  final DateTime estimatedArrival;
  final DateTime actualArrival;
  final List<DeliveryItem> items;
  final String orderId; // reference to order
  final String customerId;
  final Map<String, dynamic> contactInfo;
  final List<String> documentIds; // references to shipping documents
  final List<DeliveryStatusUpdate> statusUpdates;
  
  // Saudi-specific and sales-related fields
  final List<SalesOpportunity> potentialSales; // Sales opportunities to pursue
  final List<SalesTransaction> completedSales; // Sales made during delivery
  final List<PaymentCollection> paymentsCollected; // Payments collected
  final List<ProductReturn> productReturns; // Products returned during delivery
  final Map<String, double> vehicleInventoryStart; // Starting inventory in vehicle
  final Map<String, double> vehicleInventoryEnd; // Ending inventory in vehicle
  
  // Methods for status management, timeline tracking, sales tracking, etc.
}
```

### SalesTransaction Model

```dart
class SalesTransactionModel {
  final String id;
  final String deliveryId;
  final String driverSalesmanId;
  final String customerId;
  final DateTime timestamp;
  final List<SalesItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String invoiceNumber;
  final String notes;
  final Map<String, dynamic> customerSignature;
  final List<String> photoUrls;
  
  // Methods for calculating totals, commission, etc.
}
```

### ShippingDocument Model

```dart
class ShippingDocumentModel {
  final String id;
  final String deliveryId;
  final DocumentType type; // waybill, delivery note, etc.
  final String fileUrl;
  final DateTime issuedDate;
  final DocumentStatus status; // draft, issued, signed, archived
  final Map<String, dynamic> data; // document-specific data
  final String issuedBy;
  final String signedBy;
  final DateTime signedDate;
  
  // Methods for status management, validation, etc.
}
```

## Implementation Details

### Firebase Collection Structure

```
firestore/
  ├── vehicles/
  │   └── {vehicleId}/
  │       ├── plateNumber: string
  │       ├── type: string
  │       ├── capacity: number
  │       ├── currentLocation: geopoint
  │       ├── currentTemperature: number
  │       └── ...
  ├── vehicle_tracking/
  │   └── {vehicleId}/
  │       └── logs/
  │           └── {trackingLogId}/
  │               ├── timestamp: timestamp
  │               ├── location: geopoint
  │               ├── temperature: number
  │               ├── speed: number
  │               └── ...
  ├── temperature_readings/
  │   └── {vehicleId}/
  │       └── sensors/
  │           └── {sensorId}/
  │               └── readings/
  │                   └── {readingId}/
  │                       ├── timestamp: timestamp
  │                       ├── temperature: number
  │                       ├── status: string
  │                       └── ...
  ├── temperature_alerts/
  │   └── {alertId}/
  │       ├── vehicleId: string
  │       ├── sensorId: string
  │       ├── timestamp: timestamp
  │       ├── temperature: number
  │       ├── alertType: string
  │       └── ...
  ├── driver_salesmen/
  │   └── {driverSalesmanId}/
  │       ├── name: string
  │       ├── saudiId: string
  │       ├── licenseNumber: string
  │       ├── status: string
  │       ├── salesTerritories: array
  │       ├── monthlySalesTarget: number
  │       └── ...
  ├── routes/
  │   └── {routeId}/
  │       ├── name: string
  │       ├── stops: array
  │       ├── totalDistance: number
  │       ├── prayerTimeAdjustments: array
  │       └── ...
  ├── deliveries/
  │   └── {deliveryId}/
  │       ├── routeId: string
  │       ├── vehicleId: string
  │       ├── driverSalesmanId: string
  │       ├── status: string
  │       ├── completedSales: array
  │       └── ...
  ├── sales_transactions/
  │   └── {transactionId}/
  │       ├── deliveryId: string
  │       ├── driverSalesmanId: string
  │       ├── customerId: string
  │       ├── items: array
  │       └── ...
  └── shipping_documents/
      └── {documentId}/
          ├── deliveryId: string
          ├── type: string
          ├── fileUrl: string
          └── ...
```

### API Integration

1. Maps API Integration for route optimization and visualization in Saudi Arabia
2. SMS/Push notification services for delivery updates
3. Weather API for route planning considerations
4. Document generation API for creating shipping documents
5. Payment gateway integration for on-route sales
6. Saudi addressing system API for location accuracy
7. IoT device integration for temperature sensors and GPS tracking
8. Telematics API for vehicle diagnostics and performance data

## Vehicle Tracking System

### Real-time GPS Tracking

1. Technologies:
   - GPS hardware installation in all vehicles
   - Mobile app GPS tracking as backup
   - Cellular data transmission for real-time updates
   - Offline tracking data storage for areas with poor connectivity

2. Features:
   - Live map view of all vehicles
   - Historical route replay
   - Geofencing and boundary alerts
   - Unauthorized movement detection
   - Driver behavior monitoring (speeding, harsh braking)
   - Estimated arrival time calculations

### Temperature Monitoring System

1. Technologies:
   - Wireless temperature sensors in refrigerated compartments
   - Multiple sensor points for large vehicles
   - Automated alert system for temperature violations
   - Temperature log recording for quality assurance

2. Features:
   - Real-time temperature dashboard
   - Temperature history graphs
   - Configurable alert thresholds
   - Automated notifications for temperature breaches
   - Temperature compliance reporting
   - Integration with product quality monitoring

### Implementation Approach

1. Hardware Requirements:
   - GPS tracking devices for all vehicles
   - Temperature sensors for refrigerated vehicles
   - Mobile data connectivity solutions
   - Backup power systems for tracking devices

2. Software Components:
   - Vehicle tracking backend service
   - Temperature monitoring service
   - Alert management system
   - Mobile app integration
   - Admin dashboard for monitoring
   - Reporting and analytics engine

## Integration with Riverpod State Management

### Providers Structure

```dart
// Core providers
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.read(firestoreProvider));
});

final driverSalesmanRepositoryProvider = Provider<DriverSalesmanRepository>((ref) {
  return DriverSalesmanRepositoryImpl(ref.read(firestoreProvider));
});

// Vehicle tracking providers
final vehicleTrackingRepositoryProvider = Provider<VehicleTrackingRepository>((ref) {
  return VehicleTrackingRepositoryImpl(ref.read(firestoreProvider));
});

final temperatureMonitoringRepositoryProvider = Provider<TemperatureMonitoringRepository>((ref) {
  return TemperatureMonitoringRepositoryImpl(ref.read(firestoreProvider));
});

// Use case providers
final registerVehicleUseCaseProvider = Provider<RegisterVehicleUseCase>((ref) {
  return RegisterVehicleUseCase(ref.read(vehicleRepositoryProvider));
});

final scheduleDeliveryUseCaseProvider = Provider<ScheduleDeliveryUseCase>((ref) {
  return ScheduleDeliveryUseCase(
    ref.read(deliveryRepositoryProvider),
    ref.read(vehicleRepositoryProvider),
    ref.read(driverSalesmanRepositoryProvider),
    ref.read(routeRepositoryProvider),
  );
});

final recordSaleUseCaseProvider = Provider<RecordSaleUseCase>((ref) {
  return RecordSaleUseCase(
    ref.read(salesTransactionRepositoryProvider),
    ref.read(deliveryRepositoryProvider),
    ref.read(inventoryRepositoryProvider),
  );
});

final trackVehicleLocationUseCaseProvider = Provider<TrackVehicleLocationUseCase>((ref) {
  return TrackVehicleLocationUseCase(ref.read(vehicleTrackingRepositoryProvider));
});

final monitorTemperatureUseCaseProvider = Provider<MonitorTemperatureUseCase>((ref) {
  return MonitorTemperatureUseCase(ref.read(temperatureMonitoringRepositoryProvider));
});

final handleTemperatureAlertUseCaseProvider = Provider<HandleTemperatureAlertUseCase>((ref) {
  return HandleTemperatureAlertUseCase(
    ref.read(temperatureMonitoringRepositoryProvider),
    ref.read(notificationServiceProvider),
  );
});

// UI state providers
final activeDeliveriesProvider = StreamProvider<List<DeliveryModel>>((ref) {
  return ref.read(deliveryRepositoryProvider).getActiveDeliveries();
});

final driverSalesPerformanceProvider = StreamProvider.family<SalesPerformance, String>((ref, driverSalesmanId) {
  return ref.read(salesTransactionRepositoryProvider).getDriverSalesPerformance(driverSalesmanId);
});

final activeVehicleLocationsProvider = StreamProvider<List<VehicleLocationData>>((ref) {
  return ref.read(vehicleTrackingRepositoryProvider).getActiveVehicleLocations();
});

final vehicleTemperatureDataProvider = StreamProvider.family<List<TemperatureReading>, String>((ref, vehicleId) {
  return ref.read(temperatureMonitoringRepositoryProvider).getVehicleTemperatureData(vehicleId);
});

final temperatureAlertsProvider = StreamProvider<List<TemperatureAlert>>((ref) {
  return ref.read(temperatureMonitoringRepositoryProvider).getActiveTemperatureAlerts();
});

final selectedVehicleProvider = StateProvider<VehicleModel?>((ref) => null);
```

## Flutter Feature Implementation Roadmap

### Sprint 1: Core Domain Models and Repository Setup
- Implement domain entities and repositories with Saudi-specific fields
- Set up Firebase collections and indexes
- Implement basic CRUD operations for all models
- Leverage existing i10n for localization

### Sprint 2: Vehicle and Driver/Salesman Management
- Implement vehicle registration and management screens
- Implement vehicle tracking and temperature monitoring functionality
- Build driver/salesman registration and management screens
- Create maintenance scheduling functionality
- Implement Saudi labor law compliance tracking

### Sprint 3: Route Planning Implementation
- Build route creation and editing screens with Saudi geographic considerations
- Implement maps integration for route visualization
- Develop route optimization algorithms considering local conditions
- Add prayer time integration

### Sprint 4: Delivery Scheduling and Sales Functionality
- Create delivery scheduling screens
- Implement delivery status tracking
- Build shipping document generation
- Develop mobile point-of-sale functionality
- Create payment collection interface

### Sprint 5: Mobile Driver/Salesman Features
- Develop driver/salesman mobile interface
- Implement offline support for mobile features
- Create digital proof of delivery functionality
- Build sales order creation interface
- Develop inventory management for vehicle stock
- Implement real-time temperature monitoring alerts on mobile
- Create vehicle tracking status reporting

### Sprint 6: Integration with Existing Modules
- Connect with inventory management
- Integrate with CRM for customer and salesman data
- Link with order management
- Connect with production planning

### Sprint 7: Analytics and Reporting
- Implement analytics dashboard
- Build performance reports for both delivery and sales
- Create cost analysis tools
- Develop commission calculation systems

### Sprint 8: Testing, Refinement, and Documentation
- Comprehensive testing of all features
- Performance optimization
- Documentation completion
- Market-specific customizations for Saudi Arabia