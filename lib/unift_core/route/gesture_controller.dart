import 'dart:math' show min;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart'
    show
        AnimationController,
        AnimationStatus,
        AnimationStatusListener,
        Curve,
        Curves,
        NavigatorState;

/// 手势监听方向
enum GestureDirection { left, top }

/// 手势控制器
class BackGestureController {
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
  BackGestureController({
    required this.controller,
    required this.navigator,
    required this.direction,
    this.minFlingVelocity = 1.0,
    this.minGestureProgress = 0.5,
    this.animationDuration = 300,
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

  /// 判断是否监听X横轴手势
  bool get dx => direction == GestureDirection.left;

  /// 判断是否监听X横轴手势
  bool get dy => direction == GestureDirection.top;
}
