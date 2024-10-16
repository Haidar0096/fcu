import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

const Duration _defaultButtonAnimationDuration = Duration(milliseconds: 200);
const Duration _defaultScrollAnimationDuration = Duration(milliseconds: 500);
const double _defaultIconSize = 30;

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

/// A widget that wraps its child scrollable view with scroll buttons.
///
/// This abstract class provides the base functionality for creating
/// scrollable widgets with customizable scroll buttons at the start and end.
abstract class ScrollableWithScrollButtons extends StatefulWidget {
  /// Creates a [ScrollableWithScrollButtons].
  ///
  /// The [children] parameter is required and specifies the widgets to be
  /// displayed in the scrollable view.
  const ScrollableWithScrollButtons({
    required this.children,
    super.key,
    this.toStartScrollButton,
    this.toEndScrollButton,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// The widget to use as the scroll-to-start button.
  ///
  /// If null, a default button will be used.
  final Widget? toStartScrollButton;

  /// The widget to use as the scroll-to-end button.
  ///
  /// If null, a default button will be used.
  final Widget? toEndScrollButton;

  /// Determines how much space the scrollable should occupy in the main axis.
  final MainAxisSize mainAxisSize;

  /// How the children should be placed along the main axis in a flex layout.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the cross axis in a flex layout.
  final CrossAxisAlignment crossAxisAlignment;

  /// The widgets to display in the scrollable view.
  final List<Widget> children;

  /// Builds the scrollable widget with the provided scroll controller and
  /// direction.
  Widget _buildScrollable({
    required ScrollController scrollController,
    required Axis scrollDirection,
  }) =>
      SingleChildScrollView(
        controller: scrollController,
        scrollDirection: scrollDirection,
        child: switch (scrollDirection) {
          Axis.horizontal => Row(
              mainAxisSize: mainAxisSize,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          Axis.vertical => Column(
              mainAxisSize: mainAxisSize,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
        },
      );
}

/// The base state class for [ScrollableWithScrollButtons].
///
/// This class manages the scroll controller and provides methods for building
/// the scroll buttons and handling scroll animations.
abstract class ScrollableWithScrollButtonsState
    extends State<ScrollableWithScrollButtons> {
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

  /// Builds the scroll-to-end button with the given icon.
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

  /// Builds an animated cross-fade for the scroll-to-end button.
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

  /// Builds the scroll-to-start button with the given icon.
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

  /// Builds an animated cross-fade for the scroll-to-start button.
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

  /// Scrolls the view to the start position.
  void scrollToStart() => _scrollController.animateTo(
        0,
        duration: _defaultScrollAnimationDuration,
        curve: Curves.easeInOut,
      );
}

/// A horizontal scrollable widget with scroll buttons.
class HorizontalScrollableWithScrollButtons
    extends ScrollableWithScrollButtons {
  /// Creates a [HorizontalScrollableWithScrollButtons].
  const HorizontalScrollableWithScrollButtons({
    required super.children,
    super.key,
    super.mainAxisSize,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.toStartScrollButton,
    super.toEndScrollButton,
  });

  @override
  ScrollableWithScrollButtonsState createState() =>
      HorizontalScrollableWithScrollButtonsState();
}

/// The state for [HorizontalScrollableWithScrollButtons].
class HorizontalScrollableWithScrollButtonsState
    extends ScrollableWithScrollButtonsState {
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget._buildScrollable(
            scrollController: _scrollController,
            scrollDirection: Axis.horizontal,
          ),
          // only show this icon if the list is scrollable and the scroll
          // position is at the beginning
          Align(
            alignment: Alignment.centerRight.add(const Alignment(-0.05, 0)),
            child:
                _buildToEndAnimatedCrossFade(Icons.arrow_circle_right_outlined),
          ),
          // only show this icon if the list is scrollable and the scroll
          // position is at the end
          Align(
            alignment: Alignment.centerLeft.add(const Alignment(0.05, 0)),
            child: _buildToStartAnimatedCrossFade(
              Icons.arrow_circle_left_outlined,
            ),
          ),
        ],
      );
}

/// A vertical scrollable widget with scroll buttons.
class VerticalScrollableWithScrollButtons extends ScrollableWithScrollButtons {
  /// Creates a [VerticalScrollableWithScrollButtons].
  const VerticalScrollableWithScrollButtons({
    required super.children,
    super.key,
    super.mainAxisSize,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.toStartScrollButton,
    super.toEndScrollButton,
  });

  @override
  VerticalScrollableWithScrollButtonsState createState() =>
      VerticalScrollableWithScrollButtonsState();
}

/// The state for [VerticalScrollableWithScrollButtons].
class VerticalScrollableWithScrollButtonsState
    extends ScrollableWithScrollButtonsState {
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget._buildScrollable(
            scrollController: _scrollController,
            scrollDirection: Axis.vertical,
          ),
          // only show this icon if the list is scrollable and the scroll
          // position is at the beginning
          Align(
            alignment: Alignment.bottomCenter.add(const Alignment(0, -0.05)),
            child: _buildToEndAnimatedCrossFade(Icons.arrow_circle_down),
          ),
          // only show this icon if the list is scrollable and the scroll
          // position is at the end
          Align(
            alignment: Alignment.topCenter.add(const Alignment(0, 0.05)),
            child: _buildToStartAnimatedCrossFade(Icons.arrow_circle_up),
          ),
        ],
      );
}
