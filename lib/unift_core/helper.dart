import 'package:unift/unift_core/model.dart';

import 'app_container.dart';

/// rpx单位换算 return 逻辑像素px
double rpx(double size) {
  return app().get<WindowInfo>().uiSizeRation * size;
}

/// 获取屏幕信息
WindowInfo getWindowInfo() {
  return app().get<WindowInfo>();
}

/// 获取App容器实例
AppContainer unift() {
  return AppContainer();
}

/// 获取App容器实例
AppContainer app() {
  return AppContainer();
}

/// 获取模型容器实例
ModelContainer model() {
  return ModelContainer();
}
