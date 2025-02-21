import 'package:{{proj_name}}/variables/variables.dart';
import 'package:{{proj_name}}/infrastructure/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/infrastructure/l10n/l10n.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RootBlocsProvider extends StatelessWidget {
  const RootBlocsProvider({required this.builder, super.key});

  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<LocalizationCubit>(
        create: (_) => serviceProvider.get<LocalizationCubit>(),
      ),
      BlocProvider<ThemeCubit>(
        create: (_) => serviceProvider.get<ThemeCubit>(),
      ),
      BlocProvider<AppMetaDataCubit>(
        create: (_) => serviceProvider.get<AppMetaDataCubit>(),
      ),
    ],
    child: Builder(builder: builder),
  );
}
