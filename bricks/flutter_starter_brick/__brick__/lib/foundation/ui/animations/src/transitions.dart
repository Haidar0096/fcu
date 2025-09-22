import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/src/defaults.dart';

Widget fadeTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(AnimationDefaults.curveTween);

  return FadeTransition(opacity: animation.drive(tween), child: child);
}

Widget scaleTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(AnimationDefaults.curveTween);

  return ScaleTransition(scale: animation.drive(tween), child: child);
}
