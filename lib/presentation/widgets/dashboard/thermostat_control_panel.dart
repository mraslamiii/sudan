import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import 'card_styles.dart';
import 'painters/thermostat_dial_painter.dart';

/// Thermostat Control Panel Widget - Apple-style Minimal Design
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
    this.mode = 'Auto',
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
    _selectedModeIndex = _modesData.indexWhere((m) => m['name'] == widget.mode);
    if (_selectedModeIndex == -1) _selectedModeIndex = 3;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isOn) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThermostatControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      final newIndex = _modesData.indexWhere((m) => m['name'] == widget.mode);
      if (newIndex != -1 && newIndex != _selectedModeIndex) {
        setState(() => _selectedModeIndex = newIndex);
      }
    }
    if (oldWidget.isOn != widget.isOn) {
      if (widget.isOn) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  void _changeTemperature(int delta) {
    HapticFeedback.selectionClick();
    final newTemp = (widget.temperature + delta).clamp(16, 30);
    widget.onTemperatureChanged?.call(newTemp);
  }

  Color get _modeColor => _modesData[_selectedModeIndex]['color'] as Color;

  Map<String, dynamic> _getTemperatureState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.temperature <= 18) return {'text': l10n.cold, 'icon': Icons.ac_unit_rounded};
    if (widget.temperature <= 22) return {'text': l10n.cool, 'icon': Icons.wb_twilight_rounded};
    if (widget.temperature <= 25) return {'text': l10n.comfort, 'icon': Icons.wb_sunny_rounded};
    if (widget.temperature <= 27) return {'text': l10n.warm, 'icon': Icons.wb_incandescent_rounded};
    return {'text': l10n.hot, 'icon': Icons.local_fire_department_rounded};
  }

  void _handleDialInteraction(Offset localPosition, double size) {
    if (!widget.isOn) return;
    
    final center = Offset(size / 2, size / 2);
    final vector = localPosition - center;
    double angleDegrees = math.atan2(vector.dy, vector.dx) * 180 / math.pi;

    angleDegrees = angleDegrees.clamp(-135.0, 135.0);
    final progress = (angleDegrees + 135) / 270;
    final newTemp = (16 + progress * 14).round();

    if (newTemp != widget.temperature) {
      HapticFeedback.selectionClick();
      widget.onTemperatureChanged?.call(newTemp);
    }
  }

  void _handlePointerScroll(PointerScrollEvent event) {
    if (!widget.isOn) return;
    if (event.scrollDelta.dy == 0) return;

    final direction = event.scrollDelta.dy > 0 ? -1 : 1;
    _changeTemperature(direction);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modes = _modes(context);
    final currentIndex = _modesData.indexWhere((m) => m['name'] == widget.mode);
    if (currentIndex != -1 && currentIndex != _selectedModeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedModeIndex = currentIndex);
        }
      });
    }

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
                title: AppLocalizations.of(context)!.thermostat,
                subtitle: widget.isOn
                    ? '${modes[_selectedModeIndex]['displayName']} · ${widget.temperature}°'
                    : 'Off',
                isDark: isDark,
                isCompact: isCompact,
                accentColor: _modeColor,
                isActive: widget.isOn,
                onPowerTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onToggle?.call(!widget.isOn);
                },
              ),
              
              SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space20),

              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Temperature dial
                    Expanded(
                      flex: 5,
                      child: _buildTemperatureDial(context, isDark, isCompact, isVeryCompact),
                    ),
                    SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
                    // Mode selection and controls
                    Expanded(
                      flex: 3,
                      child: _buildModeAndControls(context, isDark, isCompact, isVeryCompact, modes),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemperatureDial(BuildContext context, bool isDark, bool isCompact, bool isVeryCompact) {
    final temperatureState = _getTemperatureState(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.max(1.0, math.min(constraints.maxWidth, constraints.maxHeight));
        if (size <= 0 || !size.isFinite) {
          return const SizedBox.shrink();
        }
        
        final startAngle = -135 * math.pi / 180;
        final normalizedTemp = ((widget.temperature - 16) / 14).clamp(0.0, 1.0);
        final sweepAngle = normalizedTemp * 270 * math.pi / 180;

        return Center(
          child: Listener(
            onPointerSignal: widget.isOn
                ? (event) {
                    if (event is PointerScrollEvent) {
                      _handlePointerScroll(event);
                    }
                  }
                : null,
            child: GestureDetector(
              onTapDown: widget.isOn
                  ? (details) => _handleDialInteraction(details.localPosition, size)
                  : null,
              onPanStart: widget.isOn
                  ? (details) => _handleDialInteraction(details.localPosition, size)
                  : null,
              onPanUpdate: widget.isOn
                  ? (details) => _handleDialInteraction(details.localPosition, size)
                  : null,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = widget.isOn ? _pulseAnimation.value : 1.0;
                  
                  return Transform.scale(
                    scale: scale.isFinite && scale > 0 ? scale : 1.0,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dial painter
                          CustomPaint(
                            size: Size(size, size),
                            painter: ThermostatDialPainter(
                              startAngle: startAngle.isFinite ? startAngle : -135 * math.pi / 180,
                              sweepAngle: sweepAngle.isFinite && sweepAngle >= 0 ? sweepAngle : 0.0,
                              isOn: widget.isOn,
                              modeColor: _modeColor,
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Temperature value
                              AnimatedDefaultTextStyle(
                                duration: CardStyles.normal,
                                style: TextStyle(
                                  fontSize: isVeryCompact ? 28 : (isCompact ? 34 : 42),
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -2,
                                  height: 1,
                                  color: widget.isOn
                                      ? _modeColor
                                      : CardStyles.iconColor(isDark),
                                ),
                                child: Text('${widget.temperature}°'),
                              ),
                              SizedBox(height: isCompact ? 4 : 6),
                              // Status indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    temperatureState['icon'] as IconData,
                                    size: isCompact ? 12 : 14,
                                    color: widget.isOn
                                        ? _modeColor
                                        : CardStyles.iconColor(isDark),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    temperatureState['text'] as String,
                                    style: TextStyle(
                                      fontSize: isCompact ? 11 : 12,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isOn
                                          ? _modeColor
                                          : CardStyles.iconColor(isDark),
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
      },
    );
  }

  Widget _buildModeAndControls(
    BuildContext context,
    bool isDark,
    bool isCompact,
    bool isVeryCompact,
    List<Map<String, dynamic>> modes,
  ) {
    return Column(
      children: [
        // Mode grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemHeight = (constraints.maxHeight - (isCompact ? 4 : 6)) / 2;
              final itemWidth = (constraints.maxWidth - (isCompact ? 4 : 6)) / 2;
              final aspectRatio = (itemWidth / itemHeight).clamp(0.6, 2.5);

              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: isCompact ? 4 : 6,
                crossAxisSpacing: isCompact ? 4 : 6,
                childAspectRatio: aspectRatio,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: modes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mode = entry.value;
                  final isSelected = _selectedModeIndex == index;
                  final color = mode['color'] as Color;

                  return GestureDetector(
                    onTap: widget.isOn
                        ? () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedModeIndex = index);
                            widget.onModeChanged?.call(mode['name'] as String);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: CardStyles.normal,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(isDark ? 0.2 : 0.12)
                            : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mode['icon'] as IconData,
                            size: isVeryCompact ? 14 : (isCompact ? 16 : 18),
                            color: isSelected
                                ? color
                                : CardStyles.iconColor(isDark),
                          ),
                          SizedBox(height: isCompact ? 2 : 4),
                          Text(
                            isVeryCompact
                                ? (mode['displayName'] as String).substring(0, 1)
                                : mode['displayName'] as String,
                            style: TextStyle(
                              fontSize: isVeryCompact ? 9 : (isCompact ? 10 : 11),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? color
                                  : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        
        SizedBox(height: isCompact ? CardStyles.space8 : CardStyles.space12),
        
        // Temperature controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTempButton(
              icon: Icons.remove_rounded,
              onTap: () => _changeTemperature(-1),
              isDark: isDark,
              isCompact: isCompact,
            ),
            SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
            _buildTempButton(
              icon: Icons.add_rounded,
              onTap: () => _changeTemperature(1),
              isDark: isDark,
              isCompact: isCompact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTempButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required bool isCompact,
  }) {
    final size = isCompact ? 32.0 : 38.0;

    return GestureDetector(
      onTap: widget.isOn ? onTap : null,
      child: AnimatedContainer(
        duration: CardStyles.normal,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.isOn
              ? _modeColor.withOpacity(isDark ? 0.15 : 0.1)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isOn
                ? _modeColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: widget.isOn ? _modeColor : CardStyles.iconColor(isDark),
          size: isCompact ? 16 : 18,
        ),
      ),
    );
  }
}
