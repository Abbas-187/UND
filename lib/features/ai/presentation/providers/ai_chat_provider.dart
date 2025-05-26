import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_response.dart';
import '../../data/services/universal_ai_service.dart'; // To send messages

class AIChatMessage {
  final String id;
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;
  final String? error; // For AI messages that failed

  AIChatMessage({
    required this.id,
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIChatState {
  final List<AIChatMessage> messages;
  final bool isLoading;
  final String? currentSessionId;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentSessionId,
  });

  AIChatState copyWith({
    List<AIChatMessage>? messages,
    bool? isLoading,
    String? currentSessionId,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  final UniversalAIService _aiService;
  final String _module; // Context for the chat

  AIChatNotifier(this._aiService, this._module)
      : super(AIChatState(
            currentSessionId:
                DateTime.now().millisecondsSinceEpoch.toString()));

  Future<void> sendMessage(String text, {String? userId}) async {
    if (text.trim().isEmpty) return;

    final userMessage = AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUserMessage: true);
    state = state
        .copyWith(messages: [...state.messages, userMessage], isLoading: true);

    try {
      final response = await _aiService.chat(
        message: text,
        module: _module,
        userId: userId,
        sessionId: state.currentSessionId,
      );

      final aiMessage = AIChatMessage(
        id: response.requestId,
        text: response.content ?? response.error ?? 'No response content.',
        isUserMessage: false,
        error: response.isSuccess ? null : response.error,
      );
      state = state
          .copyWith(messages: [...state.messages, aiMessage], isLoading: false);
    } catch (e) {
      final errorMessage = AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Error: ${e.toString()}",
          isUserMessage: false,
          error: e.toString());
      state = state.copyWith(
          messages: [...state.messages, errorMessage], isLoading: false);
    }
  }

  void clearChat() {
    state = AIChatState(
        currentSessionId: DateTime.now()
            .millisecondsSinceEpoch
            .toString()); // Start a new session
  }
}

final aiChatProvider =
    StateNotifierProvider.family<AIChatNotifier, AIChatState, String>(
        (ref, module) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return AIChatNotifier(universalAIService, module);
});
