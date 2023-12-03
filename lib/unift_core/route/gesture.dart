import 'dart:math' show min;
import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart'
    show
        DragGestureRecognizer,
        HorizontalDragGestureRecognizer,
        VerticalDragGestureRecognizer;
import 'package:flutter/widgets.dart'
    show
        AnimationController,
        AnimationStatus,
        AnimationStatusListener,
        BuildContext,
        Curve,
        Curves,
        DragEndDetails,
        DragStartDetails,
        DragUpdateDetails,
        HitTestBehavior,
        Listener,
        MediaQuery,
        ModalRoute,
        NavigatorState,
        PointerDownEvent,
        PositionedDirectional,
        Stack,
        State,
        StatefulWidget,
        ValueGetter,
        Widget;

/// 手势监听方向
enum GestureDirection { left, top }

/// 过渡功能
mixin BackGestureMixin<T> on ModalRoute<T> {
  /// 手势方向
  GestureDirection get gestureDirection => GestureDirection.left;

  /// 最小滑动速度
  double get minFlingVelocity => 1.0;

  /// 可手势操控的位置
  ({
    double? top,
    double? left,
    double? width,
    double? height,
    double? right,
    double? bottom
  })? get gesturePosition => null;

  /// 最小手势进度
  ///
  /// 如果手势停止时大于该手势进度则会返回上一页
  double get minGestureProgress => 0.5;

  /// 动画时间
  int get animationDuration => 300;

  /// 命中行为控制
  HitTestBehavior get gestureHitTestBehavior => HitTestBehavior.translucent;

  /// 是否启用手势返回
  bool get popGestureEnabled => true;

  /// 开始拖动时调用该方法创建控制器
  _BackGestureController _createBackGestureController() {
    return _BackGestureController(
      controller: controller!,
      navigator: navigator!,
      direction: gestureDirection,
      minFlingVelocity: minFlingVelocity,
      minGestureProgress: minGestureProgress,
      animationDuration: animationDuration,
    );
  }

  /// 检测是否能够开启手势返回功能
  ///
  /// 可重写该方法实现自定义
  bool isPopGestureEnabled() {
    if (!popGestureEnabled) return false;
    // 如果这是应用中的唯一路由则返回false
    if (isFirst) return false;
    // 判断能否返回路由
    if (willHandlePopInternally) return false;
    // 判断是否监听了返回事件
    if (hasScopedWillPopCallback) return false;
    // 判断路由动画状态是否已结束
    if (animation!.status != AnimationStatus.completed) return false;
    // 判断secondaryAnimation是否已经结束
    if (secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }
    // 判断是否正在操作手势
    if (navigator!.userGestureInProgress) return false;

    return true;
  }

  /// 构建手势widget
  Widget buildGesture(Widget child) {
    // 如果明确禁用侧滑返回 则直接返回child
    if (!popGestureEnabled) return child;
    return _GestureBuilder(
      gesturePosition: gesturePosition,
      gestureHitTestBehavior: gestureHitTestBehavior,
      isEnabled: isPopGestureEnabled,
      gestureDirection: gestureDirection,
      getGestureController: _createBackGestureController,
      child: child,
    );
  }
}

/// 手势控制器
class _BackGestureController {
  /// 动画控制器
  final AnimationController controller;

  /// 导航实例
  final NavigatorState navigator;

  /// 手势方向
  final GestureDirection direction;

  /// 最小滑动速度
  final double minFlingVelocity;

  /// 最小手势进度
  ///
  /// 如果手势停止时大于该手势进度则会返回上一页
  final double minGestureProgress;

  /// 动画时间
  final int animationDuration;

  /// 手势控制器
  _BackGestureController({
    required this.controller,
    required this.navigator,
    required this.direction,
    required this.minFlingVelocity,
    required this.minGestureProgress,
    required this.animationDuration,
  }) {
    navigator.didStartUserGesture();
  }

  /// 更新动画
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// 拖动结束
  ///
  /// [velocity] 手势滑动速度
  void dragEnd(double velocity) {
    // 动画曲线
    const Curve animationCurve = Curves.easeOut;

    // 是否重置 如果滑动的距离或速度未达到预期则重置到初始的位置
    final bool isBackForward;
    // 判断滑动速度大于等于最小滑动速度
    if (velocity.abs() >= minFlingVelocity) {
      // 如果滑动速度大于等于0 则需要返回上一页
      isBackForward = true;
    } else {
      // 如果动画已经执行超过最小手势进度，则也代表需要返回上一页
      isBackForward = controller.value <= minGestureProgress;
    }
    if (isBackForward) {
      navigator.pop();
      if (controller.isAnimating) {
        // 计算出返回动画剩余时间
        final int droppedPageBackAnimationTime =
            lerpDouble(0, animationDuration, controller.value)!.floor();

        /// 执行返回动画
        controller.animateBack(
          0.0,
          duration: Duration(
            milliseconds: droppedPageBackAnimationTime,
          ),
          curve: animationCurve,
        );
      }
    } else {
      /// 计算出还原动画的剩余时间
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(animationDuration, 0, controller.value)!.floor(),
        animationDuration,
      );
      controller.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime),
          curve: animationCurve);
    }
    // 如果动画正在反向播放
    if (controller.isAnimating) {
      late AnimationStatusListener animationStatusCallback;
      // 监听动画状态回调
      animationStatusCallback = (AnimationStatus status) {
        // 上报停止手势
        navigator.didStopUserGesture();
        // 删除监听
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class _GestureBuilder extends StatefulWidget {
  final Widget child;
  final ({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    double? height
  })? gesturePosition;
  final HitTestBehavior gestureHitTestBehavior;

  /// 是否能开启手势返回功能
  final ValueGetter<bool> isEnabled;
  final GestureDirection gestureDirection;

  /// 手势控制器
  final ValueGetter<_BackGestureController> getGestureController;
  const _GestureBuilder({
    required this.child,
    required this.gesturePosition,
    required this.gestureHitTestBehavior,
    required this.isEnabled,
    required this.gestureDirection,
    required this.getGestureController,
  });

  @override
  State<_GestureBuilder> createState() => __GestureBuilderState();
  bool get dx => gestureDirection == GestureDirection.left;
}

class __GestureBuilderState extends State<_GestureBuilder> {
  /// 手势识别器。
  late DragGestureRecognizer _recognizer;

  /// 当前手势控制器
  _BackGestureController? currentGestureController;
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

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  /// 开始拖动
  void _handleDragStart(DragStartDetails details) {
    currentGestureController = widget.getGestureController();
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

  /// 可手势操控的位置
  ({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    double? height
  }) get gesturePosition {
    if (widget.gesturePosition != null) return widget.gesturePosition!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (widget.gestureDirection == GestureDirection.left) {
      return (
        top: 0,
        left: 0.0,
        width: 50,
        height: height,
        right: null,
        bottom: null
      );
    } else {
      return (
        top: 0.0,
        left: 0.0,
        width: width,
        height: 30,
        right: null,
        bottom: null
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        // 创建一个覆盖在页面上的区域来监听拖动事件
        PositionedDirectional(
          start: gesturePosition.left,
          top: gesturePosition.top,
          bottom: gesturePosition.bottom,
          end: gesturePosition.right,
          height: gesturePosition.height,
          width: gesturePosition.width,
          child: Listener(
            // 监听事件
            onPointerDown: _handlePointerDown,
            // 让事件透传
            behavior: widget.gestureHitTestBehavior,
          ),
        ),
      ],
    );
  }
}
