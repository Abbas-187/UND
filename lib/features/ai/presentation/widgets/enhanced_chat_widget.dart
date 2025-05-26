import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_message.dart';
import '../providers/chat_providers.dart'; // Assuming chat specific providers
import 'voice_ai_widget.dart';
import 'file_upload_widget.dart';

class EnhancedChatWidget extends ConsumerStatefulWidget {
  final String module;
  final bool showModuleSelector;
  final bool isModal;
  final ScrollController?
      scrollController; // For use in DraggableScrollableSheet

  const EnhancedChatWidget({
    Key? key,
    required this.module,
    this.showModuleSelector = false,
    this.isModal = false,
    this.scrollController,
  }) : super(key: key);

  @override
  _EnhancedChatWidgetState createState() => _EnhancedChatWidgetState();
}

class _EnhancedChatWidgetState extends ConsumerState<EnhancedChatWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  String _selectedModule = 'general';

  @override
  void initState() {
    super.initState();
    _selectedModule = widget.module;
    // Example: Load initial messages or context based on module
    // ref.read(chatControllerProvider(_selectedModule).notifier).loadInitialMessages();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref
        .read(chatControllerProvider(_selectedModule).notifier)
        .sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Ensure messages are built before trying to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(_selectedModule));

    return Column(
      children: [
        if (widget.isModal)
          Container(
            // Handle for DraggableScrollableSheet
            width: 40,
            height: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        if (widget.showModuleSelector) _buildModuleSelector(),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController ?? _listScrollController,
            padding: EdgeInsets.all(8.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildModuleSelector() {
    // Placeholder for module selection UI
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: _selectedModule,
        items: ['general', 'inventory', 'production', 'quality']
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                ))
            .toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedModule = newValue;
              // Potentially clear messages or load context for new module
              // ref.read(chatControllerProvider(newValue).notifier).loadInitialMessages();
            });
          }
        },
        isExpanded: true,
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    bool isUserMessage = message.sender == MessageSender.user;
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color:
              isUserMessage ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.text,
          style:
              TextStyle(color: isUserMessage ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 1,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          FileUploadWidget(onFileUploaded: (filePath) {
            // Handle file path, e.g., send as part of message or analyze
            _sendMessage("Uploaded file: $filePath (content to be processed)");
          }),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          VoiceAIWidget(onSpeechResult: (text) => _sendMessage(text)),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
