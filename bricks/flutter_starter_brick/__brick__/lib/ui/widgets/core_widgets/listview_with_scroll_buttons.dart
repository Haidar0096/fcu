import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

const Duration _defaultButtonAnimationDuration = Duration(milliseconds: 200);
const Duration _defaultScrollAnimationDuration = Duration(milliseconds: 500);
const double _defaultIconSize = 30;

/// Layout builder for animated cross fade.
Widget _defaultAnimatedCrossFadeLayoutBuilder(
  Widget topChild,
  Key topChildKey,
  Widget bottomChild,
  Key bottomChildKey,
) =>
    Stack(
      children: [
        Positioned(key: bottomChildKey, child: bottomChild),
        Positioned(key: topChildKey, child: topChild),
      ],
    );

/// A widget that wraps its child list view with scroll buttons.
abstract class ListViewWithScrollButtons extends StatefulWidget {
  /// Creates a [ListViewWithScrollButtons].
  const ListViewWithScrollButtons({
    required this.children,
    super.key,
    this.toStartScrollButton,
    this.toEndScrollButton,
    this.padding,
    this.shrinkWrap = false,
  });

  /// The button to scroll to the start of the list.
  final Widget? toStartScrollButton;

  /// The button to scroll to the end of the list.
  final Widget? toEndScrollButton;

  /// The padding for the list view.
  final EdgeInsetsGeometry? padding;

  /// Whether the list view should shrink to fit its children.
  final bool shrinkWrap;

  /// The list of children to display in the list view.
  final List<Widget> children;

  /// Builds the list view with the provided scroll controller and direction.
  ListView _buildListView({
    required ScrollController scrollController,
    required Axis scrollDirection,
  }) =>
      ListView(
        padding: padding,
        shrinkWrap: shrinkWrap,
        controller: scrollController,
        scrollDirection: scrollDirection,
        children: children,
      );
}

abstract class ListViewWithScrollButtonsState
    extends State<ListViewWithScrollButtons> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      setState(() {});
    });
    Future.delayed(Duration.zero, () => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Builds the button to scroll to the end of the list.
  Widget _buildToEndScrollButton(IconData icon) =>
      widget.toEndScrollButton ??
      IconButton(
        icon: Icon(
          icon,
          size: _defaultIconSize,
          color: context.appColorsTheme.buttonPurple,
        ),
        onPressed: () => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: _defaultScrollAnimationDuration,
          curve: Curves.easeInOut,
        ),
      );

  /// Creates an animated cross fade for the end scroll button.
  Widget _buildToEndAnimatedCrossFade(IconData icon) => AnimatedCrossFade(
        firstChild: _buildToEndScrollButton(icon),
        secondChild: const SizedBox.shrink(),
        crossFadeState:
            (_scrollController.hasClients && _scrollController.offset == 0)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
        layoutBuilder: _defaultAnimatedCrossFadeLayoutBuilder,
        duration: _defaultButtonAnimationDuration,
      );

  /// Builds the button to scroll to the start of the list.
  Widget _buildToStartScrollButton(IconData icon) =>
      widget.toStartScrollButton ??
      IconButton(
        icon: Icon(
          icon,
          size: _defaultIconSize,
          color: context.appColorsTheme.buttonPurple,
        ),
        onPressed: () => _scrollController.animateTo(
          0,
          duration: _defaultScrollAnimationDuration,
          curve: Curves.easeInOut,
        ),
      );

  /// Creates an animated cross fade for the start scroll button.
  Widget _buildToStartAnimatedCrossFade(IconData icon) => AnimatedCrossFade(
        firstChild: _buildToStartScrollButton(icon),
        secondChild: const SizedBox.shrink(),
        crossFadeState: (_scrollController.hasClients &&
                _scrollController.offset ==
                    _scrollController.position.maxScrollExtent)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        layoutBuilder: _defaultAnimatedCrossFadeLayoutBuilder,
        duration: _defaultButtonAnimationDuration,
      );

  /// Scrolls to the start of the list.
  void scrollToStart() => _scrollController.animateTo(
        0,
        duration: _defaultScrollAnimationDuration,
        curve: Curves.easeInOut,
      );
}

class HorizontalListViewWithScrollButtons extends ListViewWithScrollButtons {
  const HorizontalListViewWithScrollButtons({
    required super.children,
    super.key,
    super.padding,
    super.shrinkWrap,
    super.toStartScrollButton,
    super.toEndScrollButton,
  });

  @override
  ListViewWithScrollButtonsState createState() =>
      HorizontalListViewWithScrollButtonsState();
}

class HorizontalListViewWithScrollButtonsState
    extends ListViewWithScrollButtonsState {
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget._buildListView(
            scrollController: _scrollController,
            scrollDirection: Axis.horizontal,
          ),
          // Show this icon if the list is scrollable and at the beginning
          Align(
            alignment: Alignment.centerRight.add(const Alignment(-0.05, 0)),
            child:
                _buildToEndAnimatedCrossFade(Icons.arrow_circle_right_outlined),
          ),
          // Show this icon if the list is scrollable and at the end
          Align(
            alignment: Alignment.centerLeft.add(const Alignment(0.05, 0)),
            child: _buildToStartAnimatedCrossFade(
              Icons.arrow_circle_left_outlined,
            ),
          ),
        ],
      );
}

class VerticalListViewWithScrollButtons extends ListViewWithScrollButtons {
  const VerticalListViewWithScrollButtons({
    required super.children,
    super.key,
    super.padding,
    super.shrinkWrap,
    super.toStartScrollButton,
    super.toEndScrollButton,
  });

  @override
  VerticalListViewWithScrollButtonsState createState() =>
      VerticalListViewWithScrollButtonsState();
}

class VerticalListViewWithScrollButtonsState
    extends ListViewWithScrollButtonsState {
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget._buildListView(
            scrollController: _scrollController,
            scrollDirection: Axis.vertical,
          ),
          // Show this icon if the list is scrollable and at the beginning
          Align(
            alignment: Alignment.bottomCenter.add(const Alignment(0, -0.05)),
            child: _buildToEndAnimatedCrossFade(Icons.arrow_circle_down),
          ),
          // Show this icon if the list is scrollable and at the end
          Align(
            alignment: Alignment.topCenter.add(const Alignment(0, 0.05)),
            child: _buildToStartAnimatedCrossFade(Icons.arrow_circle_up),
          ),
        ],
      );
}
