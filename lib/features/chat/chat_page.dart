import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/live2d_canvas.dart';
import 'widgets/thinking_indicator.dart';
import 'widgets/voice_button.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = ref.watch(chatProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Live2D 角色
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Live2DCanvas(currentState: cs.live2dState),
              ),
            ),

            // 对话列表
            Expanded(
              child: cs.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.record_voice_over, size: 48,
                            color: theme.colorScheme.primary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('按住下方按钮说话',
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 15)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cs.messages.length + (cs.isProcessing ? 1 : 0),
                      itemBuilder: (_, i) =>
                          (cs.isProcessing && i == cs.messages.length)
                              ? const ThinkingIndicator()
                              : ChatBubble(message: cs.messages[i]),
                    ),
            ),

            if (cs.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(cs.error!, style: TextStyle(color: Colors.red[300], fontSize: 13)),
              ),

            // 底部栏
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cs.messages.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 22),
                      color: Colors.grey[500],
                      onPressed: () => ref.read(chatProvider.notifier).clearChat(),
                    ),
                  const Spacer(),
                  const VoiceButton(),
                  const Spacer(),
                  if (cs.messages.isNotEmpty) const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
