import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/features/critical_error_screen/critical_error_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';
import 'package:{{proj_name}}/router/src/route_paths.dart';

part 'router.g.dart';

const String _tag = 'router';

/// Reports a routing failure through the app's error road.
///
/// The loggers are resolved with `tryGet` so a missing one cannot turn a
/// reportable failure into a crash on the error path itself.
void _reportRouteFailure(String message, StackTrace stackTrace) {
  serviceLocator.tryGet<AppLogger>()?.log(message, tag: _tag);
  final errorLogger = serviceLocator.tryGet<ErrorLogger>();
  if (errorLogger != null) {
    unawaited(errorLogger.recordError(error: message, stackTrace: stackTrace));
  }
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: SplashRoutePath.path,
  debugLogDiagnostics: kDebugMode,
  // The screen trail: every report carries the screens the user visited
  // before the failure. The observer reads the NAME each page below declares
  // and never the address.
  observers: [
    ScreenTrailObserver(flowBuffer: serviceLocator.get<FlowBuffer>()),
  ],
  redirect: (context, state) {
    final currentPath = state.matchedLocation;

    try {
      RoutePath.fromPath(currentPath);
    } catch (error, stackTrace) {
      // A bad address is real breakage: it is reported before the user lands
      // on the fallback screen. The full address is named alongside the
      // matched location, which can be a shorter prefix of it.
      _reportRouteFailure(
        'Unrecognized route address ${state.uri} '
        '(matched location: $currentPath): $error',
        stackTrace,
      );
      return CriticalErrorRoutePath.path;
    }

    // TODO({{dev_name}}): Add the auth guard here when authentication is
    // implemented.
    //
    // Access control lives in this ONE redirect and nowhere else, decided off
    // the route's own auth fact. The starter ships without it on purpose and
    // has neither half of it: no bloc that answers "is the user logged in?",
    // and no `requiresAuth` fact on the sealed `RoutePath`, because the app's
    // lock model is a per-project answer settled at setup. Adding auth is one
    // change carrying all three: the fact on every `RoutePath`, the bloc that
    // holds the answer wired into the redirect's listenable, and the branch
    // here that reads both. Nothing is written here as ready-to-uncomment
    // code, because none of the names it would use exists yet.

    // If all checks above passed, let the app go to the requested route
    return null;
  },
  onException: (context, state, router) {
    // The last resort for routing failures the redirect above cannot recover
    // from: a redirect target that matches nothing, a redirect loop, or an
    // initial deep link blocked with no route left to fall back to.
    _reportRouteFailure(
      'Routing failed for address: ${state.uri}',
      StackTrace.current,
    );
    router.go(CriticalErrorRoutePath.path);
  },
);

/// Returns a [Page] based on the platform.
///
/// [screenName] is the route's own compile-time name constant. It rides the
/// page so `ScreenTrailObserver` can record it without ever reading the live
/// address.
Page<T> _getPageByPlatform<T>({
  required Widget child,
  required LocalKey pageKey,
  required String screenName,
}) {
  if (kIsWeb) {
    return NoTransitionPage(child: child, key: pageKey, name: screenName);
  }
  if (Platform.isAndroid) {
    return MaterialPage(child: child, key: pageKey, name: screenName);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoPage(child: child, key: pageKey, name: screenName);
  }
  return MaterialPage(child: child, key: pageKey, name: screenName);
}

@TypedGoRoute<SplashScreenRoute>(path: SplashRoutePath.path)
@immutable
class SplashScreenRoute extends GoRouteData with $SplashScreenRoute {
  const SplashScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        screenName: SplashRoutePath.name,
        child: BlocProvider(
          create: (_) => serviceLocator.get<SplashCubit>(),
          child: SplashScreen(
            onNavigateToCriticalError: ({required String message}) {
              if (context.mounted) {
                CriticalErrorScreenRoute(errorMessage: message).go(context);
              }
            },
            onNavigateToRandomJokes: () {
              if (context.mounted) {
                const RandomJokesScreenRoute().go(context);
              }
            },
          ),
        ),
      );
}

@TypedGoRoute<CriticalErrorScreenRoute>(path: CriticalErrorRoutePath.path)
@immutable
class CriticalErrorScreenRoute extends GoRouteData
    with $CriticalErrorScreenRoute {
  const CriticalErrorScreenRoute({this.errorMessage});
  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        screenName: CriticalErrorRoutePath.name,
        child: CriticalErrorScreen(errorMessage: errorMessage),
      );
}

@TypedGoRoute<RandomJokesScreenRoute>(path: RandomJokesRoutePath.path)
@immutable
class RandomJokesScreenRoute extends GoRouteData with $RandomJokesScreenRoute {
  const RandomJokesScreenRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        screenName: RandomJokesRoutePath.name,
        child: BlocProvider(
          create: (_) => serviceLocator.get<JokesCubit>(),
          child: const RandomJokesScreen(),
        ),
      );
}
