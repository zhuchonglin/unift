import 'dart:ui' as ui show PlatformDispatcher, FlutterView;

import 'package:flutter/foundation.dart';
import 'package:unift/unift_core/container.dart';

/// uniftApp 依赖管理
class AppContainer with Container<Object> {
  // 容器实例
  static AppContainer? _appInstance;
  // 容器内实例映射
  final bool isDebug = kDebugMode;

  /// 私有构造函数
  AppContainer._({int uiSketchBaseWidth = 750}) {
    if (kDebugMode) {
      print('UniFt AppContainer Single Instance Create ${DateTime.now()}');
    }
    addInstance(WindowInfo._(uiSketchBaseWidth));
  }

  /// 初始化构建容器（单实例）
  factory AppContainer({int uiSketchBaseWidth = 750}) {
    _appInstance ??= AppContainer._(uiSketchBaseWidth: uiSketchBaseWidth);
    return _appInstance!;
  }

  static WindowInfo get windowInfo {
    return AppContainer().getInstance<WindowInfo>();
  }
}

/// 窗口信息类
class WindowInfo {
  late final double pixelRatio;
  late final double screenPixelWidth;
  late final double screenPixelHeight;
  late final double screenWidth;
  late final double screenHeight;
  late final SafeAreaInsets safeAreaInsets;
  late final double uiSizeRation;
  WindowInfo._([int uiSketchBaseWidth = 750]) {
    final ui.FlutterView view = ui.PlatformDispatcher.instance.implicitView!;
    screenWidth = view.physicalSize.width / view.devicePixelRatio;
    screenHeight = view.physicalSize.height / view.devicePixelRatio;
    pixelRatio = view.devicePixelRatio;
    screenPixelWidth = view.physicalSize.width;
    screenPixelHeight = view.physicalSize.height;
    safeAreaInsets = SafeAreaInsets._(
      left: view.padding.left / view.devicePixelRatio,
      right: view.padding.right / view.devicePixelRatio,
      top: view.padding.top / view.devicePixelRatio,
      bottom: view.padding.bottom / view.devicePixelRatio,
    );
    uiSizeRation = screenWidth / uiSketchBaseWidth;
  }
}

/// 安全区域插入位置
class SafeAreaInsets {
  final double top;
  final double bottom;
  final double left;
  final double right;
  const SafeAreaInsets._(
      {required this.top,
      required this.bottom,
      required this.left,
      required this.right});
  static const SafeAreaInsets zero =
      SafeAreaInsets._(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0);

  @override
  String toString() {
    return 'SafeAreaInsets(left: $left, top: $top, right: $right, bottom: $bottom)';
  }
}
