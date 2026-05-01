import 'package:webview_flutter/webview_flutter.dart';
import '../core/models/live2d_state.dart';

/// Live2D JS Bridge
/// 通过 WebView JavaScript 通道控制 Live2D 模型
/// 由 Live2DCanvas 初始化 controller 后全局可用
class Live2DBridge {
  WebViewController? _controller;

  bool get isReady => _controller != null;

  void setController(WebViewController ctrl) {
    _controller = ctrl;
  }

  /// 切换动作
  Future<void> playMotion(Live2dState state) async {
    await _call('playMotion', state.motionName);
  }

  /// 设置口型开合 (0.0 - 1.0)
  Future<void> setMouthOpenY(double value) async {
    await _call('setMouthOpenY', value.toStringAsFixed(3));
  }

  /// 设置视线方向
  Future<void> setEyeGaze(double x, double y) async {
    await _call('setEyeGaze', '${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}');
  }

  /// 热切换模型
  Future<void> loadModel(String url) async {
    await _call('loadModel', url);
  }

  Future<void> _call(String fn, String arg) async {
    if (_controller == null) return;
    try {
      await _controller!.runJavaScript('live2dAPI.$fn("$arg")');
    } catch (_) {}
  }

  void clear() {
    _controller = null;
  }
}

/// 全局单例
final live2dBridge = Live2DBridge();
