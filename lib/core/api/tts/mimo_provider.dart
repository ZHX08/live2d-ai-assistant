import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../api_config.dart';
import 'tts_provider.dart';

class MiMoTtsProvider implements TtsProvider {
  late final Dio _dio;
  static const String defaultVoice = 'mimo_default';

  MiMoTtsProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.xiaomimimo.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'api-key': ApiConfig.mimoApiKey ?? '',
        'Content-Type': 'application/json',
      },
    ));
  }

  @override
  String get name => '小米 MiMo TTS';

  @override
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) async {
    final payload = {
      'model': extra?['model'] ?? 'mimo-v2-tts',
      'messages': [
        {'role': 'assistant', 'content': text},
      ],
      'audio': {
        'format': extra?['format'] ?? 'wav',
        'voice': voice ?? defaultVoice,
      },
    };

    final response = await _dio.post('/chat/completions', data: payload);
    if (response.statusCode != 200) throw Exception('MiMo TTS error: ${response.statusCode}');

    final data = response.data;
    final audioBase64 = data['choices']?[0]?['message']?['audio'] as String?;
    if (audioBase64 == null || audioBase64.isEmpty) {
      throw Exception('MiMo TTS: 响应中未找到音频数据');
    }

    final audioBytes = base64Decode(audioBase64);
    final tempDir = await getTemporaryDirectory();
    final ext = (payload['audio'] as Map)['format'] as String;
    final filePath = '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(filePath).writeAsBytes(audioBytes);
    return filePath;
  }

  @override
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) async {
    final sentences = text.split(RegExp(r'(?<=[。！？.!?\n])')).where((s) => s.trim().isNotEmpty).toList();
    final results = <String>[];
    for (final s in sentences) {
      results.add(await synthesize(text: s, voice: voice, speed: speed, extra: extra));
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}
