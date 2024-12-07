import 'package:flutter/material.dart';

final CurveTween _defaultCurveTween = CurveTween(curve: Curves.ease);

Widget fadeTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<double>(begin: 0, end: 1).chain(_defaultCurveTween);

  return FadeTransition(
    opacity: animation.drive(tween),
    child: child,
  );
}

Widget scaleTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween<double>(begin: 0, end: 1).chain(_defaultCurveTween);

  return ScaleTransition(
    scale: animation.drive(tween),
    child: child,
  );
}
