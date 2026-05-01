import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'tts/tts_provider.dart';

/// API 配置
/// 优先从 .env 文件读取，其次从系统环境变量，最后从构造函数注入
class ApiConfig {
  // ── LLM ──
  static const String llmBaseUrl = 'https://api.deepseek.com';
  static const String llmModel = 'deepseek-chat';
  static String? llmApiKey;

  // ── ASR ──
  static const String asrBaseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String asrModel = 'whisper-1';
  static String? asrApiKey;

  // ── TTS —— 多 Provider ──
  static String? ttsApiKey;        // OpenAI TTS
  static String? miniMaxApiKey;    // MiniMax TTS
  static String? mimoApiKey;       // 小米 MiMo TTS
  static TtsProviderType ttsProvider = TtsProviderType.openai;

  /// 初始化配置，程序启动时调用一次
  static Future<void> init({
    String envFile = '.env',
    String? llmKey,
    String? asrKey,
    String? ttsKey,
    String? miniMaxKey,
    String? mimoKey,
    TtsProviderType ttsProviderType = TtsProviderType.openai,
  }) async {
    // 1. 尝试从 .env 文件加载
    try {
      await dotenv.load(fileName: envFile);
    } catch (_) {}

    // 2. 按优先级：参数 > .env > 系统环境变量
    llmApiKey = llmKey ??
        dotenv.maybeGet('DEEPSEEK_API_KEY') ??
        Platform.environment['DEEPSEEK_API_KEY'];

    asrApiKey = asrKey ??
        dotenv.maybeGet('OPENAI_API_KEY') ??
        Platform.environment['OPENAI_API_KEY'];

    // TTS Keys
    ttsApiKey = ttsKey ??
        dotenv.maybeGet('OPENAI_API_KEY') ??
        Platform.environment['OPENAI_API_KEY'];

    miniMaxApiKey = miniMaxKey ??
        dotenv.maybeGet('MINIMAX_API_KEY') ??
        Platform.environment['MINIMAX_API_KEY'];

    mimoApiKey = mimoKey ??
        dotenv.maybeGet('MIMO_API_KEY') ??
        Platform.environment['MIMO_API_KEY'];

    ttsProvider = ttsProviderType;
  }

  /// 检查核心 API 是否已配置
  static bool get isReady =>
      (llmApiKey != null && llmApiKey!.isNotEmpty) &&
      (asrApiKey != null && asrApiKey!.isNotEmpty);
}
