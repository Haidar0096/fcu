import 'package:{{proj_name}}/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/ui/screens/error_screen/error_screen.dart';
import 'package:{{proj_name}}/ui/screens/home_screen/home_screen.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
              context.goNamed(HomeScreen.routeName);
            case AppMetaDataLoadingFailed():
              context.goNamed(ErrorScreen.routeName);
          }
        },
        builder: (context, appMetaDataState) => const BaseScreenWidget(
          loading: true,
          body: Center(child: FlutterLogo(size: 300)),
        ),
      );
}
