import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unift/unift_core/theme.dart';
import 'package:unift/unift_core/app.dart';
import 'package:unift/unift_core/router.dart';

/// 页面构建器
typedef PageBuilder = Widget Function(BuildContext context, Widget? child);

/// 需要从右到左对齐的语言代码
const Set<String> rtlLanguages = {
  'ar', // Arabic
  'fa', // Farsi
  'he', // Hebrew
  'ps', // Pashto
  'ur'
};

/// APP根组件
class UniFtApp extends StatefulWidget {
  /// 应用标题，APP应用几乎用不上该属性，只有在部分安卓机型查看后台应用时会显示该名称
  final String title;

  /// 应用首页
  final Widget? home;

  /// 主题管理器
  final ThemeManager? themeManager;

  /// 高亮主题（使用主题管理器则该配置无效）
  final ThemeData? theme;

  /// 暗黑主题（使用主题管理器则该配置无效）
  final ThemeData? darkTheme;

  /// 页面构造器（包裹在页面外层）
  final PageBuilder? builder;

  /// routes命名路由映射（传入路由管理器则无效）
  final Map<String, WidgetBuilder> routes;

  /// UniFtMaterialApp封装了路由管理器
  const UniFtApp({
    super.key,
    this.title = 'UniFt',
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.themeManager,
    this.theme,
    this.darkTheme,
    this.builder,
  });

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<UniFtApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.themeManager != null) {
      widget.themeManager!.onThemeChange(() {
        didChangePlatformBrightness();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // 刷新ui状态
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色和样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 设置状态栏透明
      statusBarIconBrightness: Brightness.dark, // 设置状态栏图标为暗色
      statusBarBrightness: Brightness.dark, // 设置状态栏文字为暗色（仅Android）
    ));

    /// 路由管理类初始化，后续可以通过App.router获取路由管理器
    final router = RouteManager.init(
      GlobalKey<NavigatorState>(debugLabel: 'UniFtRouteManager'),
      widget.routes,
    );
    return MaterialApp(
      color: Colors.blue,
      navigatorKey: router.navigatorKey,
      home: widget.home,
      builder: widget.builder ?? defaultPageBuilder,
      themeMode:
          widget.themeManager == null ? ThemeMode.system : ThemeMode.light,
      theme: widget.themeManager == null
          ? widget.theme
          : widget.themeManager!.themeData,
      darkTheme: widget.darkTheme,
      routes: widget.routes,
    );
  }
}

Widget defaultPageBuilder(BuildContext context, Widget? child) =>
    DefaultPageBuilder(child: child);

/// 默认APP构建器
class DefaultPageBuilder extends StatelessWidget {
  final Widget? child;
  const DefaultPageBuilder({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: (rtlLanguages.contains(App.locale.languageCode)
          ? TextDirection.rtl
          : TextDirection.ltr), // 文字默认对齐方式
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelMedium!,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}
