import 'package:flutter/material.dart';
import 'package:{{proj_name}}/features/critical_error_screen/src/ui/critical_error_screen_defaults.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Screen shown when a critical error occurs that prevents the app from
/// functioning.
///
/// This screen blocks navigation and requires the user to restart the app.
/// Used for unrecoverable errors like:
/// - App metadata loading failure
/// - Critical initialization failures
class CriticalErrorScreen extends StatelessWidget {
  const CriticalErrorScreen({this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) => RootScreenWidget(
    applySafeArea: false,
    canPop: false, // Disable back navigation completely
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeDefaults.screenContentPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: CriticalErrorScreenDefaults.iconSize,
              color: context.themeData.colorScheme.error,
            ),
            SizedBox(height: SpacingSize.spacing24.value),
            Text(
              context.appLocalizations.criticalErrorTitle,
              style: context.typography?.primaryTitle.copyWith(
                color: context.themeData.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SpacingSize.spacing16.value),
            Text(
              errorMessage ?? context.appLocalizations.criticalErrorFullMessage,
              style: context.typography?.bodyText.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(
                  alpha: CriticalErrorScreenDefaults.messageAlpha,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
