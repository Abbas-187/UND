import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';

/// Data model for Supplier
class SupplierModel {
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

  /// Convert from Domain Entity to Model
  factory SupplierModel.fromEntity(Supplier entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      type: entity.type.toString().split('.').last,
      status: entity.status.toString().split('.').last,
      address: entity.address,
      contactPerson: entity.contactPerson,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to Domain Entity
  Supplier toEntity() {
    return Supplier(
      id: id ?? '',
      name: name,
      code: code,
      type: _mapStringToSupplierType(type),
      status: _mapStringToSupplierStatus(status),
      address: address,
      contactPerson: contactPerson,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
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
