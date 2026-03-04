import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/splash_screen/src/blocs/splash_cubit/splash_cubit.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Initial loading screen shown when the app starts.
///
/// This screen handles:
/// - App metadata initialization
/// - Navigation to appropriate screen based on states
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.onNavigateToCriticalError,
    required this.onNavigateToRandomJokes,
    super.key,
  });

  final void Function({required String message}) onNavigateToCriticalError;
  final VoidCallback onNavigateToRandomJokes;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      // Listen to AppMetaData and trigger splash completion when loaded
      BlocListener<AppMetaDataCubit, AppMetaDataState>(
        listener: _metaDataCubitListener,
      ),
      // Listen to SplashCubit states
      BlocListener<SplashCubit, SplashState>(listener: _splashCubitListener),
    ],
    child: RootScreenWidget(
      applySafeArea: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name
            Text(
              '{{proj_name.upperCase()}}',
              style: context.typography?.primaryTitle.copyWith(
                color: context.themeData.colorScheme.onSurface,
                letterSpacing: 8,
              ),
            ),
            SizedBox(height: SpacingSize.spacing8.value),
            Text(
              context.appLocalizations.appTagline,
              style: context.typography?.bodyText.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: SpacingSize.spacing32.value),
            const LoaderWidget(size: 40),
          ],
        ),
      ),
    ),
  );

  void _metaDataCubitListener(BuildContext context, AppMetaDataState state) {
    switch (state) {
      case AppMetaDataInitial():
      case AppMetaDataLoading():
        // Do nothing - waiting for metadata to load
        break;
      case AppMetaDataLoadingFailed():
        // Emit critical error state for metadata loading failure
        // This is unrecoverable and requires app restart
        context.read<SplashCubit>().onMetadataLoadingFailed(
          errorMessage: context.appLocalizations.criticalErrorMessage,
        );
      case AppMetaDataLoaded():
        context.read<SplashCubit>().onMetadataLoaded();
    }
  }

  void _splashCubitListener(BuildContext context, SplashState state) {
    switch (state) {
      case SplashInitial():
        // Do nothing - initial state
        break;
      case SplashComplete():
        // Splash complete - navigate to main screen
        onNavigateToRandomJokes();
      case SplashCriticalError(:final errorMessage):
        // Navigate to critical error screen
        onNavigateToCriticalError(
          message:
              errorMessage ?? context.appLocalizations.criticalErrorMessage,
        );
    }
  }
}
