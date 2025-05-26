import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_response.dart';
// Assuming you'll have a chat provider to manage state and interactions
import '../providers/ai_chat_provider.dart'; // We'll create this later in Week 4

class UniversalAIChatWidget extends ConsumerStatefulWidget {
  final String module; // To provide context for the chat
  final String? userId;
  final String? initialMessage;

  const UniversalAIChatWidget({
    super.key,
    required this.module,
    this.userId,
    this.initialMessage,
  });

  @override
  ConsumerState<UniversalAIChatWidget> createState() =>
      _UniversalAIChatWidgetState();
}

class _UniversalAIChatWidgetState extends ConsumerState<UniversalAIChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      // Potentially send initial message or pre-fill
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      // ref.read(aiChatProvider(widget.module).notifier).sendMessage(message, userId: widget.userId);
      // For now, let's just simulate adding to a local list or printing
      print("Sending message: $message in module ${widget.module}");
      _controller.clear();
      // Scroll to bottom
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final chatState = ref.watch(aiChatProvider(widget.module)); // Placeholder for actual state
    final messages = []; // Placeholder for List<AIMessage> or similar

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length, // Replace with actual messages
            itemBuilder: (context, index) {
              // final message = messages[index];
              // return ListTile(title: Text(message.text), leading: Icon(message.isUser ? Icons.person : Icons.computer));
              return ListTile(
                  title: Text("Message ${index + 1}")); // Placeholder
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Ask AI...'),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
