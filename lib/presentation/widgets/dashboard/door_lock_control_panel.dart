import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'card_styles.dart';

/// Door Lock Control Panel Widget - Apple-style Minimal Design
class DoorLockControlPanel extends StatefulWidget {
  final bool isLocked;
  final bool isUnlocking;
  final Function(bool)? onLockToggled;
  final Function(bool)? onToggle;
  final Function(Map<String, dynamic>)? onStateUpdate;

  const DoorLockControlPanel({
    super.key,
    this.isLocked = true,
    this.isUnlocking = false,
    this.onLockToggled,
    this.onToggle,
    this.onStateUpdate,
  });

  @override
  State<DoorLockControlPanel> createState() => _DoorLockControlPanelState();
}

class _DoorLockControlPanelState extends State<DoorLockControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _unlockController;
  late AnimationController _loadingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _unlockAnimation;
  late Animation<double> _loadingRotationAnimation;
  late Animation<double> _loadingPulseAnimation;
  Timer? _autoCompleteTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _unlockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeOutCubic),
    );

    _loadingRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    _loadingPulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    if (!widget.isLocked) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.isUnlocking) {
      _unlockController.forward();
      _loadingController.repeat();
    }
  }

  @override
  void dispose() {
    _autoCompleteTimer?.cancel();
    _pulseController.dispose();
    _unlockController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DoorLockControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isLocked != widget.isLocked) {
      if (widget.isLocked) {
        _pulseController.stop();
        _pulseController.value = 0;
      } else {
        _pulseController.repeat(reverse: true);
      }
    }
    
    if (oldWidget.isUnlocking != widget.isUnlocking) {
      if (widget.isUnlocking) {
        _unlockController.forward();
        _loadingController.repeat();
        // Start auto-complete timer: simulate unlock/lock completion after 2 seconds
        _autoCompleteTimer?.cancel();
        _autoCompleteTimer = Timer(const Duration(seconds: 2), () {
          if (mounted && widget.isUnlocking) {
            // Complete the operation: set isUnlocking to false and toggle lock state
            final newLockState = !widget.isLocked;
            // Use onStateUpdate if available, otherwise fall back to onLockToggled
            if (widget.onStateUpdate != null) {
              widget.onStateUpdate!({
                'isLocked': newLockState,
                'isUnlocking': false,
              });
            } else {
              widget.onLockToggled?.call(newLockState);
              widget.onToggle?.call(newLockState);
            }
          }
        });
      } else {
        _unlockController.reverse();
        _loadingController.stop();
        _loadingController.reset();
        _autoCompleteTimer?.cancel();
        _autoCompleteTimer = null;
      }
    }
  }

  Color get _accentColor {
    if (widget.isLocked) return const Color(0xFF8E8E93);
    return CardStyles.accentGreen;
  }

  String _getStatusText() {
    if (widget.isUnlocking) return 'Unlocking...';
    return widget.isLocked ? 'Locked' : 'Unlocked';
  }

  void _handleLockToggle() {
    if (widget.isUnlocking) return;
    HapticFeedback.heavyImpact();
    widget.onLockToggled?.call(!widget.isLocked);
    widget.onToggle?.call(!widget.isLocked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 260;
        final isVeryCompact = constraints.maxHeight < 200;

        return Padding(
          padding: EdgeInsets.all(isCompact ? CardStyles.space12 : CardStyles.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CardStyles.buildHeader(
                context: context,
                title: 'Door Lock',
                subtitle: _getStatusText(),
                isDark: isDark,
                isCompact: isCompact,
                accentColor: _accentColor,
                isActive: !widget.isLocked,
                onPowerTap: _handleLockToggle,
                customIcon: widget.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              ),
              
              SizedBox(height: isCompact ? CardStyles.space16 : CardStyles.space24),

              // Main lock button
              Expanded(
                child: Center(
                  child: _buildLockButton(isDark, isCompact, isVeryCompact),
                ),
              ),
              
              SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space16),

              // Status indicator
              Center(
                child: _buildStatusPill(isDark, isCompact),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLockButton(bool isDark, bool isCompact, bool isVeryCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = maxSize.clamp(80.0, isVeryCompact ? 100.0 : 130.0);

        // Build the listenable list conditionally to avoid accessing _loadingController
        // when it's not needed or not yet initialized
        final listenables = <Listenable>[_pulseAnimation, _unlockAnimation];
        if (widget.isUnlocking) {
          listenables.add(_loadingController);
        }

        return AnimatedBuilder(
          animation: Listenable.merge(listenables),
          builder: (context, child) {
            final scale = widget.isUnlocking
                ? 0.95 + (0.1 * _unlockAnimation.value)
                : (!widget.isLocked ? _pulseAnimation.value : 1.0);

            return Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: _handleLockToggle,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accentColor.withOpacity(widget.isLocked ? 0.1 : 0.3),
                        _accentColor.withOpacity(widget.isLocked ? 0.03 : 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: size * 0.88,
                        height: size * 0.88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _accentColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner circle with lock
                      AnimatedContainer(
                        duration: CardStyles.normal,
                        width: size * 0.7,
                        height: size * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.isLocked
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _accentColor,
                                    Color.lerp(_accentColor, Colors.black, 0.15)!,
                                  ],
                                ),
                          color: widget.isLocked
                              ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05))
                              : null,
                          boxShadow: widget.isLocked
                              ? null
                              : [
                                  BoxShadow(
                                    color: _accentColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: -4,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Icon(
                          widget.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: size * 0.32,
                          color: widget.isLocked
                              ? _accentColor
                              : Colors.white,
                        ),
                      ),
                      // Unlocking animation overlay - elegant pulsing ring
                      if (widget.isUnlocking)
                        AnimatedBuilder(
                          animation: _loadingController,
                          builder: (context, child) {
                            return SizedBox(
                              width: size * 0.7,
                              height: size * 0.7,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rotating outer ring
                                  Transform.rotate(
                                    angle: _loadingRotationAnimation.value * 2 * math.pi,
                                    child: CustomPaint(
                                      size: Size(size * 0.7, size * 0.7),
                                      painter: _LoadingRingPainter(
                                        color: CardStyles.accentGreen,
                                        progress: _loadingPulseAnimation.value,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                  // Pulsing center dot
                                  Transform.scale(
                                    scale: _loadingPulseAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CardStyles.accentGreen,
                                        boxShadow: [
                                          BoxShadow(
                                            color: CardStyles.accentGreen.withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusPill(bool isDark, bool isCompact) {
    return AnimatedContainer(
      duration: CardStyles.normal,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 18,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: _accentColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: CardStyles.normal,
            width: isCompact ? 8 : 10,
            height: isCompact ? 8 : 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor,
              boxShadow: widget.isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
            ),
          ),
          SizedBox(width: isCompact ? 8 : 10),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for elegant loading ring animation
class _LoadingRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double strokeWidth;

  _LoadingRingPainter({
    required this.color,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw partial arc that rotates
    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 1.5 * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_LoadingRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
