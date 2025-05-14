import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/order_discussion_model.dart';
import '../../presentation/providers/order_discussion_provider.dart';

class DiscussionRoomScreen extends ConsumerStatefulWidget {
  const DiscussionRoomScreen({super.key});

  @override
  ConsumerState<DiscussionRoomScreen> createState() =>
      _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends ConsumerState<DiscussionRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String orderId;
  bool _sending = false;
  String? _editingMessageId;
  PlatformFile? _attachmentFile;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderId = GoRouterState.of(context).uri.queryParameters['id'] ?? '';
      // Real-time: provider should expose a Stream for messages
      ref.read(orderDiscussionProvider.notifier).subscribeToDiscussion(orderId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Unsubscribe from real-time updates if needed
    ref
        .read(orderDiscussionProvider.notifier)
        .unsubscribeFromDiscussion(orderId);
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty && _attachmentFile == null) return;
    setState(() => _sending = true);
    await ref.read(orderDiscussionProvider.notifier).postMessage(
          orderId,
          msg,
          'currentUser',
        );
    _messageController.clear();
    _attachmentFile = null;
    setState(() {
      _sending = false;
      _showEmojiPicker = false;
    });
    _scrollToBottom();
  }

  Future<void> _editMessage(String messageId, String oldContent) async {
    setState(() {
      _editingMessageId = messageId;
      _messageController.text = oldContent;
    });
  }

  Future<void> _saveEdit(String messageId) async {
    final newMsg = _messageController.text.trim();
    if (newMsg.isEmpty) return;
    setState(() => _sending = true);
    await ref
        .read(orderDiscussionProvider.notifier)
        .editMessage(orderId, messageId, newMsg);
    setState(() {
      _editingMessageId = null;
      _sending = false;
    });
    _messageController.clear();
  }

  Future<void> _deleteMessage(String messageId) async {
    await ref
        .read(orderDiscussionProvider.notifier)
        .deleteMessage(orderId, messageId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _closeDiscussion() async {
    await ref.read(orderDiscussionProvider.notifier).closeDiscussion(orderId);
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());
  Widget _buildError(Object e) => Center(child: Text('Error: $e'));
  Widget _buildEmpty() => const Center(child: Text('No discussion found.'));

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  Widget _buildAttachmentPreview() {
    if (_attachmentFile == null) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.attachment),
        Expanded(
            child:
                Text(_attachmentFile!.name, overflow: TextOverflow.ellipsis)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _attachmentFile = null),
          tooltip: 'Remove attachment',
        ),
      ],
    );
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachmentFile = result.files.first);
    }
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _messageController.text += emoji.emoji;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDiscussionProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Discussion', semanticsLabel: 'Discussion')),
      body: state.when(
        loading: _buildLoading,
        error: (e, st) => _buildError(e),
        data: (List<OrderDiscussionModel> list) {
          if (list.isEmpty) return _buildEmpty();
          final discussion = list.first;
          final msgs = discussion.messages;
          final isLocked = discussion.status == 'locked';
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
          List<Widget> messageWidgets = [];
          String? lastUser;
          for (int i = 0; i < msgs.length; i++) {
            final m = msgs[i];
            final isCurrentUser = m.senderId == 'currentUser';
            final showAvatar = lastUser != m.senderId;
            lastUser = m.senderId;
            messageWidgets.add(
              Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showAvatar)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            backgroundColor:
                                isCurrentUser ? Colors.blue : Colors.grey,
                            child: Text(m.senderId[0].toUpperCase()),
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (showAvatar)
                              Text(
                                m.senderId,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                                semanticsLabel: 'Sender',
                              ),
                            if (_editingMessageId == m.id)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      autofocus: true,
                                      onSubmitted: (_) => _saveEdit(m.id),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () => _saveEdit(m.id),
                                    tooltip: 'Save',
                                  ),
                                ],
                              )
                            else
                              Text(m.content),
                            Text(_formatTimestamp(m.timestamp),
                                style: const TextStyle(fontSize: 10)),
                            if (isCurrentUser && _editingMessageId != m.id)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    onPressed: () =>
                                        _editMessage(m.id, m.content),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16),
                                    onPressed: () => _deleteMessage(m.id),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  ListTile(
                    title: Text('Order #$orderId'),
                    subtitle: Text(
                      discussion.status
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                      semanticsLabel: 'Discussion status',
                    ),
                    trailing: !isLocked
                        ? TextButton(
                            onPressed: _closeDiscussion,
                            child: const Text('Close'),
                          )
                        : null,
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: messageWidgets,
                    ),
                  ),
                  if (!isLocked)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildAttachmentPreview(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.emoji_emotions),
                                onPressed: () => setState(
                                    () => _showEmojiPicker = !_showEmojiPicker),
                                tooltip: 'Emoji picker',
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _pickAttachment,
                                tooltip: 'Attach file',
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    labelText: 'Type your message',
                                  ),
                                  onSubmitted: (_) => !_sending &&
                                          _messageController.text
                                              .trim()
                                              .isNotEmpty
                                      ? _sendMessage()
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Semantics(
                                button: true,
                                enabled: !_sending &&
                                    _messageController.text.trim().isNotEmpty,
                                child: IconButton(
                                  icon: _sending
                                      ? const CircularProgressIndicator()
                                      : const Icon(Icons.send),
                                  onPressed: !_sending &&
                                          _messageController.text
                                              .trim()
                                              .isNotEmpty
                                      ? _sendMessage
                                      : null,
                                  tooltip: 'Send message',
                                ),
                              ),
                            ],
                          ),
                          if (_showEmojiPicker) _buildEmojiPicker(),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Discussion is locked',
                          style: TextStyle(color: Colors.grey)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
