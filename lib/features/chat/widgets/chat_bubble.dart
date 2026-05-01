import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(theme, bot: true),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary.withOpacity(0.85) : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(message.text, style: TextStyle(
                color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 15, height: 1.4)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar(theme),
        ],
      ),
    );
  }

  Widget _avatar(ThemeData theme, {bool bot = false}) => CircleAvatar(
    radius: 16,
    backgroundColor: bot ? theme.colorScheme.primary.withOpacity(0.2) : Colors.grey[700],
    child: Icon(bot ? Icons.face_6 : Icons.person, size: 18,
      color: bot ? theme.colorScheme.primary : Colors.white70),
  );
}
