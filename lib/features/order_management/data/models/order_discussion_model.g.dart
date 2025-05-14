// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_discussion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscussionMessageModel _$DiscussionMessageModelFromJson(
        Map<String, dynamic> json) =>
    DiscussionMessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$DiscussionMessageModelToJson(
        DiscussionMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

OrderDiscussionModel _$OrderDiscussionModelFromJson(
        Map<String, dynamic> json) =>
    OrderDiscussionModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      status: (json['status'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map(
              (e) => DiscussionMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      convertedToCrm: json['converted_to_crm'] as bool,
    );

Map<String, dynamic> _$OrderDiscussionModelToJson(
        OrderDiscussionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'status': instance.status,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'converted_to_crm': instance.convertedToCrm,
    };
