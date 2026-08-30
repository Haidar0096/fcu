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
/// live address: an address can carry an identifier that must stay out of a
/// recorded trail. Reading the address here would ship it into every later
/// report.
///
/// It lives in the logging module rather than beside the router because
/// everything that reaches a report is composed and stripped here; the router
/// is where it is wired, not where it belongs.
class ScreenTrailObserver extends NavigatorObserver {
  ScreenTrailObserver({required FlowBuffer flowBuffer})
    : _flowBuffer = flowBuffer;

  final FlowBuffer _flowBuffer;

  @override
  void didChangeTop(
    Route<dynamic> topRoute,
    Route<dynamic>? previousTopRoute,
  ) {
    _record(topRoute);
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
