import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'api_config.dart';

class TtsClient {
  late final Dio _dio;

  TtsClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.ttsBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer ${ApiConfig.ttsApiKey}'},
      responseType: ResponseType.bytes,
    ));
  }

  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
  }) async {
    final payload = {
      'model': ApiConfig.ttsModel,
      'input': text,
      'voice': voice ?? ApiConfig.ttsVoice,
      'speed': speed,
      'response_format': 'mp3',
    };
    final response = await _dio.post('', data: payload);
    if (response.statusCode != 200) throw Exception('TTS error: ${response.statusCode}');

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await File(filePath).writeAsBytes(response.data as List<int>);
    return filePath;
  }

  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
  }) async {
    final sentences = text.split(RegExp(r'(?<=[。！？.!?\n])')).where((s) => s.trim().isNotEmpty).toList();
    final results = <String>[];
    for (final s in sentences) {
      results.add(await synthesize(text: s, voice: voice, speed: speed));
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}
