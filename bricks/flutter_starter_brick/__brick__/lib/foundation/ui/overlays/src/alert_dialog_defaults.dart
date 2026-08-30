import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Design values owned by the alert dialog.
abstract final class AlertDialogDefaults {
  /// This dialog's own horizontal padding.
  ///
  /// It is deliberately NOT `DialogConstants.horizontalPadding`, which the
  /// two sibling dialogs use: the two numbers differ, the difference is
  /// older than this file, and no project decision has settled which value
  /// the three dialogs should share. Naming the value here stops a raw number
  /// at the call site; the name does not settle the question.
  static final double horizontalPadding = SpacingSize.spacing24.value;

  /// Opens the content under the dialog's top edge.
  static final double contentTopPadding = SpacingSize.spacing24.value;

  /// Closes the gap between the content and the single action below it.
  static final double contentBottomPadding = SpacingSize.spacing16.value;

  /// Seats the single action above the dialog's bottom edge.
  static final double actionsBottomPadding = SpacingSize.spacing24.value;
}
