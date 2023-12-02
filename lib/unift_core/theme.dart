import 'package:flutter/material.dart' show ThemeData;
import 'package:unift/unift_core/app.dart';
import 'package:unift/unift_ref/unift_ref.dart';

typedef OnThemeChangeCallback = void Function();

class ThemeManager {
  static ThemeManager? _selfInstance;

  /// 主题配置列表
  final Map<String, ThemeData> _themeDataMap = {
    "light": ThemeData.light(useMaterial3: true),
    "dark": ThemeData.dark(useMaterial3: true)
  };

  /// 当前系统主题类型
  final RefString _currentTheme = RefString('system');

  /// 获取当前主题
  ///
  /// 如果在refEl的builder中使用了该获取器，则视图会在主题变化时自动更新
  static String get currentTheme => ThemeManager()._currentTheme.value;

  /// 判断是否为暗色主题
  static bool get isDark => currentTheme == "dark";

  /// 判断是否为亮色主题
  static bool get isLight => currentTheme == "light";

  /// 判断是否为跟随系统主题
  static bool get isSystem => currentTheme == "system";

  /// 构造函数私有化
  ThemeManager._(Map<String, ThemeData>? themeDataMap) {
    if (themeDataMap != null) _themeDataMap.addAll(themeDataMap);
  }

  /// 主题管理类初始化工厂构造函数
  ///
  /// [themeDataMap] 接收一个map 可以自定义N多种主题模式其中已经包含了下面两种主题配置
  ///
  /// * 默认亮色主题 light:ThemeData.light(useMaterial3: true)
  ///
  /// * 默认暗黑主题 dark:ThemeData.dark(useMaterial3: true)
  ///
  /// 可以覆盖默认的主题配置，也可以添加更多自定义的主题配置
  factory ThemeManager.init([Map<String, ThemeData>? themeDataMap]) {
    _selfInstance ??= ThemeManager._(themeDataMap);
    return _selfInstance!;
  }

  /// 单实例
  factory ThemeManager() {
    assert(
      _selfInstance != null,
      "ThemeManager 未初始化，请在程序入口调用 ThemeManager.init() 初始化",
    );
    return _selfInstance!;
  }

  /// 获取主题配置
  ThemeData get themeData {
    final mode = _currentTheme.value == "system"
        ? ThemeManager.currentSystemTheme.name
        : _currentTheme.value;
    return _themeDataMap[mode]!;
  }

  /// 监听主题变化，返回监听器
  ///
  /// 在不需要监听时尽量调用监听器dispose()方法销毁监听，
  /// 避免内存外溢
  Listener onThemeChange(OnThemeChangeCallback callback) {
    return _currentTheme.addListener(null, callback);
  }

  /// 切换主题模式
  ///
  /// [mode]参数接收themeDataMap中的某个key或是system表示跟随系统
  void changeThemeMode(String mode) {
    if (mode != _currentTheme.value) {
      if (mode != 'system' && !_themeDataMap.containsKey(mode)) {
        throw ArgumentError(
          "ThemeManger Error:changeThemeMode方法mode参数必须为${_themeDataMap.keys.toString()},给定$mode",
        );
      }
      _currentTheme.value = mode;
    }
  }

  /// 获取当前系统主题
  static Brightness get currentSystemTheme =>
      App.platformDispatcher.platformBrightness;
}
