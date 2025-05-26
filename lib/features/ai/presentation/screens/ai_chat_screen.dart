import 'package:flutter/material.dart';
import '../widgets/universal_ai_chat_widget.dart';

class AIChatScreen extends StatelessWidget {
  final String module;
  final String? userId;
  final String? initialMessage;

  const AIChatScreen({
    super.key,
    required this.module,
    this.userId,
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Chat - ${module.toUpperCase()}')),
      body: UniversalAIChatWidget(
          module: module, userId: userId, initialMessage: initialMessage),
    );
  }
}
