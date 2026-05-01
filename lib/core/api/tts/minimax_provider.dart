import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../api_config.dart';
import 'tts_provider.dart';

/// MiniMax TTS 实现
/// API: https://platform.minimaxi.com/docs/api-reference/speech-t2a-http
class MiniMaxTtsProvider implements TtsProvider {
  late final Dio _dio;

  /// 默认中文男声色
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
  }) async {
    final payload = {
      'model': 'speech-2.8-hd',
      'text': text,
      'stream': false,
      'voice_setting': {
        'voice_id': voice ?? defaultVoice,
        'speed': speed,
        'vol': 1,
        'pitch': 0,
      },
      'audio_setting': {
        'sample_rate': 32000,
        'bitrate': 128000,
        'format': 'mp3',
        'channel': 1,
      },
    };

    final response = await _dio.post(
      '/t2a_v2',
      data: payload,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw Exception('MiniMax TTS error: ${response.statusCode}');
    }

    // MiniMax 非流式返回 audio/mpeg 二进制
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await File(filePath).writeAsBytes(response.data as List<int>);
    return filePath;
  }

  @override
  Future<List<String>> synthesizeSentences({
    required String text,
    String? voice,
    double speed = 1.0,
  }) async {
    final sentences = text.split(RegExp(r'(?<=[。！？.!?\n])'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final results = <String>[];
    for (final s in sentences) {
      results.add(await synthesize(text: s, voice: voice, speed: speed));
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}
