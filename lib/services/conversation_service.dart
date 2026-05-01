import '../core/api/asr_client.dart';
import '../core/api/llm_client.dart';
import '../core/api/tts_client.dart';
import '../core/audio/player.dart';
import '../core/audio/recorder.dart';
import '../core/models/chat_message.dart';
import '../core/models/live2d_state.dart';
import 'live2d_service.dart';

class ConversationService {
  final AppAudioRecorder _recorder = AppAudioRecorder();
  final AppAudioPlayer _player = AppAudioPlayer();
  final AsrClient _asr = AsrClient();
  final LlmClient _llm = LlmClient();
  final TtsClient _tts = TtsClient();
  final Live2DService _live2d = live2DService;

  final List<ChatMessage> _history = [];
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;
  List<ChatMessage> get history => List.unmodifiable(_history);

  Future<void> startVoiceRound({
    required void Function(Live2dState state) onStateChange,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;
    final granted = await _recorder.requestPermission();
    if (!granted) { _isProcessing = false; throw Exception('麦克风权限被拒绝'); }
    onStateChange(Live2dState.listening);
    await _recorder.startRecording();
  }

  Future<String> stopVoiceRound({
    required void Function(Live2dState state) onStateChange,
    void Function(String partial)? onPartialText,
  }) async {
    try {
      final audioPath = await _recorder.stopRecording();
      if (audioPath == null || audioPath.isEmpty) {
        _isProcessing = false;
        onStateChange(Live2dState.idle);
        return '';
      }
      onStateChange(Live2dState.thinking);
      final userText = await _asr.transcribe(audioPath: audioPath, language: 'zh');
      if (userText.trim().isEmpty) {
        _isProcessing = false;
        onStateChange(Live2dState.idle);
        return '';
      }
      _history.add(ChatMessage(role: MessageRole.user, text: userText));

      String fullReply = '';
      await for (final delta in _llm.chatStream(messages: _history)) {
        fullReply += delta;
        onPartialText?.call(fullReply);
      }
      _history.add(ChatMessage(role: MessageRole.assistant, text: fullReply));

      onStateChange(Live2dState.speaking);
      final audioFile = await _tts.synthesize(text: fullReply);
      await _player.play(audioFile);

      onStateChange(Live2dState.idle);
      _isProcessing = false;
      return fullReply;
    } catch (e) {
      _isProcessing = false;
      onStateChange(Live2dState.idle);
      rethrow;
    }
  }

  Future<String> sendTextMessage({
    required String text,
    required void Function(Live2dState state) onStateChange,
    void Function(String partial)? onPartialText,
  }) async {
    _isProcessing = true;
    try {
      _history.add(ChatMessage(role: MessageRole.user, text: text));
      onStateChange(Live2dState.thinking);

      String fullReply = '';
      await for (final delta in _llm.chatStream(messages: _history)) {
        fullReply += delta;
        onPartialText?.call(fullReply);
      }
      _history.add(ChatMessage(role: MessageRole.assistant, text: fullReply));

      onStateChange(Live2dState.speaking);
      final audioFile = await _tts.synthesize(text: fullReply);
      await _player.play(audioFile);

      onStateChange(Live2dState.idle);
      _isProcessing = false;
      return fullReply;
    } catch (e) {
      _isProcessing = false;
      onStateChange(Live2dState.idle);
      rethrow;
    }
  }

  void clearHistory() => _history.clear();
  void dispose() { _recorder.dispose(); _player.dispose(); }
}
