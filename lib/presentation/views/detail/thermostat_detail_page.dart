import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../../widgets/dashboard/painters/thermostat_dial_painter.dart';
import '../../widgets/dashboard/card_styles.dart' as detail_styles;

/// Full-screen detail page for thermostat control - Optimized for 9" tablet landscape
class ThermostatDetailPage extends StatefulWidget {
  const ThermostatDetailPage({super.key});

  @override
  State<ThermostatDetailPage> createState() => _ThermostatDetailPageState();
}

class _ThermostatDetailPageState extends State<ThermostatDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _selectedModeIndex = 0;

  static const List<Map<String, dynamic>> _modesData = [
    {'name': 'Cool', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF5AC8FA)},
    {'name': 'Heat', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFFF9F0A)},
    {'name': 'Fan', 'icon': Icons.air_rounded, 'color': Color(0xFF8E8E93)},
    {'name': 'Auto', 'icon': Icons.sync_rounded, 'color': Color(0xFF30D158)},
  ];

  List<Map<String, dynamic>> _modes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {..._modesData[0], 'displayName': l10n.cool},
      {..._modesData[1], 'displayName': l10n.heat},
      {..._modesData[2], 'displayName': l10n.fan},
      {..._modesData[3], 'displayName': l10n.auto},
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _changeTemperature(int delta, DeviceViewModel deviceVM) {
    HapticFeedback.selectionClick();
    final newTemp = (deviceVM.targetTemperature + delta).clamp(16, 30);
    deviceVM.setTemperature(newTemp);
  }

  Color _getModeColor(int index) => _modesData[index]['color'] as Color;

  Map<String, dynamic> _getTemperatureState(BuildContext context, int temperature) {
    final l10n = AppLocalizations.of(context)!;
    if (temperature <= 18) return {'text': l10n.cold, 'icon': Icons.ac_unit_rounded};
    if (temperature <= 22) return {'text': l10n.cool, 'icon': Icons.wb_twilight_rounded};
    if (temperature <= 25) return {'text': l10n.comfort, 'icon': Icons.wb_sunny_rounded};
    if (temperature <= 27) return {'text': l10n.warm, 'icon': Icons.wb_incandescent_rounded};
    return {'text': l10n.hot, 'icon': Icons.local_fire_department_rounded};
  }

  void _handleDialInteraction(Offset localPosition, double size, DeviceViewModel deviceVM) {
    if (!deviceVM.isThermostatOn) return;
    
    final center = Offset(size / 2, size / 2);
    final vector = localPosition - center;
    double angleDegrees = math.atan2(vector.dy, vector.dx) * 180 / math.pi;

    angleDegrees = angleDegrees.clamp(-135.0, 135.0);
    final progress = (angleDegrees + 135) / 270;
    final newTemp = (16 + progress * 14).round();

    if (newTemp != deviceVM.targetTemperature) {
      HapticFeedback.selectionClick();
      deviceVM.setTemperature(newTemp);
    }
  }

  void _handlePointerScroll(PointerScrollEvent event, DeviceViewModel deviceVM) {
    if (!deviceVM.isThermostatOn) return;
    if (event.scrollDelta.dy == 0) return;

    final direction = event.scrollDelta.dy > 0 ? -1 : 1;
    _changeTemperature(direction, deviceVM);
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
                  if (deviceVM.isThermostatOn) {
                    _pulseController.repeat(reverse: true);
                  } else {
                    _pulseController.stop();
                    _pulseController.value = 0;
                  }

                  final modes = _modes(context);
                  final currentIndex = _modesData.indexWhere((m) => m['name'] == deviceVM.thermostatMode);
                  if (currentIndex != -1 && currentIndex != _selectedModeIndex) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedModeIndex = currentIndex);
                      }
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Left: Temperature dial
                        Expanded(
                          flex: 5,
                          child: _buildTemperatureDial(context, isDark, deviceVM, screenSize),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Right: Mode selection and controls
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mode selection
                              Expanded(
                                flex: 5,
                                child: _buildModeSelection(context, isDark, deviceVM, modes),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Temperature controls
                              Expanded(
                                flex: 2,
                                child: _buildTemperatureControls(context, isDark, deviceVM),
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
          Consumer<DeviceViewModel>(
            builder: (context, deviceVM, _) {
              final modeColor = _getModeColor(_selectedModeIndex);
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: modeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.thermostat_rounded,
                  size: 18,
                  color: modeColor,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.thermostat,
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
                  deviceVM.setThermostatOn(!deviceVM.isThermostatOn);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: deviceVM.isThermostatOn
                        ? _getModeColor(_selectedModeIndex)
                        : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: deviceVM.isThermostatOn
                        ? [
                            BoxShadow(
                              color: _getModeColor(_selectedModeIndex).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    deviceVM.isThermostatOn
                        ? Icons.power_settings_new
                        : Icons.power_settings_new_outlined,
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

  Widget _buildTemperatureDial(
    BuildContext context,
    bool isDark,
    DeviceViewModel deviceVM,
    Size screenSize,
  ) {
    final temperatureState = _getTemperatureState(context, deviceVM.targetTemperature);
    final modeColor = _getModeColor(_selectedModeIndex);
    final size = math.min(screenSize.height * 0.7, screenSize.width * 0.4);
    final startAngle = -135 * math.pi / 180;
    final normalizedTemp = ((deviceVM.targetTemperature - 16) / 14).clamp(0.0, 1.0);
    final sweepAngle = normalizedTemp * 270 * math.pi / 180;

    return Center(
      child: Listener(
        onPointerSignal: deviceVM.isThermostatOn
            ? (event) {
                if (event is PointerScrollEvent) {
                  _handlePointerScroll(event, deviceVM);
                }
              }
            : null,
        child: GestureDetector(
          onTapDown: deviceVM.isThermostatOn
              ? (details) => _handleDialInteraction(details.localPosition, size, deviceVM)
              : null,
          onPanStart: deviceVM.isThermostatOn
              ? (details) => _handleDialInteraction(details.localPosition, size, deviceVM)
              : null,
          onPanUpdate: deviceVM.isThermostatOn
              ? (details) => _handleDialInteraction(details.localPosition, size, deviceVM)
              : null,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = deviceVM.isThermostatOn ? _pulseAnimation.value : 1.0;
              
              return Transform.scale(
                scale: scale.isFinite && scale > 0 ? scale : 1.0,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: ThermostatDialPainter(
                          startAngle: startAngle.isFinite ? startAngle : -135 * math.pi / 180,
                          sweepAngle: sweepAngle.isFinite && sweepAngle >= 0 ? sweepAngle : 0.0,
                          isOn: deviceVM.isThermostatOn,
                          modeColor: modeColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: detail_styles.CardStyles.normal,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -3,
                              height: 1,
                              color: deviceVM.isThermostatOn
                                  ? modeColor
                                  : AppTheme.getSecondaryGray(isDark),
                            ),
                            child: Text('${deviceVM.targetTemperature}°'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                temperatureState['icon'] as IconData,
                                size: 18,
                                color: deviceVM.isThermostatOn
                                    ? modeColor
                                    : AppTheme.getSecondaryGray(isDark),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                temperatureState['text'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: deviceVM.isThermostatOn
                                      ? modeColor
                                      : AppTheme.getSecondaryGray(isDark),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection(
    BuildContext context,
    bool isDark,
    DeviceViewModel deviceVM,
    List<Map<String, dynamic>> modes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: modes.asMap().entries.map((entry) {
              final index = entry.key;
              final mode = entry.value;
              final isSelected = _selectedModeIndex == index;
              final color = mode['color'] as Color;

              return GestureDetector(
                onTap: deviceVM.isThermostatOn
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedModeIndex = index);
                        deviceVM.updateThermostatMode(mode['name'] as String);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: detail_styles.CardStyles.normal,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(isDark ? 0.2 : 0.12)
                        : AppTheme.getSectionBackground(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mode['icon'] as IconData,
                        size: 20,
                        color: isSelected ? color : AppTheme.getSecondaryGray(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mode['displayName'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? color
                              : AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureControls(BuildContext context, bool isDark, DeviceViewModel deviceVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTempButton(
          icon: Icons.remove_rounded,
          onTap: () => _changeTemperature(-1, deviceVM),
          isDark: isDark,
          deviceVM: deviceVM,
        ),
        const SizedBox(width: 24),
        _buildTempButton(
          icon: Icons.add_rounded,
          onTap: () => _changeTemperature(1, deviceVM),
          isDark: isDark,
          deviceVM: deviceVM,
        ),
      ],
    );
  }

  Widget _buildTempButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required DeviceViewModel deviceVM,
  }) {
    final modeColor = _getModeColor(_selectedModeIndex);

    return GestureDetector(
      onTap: deviceVM.isThermostatOn ? onTap : null,
      child: AnimatedContainer(
        duration: detail_styles.CardStyles.normal,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: deviceVM.isThermostatOn
              ? modeColor.withOpacity(isDark ? 0.15 : 0.1)
              : AppTheme.getSectionBackground(isDark),
          shape: BoxShape.circle,
          border: Border.all(
            color: deviceVM.isThermostatOn
                ? modeColor.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: deviceVM.isThermostatOn ? modeColor : AppTheme.getSecondaryGray(isDark),
          size: 24,
        ),
      ),
    );
  }
}
