import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_discussion.dart';
import '../providers/order_discussion_provider.dart';
import '../services/order_discussion_service.dart';

// Mock imports - replace with actual imports when available
// import '../../order/models/order.dart';

// Provider for discussion - this would typically be in the providers directory
final discussionProvider =
    FutureProvider.family<OrderDiscussion?, String>((ref, discussionId) async {
  // This is a placeholder - actual implementation would fetch discussion
  // return ref.read(discussionRepositoryProvider).getDiscussion(discussionId);
  return null;
});

final discussionByOrderProvider =
    FutureProvider.family<OrderDiscussion?, String>((ref, orderId) async {
  // This is a placeholder - actual implementation would fetch discussion by order ID
  // return ref.read(discussionRepositoryProvider).getDiscussionByOrderId(orderId);
  return null;
});

// State notifier for sending messages
class MessageNotifier extends StateNotifier<AsyncValue<void>> {
  MessageNotifier() : super(const AsyncData(null));

  Future<void> sendMessage(String orderId, String content) async {
    state = const AsyncLoading();
    try {
      // This is a placeholder - actual implementation would send the message
      // await discussionRepository.sendMessage(orderId, content);
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, AsyncValue<void>>((ref) {
  return MessageNotifier();
});

// Mock classes for the demonstration
enum OrderStatus { draft, confirmed, processing, completed, cancelled }

enum ProductionStatus { notStarted, inProgress, completed }

enum ProcurementStatus { notRequired, pending, completed }

// Mock Order class
class Order {
  final String id;
  final String customer;
  final List<dynamic> items;
  final String location;
  final OrderStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductionStatus productionStatus;
  final ProcurementStatus procurementStatus;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.location,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.productionStatus,
    required this.procurementStatus,
  });
}

class DiscussionRoomScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? discussionId; // Can be null if a discussion doesn't exist yet
  final String? customerId; // Add customerId parameter
  final String? userId; // Add userId parameter

  const DiscussionRoomScreen({
    Key? key,
    required this.orderId,
    this.discussionId,
    this.customerId,
    this.userId,
  }) : super(key: key);

  @override
  ConsumerState<DiscussionRoomScreen> createState() =>
      _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends ConsumerState<DiscussionRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OrderDiscussionService _discussionService = OrderDiscussionService();
  List<MessageTemplate> _templates = [];
  bool _showTemplates = false;
  OrderDiscussion? discussion; // Add discussion variable

