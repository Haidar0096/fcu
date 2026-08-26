import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/logging/src/flow_buffer.dart';

/// Records each screen the user lands on, so every report can carry the
/// picture of what happened before the failure.
///
/// It is registered on the router's `observers` and it is the ONE thing that
/// fills [FlowBuffer]; without it the flow list on every report stays empty.
///
/// WHAT IT RECORDS IS THE SCREEN'S NAME AND NOTHING ELSE — the compile-time
/// name the route declares, read off the page's `name`. It never reads the
/// live address: an address can carry a message or an identifier that must
/// stay out of a recorded trail, and this app's own critical-error screen is
/// exactly that shape — its message rides the address as a query parameter.
/// Reading the address here would ship that message into every later report.
///
/// It lives in the logging module rather than beside the router because
/// everything that reaches a report is composed and stripped here; the router
/// is where it is wired, not where it belongs.
class ScreenTrailObserver extends NavigatorObserver {
  ScreenTrailObserver({required FlowBuffer flowBuffer})
    : _flowBuffer = flowBuffer;

  final FlowBuffer _flowBuffer;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _record(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The screen the user lands BACK on is the one worth recording; the one
    // being left is already in the trail.
    _record(previousRoute);
  }

  void _record(Route<dynamic>? route) {
    final name = route?.settings.name;
    // A route that declares no name records nothing at all. An unnamed entry
    // would be noise in the trail, and guessing a name from the address is
    // the one thing this observer must never do.
    if (name == null || name.isEmpty) return;
    _flowBuffer.add(name);
  }
}
