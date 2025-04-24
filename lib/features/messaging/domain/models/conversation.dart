import 'package:uuid/uuid.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    this.name,
    this.isGroup = false,
    this.groupImageUrl,
  });

  factory Conversation.create({
    required List<String> participants,
    required String lastMessage,
    String? name,
    bool isGroup = false,
    String? groupImageUrl,
  }) {
    return Conversation(
      id: const Uuid().v4(),
      participants: participants,
      lastMessage: lastMessage,
      lastMessageTimestamp: DateTime.now(),
      unreadCount: 0,
      name: name,
      isGroup: isGroup,
      groupImageUrl: groupImageUrl,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List),
      lastMessage: json['lastMessage'] as String,
      lastMessageTimestamp:
          DateTime.parse(json['lastMessageTimestamp'] as String),
      unreadCount: json['unreadCount'] as int,
      name: json['name'] as String?,
      isGroup: json['isGroup'] as bool? ?? false,
      groupImageUrl: json['groupImageUrl'] as String?,
    );
  }

  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final String? name;
  final bool isGroup;
  final String? groupImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'unreadCount': unreadCount,
      'name': name,
      'isGroup': isGroup,
      'groupImageUrl': groupImageUrl,
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
    String? name,
    bool? isGroup,
    String? groupImageUrl,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
    );
  }
}
