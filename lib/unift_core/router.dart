import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 路由管理
class RouteManager {
  static RouteManager? _selfInstance;

  /// 导航唯一标识
  final GlobalKey<NavigatorState> navigatorKey;

  /// 命名路由映射
  final Map<String, WidgetBuilder> routes;

  /// 构造函数私有化
  RouteManager._(this.navigatorKey, this.routes);

  /// 初始化构建容器（单实例）
  ///
  /// [routes] 路由表仅在第一次实例化时有用
  factory RouteManager() {
    assert(
      _selfInstance != null,
      "RouterManager 未初始化，请使用 RouterManager.init() 初始化",
    );
    return _selfInstance!;
  }

  /// 初始化路由
  factory RouteManager.init(GlobalKey<NavigatorState> navigatorKey,
      [Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{}]) {
    _selfInstance ??= RouteManager._(navigatorKey, routes);
    return _selfInstance!;
  }

  /// 当前导航状态
  NavigatorState get currentState => navigatorKey.currentState!;

  void toName(String name, {Map<String, dynamic>? arguments}) {
    currentState.pushNamed(name, arguments: arguments);
  }

  void to(Route page) {
    currentState.push(page);
  }
}
