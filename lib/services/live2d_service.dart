import '../core/models/live2d_state.dart';

class Live2DService {
  Future<void> loadModel(String modelPath) async {
    // TODO: platform channel -> Cubism Native SDK
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> playMotion(Live2dState state, {bool immediate = false}) async {
    // TODO: platform channel
    // idle: 呼吸+眨眼 | listening: 侧耳 | thinking: 歪头托腮 | speaking: 口型同步
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> setMouthOpenY(double value) async {
    // TODO: ParamMouthOpenY
    await Future.delayed(const Duration(milliseconds: 5));
  }

  Future<void> dispose() async {}
}

final live2DService = Live2DService();