  @override
  void initState() {
    super.initState();
    _loadDiscussion();
    _loadTemplates();
    // Scroll to bottom when discussion loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Add missing methods
  Future<void> _loadDiscussion() async {
    try {
      if (widget.discussionId != null) {
        // Mock implementation - replace with actual service call
        final loadedDiscussion = await Future.delayed(
          const Duration(milliseconds: 300),
          () => OrderDiscussion(
            id: widget.discussionId!,
            orderId: widget.orderId,
            status: DiscussionStatus.open,
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            convertedToCrmInteraction: false,
          ),
        );
        setState(() {
          discussion = loadedDiscussion;
        });
      } else {
        // Mock implementation - replace with actual service call
        final loadedDiscussion = await Future.delayed(
          const Duration(milliseconds: 300),
          () => OrderDiscussion(
            id: 'disc_${widget.orderId}',
            orderId: widget.orderId,
            status: DiscussionStatus.open,
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            convertedToCrmInteraction: false,
          ),
        );
        setState(() {
          discussion = loadedDiscussion;
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading discussion: $e');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      // Mock implementation - replace with actual service call
      final templates = await Future.delayed(
        const Duration(milliseconds: 300),
        () => [
          MessageTemplate(id: '1', content: 'Hello! How can I help you?'),
          MessageTemplate(id: '2', content: 'Thank you for your order.'),
          MessageTemplate(id: '3', content: 'Is there anything else you need?'),
        ],
      );
      setState(() {
        _templates = templates;
      });
    } catch (e) {
      // Handle error
      print('Error loading templates: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Send the message using the state notifier
    ref
        .read(messageNotifierProvider.notifier)
        .sendMessage(widget.orderId, message)
        .then((_) {
      _messageController.clear();
      _scrollToBottom();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the discussion data
    final discussionAsync = widget.discussionId != null
        ? ref.watch(discussionProvider(widget.discussionId!))
        : ref.watch(discussionByOrderProvider(widget.orderId));

    // Watch the message sending state
    final messageSendingState = ref.watch(messageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Discussion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show discussion info
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _convertToCrmInteraction,
            tooltip: 'Save as CRM interaction',
          ),
        ],
      ),
      body: discussionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading discussion: $err')),
        data: (discussion) {
          if (discussion == null) {
            return const Center(
              child: Text('No discussion found for this order.'),
            );
          }

          return Column(
            children: [
              _buildDiscussionInfo(discussion),
              Expanded(
                child: discussion.messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Start the conversation!'),
                      )
                    : _buildMessageList(discussion),
              ),
              if (discussion.status != DiscussionStatus.locked)
                _buildMessageInput(messageSendingState),
              if (discussion.status == DiscussionStatus.locked)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  color: Colors.grey[200],
                  child: const Text(
                    'This discussion is locked and cannot be modified.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscussionInfo(OrderDiscussion discussion) {
    String statusText;
    Color statusColor;

    switch (discussion.status) {
      case DiscussionStatus.open:
        statusText = 'OPEN';
        statusColor = Colors.green;
        break;
      case DiscussionStatus.closed:
        statusText = 'CLOSED';
        statusColor = Colors.orange;
        break;
      case DiscussionStatus.locked:
        statusText = 'LOCKED';
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${discussion.orderId}'),
                Text(
                  'Created: ${discussion.createdAt.toString().substring(0, 16)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(OrderDiscussion discussion) {
    // TODO: Replace with actual currentUserId
    const currentUserId = 'currentUserId';

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: discussion.messages.length,
      itemBuilder: (context, index) {
        final message = discussion.messages[index];
        final isCurrentUser = message.senderId == currentUserId;

        return _buildMessageBubble(
          message,
          isCurrentUser,
          index > 0 &&
              discussion.messages[index - 1].senderId == message.senderId,
        );
      },
    );
  }

  Widget _buildMessageBubble(
      DiscussionMessage message, bool isCurrentUser, bool isSameSender) {
    return Padding(
      padding: EdgeInsets.only(
        top: isSameSender ? 4 : 12,
        bottom: 4,
        left: isCurrentUser ? 60 : 0,
        right: isCurrentUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSameSender)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                message.senderId, // TODO: Replace with actual user name
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content),
                const SizedBox(height: 4),
                Text(
                  message.timestamp.toString().substring(11, 16),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(AsyncValue<void> sendingState) {
    final isSending = sendingState is AsyncLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: () {
              // TODO: Implement attachment functionality
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              enabled: !isSending,
            ),
          ),
          IconButton(
            icon: isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _convertToCrmInteraction() async {
    if (discussion == null) return;

    // Skip if already converted
    if (discussion!.convertedToCrmInteraction) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Discussion already saved as CRM interaction')),
      );
      return;
    }

    try {
      // Mock implementation - replace with actual service call
      final updatedDiscussion = await Future.delayed(
        const Duration(milliseconds: 500),
        () => OrderDiscussion(
          id: discussion!.id,
          orderId: discussion!.orderId,
          status: discussion!.status,
          messages: discussion!.messages,
          createdAt: discussion!.createdAt,
          updatedAt: DateTime.now(),
          convertedToCrmInteraction: true,
        ),
      );

      setState(() {
        discussion = updatedDiscussion;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discussion saved as CRM interaction')),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving as CRM interaction: $e')),
      );
    }
  }
}

// Mock classes
class MessageTemplate {
  final String id;
  final String content;

  MessageTemplate({required this.id, required this.content});
}

// Mock OrderDiscussion class
enum DiscussionStatus { open, closed, locked }

class DiscussionMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  DiscussionMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

class OrderDiscussion {
  final String id;
  final String orderId;
  final DiscussionStatus status;
  final List<DiscussionMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool convertedToCrmInteraction;

  OrderDiscussion({
    required this.id,
    required this.orderId,
    required this.status,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.convertedToCrmInteraction,
  });
}

// Mock OrderDiscussionService
class OrderDiscussionService {
  Future<OrderDiscussion?> getDiscussion(String discussionId) async {
    // Placeholder implementation
    return null;
  }

  Future<OrderDiscussion?> getDiscussionByOrderId(String orderId) async {
    // Placeholder implementation
    return null;
  }

  Future<List<MessageTemplate>> getMessageTemplates() async {
    // Placeholder implementation
    return [];
  }

  Future<OrderDiscussion> convertToCrmInteraction(
      OrderDiscussion discussion, Order order) async {
    // Placeholder implementation
    return discussion;
  }
}
