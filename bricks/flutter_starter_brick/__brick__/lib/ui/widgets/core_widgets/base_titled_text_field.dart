import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_text_form_field.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A widget that displays a title and a customizable text input field.
///
/// This widget combines a title section with a text input field, allowing for
/// customization of both the title and the input area. It supports various
/// properties for validation, styling, and behavior.
class BaseTitledTextField extends HookWidget {
  const BaseTitledTextField({
    super.key,
    this.initialText,
    this.onTextChanged,
    this.labelText = '',
    this.validator,
    this.width,
    this.keyboardType,
    this.autoFocus = false,
    this.inputFormatters,
    this.floatingLabelBehavior = FloatingLabelBehavior.never,
    this.maxLines = 1,
    this.fillColor,
    this.contentPadding = const EdgeInsets.only(left: 10),
    this.autoValidateMode,
    this.titleWidget,
    this.titleStyle,
    this.titleText,
    this.subtitleText,
    this.subtitleWidget,
    this.titlesFieldSectionsSpacing,
    this.titleSubtitleSpacing,
  })  : assert(
          titleWidget == null || titleText == null,
          'Only one of titleWidget or titleText can be provided',
        ),
        assert(
          subtitleWidget == null || subtitleText == null,
          'Only one of subtitleWidget or subtitleText can be provided',
        );

  /// The initial text to display in the text field.
  final String? initialText;

  /// Callback function triggered when the text changes.
  final ValueChanged<String>? onTextChanged;

  /// The label text to display in the text field.
  final String labelText;

  /// Validator function for the text field.
  final String? Function(String?)? validator;

  /// The keyboard type to use for the text field.
  final TextInputType? keyboardType;

  /// Whether the text field should auto-focus when displayed.
  final bool autoFocus;

  /// Input formatters to apply to the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// The width of the text field.
  final double? width;

  /// The behavior of the floating label.
  final FloatingLabelBehavior floatingLabelBehavior;

  /// The maximum number of lines for the text field.
  final int maxLines;

  /// The fill color of the text field.
  final Color? fillColor;

  /// The content padding for the text field.
  final EdgeInsets contentPadding;

  /// The auto-validation mode for the text field.
  final AutovalidateMode? autoValidateMode;

  /// A custom widget to use as the title.
  final Widget? titleWidget;

  /// The style to apply to the title text.
  final TextStyle? titleStyle;

  /// The text to display as the title.
  final String? titleText;

  /// The text to display as the subtitle.
  final String? subtitleText;

  /// A custom widget to use as the subtitle.
  final Widget? subtitleWidget;

  /// The spacing between the title section and the text field.
  final double? titlesFieldSectionsSpacing;

  /// The spacing between the title and subtitle.
  final double? titleSubtitleSpacing;

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: initialText);
    textController.addListener(() => onTextChanged?.call(textController.text));

    return BaseTitledWidget(
      titleWidget: titleWidget,
      titleStyle: titleStyle,
      titleText: titleText,
      subtitleText: subtitleText,
      subtitleWidget: subtitleWidget,
      titlesChildSectionsSpacing: titlesFieldSectionsSpacing,
      titleSubtitleSpacing: titleSubtitleSpacing,
      child: BaseTextFormField(
        width: width,
        maxLines: maxLines,
        fillColor: fillColor,
        contentPadding: contentPadding,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        controller: textController,
        labelText: labelText,
        floatingLabelBehavior: floatingLabelBehavior,
        labelStyle: context.appTextTheme.body2.copyWith(
          color: AppColorsTheme.purple.withOpacity(0.2),
        ),
        validator: validator,
        autoValidateMode: autoValidateMode,
        autoFocus: autoFocus,
      ),
    );
  }
}
