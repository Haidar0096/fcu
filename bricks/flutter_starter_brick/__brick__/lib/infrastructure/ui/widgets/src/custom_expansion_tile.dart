import 'package:{{proj_name}}/infrastructure/ui/widgets/src/animateable_state_mixin.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/src/widgets_list_extensions.dart';
import 'package:flutter/material.dart';

/// An expansion tile that allows for a sticky child at the bottom.
class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    super.key,
    this.stickyChildBuilder,
    this.expandedChild,
  });

  /// The child that always appears at the bottom of the tile.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(bool isExpanded)? stickyChildBuilder;

  /// The child that appears when the tile is expanded.
  final Widget? expandedChild;

  @override
  State<CustomExpansionTile> createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile>
    with
        TickerProviderStateMixin<CustomExpansionTile>,
        AnimateableStateMixin<CustomExpansionTile> {
  bool _isExpanded = false;

  /// Expands the tile.
  void expand() => startAnimation().then((_) => _isExpanded = true);

  /// Collapses the tile.
  void collapse() => reverseAnimation().then((_) => _isExpanded = false);

  /// Whether the tile is expanded.
  bool get isExpanded => _isExpanded;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children:
        [
          if (widget.expandedChild != null)
            SizeTransition(
              sizeFactor: animationController,
              child: widget.expandedChild,
            ),
          if (widget.stickyChildBuilder != null)
            GestureDetector(
              onTap: () {
                if (_isExpanded) {
                  collapse();
                } else {
                  expand();
                }
              },
              child: widget.stickyChildBuilder!(_isExpanded),
            ),
        ].wrappedWithFlexible(),
  );
}
