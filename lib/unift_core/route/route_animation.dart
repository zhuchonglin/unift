import 'package:flutter/widgets.dart';
import 'package:unift/unift_core/route/gesture_controller.dart';

import 'gesture_widget.dart';

/// 过渡动画
typedef TransitionAnimatedWidget = AnimatedWidget Function(
    {required Widget child, required Animation<double> animation});

/// 返回过渡功能
mixin BackGestureTransitionMixin<T> on ModalRoute<T> {
  /// 手势方向
  GestureDirection get gestureDirection;

  /// 是否允许手势返回
  bool get popGesture;

  /// 该方法返回一个手势控制器实例
  BackGestureController startPopGesture() {
    return BackGestureController(
      navigator: navigator!,
      // ignore: invalid_use_of_protected_member
      controller: controller!,
      direction: gestureDirection,
    );
  }

  /// 检测是否能够开启手势返回功能
  ///
  /// 可重写该方法实现自定义
  bool isPopGestureEnabled() {
    if (!popGesture) return false;
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
}

/// 内置动画类型
enum AnimationType {
  /// 新窗口从右侧进入
  slideInRight,

  /// 新窗口从左侧进入
  slideInLeft,

  /// 新窗口从顶部进入
  slideInTop,

  /// 新窗口从底部进入
  slideInBottom,

  /// 新窗体从透明到不透明逐渐显示
  fade,

  /// 新窗体从小到大缩放显示
  zoom,

  /// 新窗体从小到大逐渐放大并且从透明到不透明逐渐显示
  zoomFade,

  /// 无动画
  none
}

/// 路由过渡动画默认参数映射
const Map<String, ({dynamic begin, dynamic end, Function func})>
    routeTransitionMap = {
  'slideInRight': (
    begin: Offset(1.0, 0.0),
    end: Offset(0.0, 0.0),
    func: slideTransition,
  ),
  'slideInLeft': (
    begin: Offset(-1.0, 0.0),
    end: Offset(0.0, 0.0),
    func: slideTransition,
  ),
  'slideInTop': (
    begin: Offset(0.0, -1.0),
    end: Offset(0.0, 0.0),
    func: slideTransition,
  ),
  'slideInBottom': (
    begin: Offset(0.0, 1.0),
    end: Offset(0.0, 0.0),
    func: slideTransition,
  ),
  'fade': (
    begin: 0.0,
    end: 1.0,
    func: fadeTransition,
  ),
  'zoom': (
    begin: 0.0,
    end: 1.0,
    func: scaleTransition,
  )
};

/// 页面路由过渡
class UniFtPageRoute<T> extends PageRoute<T> with BackGestureTransitionMixin {
  /// 构建页面函数
  final WidgetBuilder builder;

  /// 动画类型
  final AnimationType animationType;

  /// 动画时间
  final int animationDuration;

  /// 是否支持侧滑返回功能 默认为true
  @override
  final bool popGesture;

  @override
  final GestureDirection gestureDirection;

  /// UniFt框架路由动画
  ///
  /// * [builder] 页面构造函数
  /// * [animationType] 过渡动画的类型 `AnimationType`枚举
  /// * [animationDuration] 过渡动画时间，单位毫秒。
  /// * [settings] 如果没有提供[settings]，则使用空的[RouteSettings]对象。
  /// * [allowSnapshotting] 路由过渡是否偏向于使用进入/退出路由的快照进行动画过渡。
  /// 当这个值为 true 时，某些路由过渡（比如 Android 中的缩放页面过渡）
  /// 会对进入和退出的路由进行截图（快照）。
  /// 这些快照会在动画中被使用，代替底层的部件以提高过渡的性能。
  /// 通常来说，这意味着在路由动画播放时，出现在进入/退出路由上的动画可能会呈现静止状态，
  /// 除非它们是 Hero 动画或者其他在单独的覆盖层上绘制的内容。
  /// 这种优化方式旨在提高路由过渡的性能，
  /// 但有时会导致在动画播放期间出现在进入/退出路由上的动画看起来像是被冻结了一样。
  /// 这种情况下，如果动画对于用户体验很重要，
  /// 可以考虑使用 Hero 动画或者在单独的覆盖层上进行绘制以避免这种冻结效果。
  /// * [fullscreenDialog] 此页面路由是否为全屏对话框。
  /// 全屏显示具有制作的效果应用程序栏有一个关闭按钮，而不是后退按钮。
  /// 在上iOS中，对话框转换的动画效果不同，也不可用关闭手势。
  UniFtPageRoute({
    required this.builder,
    this.animationType = AnimationType.slideInRight,
    this.popGesture = true,
    this.gestureDirection = GestureDirection.left,
    this.animationDuration = 300,
    super.settings,
    super.allowSnapshotting,
    super.fullscreenDialog, //全屏对话框
  });

  /// 用于设置模态屏障（Modal Barrier）的颜色。
  /// 模态屏障是渲染在每个路由后面的一层幕布，
  /// 通常用来阻止用户与当前路由下面的路由进行交互，并且通常部分遮挡这些路由。
  ///
  /// 如果页面为一个模态框时使用该属性定义一个遮蔽层颜色非常的高效，且美观，内部会自动进行过渡。
  ///
  /// 举个例子，当一个对话框（Dialog）出现在屏幕上时，
  /// 对话框下面的页面通常会被模态屏障的颜色进行一定程度的变暗。
  ///
  /// 如果设置的颜色是 null，则模态屏障将是透明的。
  /// 同时，当 [ModalRoute.offstage] 为 true 时，颜色将被忽略，模态屏障将变为不可见状态。
  ///
  /// 在路由动画进入位置时，颜色会从透明度逐渐变为指定的颜色。
  ///
  /// 如果 barrierColor 的返回值变化，
  /// 需要调用 [changedInternalState] 或者 [changedExternalState] 方法以使变化生效。
  ///
  /// 通常在此处可以安全地使用 navigator.context 来查找继承的小部件（inherited widgets），因为 [Navigator] 在其依赖项更改时会调用 [changedExternalState]，而 [changedExternalState] 会导致模态屏障进行重建。
  ///
  /// 更多参考：
  /// * [barrierDismissible]：控制屏障在被点击时的行为。
  /// * [ModalBarrier]：实现这一特性的小部件。
  @override
  Color? get barrierColor => null;

  /// 用于设置可关闭的屏障（Dismissible Barrier）的语义标签。如果屏障是可关闭的，
  /// 当辅助工具（比如 iOS 上的 VoiceOver）聚焦在屏障上时，此标签将被读出。
  @override
  String? get barrierLabel => null;

  /// 转换完成后，页面是否会遮挡以前的页面。
  /// 不透明页面的入口过渡完成后，将不会构建不透明页面后面的页面以节省资源。
  @override
  bool get opaque => true;

  /// 当该值为true时，某些路线转换（如Android缩放页面转换）将快照进入和退出路线。
  /// 然后将这些快照设置为动画，以代替底层小部件，从而提高转换的性能。
  /// 一般来说，这意味着在播放路线动画时，出现在进入/退出路线上的动画可能会显示为冻结状态，
  /// 除非它们是hero动画或在单独的覆盖中绘制的东西。
  ///
  /// 从TransitionRoute复制。
  @override
  bool get maintainState => true;

  /// 窗口进入动画时间
  @override
  Duration get transitionDuration => Duration(milliseconds: animationDuration);

  /// 窗口退出动画时间
  @override
  Duration get reverseTransitionDuration =>
      Duration(milliseconds: animationDuration);

  ///当此路由被推送到此路由的顶部或者当此路由从 [nextRoute] 弹出时，返回 true 表示此路由是否支持一个过渡动画。
  ///
  ///子类可以重写此方法来限制它们需要与之协调过渡的路由集。
  ///
  ///如果返回 true，并且 [nextRoute.canTransitionFrom()] 也返回 true，则表示 [ModalRoute.buildTransitions] 的 secondaryAnimation 将从 0.0 - 1.0 运行，当 [nextRoute] 被推送到此路由的顶部时。类似地，如果 [nextRoute] 从此路由弹出，则 secondaryAnimation 将从 1.0 - 0.0 运行。
  ///
  ///如果返回 false，则此路由的 [ModalRoute.buildTransitions] 的 secondaryAnimation 将会是 [kAlwaysDismissedAnimation]。换句话说，当 [nextRoute] 被推送到此路由的顶部时或者当 [nextRoute] 从此路由弹出时，此路由不会执行动画过渡。
  ///
  ///默认情况下返回 true。
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => true;

  /// 当此路由被推送到前一个路由的顶部或者当此路由从前一个路由弹出时，返回 true 表示 [previousRoute] 是否应该进行动画过渡。
  ///
  ///子类可以重写此方法来限制它们需要与之协调过渡的路由集。
  ///
  ///如果返回 true，并且 [previousRoute.canTransitionTo()] 也返回 true，则表示前一个路由的 [ModalRoute.buildTransitions] 的 secondaryAnimation 将从 0.0 - 1.0 运行，当此路由被推送到前一个路由的顶部时。类似地，如果此路由从 [previousRoute] 弹出，则前一个路由的 secondaryAnimation 将从 1.0 - 0.0 运行。
  ///
  ///如果返回 false，则前一个路由的 [ModalRoute.buildTransitions] 的 secondaryAnimation 将会是 [kAlwaysDismissedAnimation]。换句话说，当此路由被推送到前一个路由的顶部时或者当此路由从前一个路由弹出时，[previousRoute] 将不会执行动画过渡。
  ///
  ///默认情况下返回 true。
  /// * [previousRoute] 表示前一个路由对象，即当前路由的上一个路由。
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => true;

  /// 构建页面
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Builder(builder: builder);
  }

  /// 过渡效果
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (popGesture) {
      child = DragHandleWidget(
        isEnabled: isPopGestureEnabled,
        gestureController: startPopGesture,
        direction: gestureDirection,
        child: child,
      );
    }
    final Widget transitionWidget;
    if (animationType == AnimationType.none) {
      transitionWidget = child;
    } else if (animationType == AnimationType.zoomFade) {
      transitionWidget = zoomFadeTransition(animation: animation, child: child);
    } else {
      final ({dynamic begin, dynamic end, Function func}) t =
          routeTransitionMap[animationType.name]!;
      transitionWidget = t.func(
          animation: animation, child: child, begin: t.begin, end: t.end);
    }
    return slideTransition(
      child: transitionWidget,
      animation: secondaryAnimation,
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    );
  }
}

/// 新窗体从透明到不透明逐渐显示
AnimatedWidget fadeTransition({
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
AnimatedWidget scaleTransition({
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
AnimatedWidget zoomFadeTransition({
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
            curve: Curves.easeInOut,
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: scaleBegin, end: scaleEnd).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
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
AnimatedWidget slideTransition({
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
