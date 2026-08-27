import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/splash_screen/src/blocs/splash_cubit/splash_cubit.dart';
import 'package:{{proj_name}}/features/splash_screen/src/ui/splash_screen_defaults.dart';
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
  Widget build(BuildContext context) => RootScreenWidget(
    applySafeArea: false,
    body: MultiBlocListener(
      listeners: [
        BlocListener<AppMetaDataCubit, AppMetaDataState>(
          listener: _onAppMetaDataState,
        ),
        BlocListener<SplashCubit, SplashState>(listener: _onSplashState),
      ],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.appLocalizations.appName,
              style: context.typography?.primaryTitle.copyWith(
                color: context.themeData.colorScheme.onSurface,
                letterSpacing: SplashScreenDefaults.titleLetterSpacing,
              ),
            ),
            SizedBox(height: SpacingSize.spacing8.value),
            Text(
              context.appLocalizations.appTagline,
              style: context.typography?.bodyText.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(
                  alpha: SplashScreenDefaults.taglineAlpha,
                ),
                letterSpacing: SplashScreenDefaults.taglineLetterSpacing,
              ),
            ),
            SizedBox(height: SpacingSize.spacing32.value),
            const LoaderWidget(size: SplashScreenDefaults.loaderSize),
          ],
        ),
      ),
    ),
  );

  void _onAppMetaDataState(BuildContext context, AppMetaDataState state) {
    switch (state) {
      case AppMetaDataInitial():
      case AppMetaDataLoading():
        // Do nothing - waiting for metadata to load
        break;
      case AppMetaDataLoadingFailed():
        // Metadata is unrecoverable: the app cannot continue without it.
        context.read<SplashCubit>().onMetadataLoadingFailed(
          errorMessage: context.appLocalizations.criticalErrorMessage,
        );
      case AppMetaDataLoaded():
        context.read<SplashCubit>().onMetadataLoaded();
    }
  }

  void _onSplashState(BuildContext context, SplashState state) {
    switch (state) {
      case SplashInitial():
        // Do nothing - initial state
        break;
      case SplashComplete():
        onNavigateToRandomJokes();
      case SplashCriticalError(:final errorMessage):
        onNavigateToCriticalError(
          message:
              errorMessage ?? context.appLocalizations.criticalErrorMessage,
        );
    }
  }
}
