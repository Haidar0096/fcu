import 'dart:async';

import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';

/// A card widget that can expand/collapse with smooth animations.
///
/// This widget uses imperative API for expansion control to avoid
/// parent widget rebuilds.
///
/// Example:
/// ```dart
/// final expandableKey = GlobalKey<ExpandableCardState>();
///
/// ExpandableCard(
///   key: expandableKey,
///   child: InkWell(
///     onTap: () => expandableKey.currentState?.toggle(),
///     child: Text('Header'),
///   ),
///   expandedChild: Text('Content'),
/// )
/// ```
class ExpandableCard extends StatefulWidget {
  const ExpandableCard({
    required this.child,
    required this.expandedChild,
    required this.initiallyExpanded,
    this.onExpansionChanged,
    this.duration,
    this.curve,
    super.key,
  });

  /// The main content that is always visible
  final Widget child;

  /// The content shown when expanded
  final Widget expandedChild;

  /// Called when the expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Initial expansion state
  final bool initiallyExpanded;

  /// Animation duration
  final Duration? duration;

  /// Animation curve
  final Curve? curve;

  @override
  State<ExpandableCard> createState() => ExpandableCardState();
}

class ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;

  /// Whether the card is currently expanded
  bool get isExpanded => _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.duration ?? ExpandableCardDefaults.duration,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? ExpandableCardDefaults.curve,
    );
  }

  @override
  void didUpdateWidget(ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      _controller.duration =
          widget.duration ?? ExpandableCardDefaults.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Expands the card
  void expand() {
    if (!_isExpanded) {
      unawaited(_controller.forward());
      setState(() {
        _isExpanded = true;
      });
      widget.onExpansionChanged?.call(true);
    }
  }

  /// Collapses the card
  void collapse() {
    if (_isExpanded) {
      unawaited(_controller.reverse());
      setState(() {
        _isExpanded = false;
      });
      widget.onExpansionChanged?.call(false);
    }
  }

  /// Toggles between expanded and collapsed states
  void toggle() {
    if (_isExpanded) {
      collapse();
    } else {
      expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.child,
        SizeTransition(
          sizeFactor: _expandAnimation,
          alignment: ExpandableCardDefaults.alignment,
          child: widget.expandedChild,
        ),
      ],
    );
  }
}

abstract final class ExpandableCardDefaults {
  static const Duration duration = AnimationDefaults.animationDuration;
  static const Curve curve = AnimationDefaults.curveEaseInOut;

  /// Where the revealed child sits while the card grows: the directional
  /// form keeps the reveal correct under RTL.
  static const AlignmentGeometry alignment = AlignmentDirectional.topStart;
}
