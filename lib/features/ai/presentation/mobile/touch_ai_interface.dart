import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../../data/services/universal_ai_service.dart';
import '../../../data/providers/claude_ai_provider.dart';

/// Touch-friendly AI interface with optimized mobile interactions,
/// swipe gestures, and responsive design for warehouse operations
class TouchAIInterface extends StatefulWidget {
  final String? initialQuery;
  final Function(String)? onQuerySubmitted;
  final bool enableVoiceInput;
  final bool showQuickActions;

  const TouchAIInterface({
    Key? key,
    this.initialQuery,
    this.onQuerySubmitted,
    this.enableVoiceInput = true,
    this.showQuickActions = true,
  }) : super(key: key);

  @override
  State<TouchAIInterface> createState() => _TouchAIInterfaceState();
}

class _TouchAIInterfaceState extends State<TouchAIInterface>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _messagesController = ScrollController();
  final UniversalAIService _aiService = UniversalAIService();
  final ClaudeAIProvider _claudeProvider = ClaudeAIProvider();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _showQuickActions = true;
  String _selectedContext = 'general';

  // Touch interaction state
  double _keyboardHeight = 0;
  bool _isKeyboardVisible = false;
  Offset? _lastPanStart;
  Offset? _lastPanUpdate;

  // Quick action categories
  final List<QuickActionCategory> _quickActionCategories = [
    QuickActionCategory(
      title: 'Inventory',
      icon: Icons.inventory_2,
      color: const Color(0xFF4CAF50),
      actions: [
        'Check stock levels',
        'Find product location',
        'Generate inventory report',
        'Predict reorder needs',
      ],
    ),
    QuickActionCategory(
      title: 'Production',
      icon: Icons.precision_manufacturing,
      color: const Color(0xFF2196F3),
      actions: [
        'Check production status',
        'Schedule maintenance',
        'Optimize workflow',
        'Quality analysis',
      ],
    ),
    QuickActionCategory(
      title: 'Analytics',
      icon: Icons.analytics,
      color: const Color(0xFFFF9800),
      actions: [
        'Generate insights',
        'Performance metrics',
        'Trend analysis',
        'Cost optimization',
      ],
    ),
    QuickActionCategory(
      title: 'Alerts',
      icon: Icons.notification_important,
      color: const Color(0xFFF44336),
      actions: [
        'Check active alerts',
        'Review warnings',
        'Emergency protocols',
        'System status',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeKeyboardListener();
    _loadInitialMessages();

    if (widget.initialQuery != null) {
      _textController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  void _initializeKeyboardListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showQuickActions = false;
        });
      }
    });
  }

  void _loadInitialMessages() {
    _messages = [
      ChatMessage(
        id: '1',
        content:
            'Hello! I\'m your AI assistant. How can I help you with warehouse operations today?',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildChatInterface(),
            ),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Context: ${_selectedContext.capitalize()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showContextSelector();
            },
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            if (_showQuickActions && widget.showQuickActions)
              _buildQuickActionsGrid(),
          ],
        ),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _messagesController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    final isLast = index == _messages.length - 1;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(isUser ? 1.0 : -1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      )),
      child: Container(
        margin: EdgeInsets.only(
          bottom: isLast ? 16 : 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _showMessageOptions(message);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: Border.all(
                    color:
                        isUser ? Colors.transparent : const Color(0xFF2A2F3E),
                  ),
                ),
                child: _buildMessageContent(message),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.messageType) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isUser ? Colors.black : Colors.white,
            height: 1.4,
          ),
        );
      case MessageType.actionCard:
        return _buildActionCard(message);
      case MessageType.chart:
        return _buildChartMessage(message);
      case MessageType.list:
        return _buildListMessage(message);
    }
  }

  Widget _buildActionCard(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.title ?? 'Action Required',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          if (message.actions != null && message.actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: message.actions!
                  .map((action) => _buildActionButton(action))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _executeAction(action);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E5FF)),
        ),
        child: Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChartMessage(ChatMessage message) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.title ?? 'Chart Data',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                'Interactive Chart: ${message.content}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListMessage(ChatMessage message) {
    final items = message.listItems ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.title != null) ...[
            Text(
              message.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickActionCategories.length,
              itemBuilder: (context, index) {
                final category = _quickActionCategories[index];
                return _buildQuickActionCategory(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCategory(QuickActionCategory category) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showCategoryActions(category);
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: category.color.withOpacity(0.5)),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2F3E)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2F3E)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                      onTap: () {
                        setState(() {
                          _showQuickActions = false;
                        });
                      },
                    ),
                  ),
                  if (widget.enableVoiceInput)
                    GestureDetector(
                      onTap: _toggleVoiceInput,
                      onLongPress: _startContinuousListening,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isListening ? _pulseAnimation.value : 1.0,
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? const Color(0xFFF44336)
                                    : const Color(0xFF00E5FF),
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _sendMessage(_textController.text);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
            SizedBox(height: 16),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      messageType: MessageType.text,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _showQuickActions = false;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.processQuery(
        query: text.trim(),
        context: _selectedContext,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_ai',
        content: response.content,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: _determineMessageType(response.content),
        title: response.title,
        actions: response.suggestedActions,
        listItems: response.listData,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();

      if (widget.onQuerySubmitted != null) {
        widget.onQuerySubmitted!(text.trim());
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_error',
        content:
            'Sorry, I encountered an error processing your request. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _toggleVoiceInput() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _pulseController.repeat();
      _startVoiceRecognition();
    } else {
      _pulseController.stop();
      _stopVoiceRecognition();
    }
  }

  void _startContinuousListening() {
    HapticFeedback.heavyImpact();
    // Implement continuous listening
  }

  void _startVoiceRecognition() {
    // Implement voice recognition
  }

  void _stopVoiceRecognition() {
    // Stop voice recognition
  }

  void _showContextSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContextSelector(),
    );
  }

  Widget _buildContextSelector() {
    final contexts = [
      'general',
      'inventory',
      'production',
      'analytics',
      'alerts'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Context',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...contexts
              .map((context) => ListTile(
                    title: Text(
                      context.capitalize(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: Radio<String>(
                      value: context,
                      groupValue: _selectedContext,
                      activeColor: const Color(0xFF00E5FF),
                      onChanged: (value) {
                        setState(() {
                          _selectedContext = value!;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  void _showCategoryActions(QuickActionCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(category.icon, color: category.color),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...category.actions
                .map((action) => ListTile(
                      title: Text(
                        action,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _executeQuickAction(action);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            if (!message.isUser) ...[
              ListTile(
                leading: const Icon(Icons.thumb_up, color: Colors.white),
                title: const Text('Good Response',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _rateResponse(message, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.thumb_down, color: Colors.white),
                title: const Text('Poor Response',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _rateResponse(message, false);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _executeAction(String action) {
    _sendMessage(action);
  }

  void _executeQuickAction(String action) {
    _sendMessage(action);
  }

  void _rateResponse(ChatMessage message, bool positive) {
    // Implement response rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(positive ? 'Response rated as helpful' : 'Feedback recorded'),
        backgroundColor: positive ? Colors.green : Colors.orange,
      ),
    );
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_messagesController.hasClients) {
        _messagesController.animateTo(
          _messagesController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  MessageType _determineMessageType(String content) {
    if (content.contains('chart') || content.contains('graph')) {
      return MessageType.chart;
    } else if (content.contains('•') || content.contains('-')) {
      return MessageType.list;
    } else if (content.contains('action') || content.contains('recommend')) {
      return MessageType.actionCard;
    }
    return MessageType.text;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

// Data Models
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;
  final String? title;
  final List<String>? actions;
  final List<String>? listItems;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
    this.title,
    this.actions,
    this.listItems,
  });
}

enum MessageType { text, actionCard, chart, list }

class QuickActionCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> actions;

  QuickActionCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.actions,
  });
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
