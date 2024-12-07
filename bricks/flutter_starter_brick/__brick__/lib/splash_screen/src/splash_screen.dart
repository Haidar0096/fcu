import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/common/router/router.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/core_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = 'splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1000))
        .then((_) => ServiceProvider.get<AppMetaDataCubit>().init());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AppMetaDataCubit, AppMetaDataState>(
        listener: (context, appMetaDataState) {
          switch (appMetaDataState) {
            case AppMetaDataInitial():
            case AppMetaDataLoading():
              // no action needed for these states
              break;
            case AppMetaDataLoaded():
              const HomeScreenRoute().go(context);
            case AppMetaDataLoadingFailed():
              const ErrorScreenRoute().go(context);
          }
        },
        builder: (context, appMetaDataState) => const BaseScreenWidget(
          loading: true,
          body: Center(child: FlutterLogo(size: 300)),
        ),
      );
}
