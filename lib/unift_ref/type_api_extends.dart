import 'ref.dart' show RefProxy;
import 'type_proxy/list_map_set_proxy.dart';
import 'type_proxy/num_bool_string_proxy.dart';

extension DoubleApiExtend on double {
  /// 该方法会把变量映射为响应式对象
  RefDouble toRef() {
    return RefDouble(this);
  }
}

extension BoolApiExtend on bool {
  /// 该方法会把变量映射为响应式对象
  RefBool toRef() {
    return RefBool(this);
  }
}

extension IntApiExtend on int {
  /// 该方法会把变量映射为响应式对象
  RefInt toRef() {
    return RefInt(this);
  }
}

extension ListApiExtend<E> on List<E> {
  /// 该方法会把变量映射为响应式对象
  RefList<E> toRef() {
    return RefList<E>(this);
  }

  /// 判断指定下标是否存在
  bool indexExists(int index) {
    return index >= 0 && index < length - 1;
  }
}

extension MapApiExtend<K extends Object, V> on Map<K, V> {
  /// 该方法会把变量映射为响应式对象
  RefMap<K, V> toRef() {
    return RefMap<K, V>(this);
  }
}

extension NumApiExtend on num {
  /// 该方法会把变量映射为响应式对象
  RefNum toRef() {
    return RefNum(this);
  }
}

extension SetApiExtend<E> on Set<E> {
  /// 该方法会把变量映射为响应式对象
  RefSet<E> toRef() {
    return RefSet<E>(this);
  }
}

extension StringApiExtend on String {
  /// 该方法会把变量映射为响应式对象
  RefString toRef() {
    return RefString(this);
  }
}

extension ObjectApiExtend on Object {
  // 判断其是否为一个响应式对象
  bool get isRef {
    return this is RefProxy;
  }
}
