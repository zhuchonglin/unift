/// 容器功能基类
///
/// [T]泛型参数为可存储实例的类型
abstract mixin class Container<T> {
  /// 容器内实例映射
  final Map<String, T> _instanceMap = {};

  String _getKey(Type type, String? alias) {
    return alias == null ? type.toString() : '${type}_$alias';
  }

  /// addInstance方法别名
  void add(T instance, [String? alias]) => addInstance(instance, alias);

  /// 添加一个实例到容器，返回实例唯一k
  String addInstance(T instance, [String? alias]) {
    final instanceKey = _getKey(instance.runtimeType, alias);
    assert(
      _instanceMap.containsKey(instanceKey) == false,
      'Container error: Instance already exists, try adding alias alias',
    );
    _instanceMap[instanceKey] = instance;
    return instanceKey;
  }

  /// getInstance方法短命名方法
  C get<C extends T>([String? alias]) => getInstance<C>(alias);

  /// 从容器中获取实例
  ///
  /// 泛型参数[C]需传入实例名称
  ///
  /// [alias] 可选参数，如果实例名称设置了别名则需传入
  C getInstance<C extends T>([String? alias]) {
    final instanceKey = _getKey(C, alias);
    assert(
      _instanceMap.containsKey(instanceKey),
      'Container Error: $C instance as $alias not found in container',
    );
    return _instanceMap[instanceKey] as C;
  }

  /// 移除某个实例
  void remove<C extends T>([String? alias]) {
    final instanceKey = _getKey(C, alias);
    assert(_instanceMap.containsKey(instanceKey),
        'Container Error: $C instance as $alias not found in container No need to remove');
    _instanceMap.remove(instanceKey);
  }

  /// 使用key删除实例
  void deleteKey(String key) {
    _instanceMap.remove(key);
  }
}
