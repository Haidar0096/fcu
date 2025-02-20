import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:flutter/material.dart';

/// A mixin that provides a [ScrollController] to the class that uses it.
/// The mixin handles disposing the [ScrollController] when the class is
/// disposed.
mixin ScrollControllerProviderMixin<T extends StatefulWidget> on State<T> {
  @protected
  final ScrollController scrollController = ScrollController();

  Future<void> scrollToTop({
    Duration duration = AnimationDefaults.animationDuration,
    Curve curve = AnimationDefaults.curve,
  }) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(0, duration: duration, curve: curve);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
