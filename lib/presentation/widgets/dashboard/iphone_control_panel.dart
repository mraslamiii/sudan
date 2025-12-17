import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Door Phone Control Panel
/// Dedicated control panel for door phone/intercom device
class IPhoneControlPanel extends StatelessWidget {
  final bool isActive;
  final String deviceName;
  final int batteryLevel;
  final bool isCharging;
  final VoidCallback? onToggle;
  final VoidCallback? onOpen;

  const IPhoneControlPanel({
    super.key,
    required this.isActive,
    required this.deviceName,
    this.batteryLevel = 100,
    this.isCharging = false,
    this.onToggle,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Door Phone Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [
                        const Color(0xFF34C759).withOpacity(0.2),
                        const Color(0xFF30D158).withOpacity(0.1),
                      ]
                    : [
                        (isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05)),
                        (isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02)),
                      ],
              ),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF34C759).withOpacity(0.3)
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1)),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.doorbell_rounded,
              size: 40,
              color: isActive
                  ? const Color(0xFF34C759)
                  : (isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.5)),
            ),
          ),

          const SizedBox(height: 20),

          // Device Name
          Text(
            deviceName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Battery Level
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCharging ? Icons.battery_charging_full_rounded : Icons.battery_full_rounded,
                size: 16,
                color: AppTheme.getSecondaryGray(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                '$batteryLevel%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getSecondaryGray(isDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Button
          GestureDetector(
            onTap: onOpen ?? onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [
                          const Color(0xFF34C759),
                          const Color(0xFF30D158),
                        ]
                      : [
                          (isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05)),
                          (isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.02)),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF34C759).withOpacity(0.3)
                      : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1)),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF34C759).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 20,
                    color: isActive
                        ? Colors.white
                        : (isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActive ? 'باز' : 'باز کردن درب',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : (isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
