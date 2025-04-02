import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a resource allocation
class ResourceAllocationModel {
  final String? id;
  final String name;
  final String type;
  final double? dailyCapacity;
  final String? capacityUnit;
  final Map<String, double>? productEfficiency;
  final bool isActive;
  final Map<String, dynamic>? constraints;

  const ResourceAllocationModel({
    this.id,
    required this.name,
    required this.type,
    this.dailyCapacity,
    this.capacityUnit,
    this.productEfficiency,
    this.isActive = true,
    this.constraints,
  });

  factory ResourceAllocationModel.fromJson(Map<String, dynamic> json) {
    return ResourceAllocationModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      dailyCapacity: json['dailyCapacity'] != null
          ? (json['dailyCapacity'] as num).toDouble()
          : null,
      capacityUnit: json['capacityUnit'] as String?,
      productEfficiency: json['productEfficiency'] != null
          ? Map<String, double>.from(json['productEfficiency'] as Map)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      constraints: json['constraints'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dailyCapacity': dailyCapacity,
      'capacityUnit': capacityUnit,
      'productEfficiency': productEfficiency,
      'isActive': isActive,
      'constraints': constraints,
    };
  }

  ResourceAllocationModel copyWith({
    String? id,
    String? name,
    String? type,
    double? dailyCapacity,
    String? capacityUnit,
    Map<String, double>? productEfficiency,
    bool? isActive,
    Map<String, dynamic>? constraints,
  }) {
    return ResourceAllocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dailyCapacity: dailyCapacity ?? this.dailyCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      productEfficiency: productEfficiency ?? this.productEfficiency,
      isActive: isActive ?? this.isActive,
      constraints: constraints ?? this.constraints,
    );
  }
}
