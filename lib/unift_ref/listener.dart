import 'package:unift/unift_core/meta.dart' show protected;
import 'package:unift/unift_ref/dispose.dart';

typedef VoidCallback = void Function();

/// 监听器
final class Listener with Dispose {
  /// 监听回调函数
  final VoidCallback _callback;

  /// 监听限制次数
  final int _limitTrigger;

  /// 已经触发的次数
  int _triggerCount = 0;

  /// 构造监听器
  Listener(this._callback, {int limit = 0}) : _limitTrigger = limit;

  /// 构造单次监听器
  Listener.once(VoidCallback callback)
      : _callback = callback,
        _limitTrigger = 1;

  /// 获取当前监听已经触发的次数
  int get triggerCount => _triggerCount;

  /// 触发监听返回一个bool值表示当前监听是否还具有效应
  @protected
  bool emit() {
    // 判断是否已经销毁
    if (isDisposed) return false;

    // 如果没有限制触发次数或触发次数小于限制次数则触发回调
    if (_limitTrigger == 0 || _triggerCount < _limitTrigger) {
      _callback();
      _triggerCount++;
      // 判断是否已达到预期的监听次数
      if (_limitTrigger != 0 && _triggerCount >= _limitTrigger) {
        dispose();
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  /// 重置监听器
  void reset() {
    assert(isDisposed, 'Error: The listener is already disposed.');
    _triggerCount = 0;
  }

  /// 把当前类实例hashCode做为id
  int get id => hashCode;
}

/// 监听管理器
abstract mixin class ListenerManager {
  /// 监听器列表
  final Map<String, Map<int, Listener>> _listeners = {};

  /// 添加单个事件监听
  /// [event] 事件名称null为默认事件名称
  ///
  /// [callback] 触发事件的回调
  @protected
  Listener addListener(Object? event, VoidCallback callback,
      [int limitTrigger = 0]) {
    event = _getEventName(event);
    if (!_listeners.containsKey(event)) {
      _listeners[event as String] = {};
    }
    // 创建监听器实例
    final listenerInstance = Listener(callback, limit: limitTrigger);
    _listeners[event]![listenerInstance.id] = listenerInstance;
    listenerInstance.onDisposed(() {
      removeListener(event as String, listenerInstance.id);
    });
    return listenerInstance;
  }

  /// 添加多个事件监听
  ///
  /// 该方法会创建一个监听器，让其监听多个事件
  ///
  /// [events] 监听事件名称列表可以传入null传入null则等于是调用addListener方法
  ///
  /// [callback] 触发事件的回调
  ///
  /// * 基于该方法主要用于实现只监听响应式对象的某个属性变化
  @protected
  Listener addListeners(List<Object?>? events, VoidCallback callback,
      [int limitTrigger = 0]) {
    /// 如果传入null 则视为添加默认监听事件
    if (events == null) return addListener(null, callback, limitTrigger);
    // 创建监听器实例
    final listenerInstance = Listener(callback, limit: limitTrigger);
    final listenerId = listenerInstance.id;
    // 多个事件绑定一个监听器回调
    final List<String> onEvents = [];
    for (var eventName in events) {
      eventName = _getEventName(eventName);
      onEvents.add(eventName as String);
      if (!_listeners.containsKey(eventName)) {
        _listeners[eventName] = {};
      }
      _listeners[eventName]![listenerId] = listenerInstance;
    }
    // 监听器销毁时 删除该监听器绑定的所有事件
    listenerInstance.onDisposed(() {
      for (var eventName in onEvents) {
        removeListener(eventName, listenerId);
      }
    });
    return listenerInstance;
  }

  /// 删除对应的监听
  @protected
  void removeListener(String event, int listenerId) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(listenerId);
    }
  }

  /// 获取拼接好的监听事件名称，如果不传事件名称则监听所有变化
  ///
  /// [event] 传入事件名称，不传或传null为默认的监听事件，监听所有变化
  @protected
  String _getEventName([Object? event]) {
    if (event is num) {
      event = '_n($event)';
    } else {
      event = event != null ? '_$event' : '';
    }
    return '${runtimeType}_$hashCode$event';
  }

  /// 通知
  ///
  /// [event] 事件名称
  ///
  /// [events] 同时触发多个事件
  ///
  /// [dispose] 是否需要销毁事件监听器
  ///
  /// [triggerDefaultEvent] 如果event或events不为null时是否触发默认事件,默认会触发
  ///
  /// * 某些情况可能监听不到对象变化，可以手动调用该方法触发监听；
  /// 例如多层嵌套的map或list中就监听不到嵌套的数据变化，可以在修改过后手动调用该方法触发监听
  @protected
  void notifyListeners({
    Object? event,
    List<Object?>? events,
    bool dispose = false,
    bool triggerDefaultEvent = true,
  }) {
    if (events != null) {
      for (var item in events) {
        _emitDistribute(_getEventName(item), dispose);
      }
      // 如果在事件列表中没有找到null默认事件则触发默认事件
      if (triggerDefaultEvent && !events.contains(null)) {
        _emitDistribute(_getEventName(), false);
      }
    } else {
      _emitDistribute(_getEventName(event), dispose);
      // 如果触发了自定义事件则也需要触发默认事件
      if (triggerDefaultEvent && event != null) {
        _emitDistribute(_getEventName(), false);
      }
    }
  }

  /// 事件分发
  void _emitDistribute(String event, bool dispose) {
    // 判断是否存在该监听
    if (_listeners.containsKey(event)) {
      for (var id in _listeners[event]!.keys.toList()) {
        _listeners[event]?[id]?.emit();
        if (dispose) _listeners[event]?[id]?.dispose();
      }
      // 如果指定了销毁 则会清除该key下的所有监听
      if (dispose) _listeners.remove(event);
    }
  }
}
