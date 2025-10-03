import 'package:flutter/material.dart';

/// A simple loading widget that shows a circular progress indicator.
class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key, this.size, this.strokeWidth, this.color});

  /// The size of the circular progress indicator.
  final double? size;

  /// The width of the circle's stroke.
  final double? strokeWidth;

  /// The color of the progress indicator.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth ?? LoaderWidgetDefaults.strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).colorScheme.primary,
      ),
    );

    final effectiveSize = size ?? LoaderWidgetDefaults.size;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: indicator,
    );
  }
}

class LoaderWidgetDefaults {
  static const double size = 48;
  static const double strokeWidth = 4;
}
