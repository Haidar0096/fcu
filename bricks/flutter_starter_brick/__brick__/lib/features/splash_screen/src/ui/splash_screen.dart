import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/splash_screen/src/blocs/splash_cubit/splash_cubit.dart';
import 'package:{{proj_name}}/features/splash_screen/src/ui/splash_screen_defaults.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Navigates to the critical-error destination with safe display text.
typedef OnNavigateToCriticalErrorCallback =
    void Function({required String message});

/// Lifts the startup cover after initialization completes.
typedef OnStartupCompleteCallback = void Function();

/// Startup cover shown over the router while initialization runs.
///
/// This cover handles:
/// - App metadata initialization
/// - Navigation to appropriate screen based on states
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.onNavigateToCriticalError,
    required this.onStartupComplete,
    super.key,
  });

  final OnNavigateToCriticalErrorCallback onNavigateToCriticalError;
  final OnStartupCompleteCallback onStartupComplete;

  @override
  Widget build(BuildContext context) => RootScreenWidget(
    canPop: false,
    applySafeArea: false,
    resizeToAvoidBottomInset: true,
    applyTopSafeArea: true,
    applyBottomSafeArea: true,
    applyStartSafeArea: true,
    applyEndSafeArea: true,
    body: MultiBlocListener(
      listeners: [
        BlocListener<AppMetaDataCubit, AppMetaDataState>(
          listenWhen: _shouldHandleAppMetaDataState,
          listener: _onAppMetaDataState,
        ),
        BlocListener<SplashCubit, SplashState>(
          listenWhen: _shouldHandleSplashState,
          listener: _onSplashState,
        ),
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
            Spacing.vertical(SpacingSize.spacing8),
            Text(
              context.appLocalizations.appTagline,
              style: context.typography?.bodyText.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(
                  alpha: SplashScreenDefaults.taglineAlpha,
                ),
                letterSpacing: SplashScreenDefaults.taglineLetterSpacing,
              ),
            ),
            Spacing.vertical(SpacingSize.spacing32),
            const LoaderWidget(size: SplashScreenDefaults.loaderSize),
          ],
        ),
      ),
    ),
  );

  bool _shouldHandleAppMetaDataState(
    AppMetaDataState previous,
    AppMetaDataState current,
  ) =>
      previous.runtimeType != current.runtimeType &&
      switch (current) {
        AppMetaDataLoadedState() || AppMetaDataLoadingFailedState() => true,
        AppMetaDataInitialState() || AppMetaDataLoadingState() => false,
      };

  bool _shouldHandleSplashState(SplashState previous, SplashState current) =>
      previous.runtimeType != current.runtimeType &&
      switch (current) {
        SplashCompleteState() || SplashCriticalErrorState() => true,
        SplashInitialState() => false,
      };

  void _onAppMetaDataState(BuildContext context, AppMetaDataState state) {
    switch (state) {
      case AppMetaDataInitialState():
      case AppMetaDataLoadingState():
        break; // Do nothing
      case AppMetaDataLoadingFailedState():
        // Metadata is unrecoverable: the app cannot continue without it.
        context.read<SplashCubit>().onMetadataLoadingFailed();
      case AppMetaDataLoadedState():
        context.read<SplashCubit>().onMetadataLoaded();
    }
  }

  void _onSplashState(BuildContext context, SplashState state) {
    switch (state) {
      case SplashInitialState():
        break; // Do nothing
      case SplashCompleteState():
        onStartupComplete();
      case SplashCriticalErrorState():
        onNavigateToCriticalError(
          message: context.appLocalizations.criticalErrorMessage,
        );
    }
  }
}
