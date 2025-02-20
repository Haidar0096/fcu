import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:flutter/material.dart';

/// A state base class that provides an animation controller to the widget and
/// disposes it when the widget is disposed.
/// It contains easy methods as well to start and stop the animation.
mixin AnimateableStateMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  /// An animation controller that can be used to animate the widget.
  @protected
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: AnimationDefaults.animationDuration,
      reverseDuration: AnimationDefaults.animationDuration,
    );
    animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  TickerFuture startAnimation() => animationController.forward();

  void stopAnimation() => animationController.stop();

  TickerFuture reverseAnimation() => animationController.reverse();
}
