import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Design values owned by the alert dialog.
abstract final class AlertDialogDefaults {
  /// This dialog's own horizontal padding.
  ///
  /// It is deliberately NOT `DialogConstants.horizontalPadding`, which the
  /// two sibling dialogs use: the two numbers differ, the difference is
  /// older than this file, and nobody has ruled which one the three dialogs
  /// should share. Naming it here stops it being a raw number at the call
  /// site; it does not settle the question.
  static final double horizontalPadding = SpacingSize.spacing24.value;

  /// Opens the content under the dialog's top edge.
  static final double contentTopPadding = SpacingSize.spacing24.value;

  /// Closes the gap between the content and the single action below it.
  static final double contentBottomPadding = SpacingSize.spacing16.value;

  /// Seats the single action above the dialog's bottom edge.
  static final double actionsBottomPadding = SpacingSize.spacing24.value;
}
