import 'dart:collection';

import 'package:unift/unift_ref/listener.dart';
import 'package:unift/unift_ref/ref.dart' show RefProxy;

/// 反射响应代理抽象类
abstract class RefProxyAbstract<T> extends RefProxy<T> {
  final T _tagger;
  RefProxyAbstract(this._tagger);

  @override
  @Deprecated('map、list、set类型的代理对象的修改方式同原生类型一致')
  set value(T newValue) => UnimplementedError(
      'Proxy objects of types map, list, and set cannot be accessed or modified through the value method');

  /// map、list、set类型的代理对象的访问方式同原生类型一致,如果使用value访问请勿调用扩展方法进行修改,否则会造成异常
  @override
  T get value {
    recordTrack();
    return _tagger;
  }
}

/// list反射响应代理
class RefList<E> extends RefProxyAbstract<List<E>> with ListBase<E> {
  RefList([List<E>? tagger]) : super(tagger ?? []);

  /// 复制响应对象
  @override
  RefList<E> copy() {
    return RefList(_tagger.toList());
  }

  /// 获取数组长度
  @override
  int get length => _tagger.length;

  /// 设置数组长度
  @override
  set length(int newLength) {
    final oldLength = _tagger.length;
    if (oldLength != newLength) {
      _tagger.length = newLength;
      if (oldLength > newLength) {
        final diff = oldLength - newLength;
        final removedIndices = <int?>[];
        // 记录被移除的下标
        for (var i = oldLength - diff; i < oldLength; i++) {
          removedIndices.add(i);
        }
        // 通知下标改变事件
        notifyListeners(events: removedIndices, dispose: true);
      } else {
        // 如果是增加数组长度则通知默认的改变事件
        notifyListeners();
      }
    }
  }

  /// 获取指定位置元素
  @override
  E operator [](int index) {
    recordTrack(index);
    return _tagger[index];
  }

  /// 修改指定位置元素
  @override
  void operator []=(int index, E value) {
    if (_tagger[index] != value) {
      _tagger[index] = value;
      notifyListeners(event: index);
    }
  }

  /// 在列表末尾添加一个元素。
  ///
  /// [value]是要添加到列表末尾的元素。
  @override
  void add(E value) {
    _tagger.add(value); // 向列表添加新元素
    notifyListeners();
  }

  /// 监听指定的下标变化
  Listener watchSub(int index, VoidCallback callback) {
    if (indexExists(index)) {
      return addListener(index, callback);
    }
    throw ArgumentError('list不存在下标索引$index');
  }

  /// 监听多个下标的变化
  ///
  /// [index] 接收一个数字列表，自行确定数组中存在该下标
  Listener watchSubs(List<int> index, VoidCallback callback) {
    return addListeners(index, callback);
  }

  /// 判断指定下标是否存在
  bool indexExists(int index) {
    return index >= 0 && index < length - 1;
  }
}

/// map反射响应代理
class RefMap<K extends Object, V> extends RefProxyAbstract<Map<K, V>>
    with MapBase<K, V> {
  RefMap([Map<K, V>? tagger]) : super(tagger ?? <K, V>{});

  /// 获取指定键的值
  @override
  V? operator [](Object? key) {
    recordTrack(key);
    return _tagger[key];
  }

  /// 设置指定键的值
  @override
  void operator []=(K key, V value) {
    if (_tagger.containsKey(key)) {
      // 判断新的值是否和旧的值相等
      if (_tagger[key] != value) {
        /// 触发事件
        notifyListeners(event: key);
        _tagger[key] = value;
      }
    } else {
      _tagger[key] = value;
      notifyListeners();
    }
  }

  /// 清空map
  @override
  void clear() {
    final keys = this.keys.toList();
    _tagger.clear();
    notifyListeners(events: keys, dispose: true);
  }

  @override
  RefMap<K, V> copy() {
    return RefMap(Map<K, V>.from(_tagger));
  }

  /// 获取所有键的可低代对象
  @override
  Iterable<K> get keys => _tagger.keys;

  /// 删除指定键值
  @override
  V? remove(Object? key) {
    final result = _tagger.remove(key);
    notifyListeners(event: key, dispose: true); //触发事件并销毁监听
    return result;
  }

  /// 监听指定键
  ///
  /// [key] 需要监听的键名称
  /// [callback] 监听到变化时的回调函数
  Listener watchKey(K key, VoidCallback callback) {
    if (_tagger.containsKey(key)) {
      return addListener(key, callback);
    }
    throw ArgumentError('map不存在键$key');
  }

  /// 该方法可以同时监听多个key的变化
  ///
  /// [keys] 需要监听的key键名列表
  /// [callback] 监听到变化时的回调函数
  Listener watchKeys(List<K> keys, VoidCallback callback) {
    return addListeners(keys, callback);
  }
}

/// set反射响应代理
class RefSet<E> extends RefProxyAbstract<Set<E>> with SetBase<E> {
  RefSet([Set<E>? tagger]) : super(tagger ?? <E>{});

  /// 添加元素
  @override
  bool add(E value) {
    final result = _tagger.add(value);
    if (result) notifyListeners();
    return result;
  }

  /// 判断元素是否存在
  @override
  bool contains(Object? element) {
    return _tagger.contains(element);
  }

  /// 复制一个新的响应对象
  @override
  RefSet<E> copy() {
    return RefSet(this.toSet());
  }

  /// 可低代对象
  @override
  Iterator<E> get iterator => _tagger.iterator;

  /// 获取集合长度
  @override
  int get length => _tagger.length;

  /// 判断是否存在某元素，如果存在则会返回该元素
  @override
  E? lookup(Object? element) {
    return _tagger.lookup(element);
  }

  /// 删除指定元素
  @override
  bool remove(Object? value) {
    final result = _tagger.remove(value);
    if (result) notifyListeners();
    return result;
  }

  /// 获取一个新的set，非响应对象
  @override
  Set<E> toSet() {
    return _tagger.toSet();
  }
}
