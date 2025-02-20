import 'package:{{proj_name}}/infrastructure/l10n/l10n.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) => RootScreenWidget(
    body: Center(
      child: Text(
        errorMessage ?? context.appLocalizations.oopsAnErrorHasOccurred,
        style: context.typography?.body3,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
