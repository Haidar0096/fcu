import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// A customizable checkbox widget with an optional child widget.
///
/// This widget does not maintain any state internally. It is a stateless
/// representation of a checkbox that can be customized with various parameters.
class BaseCheckboxWidget extends StatelessWidget {
  /// Creates a [BaseCheckboxWidget].
  ///
  /// The [value] parameter must not be null.
  const BaseCheckboxWidget({
    required this.value,
    super.key,
    this.onChanged,
    this.child,
    this.padding,
    this.checkboxWidth,
    this.checkboxHeight,
    this.checkboxButtonAndChildHorizontalSpacing,
    this.enabled = true,
  });

  /// Indicates whether this checkbox is checked.
  final bool value;

  /// Callback invoked when the user clicks on the checkbox.
  ///
  /// The newValue parameter indicates the updated value of the checkbox.
  final void Function({bool? newValue})? onChanged;

  /// An optional widget displayed next to the checkbox.
  final Widget? child;

  /// The padding around the checkbox and its child.
  final EdgeInsets? padding;

  /// The width of the checkbox.
  final double? checkboxWidth;

  /// The height of the checkbox.
  final double? checkboxHeight;

  /// The horizontal spacing between the checkbox and its child.
  final double? checkboxButtonAndChildHorizontalSpacing;

  /// Indicates whether the checkbox is enabled for interaction.
  final bool enabled;

  bool get _isChecked => value;

  static const _animationDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    Widget result = AnimatedCrossFade(
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) =>
          Stack(
        children: [
          Positioned.fill(child: topChild),
          Positioned.fill(child: bottomChild),
        ],
      ),
      firstChild: const Icon(
        Icons.check_box,
        color: AppColorsTheme.purple,
      ),
      secondChild: const Icon(
        Icons.check_box_outline_blank,
        color: AppColorsTheme.purple,
      ),
      crossFadeState:
          _isChecked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: _animationDuration,
    );

    if (!enabled) {
      result = Opacity(
        opacity: 0.2,
        child: result,
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? () => onChanged?.call(newValue: !value) : null,
          child: Row(
            children: [
              SizedBox(
                width: checkboxWidth ?? 22,
                height: checkboxHeight ?? 22,
                child: result,
              ),
              if (child != null) ...[
                SizedBox(
                  width: checkboxButtonAndChildHorizontalSpacing ?? 8,
                ),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
