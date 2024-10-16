import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_elevated_button.dart';
import 'package:flutter/material.dart';

/// A custom button widget with a filled background.
///
/// This button extends [BaseElevatedButton] with predefined styling for a
/// filled button.
class FilledButton extends StatelessWidget {
  /// Creates a [FilledButton].
  ///
  /// The [text], [onPressed], and [backgroundColor] are required parameters.
  const FilledButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    super.key,
    this.width,
    this.textAlign,
    this.overflow,
    this.textColor = AppColorsTheme.white,
  });

  /// The text displayed on the button.
  final String text;

  /// The button's width. If null, it sizes to fit its content.
  final double? width;

  /// Callback invoked when the button is tapped.
  final VoidCallback? onPressed;

  /// Horizontal text alignment.
  final TextAlign? textAlign;

  /// Visual overflow handling.
  final TextOverflow? overflow;

  /// The button's background color.
  final Color backgroundColor;

  /// The button text color. Defaults to white.
  final Color textColor;

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) => BaseElevatedButton(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return context.appColorsTheme.disabledButtonBackgroundColor;
            }
            return backgroundColor;
          },
        ),
        side: const WidgetStatePropertyAll(BorderSide.none),
        width: width,
        text: text,
        textStyle: context.appTextTheme.body3.copyWith(
          color: _isDisabled
              ? context.appColorsTheme.onDisabledButtonBackgroundColor
              : textColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
        overflow: overflow,
        onPressed: onPressed,
      );
}
