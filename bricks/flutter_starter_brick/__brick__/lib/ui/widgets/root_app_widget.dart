import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nested/nested.dart';
import 'package:{{proj_name}}/blocs/localization_cubit/localization_cubit.dart';
import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';

class RootAppWidget extends StatelessWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<LocalizationCubit>(
            create: (_) => ServiceProvider.get<LocalizationCubit>(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final language = context.watch<LocalizationCubit>().state;
            return MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title:
                        Text(AppLocalizations.of(context).counterAppBarTitle),
                  ),
                  body: const Placeholder(),
                ),
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale.fromSubtags(languageCode: language.code),
            );
          },
        ),
      );
}
