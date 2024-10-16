import 'package:flutter/material.dart';

RouteTransitionsBuilder fadeTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) {
      final tween = Tween<double>(begin: 0, end: 1).chain(
        CurveTween(curve: Curves.easeInOutExpo),
      );

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    };
