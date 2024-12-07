import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/error_screen/error_screen.dart';
import 'package:{{proj_name}}/home_screen/home_screen.dart';
import 'package:{{proj_name}}/splash_screen/splash_screen.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: '_rootNavigatorKey',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: $appRoutes,
);

/// Clears all routes from the app router's stack and pushes the given
/// [path].
void clearAllRoutesAndGoToNamed(
  String path, {
  Object? extra,
}) {
  while (router.canPop()) {
    router.pop();
  }
  router.pushReplacementNamed(
    path,
    extra: extra,
  );
}

/// Returns a [Page] based on the platform.
Page<T> getPageByPlatform<T>({required Widget child}) {
  if (Platform.isAndroid) {
    return MaterialPage(child: child);
  }
  if (Platform.isIOS) {
    return CupertinoPage(child: child);
  }
  return MaterialPage(child: child);
}

@TypedGoRoute<SplashScreenRoute>(
  path: '/',
)
@immutable
class SplashScreenRoute extends GoRouteData {
  const SplashScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      getPageByPlatform<void>(child: const SplashScreen());
}

@TypedGoRoute<HomeScreenRoute>(
  path: '/home_screen',
)
@immutable
class HomeScreenRoute extends GoRouteData {
  const HomeScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      getPageByPlatform<void>(child: const HomeScreen());
}

@TypedGoRoute<ErrorScreenRoute>(
  path: '/error_screen',
)
@immutable
class ErrorScreenRoute extends GoRouteData {
  const ErrorScreenRoute({this.errorMessage});

  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      getPageByPlatform<void>(child: ErrorScreen(errorMessage: errorMessage));
}
