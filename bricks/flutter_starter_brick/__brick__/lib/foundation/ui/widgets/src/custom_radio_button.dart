import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

/// Custom radio button widget with proper styling
class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({
    required this.isSelected,
    required this.isAnimated,
    super.key,
  });

  final bool isSelected;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final duration = isAnimated
        ? AnimationDefaults.animationDuration
        : Duration.zero;
    return AnimatedContainer(
      duration: duration,
      curve: AnimationDefaults.curve,
      width: CustomRadioButtonDefaults.outerSize,
      height: CustomRadioButtonDefaults.outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? context.themeData.colorScheme.primary
              : context.themeData.colorScheme.outline,
          width: CustomRadioButtonDefaults.borderWidth,
        ),
      ),
      child: AnimatedOpacity(
        duration: duration,
        curve: AnimationDefaults.curve,
        opacity: isSelected ? 1.0 : 0.0,
        child: Center(
          child: Container(
            width: CustomRadioButtonDefaults.innerSize,
            height: CustomRadioButtonDefaults.innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.themeData.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class CustomRadioButtonDefaults {
  static const double outerSize = 24;
  static const double innerSize = 12;
  static const double borderWidth = 2;
}
