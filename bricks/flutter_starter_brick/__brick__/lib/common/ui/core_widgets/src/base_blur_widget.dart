import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that applies a blur effect to its child widget's background.
class BaseBlurWidget extends StatelessWidget {
  const BaseBlurWidget({
    required this.child,
    super.key,
    this.applyBlur = true,
    this.blurIntensity = 5.0,
  });

  final Widget child;

  /// Indicates whether to apply the blur effect. Defaults to true.
  final bool applyBlur;

  /// The intensity of the blur effect. Higher values result in a stronger
  /// blur.
  final double blurIntensity;

  @override
  Widget build(BuildContext context) => applyBlur
      ? BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: child,
        )
      : child;
}
