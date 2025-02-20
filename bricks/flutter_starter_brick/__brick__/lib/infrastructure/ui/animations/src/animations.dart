import 'package:{{proj_name}}/infrastructure/ui/animations/src/defaults.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    Key? key,
    bool withSlide = false,
    bool withFade = true,
    bool withScale = false,
    bool withRotation = false,
    SlideDirection slideDirection = SlideDirection.topToBottom,
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
      final slideOffsets = _getSlideOffsets(slideDirection);
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
    bool withSlide = false,
    bool withFade = true,
    bool withScale = false,
    bool withRotation = false,
    SlideDirection slideDirection = SlideDirection.topToBottom,
    Duration? duration,
    bool staggered = false,
    Duration staggeredDelay = const Duration(milliseconds: 50),
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final delay = staggered ? (staggeredDelay * index) : null;

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
