import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/live2d_state.dart';
import '../../services/conversation_service.dart';

class ChatState {
  final Live2dState live2dState;
  final List<ChatMessage> messages;
  final bool isProcessing;
  final String? currentReply;
  final String? error;

  const ChatState({
    this.live2dState = Live2dState.idle,
    this.messages = const [],
    this.isProcessing = false,
    this.currentReply,
    this.error,
  });

  ChatState copyWith({
    Live2dState? live2dState,
    List<ChatMessage>? messages,
    bool? isProcessing,
    String? currentReply,
    String? error,
  }) {
    return ChatState(
      live2dState: live2dState ?? this.live2dState,
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      currentReply: currentReply,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ConversationService _service = ConversationService();

  ChatNotifier() : super(const ChatState());

  Future<void> startVoice() async {
    try {
      await _service.startVoiceRound(
        onStateChange: (s) => state = state.copyWith(live2dState: s),
      );
    } catch (e) {
      state = state.copyWith(live2dState: Live2dState.idle, error: '录音失败: $e');
    }
  }

  Future<void> stopVoice() async {
    try {
      final reply = await _service.stopVoiceRound(
        onStateChange: (s) => state = state.copyWith(live2dState: s),
        onPartialText: (t) => state = state.copyWith(currentReply: t),
      );
      if (reply.isNotEmpty) {
        state = state.copyWith(messages: _service.history, currentReply: null, error: null);
      }
    } catch (e) {
      state = state.copyWith(live2dState: Live2dState.idle, error: '处理失败: $e');
    }
  }

  Future<void> sendText(String text) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final reply = await _service.sendTextMessage(
        text: text,
        onStateChange: (s) => state = state.copyWith(live2dState: s),
        onPartialText: (t) => state = state.copyWith(currentReply: t),
      );
      state = state.copyWith(messages: _service.history, isProcessing: false, currentReply: null);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: '发送失败: $e');
    }
  }

  void clearChat() { _service.clearHistory(); state = const ChatState(); }
  @override void dispose() { _service.dispose(); super.dispose(); }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier());
