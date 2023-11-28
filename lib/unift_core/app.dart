import 'package:flutter/material.dart' hide Router;
import 'package:unift/unift_core/router.dart' as unift;

class UniFtMaterialApp extends StatelessWidget {
  /// 应用标题，APP应用几乎用不上该属性，只有在部分安卓机型查看后台应用时会显示该名称
  final String title;
  const UniFtMaterialApp({
    super.key,
    this.title = 'UniFt',
  });

  @override
  Widget build(Object context) {
    return MaterialApp(
      title: title,
      navigatorKey: unift.Router().navigatorKey,
    );
  }
}
