import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:{{proj_name}}/foundation/ui/focus/focus.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

/// A customizable [TextFormField] with default styling and behavior.
///
/// This widget provides a wide range of customization options for a text form
/// field, including styling, validation, and behavior controls.
class CustomTextFormField extends StatefulWidget {
  /// Creates a [CustomTextFormField].
  ///
  /// Many parameters are optional and will use default values if not specified.
  const CustomTextFormField({
    super.key,
    this.enableSuggestions,
    this.autocorrect,
    this.scrollPadding = CustomTextFormFieldDefaults.scrollPadding,
    this.cursorColor,
    this.decoration,
    this.enabled = CustomTextFormFieldDefaults.enabled,
    this.labelText,
    this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.height,
    this.width,
    this.textInputAction = CustomTextFormFieldDefaults.textInputAction,
    this.keyboardType,
    this.validator,
    this.hintText,
    this.autofocus = CustomTextFormFieldDefaults.autofocus,
    this.cursorHeight,
    this.cursorWidth = CustomTextFormFieldDefaults.cursorWidth,
    this.onTapOutside,
    this.obscureText = CustomTextFormFieldDefaults.obscureText,
    this.suffixIcon,
    this.contentPadding = CustomTextFormFieldDefaults.contentPadding,
    this.style,
    this.filled,
    this.fillColor,
    this.textAlign = CustomTextFormFieldDefaults.textAlign,
    this.hintStyle,
    this.floatingLabelBehavior,
    this.labelStyle,
    this.suffixIconConstraints,
    this.inputFormatters,
    this.maxLines = CustomTextFormFieldDefaults.maxLines,
    this.minLines,
    this.maxLength,
    this.contextMenuBuilder,
    this.isDense,
    this.isCollapsed,
    this.showErrorMessage = CustomTextFormFieldDefaults.showErrorMessage,
    this.initialValue,
    this.disabledBorder,
  });

  /// Whether to show input suggestions.
  final bool? enableSuggestions;

  /// Whether to enable autocorrect.
  final bool? autocorrect;

  /// The padding for scrollable ancestor widgets.
  final EdgeInsets scrollPadding;

  /// The color of the cursor.
  final Color? cursorColor;

  /// The decoration to show around the text field.
  final InputDecoration? decoration;

  /// Whether the text field is enabled.
  final bool enabled;

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

  /// The height of the text field.
  final double? height;

  /// The width of the text field.
  final double? width;

  /// The type of action button to use for the keyboard.
  final TextInputAction textInputAction;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final String? Function(String? value)? validator;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

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
  final EdgeInsets contentPadding;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// If true, the decoration's container is filled with [fillColor].
  final bool? filled;

  /// The color to fill the decoration's container with, if [filled] is true.
  final Color? fillColor;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

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
  final int maxLines;

  /// The minimum number of lines to occupy when the content is shorter.
  /// Expands from minLines to maxLines as user types.
  final int? minLines;

  /// The maximum number of characters allowed in the text field.
  final int? maxLength;

  /// Builds the text selection context menu.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Whether the InputDecorator is part of a dense form
  /// (i.e., uses less vertical space).
  final bool? isDense;

  /// Whether the decoration is collapsed (i.e., has no label).
  final bool? isCollapsed;

  /// Whether to show the error message when the field is invalid.
  final bool showErrorMessage;

  /// The initial value of the field. Has no effect if a [controller] is used.
  final String? initialValue;

  /// If not null, will replace the disabled border used for this field.
  final InputBorder? disabledBorder;

