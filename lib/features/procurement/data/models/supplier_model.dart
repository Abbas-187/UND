import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/supplier.dart';
import 'supplier_performance_metrics.dart';

/// Enum representing different types of suppliers in the dairy industry
enum SupplierType {
  rawMilk,
  ingredients,
  packaging,
  equipment,
  manufacturer,
  distributor,
  retailer,
  serviceProvider,
  contractor,
}

/// Converts [SupplierType] enum to string
String supplierTypeToString(SupplierType type) {
  switch (type) {
    case SupplierType.rawMilk:
      return 'raw_milk';
    case SupplierType.ingredients:
      return 'ingredients';
    case SupplierType.packaging:
      return 'packaging';
    case SupplierType.equipment:
      return 'equipment';
    case SupplierType.manufacturer:
      return 'manufacturer';
    case SupplierType.distributor:
      return 'distributor';
    case SupplierType.retailer:
      return 'retailer';
    case SupplierType.serviceProvider:
      return 'service_provider';
    case SupplierType.contractor:
      return 'contractor';
  }
}

/// Converts string to [SupplierType] enum
SupplierType supplierTypeFromString(String type) {
  switch (type) {
    case 'raw_milk':
      return SupplierType.rawMilk;
    case 'ingredients':
      return SupplierType.ingredients;
    case 'packaging':
      return SupplierType.packaging;
    case 'equipment':
      return SupplierType.equipment;
    case 'manufacturer':
      return SupplierType.manufacturer;
    case 'distributor':
      return SupplierType.distributor;
    case 'retailer':
      return SupplierType.retailer;
    case 'service_provider':
      return SupplierType.serviceProvider;
    case 'contractor':
      return SupplierType.contractor;
    default:
      throw ArgumentError('Invalid supplier type: $type');
  }
}

/// Model class representing a supplier in the dairy factory system
class Supplier {

