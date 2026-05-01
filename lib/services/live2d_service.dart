import '../core/models/live2d_state.dart';
import 'live2d_bridge.dart';

/// Live2D 模型控制（上层接口）
/// 底层通过 live2d_bridge → WebView JS 通信
class Live2DService {
  /// 加载模型
  Future<void> loadModel(String modelUrl) async {
    await live2dBridge.loadModel(modelUrl);
  }

  /// 切换动作
  Future<void> playMotion(Live2dState state, {bool immediate = false}) async {
    await live2dBridge.playMotion(state);
  }

  /// 设置口型开合 (0.0 - 1.0)
  Future<void> setMouthOpenY(double value) async {
    await live2dBridge.setMouthOpenY(value);
  }

  /// 设置视线方向
  Future<void> setEyeGaze(double x, double y) async {
    await live2dBridge.setEyeGaze(x, y);
  }

  Future<void> dispose() async {
    live2dBridge.clear();
  }
}

/// 全局单例
final live2DService = Live2DService();
