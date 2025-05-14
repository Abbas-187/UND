import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cost_layer.dart';

part 'cost_layer_model.freezed.dart';
part 'cost_layer_model.g.dart';

@freezed
abstract class CostLayerModel with _$CostLayerModel {
  const factory CostLayerModel({
    String? id,
    required String itemId,
    required String warehouseId,
    required String batchLotNumber,
    required double initialQuantity,
    required double remainingQuantity,
    required double costAtTransaction,
    String? movementId,
    required DateTime movementDate,
    DateTime? expirationDate,
    DateTime? productionDate,
    required DateTime createdAt,
  }) = _CostLayerModel;

  factory CostLayerModel.fromJson(Map<String, dynamic> json) =>
      _$CostLayerModelFromJson(json);

  factory CostLayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime getDate(dynamic field) {
      if (field is Timestamp) return field.toDate();
      return DateTime.parse(field.toString());
    }

    return CostLayerModel(
      id: doc.id,
      itemId: data['itemId'] as String,
      warehouseId: data['warehouseId'] as String,
      batchLotNumber: data['batchLotNumber'] as String,
      initialQuantity: (data['initialQuantity'] as num).toDouble(),
      remainingQuantity: (data['remainingQuantity'] as num).toDouble(),
      costAtTransaction: (data['costAtTransaction'] as num).toDouble(),
      movementId: data['movementId'] as String?,
      movementDate: getDate(data['movementDate']),
      expirationDate: data['expirationDate'] != null
          ? getDate(data['expirationDate'])
          : null,
      productionDate: data['productionDate'] != null
          ? getDate(data['productionDate'])
          : null,
      createdAt: getDate(data['createdAt']),
    );
  }
}

extension CostLayerModelX on CostLayerModel {
  CostLayer toDomain() => CostLayer(
        id: id ?? '',
        itemId: itemId,
        warehouseId: warehouseId,
        batchLotNumber: batchLotNumber,
        initialQuantity: initialQuantity,
        remainingQuantity: remainingQuantity,
        costAtTransaction: costAtTransaction,
        movementId: movementId,
        movementDate: movementDate,
        expirationDate: expirationDate,
        productionDate: productionDate,
        createdAt: createdAt,
      );

  static CostLayerModel fromDomain(CostLayer layer) => CostLayerModel(
        id: layer.id,
        itemId: layer.itemId,
        warehouseId: layer.warehouseId,
        batchLotNumber: layer.batchLotNumber,
        initialQuantity: layer.initialQuantity,
        remainingQuantity: layer.remainingQuantity,
        costAtTransaction: layer.costAtTransaction,
        movementId: layer.movementId,
        movementDate: layer.movementDate,
        expirationDate: layer.expirationDate,
        productionDate: layer.productionDate,
        createdAt: layer.createdAt,
      );
}
