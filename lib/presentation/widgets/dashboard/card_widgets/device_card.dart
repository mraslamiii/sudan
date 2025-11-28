import 'package:flutter/material.dart';
import 'package:sudan/data/models/dashboard_card_model.dart';
import '../base_dashboard_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_colors.dart';

class DeviceCard extends StatefulWidget {
  final DashboardCardModel card;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final Function(CardSize)? onResize;
  final Function(Map<String, dynamic>)? onDataUpdate;

  const DeviceCard({
    super.key,
    required this.card,
    this.isEditMode = false,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onResize,
    this.onDataUpdate,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _iconBackgroundAnimation;
  late Animation<Color?> _iconColorAnimation;

  String get _name => widget.card.data['name'] as String? ?? _getDefaultName();
  bool get _isOn => widget.card.data['isOn'] as bool? ?? false;
  String get _status => widget.card.data['status'] as String? ?? (_isOn ? 'On' : 'Off');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize with default colors, will be updated in didChangeDependencies
    _iconBackgroundAnimation = ColorTween(
      begin: ThemeColors.lightGrayLight,
      end: ThemeColors.primaryBlueLight.withOpacity(0.2),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _iconColorAnimation = ColorTween(
      begin: ThemeColors.secondaryGrayLight,
      end: ThemeColors.primaryBlueLight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (_isOn) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update animations with theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _iconBackgroundAnimation = ColorTween(
      begin: AppTheme.getIconBackground(isDark),
      end: isDark 
          ? Colors.white.withOpacity(0.2)
          : ThemeColors.primaryBlueLight.withOpacity(0.12),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _iconColorAnimation = ColorTween(
      begin: AppTheme.getSecondaryGray(isDark),
      end: isDark 
          ? Colors.white
          : ThemeColors.primaryBlueLight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(DeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.data['isOn'] != widget.card.data['isOn']) {
      if (_isOn) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getDefaultName() {
    switch (widget.card.type) {
      case CardType.light:
        return 'Light';
      case CardType.curtain:
        return 'Curtains';
      case CardType.thermostat:
        return 'Thermostat';
      case CardType.security:
        return 'Security';
      case CardType.music:
        return 'Music';
      case CardType.tv:
        return 'TV';
      case CardType.fan:
        return 'Fan';
      case CardType.camera:
        return 'Camera';
      default:
        return 'Device';
    }
  }

  IconData _getIcon() {
    switch (widget.card.type) {
      case CardType.light:
        return Icons.lightbulb_rounded;
      case CardType.curtain:
        return Icons.curtains_rounded;
      case CardType.thermostat:
        return Icons.thermostat_rounded;
      case CardType.security:
        return Icons.shield_rounded;
      case CardType.music:
        return Icons.music_note_rounded;
      case CardType.tv:
        return Icons.tv_rounded;
      case CardType.fan:
        return Icons.toys_rounded;
      case CardType.camera:
        return Icons.videocam_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDashboardCard(
      card: widget.card,
      isEditMode: widget.isEditMode,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onDelete: widget.onDelete,
      onResize: widget.onResize,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final baseGradientStart = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF);
          final baseGradientEnd = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8F8FA);
          final activeGradientStart = isDark 
              ? ThemeColors.primaryBlueDark.withOpacity(0.15)
              : ThemeColors.primaryBlueLight.withOpacity(0.08);
          final activeGradientEnd = isDark 
              ? ThemeColors.primaryBlueDark.withOpacity(0.25)
              : ThemeColors.primaryBlueLight.withOpacity(0.15);
          
          // Active colors for light/dark mode
          final activeIconBg = isDark 
              ? Colors.white.withOpacity(0.2)
              : ThemeColors.primaryBlueLight.withOpacity(0.12);
          final activeIconColor = isDark 
              ? Colors.white
              : ThemeColors.primaryBlueLight;
          final activeTextColor = isDark 
              ? Colors.white
              : ThemeColors.primaryBlueLight;
          final activeStatusColor = isDark 
              ? Colors.white.withOpacity(0.9)
              : ThemeColors.primaryBlueLight.withOpacity(0.8);
          final activeDotColor = isDark 
              ? Colors.white
              : ThemeColors.primaryBlueLight;
          final activeBorderColor = isDark 
              ? ThemeColors.primaryBlueDark.withOpacity(0.5)
              : ThemeColors.primaryBlueLight.withOpacity(0.3);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(baseGradientStart, activeGradientStart, _glowAnimation.value) ?? baseGradientStart,
                  Color.lerp(baseGradientEnd, activeGradientEnd, _glowAnimation.value) ?? baseGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.lerp(
                  isDark 
                      ? Colors.white.withOpacity(0.08) 
                      : Colors.black.withOpacity(0.06),
                  activeBorderColor,
                  _glowAnimation.value,
                ) ?? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 120;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                        Flexible(
                          child: Transform.scale(
                            scale: 0.95 + (0.05 * _glowAnimation.value),
                            child: Container(
                              padding: EdgeInsets.all(isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                                color: _isOn
                                    ? Color.lerp(
                                        _iconBackgroundAnimation.value ?? AppTheme.getIconBackground(isDark),
                                        activeIconBg,
                                        _glowAnimation.value,
                                      )
                                    : (isDark 
                                        ? AppTheme.getBorderGray(isDark).withOpacity(0.5)
                                        : AppTheme.getLightGray(isDark)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isOn
                                    ? [
                                        BoxShadow(
                                          color: (isDark ? Colors.white : ThemeColors.primaryBlueLight)
                                              .withOpacity((isDark ? 0.2 : 0.15) * _glowAnimation.value),
                                          blurRadius: 12 * _glowAnimation.value,
                                          spreadRadius: 2 * _glowAnimation.value,
                                        ),
                                      ]
                                    : null,
                  ),
                  child: Icon(
                    _getIcon(),
                                size: isCompact ? 18 : 22,
                                color: Color.lerp(
                                  _iconColorAnimation.value ?? AppTheme.getSecondaryGray(isDark),
                                  activeIconColor,
                                  _glowAnimation.value,
                                ),
                              ),
                            ),
                  ),
                ),
                        if (!isCompact) ...[
                const Spacer(),
                          if (!widget.isEditMode)
                  Transform.scale(
                              scale: 0.7,
                    child: Switch(
                      value: _isOn,
                      onChanged: (value) {
                                  widget.onDataUpdate?.call({'isOn': value});
                      },
                                activeColor: ThemeColors.successGreen,
                                activeTrackColor: ThemeColors.successGreen.withOpacity(0.3),
                                inactiveThumbColor: Theme.of(context).cardColor,
                                inactiveTrackColor: AppTheme.getBorderGray(
                                    Theme.of(context).brightness == Brightness.dark),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ] else if (!widget.isEditMode) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              widget.onDataUpdate?.call({'isOn': !_isOn});
                            },
                            child: Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return Container(
                                  width: 32,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _isOn
                                        ? ThemeColors.successGreen
                                        : AppTheme.getBorderGray(isDark),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    alignment: _isOn ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getSectionBackground(isDark),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                    ),
                                        ],
                  ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                ],
              ),
            ),
            const Spacer(),
            Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 17,
                          fontWeight: FontWeight.w600,
                          color: Color.lerp(
                            AppTheme.getTextColor1(isDark),
                            activeTextColor,
                            _glowAnimation.value,
                          ),
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        child: Text(
                          _name,
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 6),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  AppTheme.getInactiveGray(isDark),
                                  activeDotColor,
                                  _glowAnimation.value,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: _isOn
                                    ? [
                                        BoxShadow(
                                          color: (isDark ? Colors.white : ThemeColors.primaryBlueLight)
                                              .withOpacity((isDark ? 0.6 : 0.4) * _glowAnimation.value),
                                          blurRadius: 4 * _glowAnimation.value,
                                          spreadRadius: 1 * _glowAnimation.value,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 6),
            Flexible(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color.lerp(
                                    AppTheme.getSecondaryGray(isDark),
                                    activeStatusColor,
                                    _glowAnimation.value,
                                  ),
                                ),
              child: Text(
                _status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                                ),
              ),
            ),
          ],
        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
