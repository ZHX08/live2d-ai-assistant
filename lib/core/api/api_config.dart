class ApiConfig {
  static const String llmBaseUrl = 'https://api.deepseek.com';
  static const String llmModel = 'deepseek-chat';
  static const String asrBaseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String asrModel = 'whisper-1';
  static const String ttsBaseUrl = 'https://api.openai.com/v1/audio/speech';
  static const String ttsModel = 'tts-1';
  static const String ttsVoice = 'nova';

  static String? llmApiKey;
  static String? asrApiKey;
  static String? ttsApiKey;

  static Future<void> init({
    String? llmKey,
    String? asrKey,
    String? ttsKey,
  }) async {
    llmApiKey = llmKey;
    asrApiKey = asrKey;
    ttsApiKey = ttsKey;
  }
}
