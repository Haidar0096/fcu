import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that applies a blur effect to its child widget's background.
class BlurWidget extends StatelessWidget {
  const BlurWidget({
    required this.child,
    required this.applyBlur,
    this.blurIntensity,
    super.key,
  });

  final Widget child;

  /// Indicates whether to apply the blur effect. Defaults to true.
  final bool applyBlur;

  /// The intensity of the blur effect. Higher values result in a stronger
  /// blur.
  final double? blurIntensity;

  @override
  Widget build(BuildContext context) => applyBlur
      ? BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity ?? BlurWidgetDefaults.blurIntensity,
            sigmaY: blurIntensity ?? BlurWidgetDefaults.blurIntensity,
          ),
          child: child,
        )
      : child;
}

abstract final class BlurWidgetDefaults {
  static const double blurIntensity = 5;
}
