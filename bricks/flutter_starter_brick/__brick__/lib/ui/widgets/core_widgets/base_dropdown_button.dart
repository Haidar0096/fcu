import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// A customizable dropdown button widget that allows selection from a
/// list of items.
///
/// This widget supports hint text, validation, and customization of its
/// appearance.
class BaseDropdownButton<T> extends StatelessWidget {
  const BaseDropdownButton({
    required this.items,
    required this.itemBuilder,
    super.key,
    this.value,
    this.onChanged,
    this.hintText,
    this.hintTextStyle,
    this.width,
    this.height,
    this.hintMaxLines,
    this.hintOverflow,
    this.isExpanded,
    this.validator,
    this.autoValidateMode,
  });

  /// The currently selected value.
  final T? value;

  /// The list of items to display in the dropdown.
  final List<T> items;

  /// A builder function to create the widget for each item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Callback invoked when the selected value changes.
  final void Function(T? newValue)? onChanged;

  /// The hint text displayed when no value is selected.
  final String? hintText;

  /// The style to use for the hint text.
  final TextStyle? hintTextStyle;

  /// The width of the dropdown button.
  final double? width;

  /// The height of the dropdown button.
  final double? height;

  /// Maximum number of lines for the hint text.
  final int? hintMaxLines;

  /// Overflow behavior for the hint text.
  final TextOverflow? hintOverflow;

  /// Whether the dropdown should expand to fill the available space.
  final bool? isExpanded;

  /// A function to validate the selected value.
  final String? Function(T?)? validator;

  /// The mode for automatic validation.
  final AutovalidateMode? autoValidateMode;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<T>(
            isExpanded: isExpanded ?? false,
            value: value,
            validator: validator,
            autovalidateMode: autoValidateMode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              enabledBorder: context.appDropdownMenuTheme.enabledBorder,
              disabledBorder: context.appDropdownMenuTheme.disabledBorder,
              focusedBorder: context.appDropdownMenuTheme.focusedBorder,
              errorBorder: context.appDropdownMenuTheme.errorBorder,
              focusedErrorBorder:
                  context.appDropdownMenuTheme.focusedErrorBorder,
            ),
            dropdownColor: AppColorsTheme.white,
            borderRadius: BorderRadius.circular(8),
            iconSize: 35,
            icon: const Icon(Icons.keyboard_arrow_down),
            hint: Text(
              hintText ?? context.appLocalizations.noValueSelected,
              style: hintTextStyle ??
                  context.appTextTheme.body3.copyWith(
                    color: AppColorsTheme.lightGrey,
                  ),
              maxLines: hintMaxLines ?? 1,
              overflow: hintOverflow ?? TextOverflow.ellipsis,
            ),
            style: context.appTextTheme.body3.copyWith(
              color: AppColorsTheme.purple,
            ),
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: item,
                  child: itemBuilder(context, item),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}
