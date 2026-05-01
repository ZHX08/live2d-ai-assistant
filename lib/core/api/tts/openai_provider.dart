import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../api_config.dart';
import 'tts_provider.dart';

class OpenaiTtsProvider implements TtsProvider {
  late final Dio _dio;

  OpenaiTtsProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1/audio/speech',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${ApiConfig.ttsApiKey}',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.bytes,
    ));
  }

  @override
  String get name => 'OpenAI TTS';

  @override
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) async {
    final payload = {
      'model': extra?['model'] ?? 'tts-1',
      'input': text,
      'voice': voice ?? 'nova',
      'speed': speed,
      'response_format': extra?['format'] ?? 'mp3',
    };

    final response = await _dio.post('', data: payload);
    if (response.statusCode != 200) throw Exception('OpenAI TTS error: ${response.statusCode}');

    final tempDir = await getTemporaryDirectory();
    final ext = payload['response_format'] as String;
    final filePath = '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(filePath).writeAsBytes(response.data as List<int>);
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
