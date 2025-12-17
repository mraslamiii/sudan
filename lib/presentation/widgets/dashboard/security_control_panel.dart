import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/pin_protection.dart';
import '../../../data/data_sources/local/pin/pin_service.dart';
import 'card_styles.dart';

/// Security Control Panel Widget - Apple-style Design
class SecurityControlPanel extends StatefulWidget {
  final bool isActive;
  final String status; // 'Armed', 'Disarmed', 'Triggered'
  final List<String>? zones;
  final Function(bool)? onArmDisarm;
  final Function(String)? onStatusChanged;

  const SecurityControlPanel({
    super.key,
    this.isActive = false,
    this.status = 'Disarmed',
    this.zones,
    this.onArmDisarm,
    this.onStatusChanged,
  });

  @override
  State<SecurityControlPanel> createState() => _SecurityControlPanelState();
}

class _SecurityControlPanelState extends State<SecurityControlPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == 'Triggered') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SecurityControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'Triggered' && oldWidget.status != 'Triggered') {
      _pulseController.repeat(reverse: true);
    } else if (widget.status != 'Triggered' && oldWidget.status == 'Triggered') {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.status) {
      case 'Armed':
        return CardStyles.securityAccent;
      case 'Triggered':
        return CardStyles.accentRed;
      default:
        return CardStyles.accentGreen;
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (widget.status) {
      case 'Armed':
        return l10n?.arm ?? 'Armed';
      case 'Triggered':
        return 'Alert!';
      default:
        return l10n?.disarm ?? 'Disarmed';
    }
  }

  IconData get _statusIcon {
    switch (widget.status) {
      case 'Armed':
        return Icons.shield_rounded;
      case 'Triggered':
        return Icons.warning_amber_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  Future<void> _handleStatusChange(String newStatus) async {
    // Require User PIN verification for security status changes
    final verified = await PinProtection.requirePinVerification(
      context,
      title: 'Security PIN Required',
      subtitle: 'Enter PIN to change security status',
      pinType: PinType.user, // Accept both admin and user PINs
    );
    
    if (!verified) {
      return; // User cancelled or PIN verification failed
    }
    
    HapticFeedback.mediumImpact();
    widget.onStatusChanged?.call(newStatus);
    widget.onArmDisarm?.call(newStatus == 'Armed');
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
              _buildHeader(context, isDark, isCompact),
              
              SizedBox(height: isCompact ? CardStyles.space8 : CardStyles.space12),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Shield visualization with status ring
                    Expanded(
                      flex: 3,
                      child: _buildShieldVisualization(isDark, isCompact, isVeryCompact),
                    ),
                    
                    SizedBox(height: isCompact ? CardStyles.space8 : CardStyles.space12),
                    
                    // Action buttons
                    _buildActionButtons(isDark, isCompact),
                    
                    // Zones (if available and space permits)
                    if (widget.zones != null && widget.zones!.isNotEmpty && !isVeryCompact) ...[
                      SizedBox(height: isCompact ? CardStyles.space8 : CardStyles.space12),
                      _buildZonesRow(isDark, isCompact),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isCompact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.security ?? 'Security',
                style: CardStyles.cardTitle(isDark, isCompact: isCompact),
              ),
              SizedBox(height: isCompact ? 4 : 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(context),
                    style: CardStyles.cardSubtitle(isDark, isCompact: isCompact).copyWith(
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Status icon badge
        Padding(
          padding: EdgeInsets.only(top: isCompact ? 0 : 2),
          child: Container(
            width: isCompact ? 36 : 42,
            height: isCompact ? 36 : 42,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(isDark ? 0.2 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon,
              color: _accentColor,
              size: isCompact ? 18 : 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShieldVisualization(bool isDark, bool isCompact, bool isVeryCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight.clamp(80.0, 140.0);
        
        return Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = widget.status == 'Triggered' ? _pulseAnimation.value : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: () async {
                    if (widget.status == 'Disarmed') {
                      await _handleStatusChange('Armed');
                    } else if (widget.status == 'Armed') {
                      await _handleStatusChange('Disarmed');
                    }
                  },
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _accentColor.withOpacity(widget.isActive ? 0.25 : 0.08),
                                _accentColor.withOpacity(widget.isActive ? 0.1 : 0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Progress ring
                        SizedBox(
                          width: size * 0.85,
                          height: size * 0.85,
                          child: CircularProgressIndicator(
                            value: widget.isActive ? 1.0 : 0.0,
                            strokeWidth: 4,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Inner shield container
                        Container(
                          width: size * 0.7,
                          height: size * 0.7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isActive
                                ? _accentColor.withOpacity(isDark ? 0.2 : 0.12)
                                : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                            border: Border.all(
                              color: _accentColor.withOpacity(widget.isActive ? 0.4 : 0.15),
                              width: 2,
                            ),
                            boxShadow: widget.isActive
                                ? [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(0.3),
                                      blurRadius: 16,
                                      spreadRadius: -4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _statusIcon,
                                size: size * 0.28,
                                color: _accentColor,
                              ),
                              SizedBox(height: isCompact ? 2 : 4),
                              Text(
                                widget.isActive ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: isCompact ? 10 : 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(bool isDark, bool isCompact) {
    return Row(
      children: [
        // Arm button
        Expanded(
          child: _buildModeButton(
            isDark: isDark,
            isCompact: isCompact,
            label: 'Arm',
            icon: Icons.lock_rounded,
            isSelected: widget.status == 'Armed',
            onTap: widget.status != 'Armed' ? () async => await _handleStatusChange('Armed') : null,
          ),
        ),
        SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
        // Disarm button
        Expanded(
          child: _buildModeButton(
            isDark: isDark,
            isCompact: isCompact,
            label: 'Disarm',
            icon: Icons.lock_open_rounded,
            isSelected: widget.status == 'Disarmed',
            onTap: widget.status != 'Disarmed' ? () async => await _handleStatusChange('Disarmed') : null,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required bool isDark,
    required bool isCompact,
    required String label,
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final color = isSelected ? _accentColor : CardStyles.iconColor(isDark);
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: CardStyles.normal,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withOpacity(isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accentColor.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? color : color.withOpacity(0.4),
              size: isCompact ? 18 : 20,
            ),
            SizedBox(width: isCompact ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: enabled ? color : color.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesRow(bool isDark, bool isCompact) {
    return SizedBox(
      height: isCompact ? 28 : 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.zones!.length,
        separatorBuilder: (_, __) => SizedBox(width: isCompact ? 6 : 8),
        itemBuilder: (context, index) {
          final zone = widget.zones![index];
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 14,
              vertical: isCompact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              zone,
              style: TextStyle(
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: _accentColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
