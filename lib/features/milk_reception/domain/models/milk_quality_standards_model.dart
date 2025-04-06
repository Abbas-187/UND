import 'package:cloud_firestore/cloud_firestore.dart';

enum MilkQualityType { cow, goat, sheep, buffalo }

enum TestParameterType {
  fatContent,
  proteinContent,
  lactoseContent,
  snf, // Solids-not-fat
  density,
  freezingPoint,
  addedWater,
  phLevel,
  saltContent,
  antibiotics,
  somaticCellCount,
  coliformCount,
  totalPlateCount
}

class QualityParameter {
  const QualityParameter({
    required this.name,
    required this.unit,
    required this.type,
    this.minValue,
    this.maxValue,
    required this.isCritical,
    this.description,
    this.metadata,
  });

  final String name;
  final String unit;
  final TestParameterType type;
  final double? minValue;
  final double? maxValue;
  final bool isCritical;
  final String? description;
  final Map<String, dynamic>? metadata;
}

class PricingTier {
  const PricingTier({
    required this.name,
    required this.minFatPercentage,
    required this.minProteinPercentage,
    required this.maxSomaticCellCount,
    required this.maxTotalBacterialCount,
    required this.priceAdjustmentPercentage,
    this.description,
  });

  final String name;
  final double minFatPercentage;
  final double minProteinPercentage;
  final int maxSomaticCellCount;
  final int maxTotalBacterialCount;
  final double priceAdjustmentPercentage;
  final String? description;
}

class MilkQualityStandardsModel {
  factory MilkQualityStandardsModel.fromMap(
      Map<String, dynamic> map, String id) {
    return MilkQualityStandardsModel(
      id: id,
      name: map['name'] as String,
      milkType: MilkQualityType.values.firstWhere(
          (e) => e.toString() == 'MilkQualityType.${map['milkType']}'),
      isActive: map['isActive'] as bool,
      parameters: (map['parameters'] as List)
          .map((param) => QualityParameter(
                name: param['name'] as String,
                unit: param['unit'] as String,
                type: TestParameterType.values.firstWhere((e) =>
                    e.toString() == 'TestParameterType.${param['type']}'),
                minValue: param['minValue'] != null
                    ? (param['minValue'] as num).toDouble()
                    : null,
                maxValue: param['maxValue'] != null
                    ? (param['maxValue'] as num).toDouble()
                    : null,
                isCritical: param['isCritical'] as bool,
                description: param['description'] as String?,
                metadata: param['metadata'] != null
                    ? Map<String, dynamic>.from(param['metadata'])
                    : null,
              ))
          .toList(),
      pricingTiers: (map['pricingTiers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          PricingTier(
            name: value['name'] as String,
            minFatPercentage: (value['minFatPercentage'] as num).toDouble(),
            minProteinPercentage:
                (value['minProteinPercentage'] as num).toDouble(),
            maxSomaticCellCount: value['maxSomaticCellCount'] as int,
            maxTotalBacterialCount: value['maxTotalBacterialCount'] as int,
            priceAdjustmentPercentage:
                (value['priceAdjustmentPercentage'] as num).toDouble(),
            description: value['description'] as String,
          ),
        ),
      ),
      effectiveFrom: (map['effectiveFrom'] as Timestamp).toDate(),
      effectiveTo: (map['effectiveTo'] as Timestamp?)?.toDate(),
      notes: map['notes'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
  const MilkQualityStandardsModel({
    required this.id,
    required this.name,
    required this.milkType,
    required this.isActive,
    required this.parameters,
    required this.pricingTiers,
    required this.effectiveFrom,
    this.effectiveTo,
    this.notes,
    this.metadata,
  });

  final String id;
  final String name;
  final MilkQualityType milkType; // Using MilkQualityType enum
  final bool isActive;
  final List<QualityParameter> parameters;
  final Map<String, PricingTier> pricingTiers;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'milkType': milkType.toString().split('.').last,
      'isActive': isActive,
      'parameters': parameters
          .map((param) => {
                'name': param.name,
                'unit': param.unit,
                'type': param.type.toString().split('.').last,
                'minValue': param.minValue,
                'maxValue': param.maxValue,
                'isCritical': param.isCritical,
                'description': param.description,
                'metadata': param.metadata,
              })
          .toList(),
      'pricingTiers': pricingTiers.map((key, value) => MapEntry(key, {
            'name': value.name,
            'minFatPercentage': value.minFatPercentage,
            'minProteinPercentage': value.minProteinPercentage,
            'maxSomaticCellCount': value.maxSomaticCellCount,
            'maxTotalBacterialCount': value.maxTotalBacterialCount,
            'priceAdjustmentPercentage': value.priceAdjustmentPercentage,
            'description': value.description
          })),
      'effectiveFrom': Timestamp.fromDate(effectiveFrom),
      'effectiveTo':
          effectiveTo != null ? Timestamp.fromDate(effectiveTo!) : null,
      'notes': notes,
      'metadata': metadata,
    };
  }
}
