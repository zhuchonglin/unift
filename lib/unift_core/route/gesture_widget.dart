import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart'
    show
        BuildContext,
        HitTestBehavior,
        Listener,
        MediaQuery,
        PositionedDirectional,
        Stack,
        State,
        StatefulWidget,
        ValueGetter,
        Widget;

import '../meta.dart';
import 'gesture_controller.dart';

/// 手势处理
@protected
class DragHandleWidget extends StatefulWidget {
  final Widget child;

  /// 是否能开启手势返回功能
  final ValueGetter<bool> isEnabled;

  /// 手势方向
  final GestureDirection direction;

  /// 手势控制器
  final ValueGetter<BackGestureController> gestureController;

  /// left偏移量
  final double left;

  /// 顶部偏移量
  final double top;

  /// 如果监听x方向则该长度 代表宽度 高度为屏幕高度
  ///
  /// 如果监听y方向则该长度 代表高度 宽度为屏幕宽度
  final double size;
  const DragHandleWidget({
    super.key,
    required this.child,
    required this.isEnabled,
    required this.gestureController,
    required this.direction,
    this.top = 0.0,
    this.left = 0.0,
    this.size = 30.0,
  });
  @override
  State<StatefulWidget> createState() => _DragHandleWidgetState();

  /// 判断是否监听X横轴手势
  bool get dx => direction == GestureDirection.left;
}

class _DragHandleWidgetState extends State<DragHandleWidget> {
  /// 手势识别器。
  late DragGestureRecognizer _recognizer;

  /// 当前手势控制器
  BackGestureController? currentGestureController;
  @override
  void initState() {
    super.initState();

    // 为垂直轴上的交互创建一个手势识别器。
    _recognizer = widget.dx
        ? HorizontalDragGestureRecognizer(debugOwner: this)
        : VerticalDragGestureRecognizer(debugOwner: this);
    _recognizer.onStart = _handleDragStart;
    _recognizer.onUpdate = _handleDragUpdate;
    _recognizer.onEnd = _handleDragEnd;
    _recognizer.onCancel = _handleDragCancel;
  }

  /// 开始拖动
  void _handleDragStart(DragStartDetails details) {
    currentGestureController = widget.gestureController();
  }

  /// 拖动位置更新
  void _handleDragUpdate(DragUpdateDetails details) {
    final other = widget.dx ? context.size!.width : context.size!.height;
    currentGestureController!.dragUpdate(
      details.primaryDelta! / other,
    );
  }

  /// 拖动结束
  void _handleDragEnd(DragEndDetails details) {
    final velocity = widget.dx
        ? details.velocity.pixelsPerSecond.dx / context.size!.width
        : details.velocity.pixelsPerSecond.dy / context.size!.height;
    currentGestureController!.dragEnd(
      velocity,
    );
    currentGestureController = null;
  }

  /// 拖动取消
  void _handleDragCancel() {
    currentGestureController?.dragEnd(0.0);
    currentGestureController = null;
  }

  /// 监听手指按下
  void _handlePointerDown(PointerDownEvent event) {
    if (widget.isEnabled()) _recognizer.addPointer(event);
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.dx ? widget.size : MediaQuery.of(context).size.width;
    final height = widget.dx ? MediaQuery.of(context).size.height : widget.size;
    return Stack(
      children: <Widget>[
        widget.child,
        // 创建一个覆盖在页面上的区域来监听拖动事件
        PositionedDirectional(
          start: widget.left,
          top: widget.top,
          height: height,
          width: width,
          child: Listener(
            // 监听事件
            onPointerDown: _handlePointerDown,
            // 让事件透传
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}
