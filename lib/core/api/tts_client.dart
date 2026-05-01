import 'tts/tts_provider.dart';
import 'tts/openai_provider.dart';
import 'tts/minimax_provider.dart';
import 'tts/mimo_provider.dart';

/// TTS 客户端 — 多 Provider 门面
/// 默认使用 OpenAI，可在 ApiConfig 中切换
class TtsClient {
  TtsProvider? _provider;

  /// 获取当前 Provider（懒加载）
  TtsProvider get provider {
    if (_provider == null) {
      _provider = _createProvider(TtsProviderType.openai);
    }
    return _provider!;
  }

  /// 切换 Provider
  void use(TtsProviderType type) {
    _provider = _createProvider(type);
  }

  /// 获取当前 Provider 名称
  String get providerName => provider.name;

  /// 合成文本为语音，返回音频文件路径
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
  }) {
    return provider.synthesize(text: text, voice: voice, speed: speed);
  }

  /// 分段合成
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
  }) {
    return provider.synthesizeSentences(text: text, voice: voice, speed: speed);
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
