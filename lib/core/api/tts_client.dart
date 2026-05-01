import 'tts/tts_provider.dart';
import 'tts/openai_provider.dart';
import 'tts/minimax_provider.dart';
import 'tts/mimo_provider.dart';

/// TTS 客户端 — 多 Provider 门面
/// 默认使用 OpenAI，可在 ApiConfig 中指定，或运行时动态切换
class TtsClient {
  TtsProvider? _provider;

  /// 当前 Provider
  TtsProvider get provider {
    _provider ??= _createProvider(TtsProviderType.openai);
    return _provider!;
  }

  /// 切换到指定 Provider
  void use(TtsProviderType type) {
    _provider = _createProvider(type);
  }

  /// 替换为自定义 Provider 实例（用于测试或特殊配置）
  void useCustom(TtsProvider custom) {
    _provider = custom;
  }

  /// 当前 Provider 名称
  String get providerName => provider.name;

  /// 合成文本 → 音频文件路径
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) {
    return provider.synthesize(
      text: text,
      voice: voice,
      speed: speed,
      extra: extra,
    );
  }

  /// 分段合成
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) {
    return provider.synthesizeSentences(
      text: text,
      voice: voice,
      speed: speed,
      extra: extra,
    );
  }

  TtsProvider _createProvider(TtsProviderType type) {
    switch (type) {
      case TtsProviderType.openai:
        return OpenaiTtsProvider();
      case TtsProviderType.minimax:
        return MiniMaxTtsProvider();
      case TtsProviderType.mimo:
        return MiMoTtsProvider();
    }
  }
}
