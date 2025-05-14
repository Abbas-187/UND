import '../../domain/entities/order_audit_trail_entity.dart';
import 'order_audit_trail_model.dart';

class OrderAuditTrailMapper {
  static OrderAuditTrailEntity toEntity(OrderAuditTrailModel model) =>
      model.toEntity();

  static OrderAuditTrailModel fromEntity(OrderAuditTrailEntity entity) =>
      OrderAuditTrailModel.fromEntity(entity);

  static List<OrderAuditTrailEntity> toEntityList(
          List<OrderAuditTrailModel> models) =>
      models.map((m) => toEntity(m)).toList();

  static List<OrderAuditTrailModel> fromEntityList(
          List<OrderAuditTrailEntity> entities) =>
      entities.map((e) => fromEntity(e)).toList();
}
