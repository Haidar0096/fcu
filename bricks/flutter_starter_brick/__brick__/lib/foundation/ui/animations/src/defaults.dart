import 'package:flutter/material.dart';

class AnimationDefaults {
  static const Duration animationDurationVeryShort = Duration(milliseconds: 50);

  static const Duration animationDurationShort = Duration(milliseconds: 100);

  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Animation duration used when doing simulations, usually useful for
  /// testing only.
  static const Duration animationDurationSimulation = Duration(
    milliseconds: 500,
  );

  static const Curve curve = Curves.ease;

  static final CurveTween curveTween = CurveTween(curve: curve);
}
