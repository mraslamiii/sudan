import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import 'card_styles.dart';

/// Curtain Control Panel Widget - Apple-style Minimal Design
class CurtainControlPanel extends StatefulWidget {
  final bool isOpen;
  final int position; // 0 (Closed) - 100 (Open)
  final Function(bool)? onOpenClose;
  final Function(int)? onPositionChanged;

  const CurtainControlPanel({
    super.key,
    this.isOpen = false,
    this.position = 0,
    this.onOpenClose,
    this.onPositionChanged,
  });

  @override
  State<CurtainControlPanel> createState() => _CurtainControlPanelState();
}

class _CurtainControlPanelState extends State<CurtainControlPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isDragging = false;
  double? _dragPosition;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: CardStyles.slow,
      value: widget.position / 100.0,
    );
  }

  @override
  void didUpdateWidget(CurtainControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position && !_isDragging) {
      _animController.animateTo(
        widget.position / 100.0,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updatePosition(double value, {bool commit = false}) {
    final clamped = value.clamp(0.0, 1.0);

    if (commit) {
      final int newPos = (clamped * 100).round();
      widget.onPositionChanged?.call(newPos);
      widget.onOpenClose?.call(newPos > 0);
      setState(() {
        _isDragging = false;
        _dragPosition = null;
      });
      _animController.value = clamped;
      HapticFeedback.mediumImpact();
    } else {
      setState(() {
        _dragPosition = clamped;
      });
    }
  }

  String _getStatusText(BuildContext context) {
    final percentage = widget.position;
    if (percentage == 0) return 'Closed';
    if (percentage == 100) return 'Open';
    return '$percentage%';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CardStyles.curtainAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 260;
        final isVeryCompact = constraints.maxHeight < 200;

        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final currentVal = _isDragging && _dragPosition != null
                ? _dragPosition!
                : _animController.value;

            return Padding(
              padding: EdgeInsets.all(isCompact ? CardStyles.space12 : CardStyles.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  CardStyles.buildHeader(
                    context: context,
                    title: AppLocalizations.of(context)?.curtains ?? 'Curtains',
                    subtitle: _getStatusText(context),
                    isDark: isDark,
                    isCompact: isCompact,
                    accentColor: accentColor,
                    isActive: widget.isOpen,
                    showPowerButton: false,
                  ),
                  
                  SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space20),

                  // Main visualization
                  Expanded(
                    child: _buildCurtainVisual(
                      context,
                      constraints,
                      isDark,
                      isCompact,
                      isVeryCompact,
                      currentVal,
                      accentColor,
                    ),
                  ),
                  
                  SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space16),

                  // Slider control
                  _buildSliderControl(isDark, isCompact, currentVal, accentColor),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurtainVisual(
    BuildContext context,
    BoxConstraints constraints,
    bool isDark,
    bool isCompact,
    bool isVeryCompact,
    double currentVal,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Toggle between open and closed
        if (currentVal > 0.5) {
          _updatePosition(0.0, commit: true);
        } else {
          _updatePosition(1.0, commit: true);
        }
      },
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
          _dragPosition = widget.position / 100.0;
        });
        HapticFeedback.lightImpact();
      },
      onHorizontalDragUpdate: (details) {
        final width = constraints.maxWidth - 32;
        final delta = details.primaryDelta! / width;
        final newVal = (_dragPosition ?? (widget.position / 100.0)) + delta;
        _updatePosition(newVal);
      },
      onHorizontalDragEnd: (details) {
        _updatePosition(_dragPosition ?? (widget.position / 100.0), commit: true);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Window background - subtle gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF1A237E).withOpacity(0.4),
                            const Color(0xFF0D1B2A).withOpacity(0.6),
                          ]
                        : [
                            accentColor.withOpacity(0.15),
                            accentColor.withOpacity(0.05),
                          ],
                  ),
                ),
              ),
            ),

            // Light rays when open
            if (currentVal > 0.1)
              Positioned.fill(
                child: Opacity(
                  opacity: currentVal * 0.3,
                  child: CustomPaint(
                    painter: _LightRaysPainter(
                      color: isDark ? Colors.white : accentColor,
                      progress: currentVal,
                    ),
                  ),
                ),
              ),

            // Left curtain
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: (constraints.maxWidth * 0.5 - 16) * (1.0 - currentVal),
              child: _buildCurtainPanel(isDark, isLeft: true),
            ),

            // Right curtain
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: (constraints.maxWidth * 0.5 - 16) * (1.0 - currentVal),
              child: _buildCurtainPanel(isDark, isLeft: false),
            ),

            // Center indicator
            if (!isVeryCompact)
              Center(
                child: AnimatedOpacity(
                  duration: CardStyles.normal,
                  opacity: _isDragging ? 1.0 : 0.6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(currentVal * 100).round()}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainPanel(bool isDark, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2E),
                  const Color(0xFF3A3A3C),
                ]
              : [
                  const Color(0xFFD1D1D6),
                  const Color(0xFFE5E5EA),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(isLeft ? 2 : -2, 0),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CurtainFoldsPainter(isDark: isDark),
      ),
    );
  }

  Widget _buildSliderControl(bool isDark, bool isCompact, double currentVal, Color accentColor) {
    return Row(
      children: [
        // Closed icon
        Icon(
          Icons.fullscreen_exit_rounded,
          size: isCompact ? 16 : 18,
          color: currentVal < 0.5 ? accentColor : CardStyles.iconColor(isDark),
        ),
        const SizedBox(width: 12),
        // Slider
        Expanded(
          child: SliderTheme(
            data: CardStyles.sliderTheme(context, isDark, accentColor, isCompact: isCompact),
            child: Slider(
              value: currentVal,
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _dragPosition = value;
                });
              },
              onChangeEnd: (value) {
                _updatePosition(value, commit: true);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Open icon
        Icon(
          Icons.fullscreen_rounded,
          size: isCompact ? 16 : 18,
          color: currentVal > 0.5 ? accentColor : CardStyles.iconColor(isDark),
        ),
      ],
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LightRaysPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3 * progress),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final centerX = size.width / 2;
    final rayWidth = size.width * 0.3 * progress;

    path.moveTo(centerX - rayWidth / 4, 0);
    path.lineTo(centerX - rayWidth, size.height);
    path.lineTo(centerX + rayWidth, size.height);
    path.lineTo(centerX + rayWidth / 4, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LightRaysPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CurtainFoldsPainter extends CustomPainter {
  final bool isDark;

  _CurtainFoldsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const folds = 4;
    final foldWidth = size.width / folds;

    for (int i = 1; i < folds; i++) {
      canvas.drawLine(
        Offset(foldWidth * i, 0),
        Offset(foldWidth * i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
