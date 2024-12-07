import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

class RootBlocsProvider extends StatelessWidget {
  const RootBlocsProvider({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<LocalizationCubit>(
            create: (_) => ServiceProvider.get<LocalizationCubit>(),
          ),
          BlocProvider<ThemeCubit>(
            create: (_) => ServiceProvider.get<ThemeCubit>(),
          ),
          BlocProvider<AppMetaDataCubit>(
            create: (_) => ServiceProvider.get<AppMetaDataCubit>(),
          ),
        ],
        child: Builder(builder: builder),
      );
}
