import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:{{proj_name}}/foundation/ui/animations/src/defaults.dart';

typedef SlideOffsets = ({Offset begin, Offset end});

SlideOffsets _getSlideOffsets(
  SlideDirection slideFromDirection,
) => switch (slideFromDirection) {
  SlideDirection.topToBottom => (begin: const Offset(0, -1), end: Offset.zero),
  SlideDirection.bottomToTop => (begin: const Offset(0, 1), end: Offset.zero),
  SlideDirection.leftToRight => (begin: const Offset(-1, 0), end: Offset.zero),
  SlideDirection.rightToLeft => (begin: const Offset(1, 0), end: Offset.zero),
};

extension WidgetExtension on Widget {
  /// Wraps the widget with a widget that animates with the default animation
  /// effects.
  Widget withAnimations({
    required bool withSlide,
    required bool withFade,
    required bool withScale,
    required bool withRotation,
    Key? key,
    SlideDirection? slideDirection,
    Duration? duration,
    Duration? delay,
  }) {
    final animationDuration = duration ?? AnimationDefaults.animationDuration;
    var result = animate(delay: delay);

    if (withFade) {
      result = result.fade(duration: animationDuration);
    }

    if (withScale) {
      result = result.scale(duration: animationDuration);
    }

    if (withRotation) {
      result = result.rotate(duration: animationDuration);
    }

    if (withSlide) {
      final slideOffsets = _getSlideOffsets(
        slideDirection ?? SlideDirection.topToBottom,
      );
      result = result.slide(
        begin: slideOffsets.begin,
        end: slideOffsets.end,
        duration: animationDuration,
      );
    }

    return KeyedSubtree(key: key, child: result);
  }
}

extension WidgetListExtension on List<Widget> {
  /// Wraps each widget in the list with default animation effects.
  List<Widget> withAnimations({
    required bool withSlide,
    required bool withFade,
    required bool withScale,
    required bool withRotation,
    required bool staggered,
    SlideDirection? slideDirection,
    Duration? duration,
    Duration? staggeredDelay,
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final delay = staggered
          ? ((staggeredDelay ??
                    AnimationDefaults.animationDurationVeryShort) *
                index)
          : null;

      return widget.withAnimations(
        withSlide: withSlide,
        withFade: withFade,
        withScale: withScale,
        withRotation: withRotation,
        slideDirection: slideDirection,
        duration: duration,
        delay: delay,
      );
    }).toList();
  }
}

enum SlideDirection { topToBottom, bottomToTop, leftToRight, rightToLeft }
