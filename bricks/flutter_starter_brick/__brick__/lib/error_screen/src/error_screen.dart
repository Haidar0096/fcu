import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/core_widgets.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) => BaseScreenWidget(
        body: Center(
          child: Text(
            errorMessage ?? context.appLocalizations.oopsAnErrorHasOccurred,
            style: context.typography?.body3,
            textAlign: TextAlign.center,
          ),
        ),
      );
}