  @override
  State<CustomTextFormField> createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField>
    with
        TickerProviderStateMixin<CustomTextFormField>,
        ValidateableStateMixin<CustomTextFormField, String> {
  late final TextEditingController _internalTextController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalTextController;

  @override
  String? Function(String?)? get validator => widget.validator;

  @override
  String? get currentValue => _effectiveController.text;

  @override
  bool get showErrorMessage => widget.showErrorMessage;

  @override
  void initState() {
    super.initState();
    _internalTextController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _internalTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suffixIconConstraints =
        widget.suffixIconConstraints ??
        const BoxConstraints(
          maxWidth:
              CustomTextFormFieldDefaults.suffixMaxSide +
              CustomTextFormFieldDefaults.suffixPaddingRight,
          maxHeight: CustomTextFormFieldDefaults.suffixMaxSide,
        );

    final fillColor =
        widget.fillColor ??
        (widget.enabled
            ? context.themeData.colorScheme.surface
            : context.themeData.colorScheme.surfaceContainerHighest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextFormField(
            enableSuggestions:
                widget.enableSuggestions ??
                CustomTextFormFieldDefaults.enableSuggestions,
            autocorrect:
                widget.autocorrect ?? CustomTextFormFieldDefaults.autocorrect,
            scrollPadding: widget.scrollPadding,
            cursorColor: widget.cursorColor,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            contextMenuBuilder: widget.contextMenuBuilder,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            controller: _effectiveController,
            textAlign: widget.textAlign,
            onTap: () => widget.focusNode?.requestFocus(),
            autofocus: widget.autofocus,
            style:
                widget.style ??
                context.typography?.fieldInput.copyWith(
                  color: context.themeData.colorScheme.onSurface,
                ),
            cursorHeight: widget.cursorHeight,
            cursorWidth: widget.cursorWidth,
            decoration:
                widget.decoration ??
                InputDecoration(
                  isDense: widget.isDense,
                  isCollapsed: widget.isCollapsed,
                  filled: widget.filled ?? CustomTextFormFieldDefaults.filled,
                  fillColor: fillColor,
                  suffixIcon: widget.suffixIcon,
                  suffixIconConstraints: suffixIconConstraints,
                  labelStyle:
                      widget.labelStyle ??
                      context.typography?.indicationText.copyWith(
                        color: context.themeData.colorScheme.onSurfaceVariant,
                      ),
                  labelText: widget.labelText,
                  floatingLabelBehavior:
                      widget.floatingLabelBehavior ??
                      FloatingLabelBehavior.auto,
                  hintText: widget.hintText,
                  hintStyle:
                      widget.hintStyle ??
                      context.typography?.bodyText.copyWith(
                        color: context.themeData.colorScheme.onSurface
                            .withValues(
                              alpha:
                                  CustomTextFormFieldDefaults.hintTextOpacity,
                            ),
                      ),
                  contentPadding: widget.contentPadding,
                  enabledBorder: hasError
                      ? context.themeData.inputDecorationTheme.errorBorder
                      : context.themeData.inputDecorationTheme.enabledBorder,
                  disabledBorder:
                      widget.disabledBorder ??
                      context.themeData.inputDecorationTheme.disabledBorder,
                  focusedBorder: hasError
                      ? context
                            .themeData
                            .inputDecorationTheme
                            .focusedErrorBorder
                      : context.themeData.inputDecorationTheme.focusedBorder,
                ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              autoValidate();
            },
            onFieldSubmitted: widget.onFieldSubmitted,
            textInputAction: widget.textInputAction,
            onTapOutside: widget.onTapOutside ?? (_) => context.unfocus(),
          ),
        ),
        ...errorWidgets,
      ],
    );
  }
}

abstract final class CustomTextFormFieldDefaults {
  static const double cursorWidth = 2;
  static const double suffixPaddingRight = 20.0;
  static const double suffixMaxSide = 23.0;
  static const double hintTextOpacity = 0.6;
  static const bool enableSuggestions = true;
  static const bool autocorrect = true;
  static const bool filled = true;
  static const bool enabled = true;
  static const bool autofocus = false;
  static const bool obscureText = false;
  static const bool showErrorMessage = true;
  static const EdgeInsets scrollPadding = EdgeInsets.all(20);
  static const int maxLines = 1;
  static const TextAlign textAlign = TextAlign.start;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const TextInputAction textInputAction = TextInputAction.next;
}
