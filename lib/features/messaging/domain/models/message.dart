import 'package:uuid/uuid.dart';

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.attachmentUrl,
    this.messageType = MessageType.text,
    this.deliveryStatus = DeliveryStatus.sending,
    this.isEncrypted = false,
    this.encryptionMetadata,
  });

  factory Message.create({
    required String senderId,
    required String receiverId,
    required String content,
    String? attachmentUrl,
    MessageType messageType = MessageType.text,
    bool isEncrypted = false,
    Map<String, dynamic>? encryptionMetadata,
  }) {
    return Message(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      attachmentUrl: attachmentUrl,
      messageType: messageType,
      deliveryStatus: DeliveryStatus.sending,
      isEncrypted: isEncrypted,
      encryptionMetadata: encryptionMetadata,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      attachmentUrl: json['attachmentUrl'] as String?,
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
        orElse: () => MessageType.text,
      ),
      deliveryStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == (json['deliveryStatus'] ?? 'sending'),
        orElse: () => DeliveryStatus.sending,
      ),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      encryptionMetadata: json['encryptionMetadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final MessageType messageType;
  final DeliveryStatus deliveryStatus;
  final bool isEncrypted;
  final Map<String, dynamic>? encryptionMetadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'messageType': messageType.name,
      'deliveryStatus': deliveryStatus.name,
      'isEncrypted': isEncrypted,
      'encryptionMetadata': encryptionMetadata,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentUrl,
    MessageType? messageType,
    DeliveryStatus? deliveryStatus,
    bool? isEncrypted,
    Map<String, dynamic>? encryptionMetadata,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      messageType: messageType ?? this.messageType,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encryptionMetadata: encryptionMetadata ?? this.encryptionMetadata,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
}

enum DeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
