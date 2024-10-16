import 'dart:io';

import 'package:{{proj_name}}/ui/screens/error_screen/error_screen.dart';
import 'package:{{proj_name}}/ui/screens/home_screen/home_screen.dart';
import 'package:{{proj_name}}/ui/screens/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: '_rootNavigatorKey',
);

/// The default app router.
final GoRouter appRouter = GoRouter(
  initialLocation: '/${SplashScreen.routeName}',
  navigatorKey: _rootNavigatorKey,
  routes: [
    _buildSplashScreenRoute(),
    _buildHomeScreenRoute(),
    _buildErrorScreenRoute(),
  ],
);

/// Clears all routes from the app router's stack and pushes the given
/// [path].
void clearAllRoutesAndGoToNamed(
  String path, {
  Object? extra,
}) {
  while (appRouter.canPop()) {
    appRouter.pop();
  }
  appRouter.pushReplacementNamed(
    path,
    extra: extra,
  );
}

GoRoute _buildSplashScreenRoute() => GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: SplashScreen.routeName,
      path: '/${SplashScreen.routeName}',
      pageBuilder: _getDefaultPageBuilderByPlatform(
        childBuilder: (_, __) => const SplashScreen(),
      ),
    );

GoRoute _buildHomeScreenRoute() => GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: HomeScreen.routeName,
      path: '/${HomeScreen.routeName}',
      pageBuilder: _getDefaultPageBuilderByPlatform(
        childBuilder: (_, __) => const HomeScreen(),
      ),
    );

GoRoute _buildErrorScreenRoute() => GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: ErrorScreen.routeName,
      path: '/${ErrorScreen.routeName}',
      pageBuilder: _getDefaultPageBuilderByPlatform(
        childBuilder: (_, __) => const ErrorScreen(),
      ),
    );

Page<T> _getPageByPlatform<T>({required Widget child}) {
  if (Platform.isAndroid) {
    return MaterialPage(child: child);
  }
  if (Platform.isIOS) {
    return CupertinoPage(child: child);
  }
  return MaterialPage(child: child);
}

GoRouterPageBuilder _getDefaultPageBuilderByPlatform({
  required Widget Function(
    BuildContext context,
    GoRouterState goRouterState,
  ) childBuilder,
}) =>
    (context, goRouterState) =>
        _getPageByPlatform(child: childBuilder(context, goRouterState));
