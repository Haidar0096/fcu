import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

import 'base_text_form_field.dart';

/// A widget that displays a password input field with visibility toggle.
class BaseObscureTextField extends StatefulWidget {
  const BaseObscureTextField({
    super.key,
    this.initialText,
    this.onTextChanged,
    this.labelText = '',
    this.labelStyle,
    this.validator,
    this.width,
    this.keyboardType,
    this.autoFocus,
    this.hintText,
    this.floatingLabelBehavior,
    this.labelPadding,
    this.autoValidateMode,
  });

  /// The initial text to display in the text field.
  final String? initialText;

  /// Callback invoked when the text changes.
  final void Function(String)? onTextChanged;

  /// The label text displayed above the text field.
  final String labelText;

  /// A function to validate the input.
  final String? Function(String?)? validator;

  /// The width of the text field.
  final double? width;

  /// The type of keyboard to use for input.
  final TextInputType? keyboardType;

  /// Whether the text field should auto-focus on load.
  final bool? autoFocus;

  /// The style for the label text.
  final TextStyle? labelStyle;

  /// The hint text displayed when the field is empty.
  final String? hintText;

  /// Controls the floating label behavior.
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// Padding for the label.
  final EdgeInsets? labelPadding;

  /// The mode for automatic validation.
  final AutovalidateMode? autoValidateMode;

  @override
  State<BaseObscureTextField> createState() => _BaseObscureTextFieldState();
}

class _BaseObscureTextFieldState extends State<BaseObscureTextField> {
  late final TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController
        .addListener(() => widget.onTextChanged?.call(_textController.text));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseTextFormField(
      width: widget.width,
      contentPadding: const EdgeInsets.only(left: 10),
      autoValidateMode: widget.autoValidateMode,
      suffixIconConstraints: const BoxConstraints(),
      suffixIcon: InkWell(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Padding(
          padding: const EdgeInsets.all(8).add(const EdgeInsets.only(right: 8)),
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: context.themeData.colorScheme.onSurface.withOpacity(0.6),
            size: 25,
          ),
        ),
      ),
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      controller: _textController,
      labelText: widget.labelText,
      labelPadding: widget.labelPadding,
      floatingLabelBehavior:
          widget.floatingLabelBehavior ?? FloatingLabelBehavior.never,
      labelStyle: widget.labelStyle ??
          context.typography?.body3.copyWith(
            color: context.themeData.colorScheme.primary.withOpacity(0.2),
            fontWeight: FontWeight.w700,
          ),
      hintText: widget.hintText,
      hintStyle: context.typography?.body3.copyWith(
        color: context.themeData.colorScheme.primary.withOpacity(0.2),
        fontWeight: FontWeight.w700,
      ),
      validator: widget.validator,
      autoFocus: widget.autoFocus ?? false,
    );
  }
}
