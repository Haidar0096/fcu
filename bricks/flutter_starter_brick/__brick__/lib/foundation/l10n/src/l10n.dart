import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/resources/resources.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get appLocalizations => AppLocalizations.of(this);
}

extension AppLocalizationsNullableExtension on BuildContext? {
  AppLocalizations? get appLocalizations => this?.appLocalizations;
}
