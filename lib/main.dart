import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/api/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载 API 配置（.env / 环境变量 / 手动注入）
  await ApiConfig.init();

  runApp(const ProviderScope(child: Live2dAiApp()));
}
