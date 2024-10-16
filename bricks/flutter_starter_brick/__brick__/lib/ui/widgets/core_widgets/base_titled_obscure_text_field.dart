import 'package:{{proj_name}}/ui/widgets/core_widgets/base_obscure_text_field.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_titled_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a title and a text field for password input.
///
/// Either [titleText] or [titleWidget] must be provided, but not both.
/// Similarly, either [subtitleText] or [subtitleWidget] can be provided, but
/// not both.
class BaseTitledObscureTextField extends StatelessWidget {
  const BaseTitledObscureTextField({
    super.key,
    this.titleText,
    this.titleWidget,
    this.titleStyle,
    this.initialText,
    this.onTextChanged,
    this.labelText = '********',
    this.validator,
    this.titlesFieldSectionsSpacing,
    this.width,
    this.keyboardType,
    this.autoFocus,
    this.subtitleText,
    this.subtitleWidget,
    this.titleSubtitleSpacing,
    this.hintText,
    this.floatingLabelBehavior,
    this.labelPadding,
    this.autoValidateMode,
  })  : assert(
          (titleText != null) || (titleWidget != null),
          'Either titleText or titleWidget must be provided, but not both.',
        ),
        assert(
          (subtitleText == null) || (subtitleWidget == null),
          'Either subtitleText or subtitleWidget can be provided, '
          'but not both.',
        );

  /// The text to display as the title.
  final String? titleText;

  /// A custom widget to display as the title.
  final Widget? titleWidget;

  /// The style to apply to the title text.
  final TextStyle? titleStyle;

  /// The initial text to display in the text field.
  final String? initialText;

  /// Callback function when the text changes.
  final void Function(String)? onTextChanged;

  /// The text to display as the label for the text field.
  final String labelText;

  /// Validator function for the text field.
  final String? Function(String?)? validator;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// Whether the text field should be auto-focused.
  final bool? autoFocus;

  /// The text to display as the subtitle.
  final String? subtitleText;

  /// A custom widget to display as the subtitle.
  final Widget? subtitleWidget;

  /// The text to display as a hint in the text field.
  final String? hintText;

  /// Defines the behavior of the floating label.
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// The width of the text field.
  final double? width;

  /// The spacing between the title and the subtitle.
  final double? titleSubtitleSpacing;

  /// The spacing between the titles section and the text field section.
  final double? titlesFieldSectionsSpacing;

  /// The padding for the label of the text field.
  final EdgeInsets? labelPadding;

  /// The auto-validation mode for the text field.
  final AutovalidateMode? autoValidateMode;

  @override
  Widget build(BuildContext context) => BaseTitledWidget(
        titleText: titleText,
        titleWidget: titleWidget,
        titleSubtitleSpacing: titleSubtitleSpacing,
        titlesChildSectionsSpacing: titlesFieldSectionsSpacing,
        subtitleWidget: subtitleWidget,
        subtitleText: subtitleText,
        titleStyle: titleStyle,
        child: BaseObscureTextField(
          initialText: initialText,
          onTextChanged: onTextChanged,
          labelText: labelText,
          validator: validator,
          width: width,
          keyboardType: keyboardType,
          autoFocus: autoFocus,
          hintText: hintText,
          floatingLabelBehavior: floatingLabelBehavior,
          labelPadding: labelPadding,
          autoValidateMode: autoValidateMode,
        ),
      );
}
