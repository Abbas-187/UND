import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

/// Advanced gesture-based AI controls for mobile warehouse operations
/// Supports swipe gestures, pinch-to-zoom, long press, and custom multi-touch interactions
class GestureAIControls extends StatefulWidget {
  final Widget child;
  final Function(GestureType, Map<String, dynamic>)? onGestureDetected;
  final bool enableVoiceGestures;
  final bool enableAirGestures;
  final bool enableHapticFeedback;

  const GestureAIControls({
    Key? key,
    required this.child,
    this.onGestureDetected,
    this.enableVoiceGestures = true,
    this.enableAirGestures = false,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<GestureAIControls> createState() => _GestureAIControlsState();
}

class _GestureAIControlsState extends State<GestureAIControls>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _scaleController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _scaleAnimation;

  // Gesture tracking
  final Map<int, TouchPoint> _activeTouches = {};
  Timer? _longPressTimer;
  Timer? _doubleTapTimer;
  bool _isLongPressing = false;
  bool _isPanning = false;
  bool _isScaling = false;

  // Gesture recognition state
  Offset? _initialPanPosition;
  Offset? _lastPanPosition;
  double? _initialScale;
  DateTime? _lastTapTime;
  int _tapCount = 0;

  // Air gesture detection (experimental)
  bool _isAirGestureActive = false;
  List<Offset> _airGesturePoints = [];

  // Voice gesture detection
  bool _isVoiceGestureActive = false;
  Timer? _voiceGestureTimer;

  // Haptic feedback patterns
  final Map<GestureType, HapticPattern> _hapticPatterns = {
    GestureType.tap: HapticPattern.light,
    GestureType.doubleTap: HapticPattern.medium,
    GestureType.longPress: HapticPattern.heavy,
    GestureType.swipeLeft: HapticPattern.selection,
    GestureType.swipeRight: HapticPattern.selection,
    GestureType.swipeUp: HapticPattern.selection,
    GestureType.swipeDown: HapticPattern.selection,
    GestureType.pinchIn: HapticPattern.light,
    GestureType.pinchOut: HapticPattern.light,
    GestureType.rotate: HapticPattern.light,
    GestureType.threeFingerSwipe: HapticPattern.heavy,
    GestureType.fourFingerTap: HapticPattern.heavy,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.enableAirGestures) {
      _initializeAirGestureDetection();
    }
    if (widget.enableVoiceGestures) {
      _initializeVoiceGestureDetection();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _scaleController.dispose();
    _longPressTimer?.cancel();
    _doubleTapTimer?.cancel();
    _voiceGestureTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
  }

  void _initializeAirGestureDetection() {
    // Initialize air gesture detection using device sensors
    // This would typically integrate with device accelerometer/gyroscope
  }

  void _initializeVoiceGestureDetection() {
    // Initialize voice gesture detection
    // This would integrate with speech recognition for voice commands
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onLongPress: _handleLongPress,
          onLongPressStart: _handleLongPressStart,
          onLongPressEnd: _handleLongPressEnd,
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              );
            },
          ),
        ),
        // Ripple effect overlay
        if (_rippleController.isAnimating)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: RipplePainter(
                    animation: _rippleAnimation,
                    center: _lastPanPosition ?? Offset.zero,
                  ),
                );
              },
            ),
          ),
        // Gesture indicators
        if (_isAirGestureActive) _buildAirGestureIndicator(),
        if (_isVoiceGestureActive) _buildVoiceGestureIndicator(),
      ],
    );
  }

  Widget _buildAirGestureIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air, color: Colors.blue, size: 16),
            SizedBox(width: 4),
            Text(
              'Air Gesture',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceGestureIndicator() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Voice Gesture',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Gesture Handlers
  void _handleTap() {
    _tapCount++;

    if (_doubleTapTimer?.isActive ?? false) {
      _doubleTapTimer!.cancel();
      if (_tapCount == 2) {
        _detectGesture(GestureType.doubleTap, {
          'position': _lastPanPosition,
          'timestamp': DateTime.now(),
        });
        _tapCount = 0;
      }
    } else {
      _doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
        if (_tapCount == 1) {
          _detectGesture(GestureType.tap, {
            'position': _lastPanPosition,
            'timestamp': DateTime.now(),
          });
        }
        _tapCount = 0;
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _lastPanPosition = details.localPosition;
    _scaleController.forward();
    _startRippleEffect(details.localPosition);
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleLongPress() {
    _detectGesture(GestureType.longPress, {
      'position': _lastPanPosition,
      'duration': DateTime.now(),
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _isLongPressing = true;
    _lastPanPosition = details.localPosition;

    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isLongPressing) {
        _startRippleEffect(details.localPosition);
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _isLongPressing = false;
    _longPressTimer?.cancel();
  }

  void _handlePanStart(DragStartDetails details) {
    _isPanning = true;
    _initialPanPosition = details.localPosition;
    _lastPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isPanning) return;

    _lastPanPosition = details.localPosition;

    // Detect swipe gestures
    if (_initialPanPosition != null) {
      final delta = details.localPosition - _initialPanPosition!;
      final distance = delta.distance;

      if (distance > 50) {
        // Minimum swipe distance
        final angle = _calculateSwipeAngle(delta);
        final swipeType = _determineSwipeDirection(angle);

        if (swipeType != null) {
          _detectGesture(swipeType, {
            'startPosition': _initialPanPosition,
            'endPosition': details.localPosition,
            'delta': delta,
            'velocity': details.delta,
            'distance': distance,
            'angle': angle,
          });

          _isPanning = false; // Prevent multiple swipe detections
        }
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _isPanning = false;
    _initialPanPosition = null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _isScaling = true;
    _initialScale = 1.0;

    // Check for multi-finger gestures
    if (details.pointerCount > 2) {
      _handleMultiFingerGesture(details.pointerCount);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!_isScaling) return;

    final scaleDelta = details.scale - (_initialScale ?? 1.0);

    if (scaleDelta.abs() > 0.1) {
      final gestureType =
          scaleDelta > 0 ? GestureType.pinchOut : GestureType.pinchIn;

      _detectGesture(gestureType, {
        'scale': details.scale,
        'scaleDelta': scaleDelta,
        'focalPoint': details.focalPoint,
        'rotation': details.rotation,
      });
    }

    // Detect rotation gesture
    if (details.rotation.abs() > 0.2) {
      _detectGesture(GestureType.rotate, {
        'rotation': details.rotation,
        'focalPoint': details.focalPoint,
        'scale': details.scale,
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isScaling = false;
    _initialScale = null;
  }

  void _handleMultiFingerGesture(int fingerCount) {
    switch (fingerCount) {
      case 3:
        _detectGesture(GestureType.threeFingerSwipe, {
          'fingerCount': fingerCount,
          'timestamp': DateTime.now(),
        });
        break;
      case 4:
        _detectGesture(GestureType.fourFingerTap, {
          'fingerCount': fingerCount,
          'timestamp': DateTime.now(),
        });
        break;
      case 5:
        _detectGesture(GestureType.fiveFingerPinch, {
          'fingerCount': fingerCount,
          'timestamp': DateTime.now(),
        });
        break;
    }
  }

  void _detectGesture(GestureType type, Map<String, dynamic> data) {
    // Trigger haptic feedback
    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback(type);
    }

    // Trigger visual feedback
    _triggerVisualFeedback(type);

    // Notify parent widget
    if (widget.onGestureDetected != null) {
      widget.onGestureDetected!(type, data);
    }

    // Log gesture for analytics
    _logGesture(type, data);
  }

  void _triggerHapticFeedback(GestureType type) {
    final pattern = _hapticPatterns[type] ?? HapticPattern.light;

    switch (pattern) {
      case HapticPattern.light:
        HapticFeedback.lightImpact();
        break;
      case HapticPattern.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticPattern.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticPattern.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  void _triggerVisualFeedback(GestureType type) {
    // Trigger appropriate visual feedback based on gesture type
    switch (type) {
      case GestureType.tap:
      case GestureType.doubleTap:
        _rippleController.forward().then((_) => _rippleController.reset());
        break;
      case GestureType.longPress:
        _scaleController.forward().then((_) => Timer(
            const Duration(milliseconds: 200),
            () => _scaleController.reverse()));
        break;
      case GestureType.swipeLeft:
      case GestureType.swipeRight:
      case GestureType.swipeUp:
      case GestureType.swipeDown:
        _createSwipeTrail();
        break;
      default:
        break;
    }
  }

  void _startRippleEffect(Offset position) {
    _lastPanPosition = position;
    _rippleController.forward().then((_) => _rippleController.reset());
  }

  void _createSwipeTrail() {
    // Create visual trail for swipe gestures
    // This would typically create a particle effect or animated trail
  }

  double _calculateSwipeAngle(Offset delta) {
    return atan2(delta.dy, delta.dx) * 180 / pi;
  }

  GestureType? _determineSwipeDirection(double angle) {
    const threshold = 45.0;

    if (angle >= -threshold && angle <= threshold) {
      return GestureType.swipeRight;
    } else if (angle >= threshold && angle <= 180 - threshold) {
      return GestureType.swipeDown;
    } else if (angle >= 180 - threshold || angle <= -180 + threshold) {
      return GestureType.swipeLeft;
    } else if (angle >= -180 + threshold && angle <= -threshold) {
      return GestureType.swipeUp;
    }

    return null;
  }

  void _logGesture(GestureType type, Map<String, dynamic> data) {
    // Log gesture data for analytics and AI learning
    debugPrint('Gesture detected: ${type.name} with data: $data');
  }
}

/// Advanced gesture recognition for complex multi-touch patterns
class AdvancedGestureRecognizer {
  static final AdvancedGestureRecognizer _instance =
      AdvancedGestureRecognizer._internal();
  factory AdvancedGestureRecognizer() => _instance;
  AdvancedGestureRecognizer._internal();

  final List<GesturePattern> _patterns = [];
  final Map<String, Function> _customGestureCallbacks = {};

  void registerCustomGesture({
    required String name,
    required GesturePattern pattern,
    required Function callback,
  }) {
    _patterns.add(pattern);
    _customGestureCallbacks[name] = callback;
  }

  bool recognizePattern(List<TouchPoint> touches) {
    for (final pattern in _patterns) {
      if (_matchesPattern(touches, pattern)) {
        final callback = _customGestureCallbacks[pattern.name];
        if (callback != null) {
          callback();
          return true;
        }
      }
    }
    return false;
  }

  bool _matchesPattern(List<TouchPoint> touches, GesturePattern pattern) {
    if (touches.length != pattern.touchPoints.length) return false;

    // Implement pattern matching logic
    // This would compare the current touch points with the pattern
    return false; // Placeholder
  }
}

/// Custom painter for ripple effects
class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset center;
  final Color color;

  RipplePainter({
    required this.animation,
    required this.center,
    this.color = const Color(0xFF00E5FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - animation.value))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = animation.value * 100;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.center != center;
  }
}

// Data Models
class TouchPoint {
  final int id;
  final Offset position;
  final DateTime timestamp;
  final double pressure;

  TouchPoint({
    required this.id,
    required this.position,
    required this.timestamp,
    this.pressure = 1.0,
  });
}

class GesturePattern {
  final String name;
  final List<TouchPoint> touchPoints;
  final Duration duration;
  final double tolerance;

  GesturePattern({
    required this.name,
    required this.touchPoints,
    required this.duration,
    this.tolerance = 0.1,
  });
}

enum GestureType {
  tap,
  doubleTap,
  longPress,
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,
  pinchIn,
  pinchOut,
  rotate,
  threeFingerSwipe,
  fourFingerTap,
  fiveFingerPinch,
  customGesture,
}

enum HapticPattern {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// Gesture command processor for AI integration
class GestureCommandProcessor {
  static final GestureCommandProcessor _instance =
      GestureCommandProcessor._internal();
  factory GestureCommandProcessor() => _instance;
  GestureCommandProcessor._internal();

  final Map<GestureType, String> _gestureCommands = {
    GestureType.swipeLeft: 'navigate_back',
    GestureType.swipeRight: 'navigate_forward',
    GestureType.swipeUp: 'show_menu',
    GestureType.swipeDown: 'hide_interface',
    GestureType.doubleTap: 'quick_action',
    GestureType.longPress: 'context_menu',
    GestureType.pinchOut: 'zoom_in',
    GestureType.pinchIn: 'zoom_out',
    GestureType.threeFingerSwipe: 'switch_mode',
    GestureType.fourFingerTap: 'emergency_mode',
  };

  final Map<String, Function> _commandHandlers = {};

  void registerCommandHandler(String command, Function handler) {
    _commandHandlers[command] = handler;
  }

  void processGesture(GestureType type, Map<String, dynamic> data) {
    final command = _gestureCommands[type];
    if (command != null) {
      final handler = _commandHandlers[command];
      if (handler != null) {
        handler(data);
      }
    }
  }

  String? getGestureCommand(GestureType type) {
    return _gestureCommands[type];
  }

  void updateGestureCommand(GestureType type, String command) {
    _gestureCommands[type] = command;
  }
}