  /// Creates a new [Supplier] instance
  Supplier({
    required this.id,
    required this.name,
    required this.code,
    required this.contactName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.supplierType,
    required this.qualityRating,
    required this.deliveryRating,
    required this.performanceMetrics,
    required this.certifications,
    required this.paymentTerms,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Supplier] instance from a JSON map
  factory Supplier.fromJson(Map<String, dynamic> json) {
    final performanceMetricsData =
        json['performance_metrics'] as Map<String, dynamic>? ??
            {
              'quality_score': json['quality_rating'] ?? 0.0,
              'delivery_score': json['delivery_rating'] ?? 0.0,
              'price_score': 3.0, // Default value if not available
              'overall_score': ((json['quality_rating'] ?? 0.0) +
                      (json['delivery_rating'] ?? 0.0) +
                      3.0) /
                  3.0,
            };

    return Supplier(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      contactName: json['contact_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      supplierType: supplierTypeFromString(json['supplier_type']),
      qualityRating: (json['quality_rating'] ?? 0.0).toDouble(),
      deliveryRating: (json['delivery_rating'] ?? 0.0).toDouble(),
      performanceMetrics:
          SupplierPerformanceMetrics.fromJson(performanceMetricsData),
      certifications: List<String>.from(json['certifications'] ?? []),
      paymentTerms: json['payment_terms'] ?? '',
      isActive: json['is_active'] ?? true,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
  /// Unique identifier for the supplier
  final String id;

  /// Name of the supplier
  final String name;

  /// Unique code assigned to the supplier
  final String code;

  /// Name of the primary contact person at the supplier
  final String contactName;

  /// Phone number of the supplier
  final String phoneNumber;

  /// Email address of the supplier
  final String email;

  /// Physical address of the supplier
  final String address;

  /// Type of goods or services provided by the supplier
  final SupplierType supplierType;

  /// Quality rating of the supplier (0-5 scale)
  final double qualityRating;

  /// Delivery reliability rating of the supplier (0-5 scale)
  final double deliveryRating;

  /// Performance metrics of the supplier
  final SupplierPerformanceMetrics performanceMetrics;

  /// List of certifications held by the supplier
  final List<String> certifications;

  /// Payment terms agreed with the supplier
  final String paymentTerms;

  /// Indicates if the supplier is currently active
  final bool isActive;

  /// Additional notes about the supplier
  final String? notes;

  /// DateTime when the supplier was added to the system
  final DateTime createdAt;

  /// DateTime when the supplier information was last updated
  final DateTime updatedAt;

  /// Creates a copy of this [Supplier] instance with the given fields replaced
  Supplier copyWith({
    String? id,
    String? name,
    String? code,
    String? contactName,
    String? phoneNumber,
    String? email,
    String? address,
    SupplierType? supplierType,
    double? qualityRating,
    double? deliveryRating,
    SupplierPerformanceMetrics? performanceMetrics,
    List<String>? certifications,
    String? paymentTerms,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      supplierType: supplierType ?? this.supplierType,
      qualityRating: qualityRating ?? this.qualityRating,
      deliveryRating: deliveryRating ?? this.deliveryRating,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      certifications: certifications ?? List.from(this.certifications),
      paymentTerms: paymentTerms ?? this.paymentTerms,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this [Supplier] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'supplier_type': supplierTypeToString(supplierType),
      'quality_rating': qualityRating,
      'delivery_rating': deliveryRating,
      'performance_metrics': performanceMetrics.toJson(),
      'certifications': certifications,
      'payment_terms': paymentTerms,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, code: $code, supplierType: $supplierType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Supplier &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.contactName == contactName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.address == address &&
        other.supplierType == supplierType &&
        other.qualityRating == qualityRating &&
        other.deliveryRating == deliveryRating &&
        other.performanceMetrics == performanceMetrics &&
        listEquals(other.certifications, certifications) &&
        other.paymentTerms == paymentTerms &&
        other.isActive == isActive &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      contactName,
      phoneNumber,
      email,
      address,
      supplierType,
      qualityRating,
      deliveryRating,
      performanceMetrics.hashCode,
      Object.hashAll(certifications),
      paymentTerms,
      isActive,
      notes,
      createdAt,
      updatedAt,
    );
  }
}

/// Data model for Supplier
class SupplierModel {

  const SupplierModel({
    this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.status,
    this.address,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from Firestore document to SupplierModel
  factory SupplierModel.fromMap(Map<String, dynamic> map, String docId) {
    return SupplierModel(
      id: docId,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      address: map['address'],
      contactPerson: map['contactPerson'],
      contactEmail: map['contactEmail'],
      contactPhone: map['contactPhone'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert from Domain Entity to Model
  factory SupplierModel.fromEntity(Supplier entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      type: entity.supplierType.toString().split('.').last,
      status: entity.isActive ? 'active' : 'inactive',
      address: entity.address,
      contactPerson: entity.contactName,
      contactEmail: entity.email,
      contactPhone: entity.phoneNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  final String? id;
  final String name;
  final String code;
  final String type;
  final String status;
  final String? address;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'type': type,
      'status': status,
      'address': address,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Domain Entity
  Supplier toEntity() {
    return Supplier(
      id: id ?? '',
      name: name,
      code: code,
      contactName: contactPerson ?? '',
      phoneNumber: contactPhone ?? '',
      email: contactEmail ?? '',
      address: address ?? '',
      supplierType: supplierTypeFromString(type),
      qualityRating: 0.0, // Assuming default quality rating
      deliveryRating: 0.0, // Assuming default delivery rating
      performanceMetrics: SupplierPerformanceMetrics(
        qualityScore: 0.0,
        deliveryScore: 0.0,
        priceScore: 3.0,
        overallScore: 3.0,
      ),
      certifications: [],
      paymentTerms: '',
      isActive: status == 'active',
      notes: '',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Map string to SupplierType enum
  SupplierType _mapStringToSupplierType(String type) {
    switch (type.toLowerCase()) {
      case 'manufacturer':
        return SupplierType.manufacturer;
      case 'distributor':
        return SupplierType.distributor;
      case 'retailer':
        return SupplierType.retailer;
      case 'serviceprovider':
        return SupplierType.serviceProvider;
      case 'contractor':
        return SupplierType.contractor;
      default:
        return SupplierType.manufacturer;
    }
  }

  /// Map string to SupplierStatus enum
  SupplierStatus _mapStringToSupplierStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SupplierStatus.active;
      case 'inactive':
        return SupplierStatus.inactive;
      case 'pending':
        return SupplierStatus.pending;
      case 'blacklisted':
        return SupplierStatus.blacklisted;
      case 'onhold':
        return SupplierStatus.onHold;
      default:
        return SupplierStatus.pending;
    }
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? code,
    String? type,
    String? status,
    String? address,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
