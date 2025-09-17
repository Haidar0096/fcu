import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lia/features/splash_screen/src/blocs/splash_cubit/splash_cubit.dart';
import 'package:lia/features/splash_screen/src/services/app_store_launcher.dart';
import 'package:lia/features/splash_screen/src/ui/version_check_dialog.dart';
import 'package:lia/features/subscription/subscription.dart';
import 'package:lia/foundation/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:lia/foundation/l10n/l10n.dart';
import 'package:lia/foundation/ui/theme/theme.dart';
import 'package:lia/foundation/ui/widgets/widgets.dart';

/// Initial loading screen shown when the app starts.
///
/// This screen handles:
/// - Version checking to ensure app is up to date
/// - Emits completion state for router to handle navigation
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      // Listen to AppMetaData and trigger version check when loaded
      BlocListener<AppMetaDataCubit, AppMetaDataState>(
        listener: _metaDataCubitListener,
      ),
      // Listen to SplashCubit states
      BlocListener<SplashCubit, SplashState>(
        listener: _splashCubitListener,
      ),
      // Listen to SubscriptionBloc for errors
      BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: _subscriptionBlocListener,
      ),
    ],
    child: RootScreenWidget(
      applySafeArea: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LIA Text
            Text(
              'LIA',
              style: context.typography?.title1.copyWith(
                letterSpacing: 8,
              ),
            ),
            const Spacing.vertical(SpacingSize.xSmall),
            Text(
              context.appLocalizations.appTagline,
              style: context.typography?.body4.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
                letterSpacing: 2,
              ),
            ),
            const Spacing.vertical(SpacingSize.large),
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
        context.read<SplashCubit>().emitCriticalError(
          errorMessage: context.appLocalizations.criticalErrorMessage,
        );
      case AppMetaDataLoaded(:final buildNumber):
        context.read<SplashCubit>().checkVersion(buildNumber);
    }
  }

  Future<void> _splashCubitListener(
    BuildContext context,
    SplashState state,
  ) async {
    switch (state) {
      case SplashInitial():
        // Do nothing - initial state
        break;
      case SplashVersionCheckComplete(:final isUpdateRequired):
        if (isUpdateRequired) {
          await _showForceUpdateDialog(context);
        } else {
          // No update required, complete splash screen
          context.read<SplashCubit>().completeSplash();
        }
      case SplashComplete():
        // Splash screen is complete - router will handle navigation
        // based on auth state
        break;
      case SplashVersionCheckError():
        // Show version check error dialog
        await _showVersionCheckErrorDialog(context);
      case SplashCriticalError():
        // Critical error state - router will handle navigation to error screen
        break;
    }
  }

  Future<void> _subscriptionBlocListener(
    BuildContext context,
    SubscriptionState state,
  ) async {
    switch (state) {
      case SubscriptionError():
        // Show same connection error dialog as version check
        await _showSubscriptionErrorDialog(context);
      case SubscriptionInitial():
      case SubscriptionLoading():
      case SubscriptionLoaded():
        // Do nothing for other states
        break;
    }
  }

  Future<void> _showForceUpdateDialog(BuildContext context) async {
    await showUpdateRequiredDialog(
      context: context,
      onUpdate:
          () => AppStoreLauncher.launchStore(
            onLaunchFailed: () {
              if (context.mounted) {
                showErrorSnackBar(
                  context: context,
                  text: context.appLocalizations.updateLaunchFailedMessage,
                );
              }
            },
          ),
    );
  }

  Future<void> _showVersionCheckErrorDialog(BuildContext context) async {
    // Capture cubits before showing dialog
    final splashCubit = context.read<SplashCubit>();
    final appMetaDataCubit = context.read<AppMetaDataCubit>();

    await showConnectionErrorDialog(
      context: context,
      onRetry: () {
        final appMetaData = appMetaDataCubit.state;
        switch (appMetaData) {
          case AppMetaDataInitial():
          case AppMetaDataLoading():
          case AppMetaDataLoadingFailed():
            // Can't retry without metadata
            break;
          case AppMetaDataLoaded(:final buildNumber):
            splashCubit.checkVersion(buildNumber);
        }
      },
    );
  }

  Future<void> _showSubscriptionErrorDialog(BuildContext context) async {
    // Capture bloc before showing dialog
    final subscriptionBloc = context.read<SubscriptionBloc>();

    // Reuse the same connection error dialog as version check
    await showConnectionErrorDialog(
      context: context,
      onRetry: () {
        // Retry fetching subscription
        subscriptionBloc.add(const FetchSubscription());
      },
    );
  }
}
