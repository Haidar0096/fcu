import 'dart:collection';

/// The last actions the user took, kept so every report can carry the
/// picture of what happened before the failure.
///
/// Memory only: nothing writes it to disk and it starts empty at every
/// launch, so it can never outlive the process that produced it. It is a
/// recorded trail like any other — nothing that must stay out of a trail
/// (user-typed content, tokens, personal data) is ever pushed here.
///
/// What fills it is `ScreenTrailObserver`, registered on the router's
/// `observers`, which pushes the NAME each route declares. Both halves ship
/// with the starter — the three routes carry their names and the observer is
/// wired — so a freshly generated app records its flow from its first run.
/// A route added later records nothing until it declares a name of its own.
class FlowBuffer {
  /// How many actions the buffer holds before the oldest drops out.
  static const int capacity = 20;

  final Queue<String> _actions = Queue<String>();

  /// Records [action] as the newest entry, dropping the oldest one once the
  /// buffer already holds [capacity] of them.
  void add(String action) {
    if (_actions.length >= capacity) {
      _actions.removeFirst();
    }
    _actions.addLast(action);
  }

  /// The buffered actions, oldest first, as a locked copy — a report can
  /// never hold a live view of a buffer that keeps changing under it.
  List<String> get actions => List<String>.unmodifiable(_actions);
}
