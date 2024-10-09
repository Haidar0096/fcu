import 'package:{{proj_name}}/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
{{#has_ic}}
import 'package:{{proj_name}}/blocs/connectivity_cubit/connectivity_cubit.dart';
{{/has_ic}}
import 'package:{{proj_name}}/blocs/localization_cubit/localization_cubit.dart';
import 'package:{{proj_name}}/blocs/theme_cubit/theme_cubit.dart';
import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
{{#has_ic}}
import 'package:{{proj_name}}/ui/widgets/connectivity_cubit_listener.dart';
import 'package:{{proj_name}}/ui/widgets/snackbars.dart';
{{/has_ic}}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RootAppWidget extends StatelessWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<LocalizationCubit>(
            create: (_) => ServiceProvider.get<LocalizationCubit>(),
          ),
          BlocProvider<ThemeCubit>(
            create: (_) => ServiceProvider.get<ThemeCubit>(),
          ),
          {{#has_ic}}
          BlocProvider<ConnectivityCubit>(
            create: (_) => ServiceProvider.get<ConnectivityCubit>(),
          ),
          {{/has_ic}}
          BlocProvider<AppMetaDataCubit>(
            create: (_) => ServiceProvider.get<AppMetaDataCubit>(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final language = context.watch<LocalizationCubit>().state;
            final theme = context.watch<ThemeCubit>().state;
            return MaterialApp(
              theme: theme.themeData,
              home: Builder(
                builder: (context) {
                  final result = Scaffold(
                    appBar: AppBar(
                      title: Text(
                        context.appLocalizations.counterAppBarTitle,
                        style: Theme.of(context)
                            .extension<AppTextTheme>()
                            ?.title4
                            ?.copyWith(color: AppColors.green),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Hello World!',
                        style: Theme.of(context)
                            .extension<AppTextTheme>()
                            ?.body5
                            ?.copyWith(color: AppColors.green),
                      ),
                    ),
                  );

                  {{#has_ic}}
                  return ConnectivityCubitListener(
                    onConnected: ({
                      required BuildContext context,
                      required bool isFirstCapturedState,
                    }) {
                      // TODO(dev): handle connected state
                      if (isFirstCapturedState) {
                        showSuccessSnackBar(
                          context: context,
                          text: 'Connected',
                        );
                      }
                    },
                    onDisconnected: ({
                      required BuildContext context,
                      required bool isFirstCapturedState,
                    }) {
                      // TODO(dev): handle disconnected state
                      showErrorSnackBar(
                        context: context,
                        text: 'Disconnected',
                      );
                    },
                    child: result,
                  );
                  {{/has_ic}}
                  {{^has_ic}}
                  return result;
                  {{/has_ic}}
                },
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale.fromSubtags(languageCode: language.code),
            );
          },
        ),
      );
}