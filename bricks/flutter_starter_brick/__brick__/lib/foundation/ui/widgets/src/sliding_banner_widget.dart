part of 'sliding_banner.dart';

/// Internal widget that renders the sliding banner.
class _SlidingBannerWidget extends StatefulWidget {
  const _SlidingBannerWidget({
    required this.type,
    required this.message,
    required this.onDismiss,
    this.onAction,
    this.actionText,
    super.key,
  });

  final StatusBannerType type;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final VoidCallback onDismiss;

  @override
  State<_SlidingBannerWidget> createState() => _SlidingBannerWidgetState();
}

class _SlidingBannerWidgetState extends State<_SlidingBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;
  Object? _dismissOperation;
  bool _didDismiss = false;
  double _dragDisplacement = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SlidingBannerDefaults.slideDuration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationDefaults.curveEaseOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationDefaults.curveEaseOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _dismissOperation = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissOperation != null || _didDismiss) return;
    final operation = Object();
    _dismissOperation = operation;

    SlidingBanner._dismissTimer?.cancel();
    SlidingBanner._dismissTimer = null;

    await _controller.reverse();
    if (!mounted ||
        !identical(_dismissOperation, operation) ||
        _didDismiss) {
      return;
    }
    _didDismiss = true;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragStart: (_) => _dragDisplacement = 0,
          onVerticalDragUpdate: (details) {
            _dragDisplacement += details.delta.dy;
            if (_dragDisplacement <= SlidingBannerDefaults.swipeThreshold) {
              unawaited(_dismiss());
            }
          },
          onVerticalDragEnd: (_) => _dragDisplacement = 0,
          onVerticalDragCancel: () => _dragDisplacement = 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.only(
                  top: topPadding + SpacingSize.spacing8.value,
                  left: SpacingSize.spacing16.value,
                  right: SpacingSize.spacing16.value,
                  bottom: SpacingSize.spacing8.value,
                ),
                child: StatusBannerWidget(
                  type: widget.type,
                  message: widget.message,
                  onAction: widget.onAction,
                  actionText: widget.actionText,
                  onDismiss: _dismiss,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
