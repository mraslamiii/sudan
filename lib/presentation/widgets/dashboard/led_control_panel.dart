import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import 'painters/color_wheel_painter.dart';
import 'painters/lamp_glow_painter.dart';

/// LED Control Panel Widget - Apple-style Minimal Design
class LEDControlPanel extends StatefulWidget {
  final Color selectedColor;
  final int brightness;
  final int intensity;
  final bool isOn;
  final String selectedPreset;
  final Function(Color)? onColorChanged;
  final Function(int)? onBrightnessChanged;
  final Function(int)? onIntensityChanged;
  final Function(bool)? onToggle;
  final Function(String)? onPresetChanged;

  const LEDControlPanel({
    super.key,
    this.selectedColor = const Color(0xFFFF9500),
    this.brightness = 80,
    this.intensity = 80,
    this.isOn = true,
    this.selectedPreset = 'Working',
    this.onColorChanged,
    this.onBrightnessChanged,
    this.onIntensityChanged,
    this.onToggle,
    this.onPresetChanged,
  });

  @override
  State<LEDControlPanel> createState() => _LEDControlPanelState();
}

class _LEDControlPanelState extends State<LEDControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedPresetIndex = 0;

  static const List<Map<String, dynamic>> _presetsData = [
    {'name': 'Reading', 'color': Color(0xFF5AC8FA)},
    {'name': 'Working', 'color': Colors.white},
    {'name': 'Romantic', 'color': Color(0xFFFF6B9D)},
  ];

  String _getPresetLocalizedName(BuildContext context, String preset) {
    final l10n = AppLocalizations.of(context)!;
    switch (preset) {
      case 'Reading':
        return l10n.reading;
      case 'Working':
        return l10n.working;
      case 'Romantic':
        return l10n.romantic;
      default:
        return preset;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPresetIndex = _presetsData.indexWhere((p) => p['name'] == widget.selectedPreset);
    if (_selectedPresetIndex == -1) _selectedPresetIndex = 1;

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    if (widget.isOn) _fadeController.value = 1.0;
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LEDControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn) {
      widget.isOn ? _fadeController.forward() : _fadeController.reverse();
    }
    if (oldWidget.selectedPreset != widget.selectedPreset) {
      final newIndex = _presetsData.indexWhere((p) => p['name'] == widget.selectedPreset);
      if (newIndex != -1) _selectedPresetIndex = newIndex;
    }
  }

  void _handleColorWheelTouch(Offset localPosition, double size) {
    if (!widget.isOn) return;
    final center = Offset(size / 2, size / 2);
    final distance = (localPosition - center).distance;
    if (distance > size / 2) return;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final angle = math.atan2(dy, dx);
    var hue = (angle + math.pi / 2) * 180 / math.pi;
    if (hue < 0) hue += 360;
    hue = hue % 360;
    
    HapticFeedback.selectionClick();
    widget.onColorChanged?.call(HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 280;
        final isVeryCompact = constraints.maxHeight < 220;
        final availableWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - compact
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.lighting,
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onToggle?.call(!widget.isOn);
                  },
                  child: Container(
                    width: isCompact ? 32 : 38,
                    height: isCompact ? 32 : 38,
                    decoration: BoxDecoration(
                      color: widget.isOn ? const Color(0xFFFF9500) : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: widget.isOn
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF9500).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.isOn ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                      color: Colors.white,
                      size: isCompact ? 16 : 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 6 : 8),

            // Main content - fixed height to prevent stretching
            Expanded(
              child: Row(
                children: [
                  // Color wheel - takes more space
                  Expanded(
                    flex: availableWidth < 280 ? 5 : 4,
                    child: _buildColorWheel(isDark, isCompact),
                  ),
                  SizedBox(width: isCompact ? 4 : 6),
                  // Lamp + Presets stacked
                  Expanded(
                    flex: availableWidth < 280 ? 4 : 5,
                    child: Column(
                      children: [
                        // Lamp visual - BIGGER
                        Expanded(
                          flex: isVeryCompact ? 4 : 5,
                          child: _buildLampVisual(isDark, isCompact),
                        ),
                        SizedBox(height: isCompact ? 3 : 5),
                        // Presets - horizontal layout when compact
                        _buildPresetsRow(context, isDark, isCompact, isVeryCompact),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isCompact ? 6 : 8),

            // Brightness slider
            _buildBrightnessSlider(isDark, isCompact),
          ],
        );
      },
    );
  }

  Widget _buildColorWheel(bool isDark, bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.95;
        final centerSize = size * 0.35;

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _handleColorWheelTouch(d.localPosition, size),
            onPanStart: (d) => _handleColorWheelTouch(d.localPosition, size),
            onTapDown: (d) => _handleColorWheelTouch(d.localPosition, size),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: ColorWheelPainter(widget.selectedColor, widget.isOn),
                  ),
                  GestureDetector(
                    onTap: widget.isOn
                        ? () {
                            final newIntensity = (widget.intensity + 10) % 110;
                            widget.onIntensityChanged?.call(newIntensity == 0 ? 10 : newIntensity);
                          }
                        : null,
                    child: Container(
                      width: centerSize,
                      height: centerSize,
                      alignment: Alignment.center,
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLampVisual(bool isDark, bool isCompact) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _fadeController]),
      builder: (context, child) {
        final glowIntensity = 0.6 + (_glowController.value * 0.4);
        final fadeValue = _fadeAnimation.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Make lamp BIGGER - use more of available height
            final lampHeight = constraints.maxHeight * 1.1;

            return Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Lamp image - positioned to be more visible
                Positioned(
                  top: -lampHeight * 0.35,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: widget.isOn ? 1.0 : 0.4,
                    child: SizedBox(
                      height: lampHeight * 1.3,
                      child: Image.asset('assets/images/lamp.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                // Glow effect
                if (widget.isOn && fadeValue > 0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: fadeValue * 0.5,
                      child: CustomPaint(
                        painter: LampGlowPainter(
                          widget.selectedColor,
                          widget.brightness / 100.0,
                          glowIntensity,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPresetsRow(BuildContext context, bool isDark, bool isCompact, bool isVeryCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _presetsData.asMap().entries.map((entry) {
        final index = entry.key;
        final preset = entry.value;
        final isSelected = _selectedPresetIndex == index;
        final color = preset['color'] as Color;
        final name = preset['name'] as String;
        final localizedName = _getPresetLocalizedName(context, name);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 3),
            child: GestureDetector(
              onTap: widget.isOn
                  ? () {
                      setState(() => _selectedPresetIndex = index);
                      widget.onPresetChanged?.call(name);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 4 : 8,
                  vertical: isVeryCompact ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  isVeryCompact ? localizedName[0] : localizedName,
                  style: TextStyle(
                    fontSize: isVeryCompact ? 9 : (isCompact ? 10 : 11),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? color
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrightnessSlider(bool isDark, bool isCompact) {
    return Row(
      children: [
        Icon(
          Icons.wb_sunny_outlined,
          color: isDark ? Colors.white38 : Colors.black38,
          size: isCompact ? 14 : 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: isCompact ? 4 : 5,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: isCompact ? 8 : 10),
              overlayShape: RoundSliderOverlayShape(overlayRadius: isCompact ? 14 : 18),
              activeTrackColor: const Color(0xFFFF9500),
              inactiveTrackColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              thumbColor: const Color(0xFFFF9500),
            ),
            child: Slider(
              value: widget.brightness.toDouble(),
              min: 0,
              max: 100,
              onChanged: (v) => widget.onBrightnessChanged?.call(v.round()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.wb_sunny,
          color: const Color(0xFFFF9500),
          size: isCompact ? 16 : 20,
        ),
      ],
    );
  }
}
