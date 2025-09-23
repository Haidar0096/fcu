import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/splash_screen/src/blocs/splash_cubit/splash_cubit.dart';
import 'package:{{proj_name}}/foundation/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Initial loading screen shown when the app starts.
///
/// This screen handles:
/// - App metadata initialization
/// - Shows splash for 1.5 seconds then navigates to main screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) => BlocListener<AppMetaDataCubit, AppMetaDataState>(
    listener: _metaDataCubitListener,
    child: RootScreenWidget(
      applySafeArea: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name
            Text(
              '{{proj_name.upperCase()}}',
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
        context.read<SplashCubit>().onMetadataLoadingFailed(
          errorMessage: context.appLocalizations.criticalErrorMessage,
        );
      case AppMetaDataLoaded():
        context.read<SplashCubit>().onMetadataLoaded();
    }
  }
}
