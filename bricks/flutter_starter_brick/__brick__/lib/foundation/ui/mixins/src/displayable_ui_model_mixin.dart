import 'package:{{proj_name}}/resources/resources.dart';

mixin DisplayableUiModelMixin {
  /// Returns the text that represents this model and which is suitable
  /// to be displayed on the UI.
  String getDisplayText(AppLocalizations texts);
}
