import 'package:flutter/widgets.dart'
    show BuildContext, Key, State, StatefulWidget, Widget;
import 'package:unift/unift_core/meta.dart' show protected;
import 'package:unift/unift_ref/listener.dart' show Listener;
import 'package:unift/unift_ref/ref.dart' show RefProxy;
import 'package:unift/unift_ref/ref_quote_tracker.dart';

typedef WidgetCallback = Widget Function();

/// [RefWidget] 用于自动自动计算build中使用的RefProxy响应式对象
///
/// 无需手动监听响应式变量变化重构状态，该小部件会自动监听引用的响应式对象和重构状态
///
/// [RefWidget]构造依赖[RefQuoteTracker]如果在异步并发情况下可能会存在监听不准确的情况
///
/// 如果您在代码中使用的是异步构建widget则建议使用[RefWidget.watch]构造函数实现精细化管理状态
abstract class RefWidget extends StatefulWidget {
  final Map<RefProxy, List<Object?>>? _watch;

  /// 构建全自动管理状态小部件
  const RefWidget({super.key}) : _watch = null;

  /// 构建精细化监听管理状态小部件
  ///
  /// [watch] 需传入在build中使用的响应式变量代理
  ///
  /// ```dart
  /// /// 假定userInfo 为用户信息
  /// final userInfo = map<String,dynamic>({'username':'小明','age':10}).toRef();
  /// // 假设在build中使用了userInfo的username字段则可以像以下这样传入watch来实现精细化的监听
  /// RefWidget.watch(watch:{userInfo:['username']})
  /// ```
  const RefWidget.watch({
    super.key,
    required Map<RefProxy, List<Object?>> watch,
  }) : _watch = watch;
  @override
  State<RefWidget> createState() => _RefComputedState();

  /// 在该方法中返回需要响应式构建的widget
  @protected
  Widget build();
}

/// 自动计算状态
class _RefComputedState extends State<RefWidget> {
  late Widget _widgetView;

  /// 创建的监听器
  final List<Listener> _listeners = [];
  @override
  void initState() {
    _startWatch();
    super.initState();
  }

  /// 开始监听
  void _startWatch() {
    final Map<RefProxy, List<Object?>> tracks;
    if (widget._watch != null) {
      tracks = widget._watch!;
      _widgetView = widget.build();
    } else {
      // 获取build方法中使用了哪些响应式变量
      final response = RefQuoteTracker.getQuoteTracks<Widget>(widget.build);
      tracks = response.tracks;
      _widgetView = response.result;
    }
    updateWidget() {
      if (mounted) {
        setState(() {
          _widgetView = widget.build();
        });
      }
    }

    /// 监听响应式变量
    tracks.forEach((refProxy, events) {
      final listenerInstance = refProxy.addListeners(events, updateWidget);
      _listeners.add(listenerInstance);
    });
  }

  /// 销毁监听
  void _stopWatch() {
    // 销毁监听
    for (var listener in _listeners) {
      listener.dispose();
    }
  }

  @override
  void dispose() {
    _stopWatch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _widgetView;
  }
}

/// 响应视图
class RefView extends RefWidget {
  final WidgetCallback builder;

  /// 构建响应视图（全自动监听使用的对象）
  const RefView(this.builder, {super.key});

  /// 构建响应视图（监听指定的响应对象以及事件）
  const RefView.watch(
    this.builder,
    Map<RefProxy, List<Object?>> watch, {
    Key? key,
  }) : super.watch(key: key, watch: watch);

  @override
  Widget build() {
    return builder();
  }
}

/// 响应视图元素
///
/// RefView的助手函数
///
/// [builder] 给定一个函数返回widget
/// [watch] 监听的响应式代理对象map映射 key为对象，value为事件列表，完全监听value可以设置为[null]
Widget refEl(WidgetCallback builder, [Map<RefProxy, List<Object?>>? watch]) {
  if (watch == null) {
    return RefView(builder);
  } else {
    return RefView.watch(builder, watch);
  }
}
