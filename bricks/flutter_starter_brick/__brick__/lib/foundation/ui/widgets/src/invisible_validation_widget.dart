import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';

/// An invisible widget that provides validation support for non-form-field
/// components.
///
/// This widget uses [ValidateableStateMixin] to display error messages when
/// validation fails, while remaining invisible when there's no error.
///
/// Useful for components like checkboxes, custom pickers, sliders, or any
/// widget that needs validation but isn't a standard form field.
///
/// Type parameter [T] represents the value type being validated.
///
/// Example:
/// ```dart
/// InvisibleValidationWidget<Gender>(
///   key: _genderValidationKey,
///   value: _selectedGender,
///   validator: (value) =>
///       value == null ? context.appLocalizations.<yourErrorKey> : null,
/// )
/// ```
class InvisibleValidationWidget<T> extends StatefulWidget {
  const InvisibleValidationWidget({
    required this.value,
    required this.validator,
    super.key,
  });

  /// The current value to validate
  final T? value;

  /// Validator function that returns error message or null if valid
  final String? Function(T? value) validator;

  @override
  State<InvisibleValidationWidget<T>> createState() =>
      InvisibleValidationWidgetState<T>();
}

class InvisibleValidationWidgetState<T>
    extends State<InvisibleValidationWidget<T>>
    with
        TickerProviderStateMixin<InvisibleValidationWidget<T>>,
        ValidateableStateMixin<InvisibleValidationWidget<T>, T> {
  @override
  String? Function(T?)? get validator => widget.validator;

  @override
  T? get currentValue => widget.value;

  @override
  bool get showErrorMessage => true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: errorWidgets,
  );
}
