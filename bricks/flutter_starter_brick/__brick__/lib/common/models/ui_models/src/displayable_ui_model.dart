import 'package:flutter/widgets.dart';

mixin DisplayableUiModel {
  /// Returns the text that represents this model and which is suitable
  /// to be displayed on the UI.
  String getDisplayText(BuildContext context);
}
