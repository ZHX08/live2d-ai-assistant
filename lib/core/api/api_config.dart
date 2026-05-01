import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 配置
/// 优先从 .env 文件读取，其次从系统环境变量，最后从构造函数注入
class ApiConfig {
  static const String llmBaseUrl = 'https://api.deepseek.com';
  static const String llmModel = 'deepseek-chat';

  static const String asrBaseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String asrModel = 'whisper-1';

  static const String ttsBaseUrl = 'https://api.openai.com/v1/audio/speech';
  static const String ttsModel = 'tts-1';
  static const String ttsVoice = 'nova';

  // API Keys —— 运行时初始化
  static String? llmApiKey;
  static String? asrApiKey;
  static String? ttsApiKey;

  /// 初始化配置，程序启动时调用一次
  /// [envFile] .env 文件路径，默认项目根目录
  /// [llmKey] / [asrKey] / [ttsKey] 手动覆盖
  static Future<void> init({
    String envFile = '.env',
    String? llmKey,
    String? asrKey,
    String? ttsKey,
  }) async {
    // 1. 尝试从 .env 文件加载
    try {
      await dotenv.load(fileName: envFile);
    } catch (_) {
      // .env 文件不存在时忽略
    }

    // 2. 按优先级：参数 > .env > 系统环境变量
    llmApiKey = llmKey ??
        dotenv.maybeGet('DEEPSEEK_API_KEY') ??
        Platform.environment['DEEPSEEK_API_KEY'];

    asrApiKey = ttsApiKey = llmKey ??
        dotenv.maybeGet('OPENAI_API_KEY') ??
        Platform.environment['OPENAI_API_KEY'];
  }

  /// 检查是否已配置
  static bool get isReady =>
      (llmApiKey != null && llmApiKey!.isNotEmpty) &&
      (asrApiKey != null && asrApiKey!.isNotEmpty);
}
