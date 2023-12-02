import 'package:flutter/material.dart';

abstract mixin class LifeCycle {
  void onLoad(Map<String, dynamic> params) {}
  void onReady() {}
  void onShow() {}
  void onHide() {}
  void onUnload() {}
}

/// APP页面根组件
abstract class UniFtPage extends StatelessWidget with LifeCycle {
  const UniFtPage({super.key});
}
