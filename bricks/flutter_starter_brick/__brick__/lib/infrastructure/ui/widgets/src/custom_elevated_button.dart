import 'package:flutter/material.dart';

/// Default elevated button with customizable properties.
///
/// - If [text] is provided, it will be used as the button's label.
/// - If [child] is provided, it will be used instead of [text].
/// - Only one of [text] or [child] can be provided, and at least one must be
///  specified.
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    required this.onPressed,
    super.key,
    this.text,
    this.child,
    this.width,
    this.height,
    this.textAlign = CustomElevatedButtonDefaults.textAlign,
    this.maxLines,
    this.textOverflow = CustomElevatedButtonDefaults.textOverflow,
    this.textStyle,
    this.style,
  }) : assert(
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
  final TextOverflow textOverflow;

  /// The style to use for the text.
  final TextStyle? textStyle;

  /// The style to use for the button.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      style: style,
      onPressed: onPressed,
      child:
          child ??
          Text(
            text!,
            style: textStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: textOverflow,
          ),
    ),
  );
}

class CustomElevatedButtonDefaults {
  static const TextAlign textAlign = TextAlign.center;

  static const TextOverflow textOverflow = TextOverflow.ellipsis;
}
