import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../api_config.dart';
import 'tts_provider.dart';

class MiniMaxTtsProvider implements TtsProvider {
  late final Dio _dio;
  static const String defaultVoice = 'male-qn-qingse';

  MiniMaxTtsProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.minimaxi.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${ApiConfig.miniMaxApiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }

  @override
  String get name => 'MiniMax TTS';

  @override
  Future<String> synthesize({
    required String text,
    String? voice,
    double speed = 1.0,
    Map<String, dynamic>? extra,
  }) async {
    final payload = {
      'model': extra?['model'] ?? 'speech-2.8-hd',
      'text': text,
      'stream': false,
      'voice_setting': {
        'voice_id': voice ?? defaultVoice,
        'speed': speed,
        'vol': extra?['vol'] ?? 1,
        'pitch': extra?['pitch'] ?? 0,
        if (extra?['emotion'] != null) 'emotion': extra!['emotion'],
      },
      'audio_setting': {
        'sample_rate': extra?['sample_rate'] ?? 32000,
        'bitrate': extra?['bitrate'] ?? 128000,
        'format': extra?['format'] ?? 'mp3',
        'channel': 1,
      },
    };

    final response = await _dio.post(
      '/t2a_v2',
      data: payload,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) throw Exception('MiniMax TTS error: ${response.statusCode}');

    final tempDir = await getTemporaryDirectory();
    final ext = (payload['audio_setting'] as Map)['format'] as String;
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
