import 'package:flutter/material.dart';
import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';

/// A customizable radio button widget with an optional child.
///
/// This widget doesn't maintain state for related radio buttons.
/// Use it as part of a stateful widget or with a state management solution.
class CustomRadioButton<T> extends StatelessWidget {
  const CustomRadioButton({
    required this.value,
    required this.groupValue,
    super.key,
    this.onChanged,
    this.child,
    this.padding = CustomRadioButtonDefaults.padding,
    this.radioSize = const Size(
      CustomRadioButtonDefaults.radioSize,
      CustomRadioButtonDefaults.radioSize,
    ),
    this.spacing = CustomRadioButtonDefaults.spacing,
    this.enabled = true,
    this.selectedColor,
    this.selectedInnerColor,
    this.unselectedColor,
    this.innerCircleThickness = CustomRadioButtonDefaults.innerCircleThickness,
  });

  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the group of radio buttons.
  final T? groupValue;

  /// Callback triggered when the radio button is tapped.
  final ValueChanged<T>? onChanged;

  /// Optional widget to display next to the radio button.
  final Widget? child;

  /// Padding around the entire widget.
  final EdgeInsets padding;

  /// Size of the radio button.
  final Size radioSize;

  /// Spacing between the radio button and child widget.
  final double spacing;

  /// Whether the radio button is interactive.
  final bool enabled;

  /// Color of the outer circle when selected.
  final Color? selectedColor;

  /// Color of the inner circle when selected.
  final Color? selectedInnerColor;

  /// Color of the circle when unselected.
  final Color? unselectedColor;

  /// Thickness of the inner circle when selected.
  final double innerCircleThickness;

  /// Whether this radio button is currently selected.
  bool get _isSelected => groupValue == value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: enabled ? () => onChanged?.call(value) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.fromSize(
              size: radioSize,
              child: Opacity(
                opacity:
                    enabled
                        ? CustomRadioButtonDefaults.enabledOpacity
                        : CustomRadioButtonDefaults.disabledOpacity,
                child: AnimatedContainer(
                  duration: AnimationDefaults.animationDuration,
                  curve: Curves.easeInOut,
                  child: _RadioButton(
                    isSelected: _isSelected,
                    selectedColor:
                        selectedColor ?? context.themeData.colorScheme.primary,
                    selectedInnerColor:
                        selectedInnerColor ??
                        context.themeData.colorScheme.surface,
                    unselectedColor:
                        unselectedColor ??
                        context.themeData.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                    innerCircleThickness: innerCircleThickness,
                  ),
                ),
              ),
            ),
            if (child != null) ...[SizedBox(width: spacing), child!],
          ],
        ),
      ),
    );
  }
}

class _RadioButton extends StatelessWidget {
  const _RadioButton({
    required this.isSelected,
    required this.selectedColor,
    required this.selectedInnerColor,
    required this.unselectedColor,
    required this.innerCircleThickness,
  });

  final bool isSelected;
  final Color selectedColor;
  final Color selectedInnerColor;
  final Color unselectedColor;
  final double innerCircleThickness;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AnimationDefaults.animationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? selectedColor : unselectedColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          (CustomRadioButtonDefaults.radioSize - innerCircleThickness) /
              (isSelected
                  ? CustomRadioButtonDefaults.selectedPaddingFactor
                  : CustomRadioButtonDefaults.unselectedPaddingFactor),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selectedInnerColor,
          ),
        ),
      ),
    );
  }
}

class CustomRadioButtonDefaults {
  static const EdgeInsets padding = EdgeInsets.zero;
  static const double radioSize = 24;
  static const double innerCircleThickness = 12;
  static const double selectedPaddingFactor = 2.5;
  static const double unselectedPaddingFactor = 3.5;
  static const double spacing = 8;
  static const double enabledOpacity = 1;
  static const double disabledOpacity = 0.5;
}
