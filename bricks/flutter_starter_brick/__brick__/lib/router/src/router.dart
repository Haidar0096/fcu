import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/features/common/variables/variables.dart';
import 'package:{{proj_name}}/features/error_screen/error_screen.dart';
import 'package:{{proj_name}}/features/home/home.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';

part 'router.g.dart';

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: _SplashScreenRoute.path,
);

/// Returns a [Page] based on the platform.
Page<T> _getPageByPlatform<T>({
  required Widget child,
  required LocalKey pageKey,
}) {
  if (Platform.isAndroid) {
    return MaterialPage(child: child, key: pageKey);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoPage(child: child, key: pageKey);
  }
  return MaterialPage(child: child, key: pageKey);
}

@TypedGoRoute<_SplashScreenRoute>(path: _SplashScreenRoute.path)
@immutable
class _SplashScreenRoute extends GoRouteData {
  const _SplashScreenRoute();

  static const String path = '/splash_screen';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: SplashScreen(
          onShouldNavigateToHomeScreen:
              () => const _HomeScreenRoute().go(context),
          onShouldNavigateToErrorScreen:
              () => const _ErrorScreenRoute().go(context),
        ),
      );
}

@TypedGoRoute<_HomeScreenRoute>(path: _HomeScreenRoute.path)
@immutable
class _HomeScreenRoute extends GoRouteData {
  const _HomeScreenRoute();

  static const String path = '/home_screen';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(pageKey: state.pageKey, child: HomeScreen());
}

@TypedGoRoute<_ErrorScreenRoute>(path: _ErrorScreenRoute.path)
@immutable
class _ErrorScreenRoute extends GoRouteData {
  const _ErrorScreenRoute({this.errorMessage});

  static const String path = '/error_screen';

  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: ErrorScreen(errorMessage: errorMessage),
      );
}
