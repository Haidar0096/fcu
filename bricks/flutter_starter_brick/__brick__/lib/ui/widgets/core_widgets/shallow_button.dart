import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_elevated_button.dart';
import 'package:flutter/material.dart';

/// A button with a transparent background and customizable border color.
///
/// This widget extends the functionality of [BaseElevatedButton] to create
/// a button with a transparent background and a border color that matches
/// the text color.
///
/// Either [text] or [child] must be provided, but not both.
class ShallowButton extends StatelessWidget {
  /// Creates a [ShallowButton].
  ///
  /// The [color] parameter determines both the border and text color.
  /// The [onPressed] callback is called when the button is tapped.
  ///
  /// Either [text] or [child] must be provided, but not both.
  const ShallowButton({
    required this.color,
    required this.onPressed,
    super.key,
    this.text,
    this.child,
    this.height,
    this.width,
    this.textAlign,
    this.overflow,
    this.padding,
    this.minimumSize,
    this.fixedSize,
  })  : assert(
          text == null || child == null,
          'Only one of text or child can be provided',
        ),
        assert(
          text != null || child != null,
          'Either text or child must be provided',
        );

  /// The text to display on the button. Mutually exclusive with [child].
  final String? text;

  /// A widget to display instead of text. Mutually exclusive with [text].
  final Widget? child;

  /// The height of the button. If null, the button's height is determined by
  /// its content.
  final double? height;

  /// The width of the button. If null, the button's width is determined by its
  /// content.
  final double? width;

  /// The color used for the button's border and text.
  final Color color;

  /// Called when the button is tapped or otherwise activated.
  final void Function()? onPressed;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The padding for the button's content.
  final WidgetStateProperty<EdgeInsetsGeometry>? padding;

  /// The minimum size of the button.
  final WidgetStateProperty<Size>? minimumSize;

  /// The fixed size of the button. If non-null, this takes precedence over
  /// [width] and [height].
  final WidgetStateProperty<Size>? fixedSize;

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) => BaseElevatedButton(
        padding: padding,
        minimumSize: minimumSize,
        fixedSize: fixedSize,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return context.appColorsTheme.disabledButtonBackgroundColor;
            }
            return Colors.transparent;
          },
        ),
        shape: WidgetStateProperty.resolveWith(
          (states) {
            final defaultShape = context
                .appButtonTheme.baseElevatedButtonStyle?.shape
                ?.resolve(states);
            final isDisabled = states.contains(WidgetState.disabled);
            return defaultShape?.copyWith(
              side: BorderSide(color: isDisabled ? Colors.transparent : color),
            );
          },
        ),
        height: height,
        width: width,
        text: text,
        textStyle: context.appTextTheme.body3.copyWith(
          color: _isDisabled
              ? context.appColorsTheme.onDisabledButtonBackgroundColor
              : color,
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
        overflow: overflow,
        onPressed: onPressed,
        child: child,
      );
}
