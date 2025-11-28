import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

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
  late Color _selectedColor;
  late int _brightness;
  late int _intensity;
  late bool _isOn;
  late String _selectedPreset;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late WheelPickerController _presetPickerController;
  int _selectedPresetIndex = 0;

  final List<String> _presets = ['Reading', 'Working', 'Romantic'];
  
  // Colors for each preset
  Color _getPresetColor(String preset) {
    switch (preset) {
      case 'Reading':
        return const Color(0xFF5AC8FA); // Light blue
      case 'Working':
        return Colors.white; // White
      case 'Romantic':
        return const Color(0xFFFF69B4); // Pink
      default:
        return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
    _brightness = widget.brightness;
    _intensity = widget.intensity;
    _isOn = widget.isOn;
    _selectedPreset = widget.selectedPreset;
    _selectedPresetIndex = _presets.indexWhere((p) => p == _selectedPreset);
    if (_selectedPresetIndex == -1) _selectedPresetIndex = 0;

    _presetPickerController = WheelPickerController(
      itemCount: _presets.length,
      initialIndex: _selectedPresetIndex,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    if (_isOn) {
      _fadeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    _presetPickerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LEDControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      _selectedColor = widget.selectedColor;
    }
    if (oldWidget.brightness != widget.brightness) {
      _brightness = widget.brightness;
    }
    if (oldWidget.intensity != widget.intensity) {
      _intensity = widget.intensity;
    }
    if (oldWidget.isOn != widget.isOn) {
      _isOn = widget.isOn;
      if (_isOn) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
    if (oldWidget.selectedPreset != widget.selectedPreset) {
      _selectedPreset = widget.selectedPreset;
      final newIndex = _presets.indexWhere((p) => p == _selectedPreset);
      if (newIndex != -1 && newIndex != _selectedPresetIndex) {
        final oldIndex = _selectedPresetIndex;
        _selectedPresetIndex = newIndex;
        // Shift to the new index
        final diff = newIndex - oldIndex;
        if (diff > 0) {
          for (int i = 0; i < diff; i++) {
            _presetPickerController.shiftDown();
          }
        } else if (diff < 0) {
          for (int i = 0; i < -diff; i++) {
            _presetPickerController.shiftUp();
          }
        }
      }
    }
  }

  void _handleColorWheelTouch(Offset localPosition) {
    if (!_isOn) return;
    
    const size = 240.0;
    final center = Offset(size / 2, size / 2);
    final maxRadius = size / 2; // کل دایره
    final distance = (localPosition - center).distance;

    // اگر خارج از دایره کلیک شد، نادیده بگیر
    if (distance > maxRadius) return;

    // محاسبه زاویه از مرکز به نقطه touch
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final angle = math.atan2(dy, dx);
    
    // تبدیل به hue: atan2 برمی‌گرداند -π تا π
    // می‌خواهیم 0° در بالا (12 o'clock) باشد، پس 90° می‌چرخانیم
    var hue = (angle + math.pi / 2) * 180 / math.pi;
    if (hue < 0) hue += 360;
    hue = hue % 360;
    
    final newColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    
    setState(() {
      _selectedColor = newColor;
    });
    widget.onColorChanged?.call(_selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientStart = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF);
    final gradientEnd = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8F8FA);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08) 
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and power button
            Row(
              children: [
                Text(
                  'Lighting',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOn = !_isOn;
                    });
                    if (_isOn) {
                      _fadeController.forward();
                    } else {
                      _fadeController.reverse();
                    }
                    widget.onToggle?.call(_isOn);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isOn ? const Color(0xFFFF9500) : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: _isOn
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF9500).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isOn ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main content area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Color wheel with intensity
                  Expanded(
                    flex: 20,
                    child: _buildColorWheelWithIntensity(isDark),
                  ),
                  const SizedBox(width: 24),

                  // Center: Lamp visual
                  Expanded(
                    flex: 20,
                    child: _buildLampVisual(isDark),
                  ),
                  const SizedBox(width: 24),

                  // Right: Presets
                  Expanded(
                    flex: 11,
                    child: _buildPresetsList(isDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom: Brightness slider
            _buildBrightnessSlider(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildColorWheelWithIntensity(bool isDark) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Color wheel with better touch handling
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                if (!_isOn) return;
                _handleColorWheelTouch(details.localPosition);
              },
              onPanStart: (details) {
                if (!_isOn) return;
                _handleColorWheelTouch(details.localPosition);
              },
              onTapDown: (details) {
                if (!_isOn) return;
                _handleColorWheelTouch(details.localPosition);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _MinimalColorWheelPainter(_selectedColor, _isOn),
                  ),
                  // Invisible touch area for intensity display (doesn't block wheel)
                  IgnorePointer(
                    ignoring: false,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.transparent,
                      child: _isOn
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _intensity = (_intensity + 10) % 110;
                                  if (_intensity == 0) _intensity = 10;
                                });
                                widget.onIntensityChanged?.call(_intensity);
                              },
                              child: const SizedBox.expand(),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // Intensity display in center (overlay, doesn't block wheel)
            IgnorePointer(
              ignoring: true,
              child: Container(
                width: 80,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Intensity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_intensity%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: _isOn
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? Colors.white38 : Colors.black38),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLampVisual(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _fadeController]),
      builder: (context, child) {
        final glowIntensity = 0.6 + (_glowController.value * 0.4);
        final fadeValue = _fadeAnimation.value;
        
        return SizedBox(
          width: 200,
          height: 240,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // Lamp image - positioned at top to look like hanging from ceiling
              // This is drawn first so glow can be behind it
              Positioned(
                top: -100,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _isOn ? 1.0 : 0.4,
                  child: Image.asset(
                    'assets/images/lamp.png',
                    fit: BoxFit.contain,
                    // Don't apply color or colorBlendMode when off
                    color: _isOn ? null : null,
                    colorBlendMode: _isOn ? BlendMode.overlay : null,
                  ),
                ),
              ),
              
              // Glow effect layers - positioned to cover behind and around the lamp
              // Lamp starts at top: -100, so glow should start higher to cover behind lamp
              // Glow should extend around and behind the entire lamp, not just below it
              // Only render glow when lamp is on
              if (_isOn && fadeValue > 0)
                Positioned(
                  top: -60, // Start much higher to cover behind the lamp
                  left: -60,
                  right: -60,
                  bottom: -100,
                  child: Opacity(
                    opacity: fadeValue,
                    child: CustomPaint(
                      size: const Size(320, 400),
                      painter: _LampGlowPainter(
                        _selectedColor,
                        _brightness / 100.0,
                        glowIntensity,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetsList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Wheel Picker
          WheelPicker(
            controller: _presetPickerController,
            builder: (context, index) {
              final preset = _presets[index];
              final isSelected = _selectedPresetIndex == index;
              final presetColor = _getPresetColor(preset);
              
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  preset,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? presetColor
                        : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                    letterSpacing: 0.2,
                  ),
                ),
              );
            },
            selectedIndexColor: _isOn
                ? _getPresetColor(_presets[_selectedPresetIndex])
                : (isDark ? Colors.white38 : Colors.black38),
            onIndexChanged: _isOn
                ? (index, interactionType) {
                    final newPreset = _presets[index];
                    if (newPreset != _selectedPreset) {
                      setState(() {
                        _selectedPreset = newPreset;
                        _selectedPresetIndex = index;
                      });
                      widget.onPresetChanged?.call(newPreset);
                    }
                  }
                : null,
            style: WheelPickerStyle(
              itemExtent: 56.0,
              squeeze: 1.1,
              diameterRatio: 2.0,
              surroundingOpacity: 0.4,
              magnification: 1.15,
            ),
            looping: false,
          ),
          
          // Top chevron
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom chevron
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessSlider(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: const Color(0xFFFF9500),
                  inactiveTrackColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  thumbColor: const Color(0xFFFF9500),
                ),
                child: Slider(
                  value: _brightness.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value.round();
                    });
                    widget.onBrightnessChanged?.call(_brightness);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.wb_sunny,
              color: const Color(0xFFFF9500),
              size: 24,
            ),
          ],
        ),
      ],
    );
  }
}

