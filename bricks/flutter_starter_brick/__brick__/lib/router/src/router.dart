import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/features/critical_error_screen/critical_error_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/random_jokes_screen.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/locator/locator.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';
import 'package:{{proj_name}}/router/src/route_paths.dart';
import 'package:{{proj_name}}/router/src/platform_page.dart';

part 'router.g.dart';
part 'startup_cover.dart';

const String _tag = 'router';

/// Reports a routing failure through the app's error road.
///
/// The loggers are resolved with `tryGet` so a missing one cannot turn a
/// reportable failure into a crash on the error path itself.
void _reportRouteFailure({
  required String message,
  required StackTrace stackTrace,
}) {
  serviceLocator.tryGet<AppLogger>()?.log(message: message, tag: _tag);
  final errorLogger = serviceLocator.tryGet<ErrorLogger>();
  if (errorLogger != null) {
    unawaited(errorLogger.recordError(error: message, stackTrace: stackTrace));
  }
}

/// Tells the app shell that startup no longer needs its cover.
typedef OnStartupCoverCompleteCallback = void Function();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: RandomJokesRoutePath.path,
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
      // A bad address is real breakage. Only its path is reported: query data
      // and hidden navigation data never enter a recorded trail.
      _reportRouteFailure(
        message: 'Unrecognized route path ${state.uri.path} '
        '(matched location: $currentPath): $error',
        stackTrace: stackTrace,
      );
      return CriticalErrorRoutePath.path;
    }

    // Add the auth guard here when authentication is implemented.
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

    // The route is known and this starter has no auth-dependent state.
    return null;
  },
  onException: (context, state, router) {
    // The last resort for routing failures the redirect above cannot recover
    // from: a redirect target that matches nothing, a redirect loop, or an
    // initial deep link blocked with no route left to fall back to.
    _reportRouteFailure(
      message: 'Routing failed for path: ${state.uri.path}',
      stackTrace: StackTrace.current,
    );
    router.go(CriticalErrorRoutePath.path);
  },
);

/// Adds the router-owned startup cover to the router API used by the app shell.
extension StartupCoverGoRouterExtension on GoRouter {
  Widget startupCover({
    required OnStartupCoverCompleteCallback onStartupComplete,
  }) => _StartupCover(onStartupComplete: onStartupComplete);
}

@TypedGoRoute<CriticalErrorScreenRoute>(path: CriticalErrorRoutePath.path)
@immutable
class CriticalErrorScreenRoute extends GoRouteData
    with $CriticalErrorScreenRoute {
  const CriticalErrorScreenRoute({this.$extra});

  /// Hidden navigation data. Error text never rides the route address.
  final String? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      platformPage<void>(
        pageKey: state.pageKey,
        screenName: CriticalErrorRoutePath.name,
        child: CriticalErrorScreen(errorMessage: $extra),
      );
}

@TypedGoRoute<RandomJokesScreenRoute>(path: RandomJokesRoutePath.path)
@immutable
class RandomJokesScreenRoute extends GoRouteData with $RandomJokesScreenRoute {
  const RandomJokesScreenRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      platformPage<void>(
        pageKey: state.pageKey,
        screenName: RandomJokesRoutePath.name,
        child: BlocProvider(
          create: (_) => serviceLocator.get<JokesCubit>(),
          child: const RandomJokesScreen(),
        ),
      );
}
