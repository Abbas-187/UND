import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'dart:collection';

@immutable
class OrderDiscussion {
  final String id;
  final String orderId;
  final List<String> participants;
  final List<DiscussionMessage> messages;
  final DateTime createdAt;
  final DateTime? closedAt;
  final DiscussionStatus status;
  // New CRM-related fields
  final List<MessageTemplate>? templates;
  final SentimentType? sentiment;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final bool convertedToCrmInteraction;
  final String? interactionId;

  const OrderDiscussion({
    required this.id,
    required this.orderId,
    required this.participants,
    required this.messages,
    required this.createdAt,
    this.closedAt,
    required this.status,
    // New CRM-related fields
    this.templates,
    this.sentiment,
    this.followUpRequired = false,
    this.followUpDate,
    this.convertedToCrmInteraction = false,
    this.interactionId,
  });

  // Provides immutable access to participants and messages
  List<String> get participantsList => List.unmodifiable(participants);
  List<DiscussionMessage> get messagesList => List.unmodifiable(messages);
  List<MessageTemplate>? get templatesList =>
      templates != null ? List.unmodifiable(templates!) : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDiscussion &&
        other.id == id &&
        other.orderId == orderId &&
        listEquals(other.participants, participants) &&
        listEquals(other.messages, messages) &&
        other.createdAt == createdAt &&
        other.closedAt == closedAt &&
        other.status == status &&
        // New CRM-related fields
        listEquals(other.templates, templates) &&
        other.sentiment == sentiment &&
        other.followUpRequired == followUpRequired &&
        other.followUpDate == followUpDate &&
        other.convertedToCrmInteraction == convertedToCrmInteraction &&
        other.interactionId == interactionId;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orderId,
        Object.hashAll(participants),
        Object.hashAll(messages),
        createdAt,
        closedAt,
        status,
        // New CRM-related fields
        templates != null ? Object.hashAll(templates!) : null,
        sentiment,
        followUpRequired,
        followUpDate,
        convertedToCrmInteraction,
        interactionId,
      ]);

  // Creates a copy with modified fields
  OrderDiscussion copyWith({
    String? id,
    String? orderId,
    List<String>? participants,
    List<DiscussionMessage>? messages,
    DateTime? createdAt,
    DateTime? closedAt,
    DiscussionStatus? status,
    // New CRM-related fields
    List<MessageTemplate>? templates,
    SentimentType? sentiment,
    bool? followUpRequired,
    DateTime? followUpDate,
    bool? convertedToCrmInteraction,
    String? interactionId,
  }) {
    return OrderDiscussion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      status: status ?? this.status,
      // New CRM-related fields
      templates: templates ?? this.templates,
      sentiment: sentiment ?? this.sentiment,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpDate: followUpDate ?? this.followUpDate,
      convertedToCrmInteraction:
          convertedToCrmInteraction ?? this.convertedToCrmInteraction,
      interactionId: interactionId ?? this.interactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'participants': participants,
      'messages': messages.map((message) => message.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'status': status.name,
      // New CRM-related fields
      'templates': templates?.map((template) => template.toJson()).toList(),
      'sentiment': sentiment?.name,
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate?.toIso8601String(),
      'convertedToCrmInteraction': convertedToCrmInteraction,
      'interactionId': interactionId,
    };
  }

  factory OrderDiscussion.fromJson(Map<String, dynamic> json) {
    return OrderDiscussion(
      id: json['id'],
      orderId: json['orderId'],
      participants: List<String>.from(json['participants']),
      messages: (json['messages'] as List)
          .map((message) => DiscussionMessage.fromJson(message))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      closedAt:
          json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      status:
          DiscussionStatus.values.firstWhere((e) => e.name == json['status']),
      // New CRM-related fields
      templates: json['templates'] != null
          ? (json['templates'] as List)
              .map((template) => MessageTemplate.fromJson(template))
              .toList()
          : null,
      sentiment: json['sentiment'] != null
          ? SentimentType.values.firstWhere((e) => e.name == json['sentiment'])
          : null,
      followUpRequired: json['followUpRequired'] ?? false,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
      convertedToCrmInteraction: json['convertedToCrmInteraction'] ?? false,
      interactionId: json['interactionId'],
    );
  }
}

@immutable
class DiscussionMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;
  // New CRM-related fields
  final SentimentType? sentiment;
  final bool isTemplatedMessage;
  final String? templateId;

  const DiscussionMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
    // New CRM-related fields
    this.sentiment,
    this.isTemplatedMessage = false,
    this.templateId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscussionMessage &&
        other.senderId == senderId &&
        other.content == content &&
        other.timestamp == timestamp &&
        // New CRM-related fields
        other.sentiment == sentiment &&
        other.isTemplatedMessage == isTemplatedMessage &&
        other.templateId == templateId;
  }

  @override
  int get hashCode => Object.hashAll([
        senderId,
        content,
        timestamp,
        // New CRM-related fields
        sentiment,
        isTemplatedMessage,
        templateId,
      ]);

  DiscussionMessage copyWith({
    String? senderId,
    String? content,
    DateTime? timestamp,
    // New CRM-related fields
    SentimentType? sentiment,
    bool? isTemplatedMessage,
    String? templateId,
  }) {
    return DiscussionMessage(
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      // New CRM-related fields
      sentiment: sentiment ?? this.sentiment,
      isTemplatedMessage: isTemplatedMessage ?? this.isTemplatedMessage,
      templateId: templateId ?? this.templateId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      // New CRM-related fields
      'sentiment': sentiment?.name,
      'isTemplatedMessage': isTemplatedMessage,
      'templateId': templateId,
    };
  }

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      // New CRM-related fields
      sentiment: json['sentiment'] != null
          ? SentimentType.values.firstWhere((e) => e.name == json['sentiment'])
          : null,
      isTemplatedMessage: json['isTemplatedMessage'] ?? false,
      templateId: json['templateId'],
    );
  }
}

// New class for message templates
@immutable
class MessageTemplate {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isDefault;

  const MessageTemplate({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageTemplate &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        listEquals(other.tags, tags) &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        content,
        Object.hashAll(tags),
        isDefault,
      ]);

  MessageTemplate copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    bool? isDefault,
  }) {
    return MessageTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'isDefault': isDefault,
    };
  }

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

enum DiscussionStatus {
  open,
  closed,
  locked,
}

// New enum for sentiment analysis
enum SentimentType {
  positive,
  neutral,
  negative,
  urgent,
  satisfied,
  frustrated,
}
