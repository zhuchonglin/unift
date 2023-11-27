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

/// 数字类型反射响应代理
class RefNum extends RefProxyAbstract<num> {
  RefNum(super._tagger);
  @override
  RefNum copy() {
    return RefNum(_tagger);
  }
}

/// 浮点类型反射响应代理
class RefDouble extends RefProxyAbstract<double> {
  RefDouble(super._tagger);

  @override
  RefDouble copy() {
    return RefDouble(_tagger);
  }
}

/// 整数类型反射响应代理
class RefInt extends RefProxyAbstract<int> {
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
}

/// 字符串类型反射响应代理
class RefString extends RefProxyAbstract<String> {
  RefString(super._tagger);
  @override
  RefString copy() {
    return RefString(_tagger);
  }
}