class _MinimalColorWheelPainter extends CustomPainter {
  final Color selectedColor;
  final bool isOn;

  _MinimalColorWheelPainter(this.selectedColor, this.isOn);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 5;
    final innerRadius = outerRadius - 18; // Less ring width = thinner ring, bigger inner circle
    final ringWidth = outerRadius - innerRadius;
    final ringCenterRadius = (outerRadius + innerRadius) / 2;

    if (!isOn) {
      // Draw grayed out wheel when off
      final grayPaint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, ringCenterRadius, grayPaint);
      return;
    }

    // Create color wheel using SweepGradient for smooth transitions
    // Start from top (12 o'clock) going clockwise
    final rect = Rect.fromCircle(center: center, radius: ringCenterRadius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2, // Start from top (12 o'clock)
      endAngle: 3 * math.pi / 2, // End at top after full rotation
      colors: [
        const Color(0xFFFF0000), // Red (top)
        const Color(0xFFFF7F00), // Orange
        const Color(0xFFFFFF00), // Yellow
        const Color(0xFF00FF00), // Green
        const Color(0xFF0000FF), // Blue
        const Color(0xFF4B0082), // Indigo
        const Color(0xFF9400D3), // Violet
        const Color(0xFFFF0000), // Back to Red
      ],
      stops: const [0.0, 0.14, 0.28, 0.42, 0.57, 0.71, 0.85, 1.0],
    );

    // Draw the color wheel ring
    final wheelPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, ringCenterRadius, wheelPaint);

    // Draw subtle inner border
    final innerBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, innerRadius, innerBorderPaint);

    // Draw subtle outer border
    final outerBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, outerRadius, outerBorderPaint);

    // Draw selected color indicator
    final hsv = HSVColor.fromColor(selectedColor);
    // Convert hue (0-360 degrees) to radians
    // Hue 0° = Red = top position, so we start from -90° (top)
    final hueRadians = (hsv.hue * math.pi / 180) - (math.pi / 2);
    final indicatorPos = Offset(
      center.dx + ringCenterRadius * math.cos(hueRadians),
      center.dy + ringCenterRadius * math.sin(hueRadians),
    );

    // Outer glow for indicator (minimal)
    final glowPaint = Paint()
      ..color = selectedColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(indicatorPos, 14, glowPaint);

    // White background circle for indicator
    final indicatorBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPos, 11, indicatorBgPaint);

    // Selected color border (minimal, clean)
    final borderPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(indicatorPos, 11, borderPaint);

    // Inner dot for precision
    final innerDotPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPos, 3, innerDotPaint);
  }

  @override
  bool shouldRepaint(_MinimalColorWheelPainter oldDelegate) =>
      oldDelegate.selectedColor != selectedColor || oldDelegate.isOn != isOn;
}

