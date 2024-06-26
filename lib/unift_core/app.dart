import 'dart:ui' as ui show PlatformDispatcher, FlutterView, Locale;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:unift/unift_core/abstract/container.dart';
import 'package:unift/unift_core/model.dart';
import 'package:unift/unift_core/router.dart';
export 'package:flutter/foundation.dart' show Brightness, kDebugMode;

/// uniftApp 依赖管理
class App with Container<Object> {
  /// 容器实例
  static App? _appInstance;

  /// 私有构造函数
  App._() {
    if (kDebugMode) {
      print('UniFt AppContainer Single Instance Create ${DateTime.now()}');
    }
    addInstance(WindowInfo._());
  }

  /// 初始化构建容器（单实例）
  factory App() {
    _appInstance ??= App._();
    return _appInstance!;
  }

  /// 静态of查找实例
  static C of<C extends Object>([String? alias]) => App().getInstance<C>(alias);

  /// APP窗口信息
  static WindowInfo get windowInfo {
    return App().getInstance<WindowInfo>();
  }

  /// 平台调度员实例
  static ui.PlatformDispatcher get platformDispatcher {
    return ui.PlatformDispatcher.instance;
  }

  /// 获取设备语言
  static ui.Locale get locale {
    return platformDispatcher.locale;
  }

  /// 路由器实例
  static RouteManager get router {
    return RouteManager();
  }

  /// 数据模型管理容器
  static Model get model {
    return Model();
  }
}

/// 窗口信息类
class WindowInfo {
  /// 像素比率
  late final double pixelRatio;

  /// 屏幕像素高度
  late final double screenPixelWidth;

  /// 屏幕像素高度
  late final double screenPixelHeight;

  /// 屏幕宽度
  late final double screenWidth;

  /// 屏幕高度
  late final double screenHeight;

  /// 安全区
  late final SafeAreaInsets safeAreaInsets;

  /// rpx换算比率
  late final double uiSizeRation;

  /// [uiSketchBaseWidth] ui画稿基准宽度 用于计算rpx换算比率
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
