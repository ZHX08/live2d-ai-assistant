import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/models/live2d_state.dart';
import '../../../services/live2d_bridge.dart';

/// Live2D 渲染组件
/// 通过 WebView + Cubism Web SDK 渲染 Live2D 模型
class Live2DCanvas extends StatefulWidget {
  final Live2dState currentState;
  final double? mouthOpenY; // 口型开合度 0-1，由音频驱动

  const Live2DCanvas({
    super.key,
    required this.currentState,
    this.mouthOpenY,
  });

  @override
  State<Live2DCanvas> createState() => _Live2DCanvasState();
}

class _Live2DCanvasState extends State<Live2DCanvas> {
  late final WebViewController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController();

    // JavaScript 通道：Live2D → Flutter
    _controller.addJavaScriptChannel(
      'Live2dBridge',
      onMessageReceived: (msg) {
        if (msg.message == 'ready') {
          setState(() => _ready = true);
          // 注册到全局桥接
          live2dBridge.setController(_controller);
        }
      },
    );

    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(
      NavigationDelegate(onPageFinished: (_) {
        _controller.runJavaScript('''
          if (typeof Live2dBridge === 'undefined') {
            window.Live2dBridge = { onReady: function() { Live2dBridge.postMessage('ready'); } };
            if (window.live2dAPI) Live2dBridge.onReady();
          }
        ''');
      }),
    );

    // 加载 HTML
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    if (Platform.isAndroid) {
      // Android: 从 assets 加载
      _controller.loadFlutterAsset('assets/live2d/live2d_view.html');
    } else {
      // iOS: 从文件加载
      _controller.loadFlutterAsset('assets/live2d/live2d_view.html');
    }
  }

  @override
  void didUpdateWidget(Live2DCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 状态变化 → 通知 JS
    if (_ready && widget.currentState != oldWidget.currentState) {
      _callJS('playMotion', widget.currentState.motionName);
    }

    // 口型同步
    if (_ready &&
        widget.mouthOpenY != null &&
        widget.currentState == Live2dState.speaking) {
      _callJS('setMouthOpenY', widget.mouthOpenY!.toStringAsFixed(3));
    }
  }

  void _callJS(String fn, String arg) {
    _controller.runJavaScript('live2dAPI.$fn("$arg")');
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
            ),
            // 加载中占位
            if (!_ready)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '加载 Live2D...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
