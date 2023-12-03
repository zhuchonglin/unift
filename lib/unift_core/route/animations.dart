import 'package:flutter/widgets.dart';
import 'package:unift/unift_core/route/page_route.dart';

/// 滑动路由类型
enum SlideRouteType {
  left,
  right,
  top,
  bottom,
}

/// 新页面从指定方向滑动进入
class SlidePageRoute<T> extends UniFtPageRoute<T> {
  final SlideRouteType slideType;
  final Map<String, Offset> slideBegin = {
    'left': const Offset(-1.0, 0.0),
    'right': const Offset(1.0, 0.0),
    'top': const Offset(0.0, -1.0),
    'bottom': const Offset(0.0, 1.0),
  };
  SlidePageRoute({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    this.slideType = SlideRouteType.right,
    super.gestureEnabled,
  }) : super(fullscreenDialog: slideType == SlideRouteType.bottom);
  SlidePageRoute.right({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    super.gestureEnabled,
  }) : slideType = SlideRouteType.right;
  SlidePageRoute.bottom({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    super.gestureEnabled,
  })  : slideType = SlideRouteType.bottom,
        super(fullscreenDialog: true);
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return _slideTransition(
      child: _slideTransition(
        child: buildGesture(child),
        animation: animation,
        begin: slideBegin[slideType.name]!,
      ),
      animation: secondaryAnimation,
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    if (nextRoute is SlidePageRoute &&
        nextRoute.slideType == SlideRouteType.right) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    if (slideType == SlideRouteType.right) return true;
    return false;
  }
}

/// 新页面从透明到不透明
class FadePageRoute<T> extends UniFtPageRoute<T> {
  FadePageRoute({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    super.fullscreenDialog,
    super.gestureEnabled,
  });
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    child = buildGesture(child);
    return _slideTransition(
      child: _fadeTransition(
        child: child,
        animation: animation,
      ),
      animation: secondaryAnimation,
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) => true;
  @override
  bool canTransitionFrom(TransitionRoute previousRoute) => false;
}

/// 新页面从小到大进行缩放
class ZoomPageRoute<T> extends UniFtPageRoute<T> {
  ZoomPageRoute({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    super.fullscreenDialog,
    super.gestureEnabled,
  });
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    child = buildGesture(child);
    return _slideTransition(
      child: _scaleTransition(
        child: child,
        animation: animation,
      ),
      animation: secondaryAnimation,
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) => true;
  @override
  bool canTransitionFrom(TransitionRoute previousRoute) => false;
}

/// 新页面从小到大缩放的同时从透明到不透明
class ZoomFadePageRoute<T> extends UniFtPageRoute<T> {
  ZoomFadePageRoute({
    required super.builder,
    super.settings,
    super.allowSnapshotting,
    super.animationDuration,
    super.fullscreenDialog,
    super.gestureEnabled,
  });
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    child = buildGesture(child);
    return _slideTransition(
      child: _zoomFadeTransition(
        child: child,
        animation: animation,
      ),
      animation: secondaryAnimation,
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) => true;
  @override
  bool canTransitionFrom(TransitionRoute previousRoute) => false;
}

/// 新窗体从透明到不透明逐渐显示
AnimatedWidget _fadeTransition({
  required Widget child,
  required Animation<double> animation,
  double begin = 0.0,
  double end = 1.0,
  Curve curve = Curves.easeInOut,
}) {
  final opacity = Tween<double>(begin: begin, end: end).animate(
    CurvedAnimation(
      parent: animation,
      curve: curve,
    ),
  );
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return FadeTransition(
        opacity: opacity,
        child: child,
      );
    },
    child: child,
  );
}

/// 缩放动画
AnimatedWidget _scaleTransition({
  required Widget child,
  required Animation<double> animation,
  double begin = 0.0,
  double end = 1.0,
  Curve curve = Curves.easeInOut,
}) {
  return ScaleTransition(
    scale: Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
    ),
    child: child,
  );
}

/// 新窗体从小到大逐渐放大并且从透明到不透明逐渐显示
AnimatedWidget _zoomFadeTransition({
  required Animation<double> animation,
  required Widget child,
  double fadeBegin = 0.0,
  double fadeEnd = 1.0,
  Curve fadeCurve = Curves.easeInOut,
  double scaleBegin = 0.0,
  double scaleEnd = 1.0,
  Curve scaleCurve = Curves.easeInOut,
}) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return FadeTransition(
        opacity: Tween<double>(begin: fadeBegin, end: fadeEnd).animate(
          CurvedAnimation(
            parent: animation,
            curve: fadeCurve,
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: scaleBegin, end: scaleEnd).animate(
            CurvedAnimation(
              parent: animation,
              curve: scaleCurve,
            ),
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}

/// 滑动动画
AnimatedWidget _slideTransition({
  required Widget child,
  required Animation<double> animation,
  required Offset begin,
  Offset end = const Offset(0.0, 0.0),
  Curve curve = Curves.easeInOut,
}) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: begin, // 从右侧外部开始
      end: end, // 滑动到正常位置
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
    ),
    child: child,
  );
}
