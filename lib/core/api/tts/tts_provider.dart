/// TTS Provider 抽象接口
/// 所有 TTS 服务商都要实现这个接口
abstract class TtsProvider {
  /// 合成文本为语音，返回音频文件路径
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed,
  });

  /// 分段合成（长文本）
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed,
  });

  /// 服务商名称
  String get name;
}

/// TTS Provider 枚举
enum TtsProviderType {
  openai('OpenAI TTS'),
  minimax('MiniMax TTS'),
  mimo('小米 MiMo TTS');

  final String label;
  const TtsProviderType(this.label);
}
