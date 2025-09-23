import 'package:flutter/material.dart';

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
///   child: GestureDetector(
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
    this.onExpansionChanged,
    this.initiallyExpanded = false,
    this.duration = ExpandableCardDefaults.duration,
    this.curve = ExpandableCardDefaults.curve,
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
  final Duration duration;

  /// Animation curve
  final Curve curve;

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
      duration: widget.duration,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update duration if changed
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
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
      _controller.forward();
      setState(() {
        _isExpanded = true;
      });
      widget.onExpansionChanged?.call(true);
    }
  }

  /// Collapses the card
  void collapse() {
    if (_isExpanded) {
      _controller.reverse();
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
          axisAlignment: -1,
          child: widget.expandedChild,
        ),
      ],
    );
  }
}
