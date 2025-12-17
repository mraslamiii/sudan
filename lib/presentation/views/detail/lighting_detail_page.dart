import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../../widgets/dashboard/painters/color_wheel_painter.dart';
import '../../widgets/dashboard/painters/lamp_glow_painter.dart';

/// Full-screen detail page for lighting control - Optimized for 9" tablet landscape
class LightingDetailPage extends StatefulWidget {
  const LightingDetailPage({super.key});

  @override
  State<LightingDetailPage> createState() => _LightingDetailPageState();
}

class _LightingDetailPageState extends State<LightingDetailPage>
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

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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

  void _handleColorWheelTouch(Offset localPosition, double size, DeviceViewModel deviceVM) {
    if (!deviceVM.isLedOn) return;
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
    deviceVM.updateLEDColor(HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            _buildHeader(context, isDark, l10n),
            
            // Content - horizontal layout, no scroll
            Expanded(
              child: Consumer<DeviceViewModel>(
                builder: (context, deviceVM, _) {
                  if (!deviceVM.isLedOn) {
                    _fadeController.value = 0;
                  } else {
                    _fadeController.value = 1.0;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Left: Color wheel
                        Expanded(
                          flex: 5,
                          child: _buildColorWheel(context, isDark, deviceVM, screenSize),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Right: Lamp, presets, brightness
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Lamp visual
                              Expanded(
                                flex: 5,
                                child: _buildLampVisual(context, isDark, deviceVM),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Presets
                              Expanded(
                                flex: 2,
                                child: _buildPresetsSection(context, isDark, deviceVM),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Brightness control
                              Expanded(
                                flex: 2,
                                child: _buildBrightnessControl(context, isDark, deviceVM),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSectionBackground(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.getTextColor1(isDark)),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              size: 18,
              color: Color(0xFFFF9500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.lighting,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
          ),
          Consumer<DeviceViewModel>(
            builder: (context, deviceVM, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  deviceVM.setLEDOn(!deviceVM.isLedOn);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: deviceVM.isLedOn ? const Color(0xFFFF9500) : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: deviceVM.isLedOn
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF9500).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    deviceVM.isLedOn ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorWheel(BuildContext context, bool isDark, DeviceViewModel deviceVM, Size screenSize) {
    final size = math.min(screenSize.height * 0.7, screenSize.width * 0.4);
    final centerSize = size * 0.35;

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _handleColorWheelTouch(d.localPosition, size, deviceVM),
        onPanStart: (d) => _handleColorWheelTouch(d.localPosition, size, deviceVM),
        onTapDown: (d) => _handleColorWheelTouch(d.localPosition, size, deviceVM),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: ColorWheelPainter(deviceVM.ledColor, deviceVM.isLedOn),
              ),
              Container(
                width: centerSize,
                height: centerSize,
                decoration: BoxDecoration(
                  color: AppTheme.getSectionBackground(isDark),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLampVisual(BuildContext context, bool isDark, DeviceViewModel deviceVM) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _fadeController]),
      builder: (context, child) {
        final glowIntensity = 0.6 + (_glowController.value * 0.4);
        final fadeValue = _fadeAnimation.value;

        return SizedBox(
          height: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: deviceVM.isLedOn ? 1.0 : 0.4,
                  child: SizedBox(
                    height: 200,
                    child: Image.asset('assets/images/lamp.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              if (deviceVM.isLedOn && fadeValue > 0)
                Positioned.fill(
                  child: Opacity(
                    opacity: fadeValue * 0.5,
                    child: CustomPaint(
                      painter: LampGlowPainter(
                        deviceVM.ledColor,
                        deviceVM.ledBrightness / 100.0,
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

  Widget _buildPresetsSection(BuildContext context, bool isDark, DeviceViewModel deviceVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Presets',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: _presetsData.asMap().entries.map((entry) {
              final index = entry.key;
              final preset = entry.value;
              final isSelected = _selectedPresetIndex == index;
              final color = preset['color'] as Color;
              final name = preset['name'] as String;
              final localizedName = _getPresetLocalizedName(context, name);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: deviceVM.isLedOn
                        ? () {
                            setState(() => _selectedPresetIndex = index);
                            deviceVM.updateLEDPreset(name);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.2)
                            : AppTheme.getSectionBackground(isDark),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizedName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? color
                                  : AppTheme.getSecondaryGray(isDark),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBrightnessControl(BuildContext context, bool isDark, DeviceViewModel deviceVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Brightness',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Text(
              '${deviceVM.ledBrightness}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF9500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: AppTheme.getSecondaryGray(isDark),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: const Color(0xFFFF9500),
                  inactiveTrackColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  thumbColor: const Color(0xFFFF9500),
                ),
                child: Slider(
                  value: deviceVM.ledBrightness.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    deviceVM.updateLEDBrightness(v.round());
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.wb_sunny,
              color: const Color(0xFFFF9500),
              size: 18,
            ),
          ],
        ),
      ],
    );
  }
}
