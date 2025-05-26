import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_context.dart';

// This provider could manage application-wide AI context or user-specific AI preferences
// that might influence AI behavior across different modules.

class AIAppContextState {
  final String? currentUserId;
  final String? currentSessionId;
  // Add other relevant app-wide AI context fields, e.g., user's role, current focus module

  AIAppContextState({this.currentUserId, this.currentSessionId});

  AIAppContextState copyWith(
      {String? currentUserId, String? currentSessionId}) {
    return AIAppContextState(
      currentUserId: currentUserId ?? this.currentUserId,
      currentSessionId: sessionId ??
          this.currentSessionId, // Corrected: sessionId to currentSessionId
    );
  }
}

class AIAppContextNotifier extends StateNotifier<AIAppContextState> {
  AIAppContextNotifier() : super(AIAppContextState());

  void setUserId(String? userId) =>
      state = state.copyWith(currentUserId: userId);
  void setSessionId(String? sessionId) =>
      state = state.copyWith(currentSessionId: sessionId);
}

final aiAppContextProvider =
    StateNotifierProvider<AIAppContextNotifier, AIAppContextState>((ref) {
  return AIAppContextNotifier();
});
