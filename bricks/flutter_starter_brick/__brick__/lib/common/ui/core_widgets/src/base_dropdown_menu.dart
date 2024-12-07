import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

class BaseDropdownMenu<T> extends StatelessWidget {
  const BaseDropdownMenu({
    required this.items,
    required this.itemBuilder,
    required this.itemLabelBuilder,
    super.key,
    this.initialSelection,
    this.onSelected,
    this.hintText,
    this.hintTextStyle,
    this.width,
    this.validator,
    this.menuHeight,
    this.enabled = true,
    this.enableFilter = false,
    this.enableSearch = true,
    this.filterCallback,
    this.searchCallback,
    this.controller,
    this.focusNode,
    this.requestFocusOnTap,
    this.leadingIcon,
    this.trailingIcon,
    this.selectedTrailingIcon,
    this.label,
    this.helperText,
    this.textAlign = TextAlign.start,
    this.expandedInsets,
    this.inputFormatters,
    this.errorText,
    this.inputDecorationTheme,
    this.textStyle,
  });

  final T? initialSelection;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String Function(T item) itemLabelBuilder;
  final void Function(T? value)? onSelected;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final double? width;
  final String? Function(T?)? validator;
  final double? menuHeight;
  final bool enabled;
  final bool enableFilter;
  final bool enableSearch;
  final FilterCallback<T>? filterCallback;
  final SearchCallback<T>? searchCallback;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? requestFocusOnTap;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? selectedTrailingIcon;
  final Widget? label;
  final String? helperText;
  final TextAlign textAlign;
  final EdgeInsets? expandedInsets;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final InputDecorationTheme? inputDecorationTheme;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => DropdownMenu<T>(
        width: width,
        controller: controller,
        focusNode: focusNode,
        requestFocusOnTap: requestFocusOnTap,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        selectedTrailingIcon: selectedTrailingIcon,
        label: label,
        helperText: helperText,
        expandedInsets: expandedInsets,
        inputFormatters: inputFormatters,
        initialSelection: initialSelection,
        dropdownMenuEntries: [
          for (final item in items)
            DropdownMenuEntry(
              value: item,
              label: itemLabelBuilder(item),
              leadingIcon: itemBuilder(context, item),
            ),
        ],
        menuHeight: menuHeight,
        onSelected: onSelected,
        enabled: enabled,
        errorText: errorText,
        textStyle: textStyle ?? context.typography?.body3,
        enableFilter: enableFilter,
        filterCallback: filterCallback,
        enableSearch: enableSearch,
        searchCallback: searchCallback,
        textAlign: textAlign,
        hintText: hintText ?? context.appLocalizations.noValueSelected,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            context.themeData.colorScheme.surfaceContainerHigh,
          ),
          shadowColor: WidgetStatePropertyAll(
            context.themeData.colorScheme.shadow,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: inputDecorationTheme ??
            InputDecorationTheme(
              filled: true,
              contentPadding: const EdgeInsets.all(8),
              fillColor: context.themeData.colorScheme.surface,
              hintStyle: hintTextStyle ??
                  context.typography?.body3.copyWith(
                    color: context.themeData.colorScheme.onSurfaceVariant,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
      );
}
