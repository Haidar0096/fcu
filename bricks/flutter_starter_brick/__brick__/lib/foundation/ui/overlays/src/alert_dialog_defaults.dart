/// Design values owned by the alert dialog.
abstract final class AlertDialogDefaults {
  /// This dialog's own horizontal padding.
  ///
  /// It is deliberately NOT `DialogConstants.horizontalPadding`, which the
  /// two sibling dialogs use: the two numbers differ, the difference is
  /// older than this file, and nobody has ruled which one the three dialogs
  /// should share. Naming it here stops it being a raw number at the call
  /// site; it does not settle the question.
  static const double horizontalPadding = 24;

  /// Opens the content under the dialog's top edge.
  static const double contentTopPadding = 20;

  /// Closes the gap between the content and the single action below it.
  static const double contentBottomPadding = 12;

  /// Seats the single action above the dialog's bottom edge.
  static const double actionsBottomPadding = 20;
}
