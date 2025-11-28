import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import '../../../core/theme/theme_colors.dart';

class ThermostatControlPanel extends StatefulWidget {
  final int temperature;
  final String mode;
  final bool isOn;
  final Function(int)? onTemperatureChanged;
  final Function(String)? onModeChanged;
  final Function(bool)? onToggle;

  const ThermostatControlPanel({
    super.key,
    this.temperature = 25,
    this.mode = 'Mild',
    this.isOn = true,
    this.onTemperatureChanged,
    this.onModeChanged,
    this.onToggle,
  });

  @override
  State<ThermostatControlPanel> createState() => _ThermostatControlPanelState();
}

class _ThermostatControlPanelState extends State<ThermostatControlPanel>
    with SingleTickerProviderStateMixin {
  late int _temperature;
  late String _mode;
  late bool _isOn;
  late AnimationController _pulseController;
  late WheelPickerController _modePickerController;
  int _selectedModeIndex = 0;

  final List<Map<String, dynamic>> _modes = [
    {'name': 'Cool', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF5AC8FA)},
    {'name': 'Heat', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFFF9500)},
    {'name': 'Fan', 'icon': Icons.air_rounded, 'color': Color(0xFF8E8E93)},
    {'name': 'Auto', 'icon': Icons.sync_rounded, 'color': Color(0xFF34C759)},
  ];

  @override
  void initState() {
    super.initState();
    _temperature = widget.temperature;
    _mode = widget.mode;
    _isOn = widget.isOn;
    _selectedModeIndex = _modes.indexWhere((m) => m['name'] == _mode);
    if (_selectedModeIndex == -1) _selectedModeIndex = 0;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _modePickerController = WheelPickerController(
      itemCount: _modes.length,
      initialIndex: _selectedModeIndex,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _modePickerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThermostatControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temperature != widget.temperature) {
      _temperature = widget.temperature;
    }
    if (oldWidget.mode != widget.mode) {
      _mode = widget.mode;
      final newIndex = _modes.indexWhere((m) => m['name'] == _mode);
      if (newIndex != -1 && newIndex != _selectedModeIndex) {
        final oldIndex = _selectedModeIndex;
        _selectedModeIndex = newIndex;
        // Shift to the new index
        final diff = newIndex - oldIndex;
        if (diff > 0) {
          for (int i = 0; i < diff; i++) {
            _modePickerController.shiftDown();
          }
        } else if (diff < 0) {
          for (int i = 0; i < -diff; i++) {
            _modePickerController.shiftUp();
          }
        }
      }
    }
    if (oldWidget.isOn != widget.isOn) {
      _isOn = widget.isOn;
    }
  }

  void _changeTemperature(int delta) {
    setState(() {
      _temperature = (_temperature + delta).clamp(16, 30);
    });
    widget.onTemperatureChanged?.call(_temperature);
  }

  // Get color based on temperature value
  Color _getTemperatureColor() {
    if (_temperature <= 18) {
      // Cold - Blue
      return const Color(0xFF5AC8FA);
    } else if (_temperature <= 22) {
      // Cool - Light Blue
      return const Color(0xFF64D2FF);
    } else if (_temperature <= 25) {
      // Moderate - Green
      return const Color(0xFF34C759);
    } else if (_temperature <= 27) {
      // Warm - Yellow/Orange
      return const Color(0xFFFFCC00);
    } else {
      // Hot - Red/Orange
      return const Color(0xFFFF9500);
    }
  }

  // Get state text and icon based on temperature
  Map<String, dynamic> _getTemperatureState() {
    if (_temperature <= 18) {
      return {'text': 'Cold', 'icon': Icons.ac_unit_rounded};
    } else if (_temperature <= 22) {
      return {'text': 'Cool', 'icon': Icons.wb_twilight_rounded};
    } else if (_temperature <= 25) {
      return {'text': 'Comfort', 'icon': Icons.wb_sunny_rounded};
    } else if (_temperature <= 27) {
      return {'text': 'Warm', 'icon': Icons.wb_incandescent_rounded};
    } else {
      return {'text': 'Hot', 'icon': Icons.local_fire_department_rounded};
    }
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
              // Header
            Row(
                children: [
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thermostat',
                        style: TextStyle(
                        fontSize: 28,
                          fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    const SizedBox(height: 4),
                      Text(
                        'Samsung Thermostat \'02',
                        style: TextStyle(
                        fontSize: 14,
                          fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                // Power switch
                GestureDetector(
                  onTap: () {
                      setState(() {
                      _isOn = !_isOn;
                      });
                    widget.onToggle?.call(_isOn);
                    },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _isOn ? ThemeColors.successGreen : Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left: _isOn ? 26 : 2,
                          top: 2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left: Temperature dial
                  Expanded(
                    flex: 2,
                    child: _buildTemperatureDial(isDark),
                  ),
                  const SizedBox(width: 24),

                  // Right: Mode selection and controls
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Mode selection header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
              
                        // Mode selection (scrollable) - Now has more space
                        Expanded(
                          child: _buildModeSelection(isDark),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Temperature controls - Moved to bottom, horizontal and smaller
                        _buildTemperatureControls(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureDial(bool isDark) {
    final startAngle = -135 * math.pi / 180;
    final normalizedTemp = (_temperature - 16) / (30 - 16);
    final sweepAngle = normalizedTemp * 270 * math.pi / 180;
    final temperatureColor = _getTemperatureColor();
    final temperatureState = _getTemperatureState();

    return Center(
                child: SizedBox(
        width: 240,
        height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
            // Dial background
                      CustomPaint(
              size: const Size(240, 240),
              painter: _PremiumThermostatDialPainter(
                          startAngle: startAngle,
                          sweepAngle: sweepAngle,
                isOn: _isOn,
                modeColor: temperatureColor,
                        ),
                      ),

            // Temperature display
            Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                    fontSize: 64,
                              fontWeight: FontWeight.w300,
                    color: _isOn
                        ? temperatureColor
                        : (isDark ? Colors.white38 : Colors.black38),
                              height: 1,
                    letterSpacing: -2,
                  ),
                  child: Text('$_temperature°'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      temperatureState['icon'] as IconData,
                      size: 16,
                      color: _isOn
                          ? temperatureColor
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    const SizedBox(width: 6),
                Text(
                      temperatureState['text'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isOn
                            ? temperatureColor
                        : (isDark ? Colors.white38 : Colors.black38),
                            ),
                    ),
                  ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
              
  Widget _buildTemperatureControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
                children: [
        // Decrease button
        _buildControlButton(
          icon: Icons.remove_rounded,
          onTap: () => _changeTemperature(-1),
          isDark: isDark,
              ),
        const SizedBox(width: 12),
        // Increase button
        _buildControlButton(
          icon: Icons.add_rounded,
          onTap: () => _changeTemperature(1),
          isDark: isDark,
        ),
            ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final temperatureColor = _getTemperatureColor();
    
    return GestureDetector(
      onTap: _isOn ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isOn
              ? temperatureColor.withOpacity(0.15)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
          shape: BoxShape.circle,
          border: Border.all(
            color: _isOn
                ? temperatureColor.withOpacity(0.4)
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: _isOn
              ? temperatureColor
              : (isDark ? Colors.white38 : Colors.black38),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildModeSelection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF8F8FA);
    final gradientStart = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF8F8FA);
    final gradientEnd = isDark ? const Color(0xFF1F1F23) : const Color(0xFFFFFFFF);
    
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.06) 
                : Colors.black.withOpacity(0.04),
            width: 1,
          ),
        ),
        child: Stack(
        children: [
          // Wheel Picker
          WheelPicker(
            controller: _modePickerController,
            builder: (context, index) {
              final mode = _modes[index];
              final isSelected = _selectedModeIndex == index;
              
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  mode['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                    letterSpacing: 0.5,
                  ),
                ),
              );
            },
            selectedIndexColor: _isOn
                ? (_modes[_selectedModeIndex]['color'] as Color)
                : (isDark ? Colors.white38 : Colors.black38),
            onIndexChanged: _isOn
                ? (index, interactionType) {
                    final newMode = _modes[index]['name'] as String;
                    if (newMode != _mode) {
        setState(() {
                        _mode = newMode;
                        _selectedModeIndex = index;
        });
                  widget.onModeChanged?.call(_mode);
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
          
          // Top fade gradient with chevron
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 50,
            child: IgnorePointer(
              child: Container(
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgColor,
                      bgColor.withOpacity(0.0),
                    ],
                  ),
                ),
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
          ),
          
          // Bottom fade gradient with chevron
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      bgColor,
                      bgColor.withOpacity(0.0),
                    ],
                  ),
                ),
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
          ),
        ],
        ),
      ),
    );
  }
}

class _PremiumThermostatDialPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final bool isOn;
  final Color modeColor;

  _PremiumThermostatDialPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.isOn,
    required this.modeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background track
    final backgroundPaint = Paint()
      ..color = isOn
          ? const Color(0xFF2C2C2E).withOpacity(0.3)
          : const Color(0xFF2C2C2E).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -135 * math.pi / 180,
      270 * math.pi / 180,
      false,
      backgroundPaint,
    );

    if (isOn) {
      // Active track with gradient
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          modeColor,
          modeColor.withOpacity(0.7),
        ],
      );

    final activePaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
      ..style = PaintingStyle.stroke
        ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );

      // Handle with glow
    final handleAngle = startAngle + sweepAngle;
    final handleX = center.dx + radius * math.cos(handleAngle);
    final handleY = center.dy + radius * math.sin(handleAngle);
    final handlePos = Offset(handleX, handleY);

      // Outer glow
      final glowPaint = Paint()
        ..color = modeColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(handlePos, 16, glowPaint);

      // Handle
      final handleGradient = RadialGradient(
        colors: [
          Colors.white,
          modeColor,
        ],
      );
    final handlePaint = Paint()
        ..shader = handleGradient.createShader(
          Rect.fromCircle(center: handlePos, radius: 12),
        );
      canvas.drawCircle(handlePos, 12, handlePaint);
    
      // Handle border
    final handleBorderPaint = Paint()
        ..color = modeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      canvas.drawCircle(handlePos, 12, handleBorderPaint);
    }

    // Temperature markers
    if (isOn) {
      final markerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      for (int i = 0; i <= 14; i++) {
        final angle = -135 + (i / 14) * 270;
        final angleRad = angle * math.pi / 180;

        final markerX = center.dx + radius * math.cos(angleRad);
        final markerY = center.dy + radius * math.sin(angleRad);
        final markerPos = Offset(markerX, markerY);

        // Draw marker
        if (i % 2 == 0) {
          // Major marker
          canvas.drawCircle(markerPos, 3, markerPaint);
        } else {
          // Minor marker
          canvas.drawCircle(markerPos, 1.5, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PremiumThermostatDialPainter oldDelegate) =>
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.isOn != isOn ||
      oldDelegate.modeColor != modeColor;
}
