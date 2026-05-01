import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/chat/chat_page.dart';
import 'theme.dart';

class Live2dAiApp extends ConsumerWidget {
  const Live2dAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Live2D AI 助手',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const ChatPage(),
    );
  }
}
