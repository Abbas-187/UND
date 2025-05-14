import '../../domain/entities/order_discussion_entity.dart';
import 'order_discussion_model.dart';

class OrderDiscussionMapper {
  static OrderDiscussionEntity toEntity(OrderDiscussionModel model) =>
      model.toEntity();

  static OrderDiscussionModel fromEntity(OrderDiscussionEntity entity) =>
      OrderDiscussionModel.fromEntity(entity);

  static List<OrderDiscussionEntity> toEntityList(
          List<OrderDiscussionModel> models) =>
      models.map((m) => toEntity(m)).toList();

  static List<OrderDiscussionModel> fromEntityList(
          List<OrderDiscussionEntity> entities) =>
      entities.map((e) => fromEntity(e)).toList();
}
