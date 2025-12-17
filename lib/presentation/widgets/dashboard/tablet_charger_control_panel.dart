import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Tablet Charger Control Panel Widget - Fully Responsive
/// Controls tablet charging and discharging with beautiful UI
class TabletChargerControlPanel extends StatefulWidget {
  final int batteryLevel; // 0-100
  final bool isCharging;
  final bool isDischarging;
  final bool isConnected;
  final Function()? onCharge;
  final Function()? onDischarge;
  final Function(bool)? onToggle;

  const TabletChargerControlPanel({
    super.key,
    this.batteryLevel = 75,
    this.isCharging = false,
    this.isDischarging = false,
    this.isConnected = true,
    this.onCharge,
    this.onDischarge,
    this.onToggle,
  });

  @override
  State<TabletChargerControlPanel> createState() => _TabletChargerControlPanelState();
}

class _TabletChargerControlPanelState extends State<TabletChargerControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _chargeAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _chargeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _chargeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _chargeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chargeAnimationController, curve: Curves.easeInOut),
    );

    if (widget.isCharging) {
      _chargeAnimationController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chargeAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TabletChargerControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCharging != widget.isCharging) {
      if (widget.isCharging) {
        _chargeAnimationController.repeat();
      } else {
        _chargeAnimationController.stop();
        _chargeAnimationController.reset();
      }
    }
  }

  Color _getBatteryColor() {
    if (widget.batteryLevel > 50) {
      return ThemeColors.successGreen;
    } else if (widget.batteryLevel > 20) {
      return ThemeColors.amber;
    } else {
      return ThemeColors.errorRed;
    }
  }

  String _getBatteryStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.isCharging) return l10n.charging;
    if (widget.isDischarging) return l10n.discharging;
    if (widget.batteryLevel > 80) return l10n.fullCharge;
    if (widget.batteryLevel > 50) return l10n.goodCharge;
    if (widget.batteryLevel > 20) return l10n.lowCharge;
    return l10n.criticalCharge;
  }

  // Remove unused variable
  // bool isActive is not used, but we keep it for future use

  IconData _getBatteryIcon() {
    if (widget.isCharging) return Icons.battery_charging_full_rounded;
    if (widget.batteryLevel > 80) return Icons.battery_full_rounded;
    if (widget.batteryLevel > 50) return Icons.battery_6_bar_rounded;
    if (widget.batteryLevel > 20) return Icons.battery_3_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final batteryColor = _getBatteryColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 280;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Size based on content
          children: [
            // Header with power button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tabletCharging,
                        style: TextStyle(
                          fontSize: isCompact ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor1(isDark),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getBatteryStatus(context),
                        style: TextStyle(
                          fontSize: isCompact ? 10 : 11,
                          color: AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                // Power button
                GestureDetector(
                  onTap: () => widget.onToggle?.call(!widget.isConnected),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCompact ? 32 : 38,
                    height: isCompact ? 32 : 38,
                    decoration: BoxDecoration(
                      color: widget.isConnected ? batteryColor : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: widget.isConnected
                          ? [
                              BoxShadow(
                                color: batteryColor.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.isConnected
                          ? Icons.power_settings_new
                          : Icons.power_settings_new_outlined,
                      color: Colors.white,
                      size: isCompact ? 16 : 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 6 : 8),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Battery indicator - larger
                  Expanded(
                    flex: 5,
                    child: _buildBatteryIndicator(isDark, isCompact, batteryColor),
                  ),
                  SizedBox(width: isCompact ? 4 : 6),
                  // Control buttons - compact
                  Expanded(
                    flex: 3,
                    child: _buildControlButtons(isDark, isCompact, batteryColor),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBatteryIndicator(bool isDark, bool isCompact, Color batteryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isCharging ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        batteryColor.withOpacity(widget.isConnected ? 0.3 : 0.1),
                        batteryColor.withOpacity(widget.isConnected ? 0.15 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Battery level ring
                      SizedBox(
                        width: size * 0.85,
                        height: size * 0.85,
                        child: CircularProgressIndicator(
                          value: widget.batteryLevel / 100,
                          strokeWidth: isCompact ? 8 : 10,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isConnected ? batteryColor : Colors.grey,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Battery icon and percentage
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _chargeAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: widget.isCharging
                                    ? _chargeAnimation.value * 2 * math.pi
                                    : 0,
                                child: Icon(
                                  _getBatteryIcon(),
                                  size: isCompact ? 32 : 40,
                                  color: widget.isConnected
                                      ? batteryColor
                                      : AppTheme.getSecondaryGray(isDark),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isCompact ? 4 : 6),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isCompact ? 24 : 32,
                              fontWeight: FontWeight.w300,
                              color: widget.isConnected
                                  ? batteryColor
                                  : AppTheme.getSecondaryGray(isDark),
                              height: 1,
                            ),
                            child: Text('${widget.batteryLevel}%'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(bool isDark, bool isCompact, Color batteryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Charge button
        _buildActionButton(
          icon: Icons.battery_charging_full_rounded,
          label: AppLocalizations.of(context)!.charge,
          color: ThemeColors.successGreen,
          isActive: widget.isCharging,
          isDark: isDark,
          isCompact: isCompact,
          onTap: widget.isConnected && !widget.isCharging
              ? () => widget.onCharge?.call()
              : null,
        ),
        SizedBox(height: isCompact ? 6 : 10),
        // Discharge button
        _buildActionButton(
          icon: Icons.battery_std_rounded,
          label: AppLocalizations.of(context)!.discharging,
          color: ThemeColors.amber,
          isActive: widget.isDischarging,
          isDark: isDark,
          isCompact: isCompact,
          onTap: widget.isConnected && !widget.isDischarging
              ? () => widget.onDischarge?.call()
              : null,
        ),
        SizedBox(height: isCompact ? 6 : 10),
        // Status indicator - minimal design
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 8,
            vertical: isCompact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: (widget.isCharging
                    ? ThemeColors.successGreen
                    : widget.isDischarging
                        ? ThemeColors.amber
                        : AppTheme.getSecondaryGray(isDark))
                .withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: (widget.isCharging
                      ? ThemeColors.successGreen
                      : widget.isDischarging
                          ? ThemeColors.amber
                          : AppTheme.getSecondaryGray(isDark))
                  .withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isCompact ? 5 : 6,
                height: isCompact ? 5 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCharging
                      ? ThemeColors.successGreen
                      : widget.isDischarging
                          ? ThemeColors.amber
                          : AppTheme.getSecondaryGray(isDark),
                ),
              ),
              SizedBox(width: isCompact ? 3 : 4),
              Flexible(
                child: Text(
                  widget.isCharging
                      ? AppLocalizations.of(context)!.activeCharging
                      : widget.isDischarging
                          ? AppLocalizations.of(context)!.activeDischarging
                          : AppLocalizations.of(context)!.off,
                  style: TextStyle(
                    fontSize: isCompact ? 8 : 9,
                    fontWeight: FontWeight.w600,
                    color: widget.isCharging
                        ? ThemeColors.successGreen
                        : widget.isDischarging
                            ? ThemeColors.amber
                            : AppTheme.getSecondaryGray(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required bool isDark,
    required bool isCompact,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: isCompact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.85),
                  ],
                )
              : LinearGradient(
                  colors: [
                    (isDark ? Colors.white : Colors.black).withOpacity(0.10),
                    (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.6)
                : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.12)),
            width: 1.8,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCompact ? 14 : 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            SizedBox(width: isCompact ? 3 : 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

