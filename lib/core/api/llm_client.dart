import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import 'api_config.dart';

class LlmClient {
  late final Dio _dio;

  LlmClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.llmBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${ApiConfig.llmApiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<String> chat({
    required List<ChatMessage> messages,
    String systemPrompt = '你是一个可爱的桌面助手，说话简洁温柔。',
    double temperature = 0.7,
  }) async {
    final payload = {
      'model': ApiConfig.llmModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => m.toApiMap()),
      ],
      'temperature': temperature,
      'stream': false,
    };
    final response = await _dio.post('/v1/chat/completions', data: payload);
    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'] as String;
    }
    throw Exception('LLM error: ${response.statusCode}');
  }

  Stream<String> chatStream({
    required List<ChatMessage> messages,
    String systemPrompt = '你是一个可爱的桌面助手，说话简洁温柔。',
    double temperature = 0.7,
  }) async* {
    final payload = {
      'model': ApiConfig.llmModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => m.toApiMap()),
      ],
      'temperature': temperature,
      'stream': true,
    };
    final response = await _dio.post(
      '/v1/chat/completions',
      data: payload,
      options: Options(responseType: ResponseType.stream),
    );
    await for (final chunk in response.data.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6);
        if (jsonStr == '[DONE]') return;
        try {
          final json = jsonDecode(jsonStr);
          final delta = json['choices']?[0]?['delta']?['content'] as String?;
          if (delta != null && delta.isNotEmpty) yield delta;
        } catch (_) {}
      }
    }
  }
}
