import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A gesture recognizer for pinch-to-zoom that only accepts the gesture
/// when at least two pointers (fingers) are on screen.
///
/// This prevents competing with or intercepting single-finger drag/scroll
/// gestures (such as feed scrolling, Dismissible, or PageView swiping).
class PinchScaleGestureRecognizer extends ScaleGestureRecognizer {
  PinchScaleGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
  });

  @override
  void resolve(GestureDisposition disposition) {
    if (disposition == GestureDisposition.accepted && pointerCount < 2) {
      return;
    }
    super.resolve(disposition);
  }
}

/// An Instagram-style pinch-to-zoom overlay widget.
///
/// When pinched with two fingers, the child scales and translates above
/// the rest of the app in the root [Overlay], with a dimming backdrop.
/// Releasing fingers smoothly animates the image back to its original
/// bounds and removes the overlay.
class PinchZoom extends StatefulWidget {
  const PinchZoom({
    super.key,
    required this.child,
    this.maxScale = 4.0,
    this.minScale = 1.0,
    this.resetDuration = const Duration(milliseconds: 220),
    this.resetCurve = Curves.easeOutCubic,
    this.maxBackdropOpacity = 0.7,
  });

  final Widget child;
  final double maxScale;
  final double minScale;
  final Duration resetDuration;
  final Curve resetCurve;
  final double maxBackdropOpacity;

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _scaleAnim;
  Animation<Offset>? _deltaAnim;

  OverlayEntry? _overlayEntry;
  bool _isZooming = false;

  Offset _originOffset = Offset.zero;
  Size _originSize = Size.zero;

  Offset _initialFocalPoint = Offset.zero;
  Offset _currentDelta = Offset.zero;
  double _currentScale = 1.0;
  Offset _localFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.resetDuration,
    )..addListener(_onAnimTick)
     ..addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         _cleanupOverlay();
       }
     });
  }

  @override
  void dispose() {
    _cleanupOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _onAnimTick() {
    if (_scaleAnim != null && _deltaAnim != null) {
      setState(() {
        _currentScale = _scaleAnim!.value;
        _currentDelta = _deltaAnim!.value;
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _cleanupOverlay() {
    if (_overlayEntry != null) {
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    }
    if (_isZooming && mounted) {
      setState(() {
        _isZooming = false;
        _currentScale = 1.0;
        _currentDelta = Offset.zero;
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2 || _animController.isAnimating) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    _originOffset = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    _originSize = renderBox.size;

    _initialFocalPoint = details.focalPoint;
    _currentDelta = Offset.zero;
    _currentScale = 1.0;
    _localFocal = _initialFocalPoint - _originOffset;

    _isZooming = true;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isZooming || _animController.isAnimating) return;

    setState(() {
      _currentScale = details.scale.clamp(widget.minScale * 0.8, widget.maxScale);
      _currentDelta = details.focalPoint - _initialFocalPoint;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isZooming || _animController.isAnimating) return;

    _scaleAnim = Tween<double>(begin: _currentScale, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: widget.resetCurve),
    );
    _deltaAnim = Tween<Offset>(begin: _currentDelta, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: widget.resetCurve),
    );

    _animController.forward(from: 0.0);
  }

  Matrix4 _computeTransform() {
    final scale = _currentScale;
    final delta = _currentDelta;
    final dx = delta.dx + _localFocal.dx * (1.0 - scale);
    final dy = delta.dy + _localFocal.dy * (1.0 - scale);
    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0);
  }

  Widget _buildOverlay(BuildContext context) {
    final progress = ((_currentScale - 1.0) / (widget.maxScale - 1.0)).clamp(0.0, 1.0);
    final opacity = (progress * widget.maxBackdropOpacity).clamp(0.0, widget.maxBackdropOpacity);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: opacity)),
          ),
          Positioned(
            left: _originOffset.dx,
            top: _originOffset.dy,
            width: _originSize.width,
            height: _originSize.height,
            child: IgnorePointer(
              child: Transform(
                alignment: Alignment.topLeft,
                transform: _computeTransform(),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        PinchScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<PinchScaleGestureRecognizer>(
          () => PinchScaleGestureRecognizer(),
          (instance) {
            instance
              ..onStart = _onScaleStart
              ..onUpdate = _onScaleUpdate
              ..onEnd = _onScaleEnd;
          },
        ),
      },
      child: Opacity(
        opacity: _isZooming ? 0.0 : 1.0,
        child: widget.child,
      ),
    );
  }
}
