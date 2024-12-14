import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:{{proj_name}}/common/validators/validators.dart';

/// A customizable [TextFormField] with default styling and behavior.
///
/// This widget provides a wide range of customization options for a text form
/// field, including styling, validation, and behavior controls.
class BaseTextFormField extends StatelessWidget {
  /// Creates a [BaseTextFormField].
  ///
  /// Many parameters are optional and will use default values if not specified.
  const BaseTextFormField({
    super.key,
    this.enableSuggestions,
    this.autocorrect,
    this.scrollPadding,
    this.cursorColor,
    this.decoration,
    this.enabled,
    this.labelText,
    this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.onValidate,
    this.height,
    this.width,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.hintText,
    this.errorMaxLines,
    this.autofocus = false,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.onTapOutside,
    this.obscureText = false,
    this.suffixIcon,
    this.contentPadding,
    this.style,
    this.filled,
    this.fillColor,
    this.defaultValidatorErrorMessage,
    this.textAlign,
    this.hintStyle,
    this.floatingLabelBehavior,
    this.labelStyle,
    this.suffixIconConstraints,
    this.inputFormatters,
    this.maxLines,
    this.labelPadding,
    this.autoValidateMode,
    this.contextMenuBuilder,
  });

  /// Whether to show input suggestions.
  final bool? enableSuggestions;

  /// Whether to enable autocorrect.
  final bool? autocorrect;

  /// The padding for scrollable ancestor widgets.
  final EdgeInsets? scrollPadding;

  /// The color of the cursor.
  final Color? cursorColor;

  /// The decoration to show around the text field.
  final InputDecoration? decoration;

  /// Whether the text field is enabled.
  final bool? enabled;

  /// The text to use for the floating label.
  final String? labelText;

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  final void Function(String text)? onFieldSubmitted;

  /// Called when the user changes the text in the field.
  final void Function(String text)? onChanged;

  /// Called with the current validation state when the input is validated.
  final void Function({required bool isValid})? onValidate;

  /// The height of the text field.
  final double? height;

  /// The width of the text field.
  final double? width;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final String? Function(String? value)? validator;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// The maximum number of lines the error text can occupy.
  final int? errorMaxLines;

  /// Whether this text field should focus itself if nothing else is already
  /// focused.
  final bool autofocus;

  /// The height of the cursor.
  final double? cursorHeight;

  /// The width of the cursor.
  final double cursorWidth;

  /// Called when the user taps outside of the text field.
  final void Function(PointerDownEvent event)? onTapOutside;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  /// An icon that appears after the editable part of the text field.
  final Widget? suffixIcon;

  /// The padding for the input decoration's container.
  final EdgeInsets? contentPadding;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// If true, the decoration's container is filled with [fillColor].
  final bool? filled;

  /// The color to fill the decoration's container with, if [filled] is true.
  final Color? fillColor;

  /// The error message to show when the default validator fails.
  final String? defaultValidatorErrorMessage;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The style to use for the [hintText].
  final TextStyle? hintStyle;

  /// Defines how the floating label should behave.
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// The style to use for the [labelText].
  final TextStyle? labelStyle;

  /// Optional size constraints for the suffix icon.
  final BoxConstraints? suffixIconConstraints;

  /// Optional input validation and formatting rules.
  final List<TextInputFormatter>? inputFormatters;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  final int? maxLines;

  /// The padding for the [labelText].
  final EdgeInsetsGeometry? labelPadding;

  /// Used to configure the auto validation of [FormField] and [Form] widgets.
  final AutovalidateMode? autoValidateMode;

  /// A builder for the context menu that appears when the user long-presses
  /// this text field.
  final EditableTextContextMenuBuilder? contextMenuBuilder;


  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: TextFormField(
          enableSuggestions: enableSuggestions ?? true,
          autocorrect: autocorrect ?? true,
          scrollPadding: scrollPadding ?? const EdgeInsets.all(20),
          cursorColor: cursorColor ?? context.themeData.colorScheme.primary,
          maxLines: maxLines ?? 1,
          enabled: enabled,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          contextMenuBuilder: contextMenuBuilder,
          controller: controller,
          textAlign: textAlign ?? TextAlign.start,
          onTap: () => focusNode?.requestFocus(),
          autofocus: autofocus,
          autovalidateMode: autoValidateMode,
          style: style ??
              context.typography?.body3.copyWith(
                color: context.themeData.colorScheme.onSurface,
              ),
          cursorHeight: cursorHeight,
          cursorWidth: cursorWidth,
          decoration: decoration ??
              InputDecoration(
                filled: filled ?? true,
                fillColor: fillColor ?? context.themeData.colorScheme.surface,
                suffixIcon: suffixIcon,
                suffixIconConstraints: suffixIconConstraints,
                errorMaxLines: errorMaxLines,
                label: Padding(
                  padding: labelPadding ?? EdgeInsets.zero,
                  child: Text(
                    labelText ?? '',
                    style: labelStyle ??
                        context.typography?.body3.copyWith(
                          color: context.themeData.colorScheme.primary,
                        ),
                  ),
                ),
                floatingLabelBehavior:
                    floatingLabelBehavior ?? FloatingLabelBehavior.always,
                hintText: hintText,
                hintStyle: hintStyle ??
                    context.typography?.body3.copyWith(
                      color: context.themeData.colorScheme.onSurface
                          .withOpacity(0.6),
                    ),
                contentPadding:
                    contentPadding ?? const EdgeInsets.only(left: 10),
                enabledBorder:
                    context.themeData.inputDecorationTheme.enabledBorder,
                disabledBorder:
                    context.themeData.inputDecorationTheme.disabledBorder,
                focusedBorder:
                    context.themeData.inputDecorationTheme.focusedBorder,
                errorBorder: context.themeData.inputDecorationTheme.errorBorder,
                focusedErrorBorder:
                    context.themeData.inputDecorationTheme.focusedErrorBorder,
              ),
          onChanged: onChanged,
          validator: (String? value) {
            if (validator != null) {
              final error = validator!.call(value);
              if (error != null) {
                onValidate?.call(isValid: false);
                return error;
              }
              onValidate?.call(isValid: true);
              return null;
            } else {
              // Use default validator if no custom validator is provided
              final textLengthValidatorErrorMessage = validateTextLength(
                value,
                appLocalizations: context.appLocalizations,
              );
              if (textLengthValidatorErrorMessage != null) {
                onValidate?.call(isValid: false);
                return defaultValidatorErrorMessage ?? 'This field is required';
              }
              onValidate?.call(isValid: true);
              return null;
            }
          },
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction ?? TextInputAction.next,
          onTapOutside: onTapOutside ??
              (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
      );
}
