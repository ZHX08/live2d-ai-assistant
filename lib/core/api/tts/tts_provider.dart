/// TTS Provider 抽象接口
/// 所有 TTS 服务商都要实现这个接口
/// 添加新的 Provider 只需:
///   1. 新建 xxx_provider.dart 实现 TtsProvider
///   2. ApiConfig 中加对应的 API Key
///   3. tts_client.dart 的 _createProvider 中注册
abstract class TtsProvider {
  /// 合成文本为语音，返回音频文件路径
  /// [text] 待合成文本
  /// [voice] 音色 ID（各 Provider 格式不同）
  /// [speed] 语速 (0.5~2.0)
  /// [extra] Provider 独有参数（情感、音高、采样率等），不修改接口
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  });

  /// 分段合成（长文本自动按句分割）
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  });

  /// 服务商名称
  String get name;
}

/// TTS Provider 枚举
/// 新增 Provider 时在此添加
enum TtsProviderType {
  openai('OpenAI TTS'),
  minimax('MiniMax TTS'),
  mimo('小米 MiMo TTS'),
  // 后续：
  // fishAudio('Fish Audio'),
  // cosyVoice('CosyVoice'),
  // qwenTts('Qwen3 TTS'),
  ;

  final String label;
  const TtsProviderType(this.label);
}