class _LampGlowPainter extends CustomPainter {
  final Color lightColor;
  final double brightness;
  final double glowIntensity;

  _LampGlowPainter(this.lightColor, this.brightness, this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    // Position glow to cover behind and around the lamp
    // Glow container: 320x400, starts at top: -60
    // Center should be higher to cover lamp and spread around
    // Bulb is approximately at 35% from top of glow container
    final glowCenter = Offset(size.width / 2, size.height * 0.35);
    final baseOpacity = brightness * glowIntensity;

    // Mix light color with white for more natural warm glow
    final warmWhite = Color.lerp(Colors.white, lightColor, 0.5) ?? lightColor;
    final glowColor = Color.lerp(warmWhite, lightColor, 0.5) ?? lightColor;

    // Layer 1: Extra large soft outer halo (very subtle, natural spread)
    final outerHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.04 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(glowCenter, 130 * brightness, outerHaloPaint);

    // Layer 2: Large soft outer halo (soft spread)
    final largeHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.06 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(glowCenter, 110 * brightness, largeHaloPaint);

    // Layer 3: Medium soft halo (gentle spread around and behind)
    final mediumHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.10 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(glowCenter, 90 * brightness, mediumHaloPaint);

    // Layer 4: Inner soft core (around bulb area)
    final innerCorePaint = Paint()
      ..color = glowColor.withOpacity(0.15 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(glowCenter, 70 * brightness, innerCorePaint);

    // Layer 5: Soft center (natural light source at bulb)
    final centerCorePaint = Paint()
      ..color = glowColor.withOpacity(0.20 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(glowCenter, 50 * brightness, centerCorePaint);

    // Layer 6: Core light (softest point at bulb)
    final coreLightPaint = Paint()
      ..color = glowColor.withOpacity(0.25 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(glowCenter, 30 * brightness, coreLightPaint);
  }

  @override
  bool shouldRepaint(_LampGlowPainter oldDelegate) =>
      oldDelegate.lightColor != lightColor ||
      oldDelegate.brightness != brightness ||
      oldDelegate.glowIntensity != glowIntensity;
}

