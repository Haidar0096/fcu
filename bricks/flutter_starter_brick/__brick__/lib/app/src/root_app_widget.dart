import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/app/src/root_blocs_provider.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:{{proj_name}}/router/router.dart';

/// The root widget of the application.
///
/// This widget sets up the BLoC providers, routing, theming, and localization
/// for the entire app.
class RootAppWidget extends StatelessWidget {
  /// Creates a [RootAppWidget].
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context) => RootBlocsProvider(
    builder:
        (context) => BlocBuilder<ThemeCubit, {{proj_name.pascalCase()}}Theme>(
          builder:
              (context, themeState) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                theme: themeState.themeData,
                builder: (context, child) => Directionality(
                  textDirection: context
                      .select<LocalizationCubit, TextDirection>(
                        (cubit) => cubit.state.textDirection,
                      ),
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Overlay(
                      initialEntries: [
                        OverlayEntry(builder: (context) => child!),
                      ],
                    ),
                  ),
                ),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale.fromSubtags(
                  languageCode: context.select<LocalizationCubit, String>(
                    (cubit) => cubit.state.code,
                  ),
                ),
              ),
        ),
  );
}
