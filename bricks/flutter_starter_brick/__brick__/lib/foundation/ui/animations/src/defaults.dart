import 'package:flutter/material.dart';

abstract final class AnimationDefaults {
  static const Duration animationDurationVeryShort = Duration(milliseconds: 50);

  static const Duration animationDurationShort = Duration(milliseconds: 100);

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const Curve curve = Curves.ease;

  static final CurveTween curveTween = CurveTween(curve: curve);
}
