enum Live2dState {
  idle('待机', 'idle'),
  listening('聆听中', 'listening'),
  thinking('思考中', 'thinking'),
  speaking('说话中', 'speaking');

  final String label;
  final String motionName;
  const Live2dState(this.label, this.motionName);
}

class Live2dAction {
  final Live2dState state;
  final bool immediate;
  const Live2dAction(this.state, {this.immediate = false});
}
