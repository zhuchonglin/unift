import 'package:unift/unift_core/model.dart';
import 'package:unift/unift_core/router.dart';

import 'app.dart';
import 'dart:ui' show PlatformDispatcher;

/// rpx单位换算 return 逻辑像素px
double rpx(double size) {
  return app().get<WindowInfo>().uiSizeRation * size;
}

/// 获取屏幕信息
WindowInfo getWindowInfo() {
  return App.windowInfo;
}

/// 获取App容器实例
App unift() {
  return App();
}

/// 获取App容器实例
App app() {
  return App();
}

/// 获取模型容器实例
Model model() {
  return Model();
}

/// 获取平台调度员实例
PlatformDispatcher window() {
  return App.platformDispatcher;
}

/// 路由管理器
RouteManager router() {
  return RouteManager();
}
