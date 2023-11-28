import 'package:flutter/widgets.dart' show GlobalKey, NavigatorState;

class Router {
  static Router? _selfInstance;

  /// 路由key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 构造函数私有化
  Router._();

  /// 初始化构建容器（单实例）
  factory Router() {
    _selfInstance ??= Router._();
    return _selfInstance!;
  }
}
