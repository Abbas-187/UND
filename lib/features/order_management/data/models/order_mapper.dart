// order_mapper.dart
import '../../domain/entities/order_entity.dart';
import 'order_model.dart';

class OrderMapper {
  static OrderEntity toEntity(OrderModel model) {
    return model.toEntity();
  }

  static OrderModel fromEntity(OrderEntity entity) {
    return OrderModel.fromEntity(entity);
  }

  static List<OrderEntity> listToEntity(List<OrderModel> models) {
    return models.map((m) => toEntity(m)).toList();
  }

  static List<OrderModel> listFromEntity(List<OrderEntity> entities) {
    return entities.map((e) => fromEntity(e)).toList();
  }
}
