import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/resources/resources.dart';

extension AppLocalizationsBuildContextExtension on BuildContext {
  AppLocalizations get appLocalizations => AppLocalizations.of(this);
}
