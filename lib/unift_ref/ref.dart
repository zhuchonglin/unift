// ignore_for_file: deprecated_member_use_from_same_package

import 'package:unift/unift_core/meta.dart' show protected;
import 'package:unift/unift_ref/listener.dart';
import 'package:unift/unift_ref/ref_quote_tracker.dart';

/// 响应式变量代理
abstract class RefProxy<T> with ListenerManager {
  T get value;

  set value(T newValue);

  /// 复制响应式对象
  RefProxy<T> copy();

  /// 监听响应式对象变化
  Listener watch(VoidCallback callback) {
    return addListener(null, callback);
  }

  /// 记录引用轨道
  ///
  /// [event] 事件名称，默认监听事件null
  @protected
  void recordTrack([Object? event]) {
    RefQuoteTracker.track(proxy: this, event: event);
  }

  @override
  String toString() {
    recordTrack();
    return value.toString();
  }
}

/// 监听响应式对象(助手函数)
Listener watch(
  RefProxy ref,
  VoidCallback callback,
) {
  return ref.watch(callback);
}
