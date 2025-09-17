import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/foundation/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

class RootBlocsProvider extends StatelessWidget {
  const RootBlocsProvider({required this.builder, super.key});

  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      // TODO({{dev_name}}): Add app-specific global blocs here
      BlocProvider<LocalizationCubit>.value(
        value: serviceLocator.get<LocalizationCubit>(),
      ),
      BlocProvider<ThemeCubit>.value(
        value: serviceLocator.get<ThemeCubit>(),
      ),
      BlocProvider<AppMetaDataCubit>.value(
        value: serviceLocator.get<AppMetaDataCubit>()..init(),
      ),
    ],
    child: Builder(builder: builder),
  );
}
