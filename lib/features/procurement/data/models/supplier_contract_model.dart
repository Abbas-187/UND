// c:\Users\morel\OneDrive\Documents\FlutterProjects\UNDAPP\und_app\lib\features\procurement\data\models\supplier_contract_model.dart

import 'package:flutter/foundation.dart';

/// Enum representing different types of supplier contracts
enum ContractType {
  service,
  supply,
  maintenance,
}

/// Converts [ContractType] enum to string
String contractTypeToString(ContractType type) {
  return type.toString().split('.').last;
}

/// Converts string to [ContractType] enum
ContractType contractTypeFromString(String type) {
  return ContractType.values.firstWhere(
    (e) => e.toString().split('.').last == type,
    orElse: () => throw ArgumentError('Invalid contract type: $type'),
  );
}

/// Model class for supplier contracts
class SupplierContract {
  /// Unique identifier for the contract
  final String id;

  /// Contract number (business identifier)
  final String contractNumber;

  /// Type of the contract (e.g., supply, service)
  final ContractType contractType;

  /// Date when the contract was signed
  final DateTime contractDate;

  /// Start date of the contract
  final DateTime startDate;

  /// End date of the contract
  final DateTime endDate;

  /// Identifier of the supplier party to this contract
  final String supplierId;

  /// Name of the supplier
  final String supplierName;

  /// Terms and conditions of the contract
  final String termsAndConditions;

  /// Pricing schedules (can be a detailed string or a reference to a separate document)
  final String pricingSchedules;

  /// Material quality specifications
  final String materialQualitySpecifications;

  /// Delivery requirements for the supplier
  final String deliveryRequirements;

  /// Special conditions of the contract
  final String? specialConditions;

  /// Additional notes about the contract
  final String? notes;

  /// Date and time when the contract was created
  final DateTime createdAt;

  /// Date and time when the contract was last updated
  final DateTime updatedAt;

  /// Creates a new [SupplierContract] instance
  SupplierContract({
    required this.id,
    required this.contractNumber,
    required this.contractType,
    required this.contractDate,
    required this.startDate,
    required this.endDate,
    required this.supplierId,
    required this.supplierName,
    required this.termsAndConditions,
    required this.pricingSchedules,
    required this.materialQualitySpecifications,
    required this.deliveryRequirements,
    this.specialConditions,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this [SupplierContract] instance with the given fields replaced
  SupplierContract copyWith({
    String? id,
    String? contractNumber,
    ContractType? contractType,
    DateTime? contractDate,
    DateTime? startDate,
    DateTime? endDate,
    String? supplierId,
    String? supplierName,
    String? termsAndConditions,
    String? pricingSchedules,
    String? materialQualitySpecifications,
    String? deliveryRequirements,
    String? specialConditions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierContract(
      id: id ?? this.id,
      contractNumber: contractNumber ?? this.contractNumber,
      contractType: contractType ?? this.contractType,
      contractDate: contractDate ?? this.contractDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      pricingSchedules: pricingSchedules ?? this.pricingSchedules,
      materialQualitySpecifications:
          materialQualitySpecifications ?? this.materialQualitySpecifications,
      deliveryRequirements: deliveryRequirements ?? this.deliveryRequirements,
      specialConditions: specialConditions ?? this.specialConditions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this [SupplierContract] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_number': contractNumber,
      'contract_type': contractTypeToString(contractType),
      'contract_date': contractDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'terms_and_conditions': termsAndConditions,
      'pricing_schedules': pricingSchedules,
      'material_quality_specifications': materialQualitySpecifications,
      'delivery_requirements': deliveryRequirements,
      'special_conditions': specialConditions,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [SupplierContract] instance from a JSON map
  factory SupplierContract.fromJson(Map<String, dynamic> json) {
    return SupplierContract(
      id: json['id'],
      contractNumber: json['contract_number'],
      contractType: contractTypeFromString(json['contract_type']),
      contractDate: DateTime.parse(json['contract_date']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      termsAndConditions: json['terms_and_conditions'],
      pricingSchedules: json['pricing_schedules'],
      materialQualitySpecifications: json['material_quality_specifications'],
      deliveryRequirements: json['delivery_requirements'],
      specialConditions: json['special_conditions'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  String toString() {
    return 'SupplierContract(id: $id, contractNumber: $contractNumber, supplier: $supplierName, contractType: $contractType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupplierContract &&
        other.id == id &&
        other.contractNumber == contractNumber &&
        other.contractType == contractType &&
        other.contractDate == contractDate &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.supplierId == supplierId &&
        other.supplierName == supplierName &&
        other.termsAndConditions == termsAndConditions &&
        other.pricingSchedules == pricingSchedules &&
        other.materialQualitySpecifications == materialQualitySpecifications &&
        other.deliveryRequirements == deliveryRequirements &&
        other.specialConditions == specialConditions &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      contractNumber,
      contractType,
      contractDate,
      startDate,
      endDate,
      supplierId,
      supplierName,
      termsAndConditions,
      pricingSchedules,
      materialQualitySpecifications,
      deliveryRequirements,
      specialConditions,
      notes,
      createdAt,
      updatedAt,
    );
  }
}
