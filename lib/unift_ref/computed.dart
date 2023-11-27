import 'package:unift/unift_ref/ref.dart' show RefProxy;
import 'package:unift/unift_ref/ref_quote_tracker.dart';

typedef ComputedFunction<T> = T Function();

/// 计算属性类,功能同vue的计算属性
class Computed<T> extends RefProxy<T> {
  /// 计算结果
  late T _result;

  /// 初始化
  bool _init = false;

  /// 计算函数
  final ComputedFunction<T> _func;
  Computed(this._func);
  void init() {
    if (!_init) {
      _init = true;
      final response = RefQuoteTracker.getQuoteTracks<T>(this._func);
      _result = response.result;
      // 重新计算
      void callback() {
        final newResult = _func();
        if (_result != newResult) {
          notifyListeners();
        }
      }

      // 监听变化
      response.tracks.forEach((refProxy, keys) {
        refProxy.addListeners(keys, callback);
      });
    }
  }

  @override
  T get value {
    super.recordTrack();
    if (!_init) init();
    return _result;
  }

  @override
  set value(T newValue) =>
      throw UnimplementedError('Computed instance does not allow setters');
  @override
  RefProxy<T> copy() =>
      throw UnimplementedError('Computed instance does not allow copying');
}

/// 计算属性（助手函数）
Computed<T> computed<T extends Object?>(ComputedFunction<T> func) {
  return Computed<T>(func);
}
