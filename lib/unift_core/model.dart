import 'package:unift/unift_core/abstract/container.dart';
import 'package:unift/unift_core/meta.dart' show protected;

import 'typedef.dart' show VoidCallback;

/// 模型基类
abstract mixin class BaseModel {
  /// 是否已销毁
  bool _isDisposed = false;

  /// 该key由[Model]分发,在销毁模型时会从容器中自动移除该模型
  @protected
  String? _key;

  /// 返回bool,false代表当前监听已销毁
  bool get isDisposed {
    return _isDisposed;
  }

  /// 销毁之前的回调
  final List<VoidCallback> _onDisposedCallback = [];

  /// 销毁实例
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      if (_onDisposedCallback.isNotEmpty) {
        // 遍历监听销毁回调事件列表
        for (var callback in _onDisposedCallback) {
          callback.call();
        }
        // 清空回调记录器
        _onDisposedCallback.clear();
      }
      if (_key != null) Model().deleteKey(_key!);
    }
  }

  /// 监听销毁
  void onDisposed(VoidCallback callback) {
    _onDisposedCallback.add(callback);
  }

  /// 共享模型，允许通过Model.of<当前模型>()得到该模型实例。
  ///
  /// [alias] 如果存在多个模型类名称相同会冲突,则需要为模型指定别名。
  void share([String? alias]) {
    assert(_key == null, '该模型已共享，请勿重复共享');
    Model().addInstance(this, alias);
  }
}

/// 模型管理容器
final class Model with Container<BaseModel> {
  static Model? _selfInstance;

  /// 构造函数私有化
  Model._();

  /// 初始化构建容器（单实例）
  factory Model() {
    _selfInstance ??= Model._();
    return _selfInstance!;
  }

  @override
  String addInstance(BaseModel instance, [String? alias]) {
    final instanceKey = super.addInstance(instance, alias);
    instance._key = instanceKey;
    return instanceKey;
  }

  /// getInstance方法短命名方法
  static C of<C extends BaseModel>([String? alias]) =>
      Model().getInstance<C>(alias);

  /// 共享一个模型,共享过后可以通过of方法进行查找该模型
  ///
  /// 功能同[add]、[addInstance]方法一致，不同之处是该方法返回共享的实例
  ///
  /// 静态代理addInstance方法
  static T share<T extends BaseModel>(T instance, [String? alias]) {
    Model().addInstance(instance, alias);
    return instance;
  }
}
