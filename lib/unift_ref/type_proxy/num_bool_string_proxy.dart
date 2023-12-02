import 'package:unift/unift_ref/ref.dart';

abstract class RefProxyAbstract<T> extends RefProxy<T> {
  T _tagger;
  RefProxyAbstract(this._tagger);
  @override
  set value(T newValue) {
    if (_tagger != newValue) {
      _tagger = newValue;
      notifyListeners();
    }
  }

  @override
  T get value {
    recordTrack();
    return _tagger;
  }
}

/// 数字类型扩展运算方法
abstract class Number<T extends num> extends RefProxyAbstract<T> {
  Number(super.tagger);

  num operator +(num other) {
    return _tagger + other;
  }

  num operator -(num other) {
    return value - other;
  }

  num operator *(num other) {
    return value * other;
  }

  num operator /(num other) {
    return value / other;
  }

  num operator ~/(num other) {
    return value ~/ other;
  }

  num operator %(num other) {
    return value % other;
  }

  bool operator >(num other) {
    return value > other;
  }

  bool operator >=(num other) {
    return value >= other;
  }

  bool operator <(num other) {
    return value < other;
  }

  bool operator <=(num other) {
    return value <= other;
  }

  /// 判断是否为负数
  bool get isNegative => value.isNegative;

  /// 取负数
  num operator -() {
    return -value;
  }

  /// 判断是否非数字值
  bool get isNaN => value.isNaN;

  bool get isInfinite => value.isInfinite;

  /// Truncates this [num] to an integer and returns the result as an [int].
  ///
  /// Equivalent to [truncate].
  int toInt() => value.toInt();

  /// This number as a [double].
  ///
  /// If an integer number is not precisely representable as a [double],
  /// an approximation is returned.
  double toDouble() => value.toDouble();
}

/// 数字类型反射响应代理
class RefNum extends Number<num> {
  RefNum(super._tagger);

  @override
  RefNum copy() {
    return RefNum(_tagger);
  }
}

/// 浮点类型反射响应代理
class RefDouble extends Number<double> {
  RefDouble(super._tagger);

  @override
  RefDouble copy() {
    return RefDouble(_tagger);
  }
}

/// 整数类型反射响应代理
class RefInt extends Number<int> {
  RefInt(super._tagger);

  @override
  RefInt copy() {
    return RefInt(_tagger);
  }
}

/// 布尔类型反射响应代理
class RefBool extends RefProxyAbstract<bool> {
  RefBool(super._tagger);
  @override
  RefBool copy() {
    return RefBool(_tagger);
  }

  bool get isTrue => value;

  bool get isFalse => !isTrue;

  bool operator &(bool other) => other && value;

  bool operator |(bool other) => other || value;

  bool operator ^(bool other) => !other == value;
}

/// 字符串类型反射响应代理
class RefString extends RefProxyAbstract<String>
    implements Comparable<String>, Pattern {
  RefString(super._tagger);
  @override
  RefString copy() {
    return RefString(_tagger);
  }

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return value.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return value.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return value.compareTo(other);
  }
}
