import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_provider.dart';

class VoiceButton extends ConsumerStatefulWidget {
  const VoiceButton({super.key});
  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  void _onDown(TapDownDetails d) {
    setState(() => _holding = true);
    _pulseCtrl.repeat(reverse: true);
    ref.read(chatProvider.notifier).startVoice();
  }

  void _onUp(TapUpDetails d) => _finish();
  void _onCancel() => _finish();

  void _finish() {
    if (!_holding) return;
    setState(() => _holding = false);
    _pulseCtrl.stop(); _pulseCtrl.reset();
    ref.read(chatProvider.notifier).stopVoice();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: _onDown, onTapUp: _onUp, onTapCancel: _onCancel,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Transform.scale(
          scale: _holding ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _holding ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.8),
            boxShadow: [BoxShadow(
              color: theme.colorScheme.primary.withOpacity(_holding ? 0.4 : 0.2),
              blurRadius: _holding ? 20 : 12, spreadRadius: _holding ? 4 : 0)],
          ),
          child: Icon(_holding ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
