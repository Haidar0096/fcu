import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that applies a blur effect to its child widget's background.
class BlurWidget extends StatelessWidget {
  const BlurWidget({
    required this.child,
    super.key,
    this.applyBlur = true,
    this.blurIntensity = BlurWidgetDefaults.blurIntensity,
  });

  final Widget child;

  /// Indicates whether to apply the blur effect. Defaults to true.
  final bool applyBlur;

  /// The intensity of the blur effect. Higher values result in a stronger
  /// blur.
  final double blurIntensity;

  @override
  Widget build(BuildContext context) =>
      applyBlur
          ? BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurIntensity,
              sigmaY: blurIntensity,
            ),
            child: child,
          )
          : child;
}

class BlurWidgetDefaults {
  static const double blurIntensity = 5.0;
}
