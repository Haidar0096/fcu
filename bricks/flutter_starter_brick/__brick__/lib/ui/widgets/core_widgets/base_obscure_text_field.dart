import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A widget that displays a password input field with visibility toggle.
class BaseObscureTextField extends HookWidget {
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
  Widget build(BuildContext context) {
    final obscureText = useState(true);

    final textController = useTextEditingController(
      text: initialText,
    );
    textController.addListener(() => onTextChanged?.call(textController.text));

    return BaseTextFormField(
      width: width,
      contentPadding: const EdgeInsets.only(left: 10),
      autoValidateMode: autoValidateMode,
      suffixIconConstraints: const BoxConstraints(),
      suffixIcon: InkWell(
        onTap: () => obscureText.value = !obscureText.value,
        child: Padding(
          padding: const EdgeInsets.all(8).add(const EdgeInsets.only(right: 8)),
          child: Icon(
            obscureText.value ? Icons.visibility : Icons.visibility_off,
            color: AppColorsTheme.darkGrey,
            size: 25,
          ),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText.value,
      controller: textController,
      labelText: labelText,
      labelPadding: labelPadding,
      floatingLabelBehavior:
          floatingLabelBehavior ?? FloatingLabelBehavior.never,
      labelStyle: labelStyle ??
          context.appTextTheme.body3.copyWith(
            color: AppColorsTheme.purple.withOpacity(0.2),
            fontWeight: FontWeight.w700,
          ),
      hintText: hintText,
      hintStyle: context.appTextTheme.body3.copyWith(
        color: AppColorsTheme.purple.withOpacity(0.2),
        fontWeight: FontWeight.w700,
      ),
      validator: validator,
      autoFocus: autoFocus ?? false,
    );
  }
}
