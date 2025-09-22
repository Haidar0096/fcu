/// A mixin that marks a DTO as convertible to a UI model.
///
/// DTOs that implement this mixin are response DTOs meant to be
/// transformed into UI models for presentation layer usage.
mixin UiConvertibleDtoMixin<TU> {
  /// Converts this DTO to its corresponding UI model.
  TU toUiModel();
}
