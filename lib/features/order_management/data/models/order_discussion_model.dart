import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_discussion_entity.dart';

part 'order_discussion_model.g.dart';

@JsonSerializable()
class DiscussionMessageModel {

  DiscussionMessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory DiscussionMessageModel.fromJson(Map<String, dynamic> json) =>
      _$DiscussionMessageModelFromJson(json);
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  Map<String, dynamic> toJson() => _$DiscussionMessageModelToJson(this);
}

@JsonSerializable()
class OrderDiscussionModel {

  OrderDiscussionModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.messages,
    required this.convertedToCrm,
  });

  factory OrderDiscussionModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDiscussionModelFromJson(json);

  factory OrderDiscussionModel.fromEntity(OrderDiscussionEntity e) =>
      OrderDiscussionModel(
        id: e.id,
        orderId: e.orderId,
        status: e.status.index,
        messages: e.messages
            .map((m) => DiscussionMessageModel(
                  id: m.id,
                  senderId: m.senderId,
                  content: m.content,
                  timestamp: m.timestamp,
                ))
            .toList(),
        convertedToCrm: e.convertedToCrm,
      );
  final String id;
  final String orderId;
  final int status;
  final List<DiscussionMessageModel> messages;
  final bool convertedToCrm;
  Map<String, dynamic> toJson() => _$OrderDiscussionModelToJson(this);

  OrderDiscussionEntity toEntity() => OrderDiscussionEntity(
        id: id,
        orderId: orderId,
        status: DiscussionStatus.values[status],
        messages: messages
            .map((m) => DiscussionMessage(
                  id: m.id,
                  senderId: m.senderId,
                  content: m.content,
                  timestamp: m.timestamp,
                ))
            .toList(),
        convertedToCrm: convertedToCrm,
      );
}
