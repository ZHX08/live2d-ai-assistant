import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';

class AsrClient {
  late final Dio _dio;

  AsrClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.asrBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer ${ApiConfig.asrApiKey}'},
    ));
  }

  Future<String> transcribe({
    required String audioPath,
    String? language,
  }) async {
    final file = File(audioPath);
    if (!file.existsSync()) throw Exception('File not found: $audioPath');

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(audioPath, filename: 'audio.m4a'),
      'model': ApiConfig.asrModel,
      if (language != null) 'language': language,
      'response_format': 'json',
    });

    final response = await _dio.post('', data: formData);
    if (response.statusCode == 200) return response.data['text'] as String;
    throw Exception('ASR error: ${response.statusCode}');
  }
}
