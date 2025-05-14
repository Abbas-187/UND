import 'package:equatable/equatable.dart';

enum DiscussionStatus { open, closed, locked }

class DiscussionMessage extends Equatable {

  const DiscussionMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, senderId, content, timestamp];
}

class OrderDiscussionEntity extends Equatable {

  const OrderDiscussionEntity({
    required this.id,
    required this.orderId,
    required this.status,
    this.messages = const [],
    this.convertedToCrm = false,
  });
  final String id;
  final String orderId;
  final DiscussionStatus status;
  final List<DiscussionMessage> messages;
  final bool convertedToCrm;

  @override
  List<Object?> get props => [id, orderId, status, messages, convertedToCrm];
}
