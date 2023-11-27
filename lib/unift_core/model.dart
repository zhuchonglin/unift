import 'package:unift/unift_core/container.dart';

import 'typedef.dart' show VoidCallback;

/// 模型基类
abstract mixin class BaseModel {
  /// 是否已销毁
  bool _isDisposed = false;
  late final String _key;

  /// 返回bool,false代表当前监听已销毁
  bool get isDisposed {
    return _isDisposed;
  }

  /// 销毁之前的回调
  final List<VoidCallback> _onDisposedCallback = [];

  /// 销毁实例
  void dispose() {
    if (!_isDisposed) {
      if (_onDisposedCallback.isNotEmpty) {
        // 遍历监听销毁回调事件列表
        for (var callback in _onDisposedCallback) {
          callback.call();
        }
        // 清空回调记录器
        _onDisposedCallback.clear();
      }
      ModelContainer().deleteKey(_key);
      _isDisposed = true;
    }
  }

  /// 监听销毁
  void onDisposed(VoidCallback callback) {
    _onDisposedCallback.add(callback);
  }
}

/// 模型管理容器
final class ModelContainer with Container<BaseModel> {
  static ModelContainer? _selfInstance;

  /// 构造函数私有化
  ModelContainer._();

  /// 初始化构建容器（单实例）
  factory ModelContainer() {
    _selfInstance ??= ModelContainer._();
    return _selfInstance!;
  }
  @override
  String addInstance(BaseModel instance, [String? alias]) {
    final instanceKey = super.addInstance(instance, alias);
    return instanceKey;
  }

  /// 添加一个实例到容器,返回实例唯一k
  String put(BaseModel instance, [String? alias]) =>
      addInstance(instance, alias);
}
