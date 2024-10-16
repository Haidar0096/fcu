import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_screen_widget.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.errorMessage,
  });

  final String? errorMessage;

  static const routeName = 'error_screen';

  @override
  Widget build(BuildContext context) {
    return BaseScreenWidget(
      body: Center(
        child: Text(
          errorMessage ?? context.appLocalizations.oopsAnErrorHasOccurred,
          style: context.appTextTheme.body3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
