import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

/// Default elevated button with customizable properties.
///
/// - If [text] is provided, it will be used as the button's label.
/// - If [child] is provided, it will be used instead of [text].
/// - Only one of [text] or [child] can be provided, and at least one must be
///  specified.
///
/// Use properties like [backgroundColor], [padding], [side], etc. to customize
/// the button's appearance.
class BaseElevatedButton extends StatelessWidget {
  const BaseElevatedButton({
    required this.onPressed,
    super.key,
    this.text,
    this.child,
    this.width,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.side,
    this.minimumSize,
    this.fixedSize,
    this.maximumSize,
    this.tapTargetSize,
    this.shape,
  })  : assert(
          text == null || child == null,
          'Provide either text or child, not both',
        ),
        assert(
          text != null || child != null,
          'Either text or child must be provided',
        );

  /// The text to display on the button.
  final String? text;

  /// A custom widget to display instead of text.
  final Widget? child;

  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// The width of the button.
  final double? width;

  /// The height of the button.
  final double? height;

  /// The alignment of the text within the button.
  final TextAlign? textAlign;

  /// The maximum number of lines for the text to span.
  final int? maxLines;

  /// How visual overflow should be handled for the text.
  final TextOverflow? overflow;

  /// The style to use for the text.
  final TextStyle? textStyle;

  /// The background color of the button in different states.
  final WidgetStateProperty<Color>? backgroundColor;

  /// The padding inside the button.
  final WidgetStateProperty<EdgeInsetsGeometry>? padding;

  /// The side (border) of the button.
  final WidgetStateProperty<BorderSide>? side;

  /// The minimum size of the button.
  final WidgetStateProperty<Size>? minimumSize;

  /// The fixed size of the button.
  final WidgetStateProperty<Size>? fixedSize;

  /// The maximum size of the button.
  final WidgetStateProperty<Size>? maximumSize;

  /// Configures the minimum size of the tap target.
  final MaterialTapTargetSize? tapTargetSize;

  /// The shape of the button's material.
  final WidgetStateProperty<OutlinedBorder?>? shape;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          style: context.themeData.elevatedButtonTheme.style?.copyWith(
            backgroundColor: backgroundColor,
            padding: padding,
            side: side,
            shape: shape,
            minimumSize: minimumSize,
            fixedSize: fixedSize,
            maximumSize: maximumSize,
            tapTargetSize: tapTargetSize,
          ),
          onPressed: onPressed,
          child: child ??
              Text(
                text!,
                style: textStyle,
                textAlign: textAlign ?? TextAlign.center,
                maxLines: maxLines,
                overflow: overflow ?? TextOverflow.ellipsis,
              ),
        ),
      );
}
