import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/device_entity.dart';

/// Device Type Selector
/// Bottom sheet for selecting device type
/// 
/// Usage:
/// ```dart
/// final deviceType = await DeviceTypeSelector.show(context);
/// ```
class DeviceTypeSelector {
  static Future<DeviceType?> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = _deviceTemplates(context);

    return showModalBottomSheet<DeviceType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.getSectionGradient(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(isDark)
                  .withOpacity(isDark ? 0.7 : 0.55),
              width: 1.2,
            ),
            boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getSecondaryGray(isDark)
                                  .withOpacity(0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.getPrimaryButtonGradient(
                                  isDark,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppTheme.getSectionShadows(
                                  isDark,
                                  elevated: true,
                                ),
                              ),
                              child: Icon(
                                Icons.devices_other_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.addDevice,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getTextColor1(isDark),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.of(context)!.chooseDeviceType,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.getSecondaryGray(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return _buildDeviceOptionTile(
                        context: sheetContext,
                        option: option,
                        isDark: isDark,
                        onTap: () =>
                            Navigator.of(sheetContext).pop(option.type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDeviceOptionTile({
    required BuildContext context,
    required _DeviceTemplateData option,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withOpacity(isDark ? 0.15 : 0.12),
                option.color.withOpacity(isDark ? 0.08 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: option.color.withOpacity(isDark ? 0.3 : 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: option.color.withOpacity(isDark ? 0.12 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      option.color.withOpacity(isDark ? 0.4 : 0.3),
                      option.color.withOpacity(isDark ? 0.25 : 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: option.color.withOpacity(isDark ? 0.25 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(option.icon, color: option.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppTheme.getSecondaryGray(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(isDark ? 0.2 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: option.color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_DeviceTemplateData> _deviceTemplates(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _DeviceTemplateData(
        type: DeviceType.light,
        title: l10n.light,
        description: l10n.lightDescription,
        icon: Icons.lightbulb_rounded,
        color: const Color(0xFFFFB74D),
      ),
      _DeviceTemplateData(
        type: DeviceType.curtain,
        title: l10n.curtains,
        description: l10n.curtainsDescription,
        icon: Icons.curtains_rounded,
        color: const Color(0xFF80CBC4),
      ),
      _DeviceTemplateData(
        type: DeviceType.thermostat,
        title: l10n.thermostat,
        description: l10n.thermostatDescription,
        icon: Icons.thermostat_rounded,
        color: const Color(0xFF90CAF9),
      ),
      _DeviceTemplateData(
        type: DeviceType.tv,
        title: l10n.tv,
        description: l10n.tvDescription,
        icon: Icons.tv_rounded,
        color: const Color(0xFF90CAF9),
      ),
      _DeviceTemplateData(
        type: DeviceType.music,
        title: l10n.musicPlayer,
        description: l10n.musicPlayerDescription,
        icon: Icons.music_note_rounded,
        color: const Color(0xFF9575CD),
      ),
      _DeviceTemplateData(
        type: DeviceType.fan,
        title: l10n.fan,
        description: l10n.fanDescription,
        icon: Icons.toys_rounded,
        color: const Color(0xFF4FC3F7),
      ),
      _DeviceTemplateData(
        type: DeviceType.security,
        title: l10n.security,
        description: l10n.securityDescription,
        icon: Icons.shield_rounded,
        color: const Color(0xFFEF9A9A),
      ),
      _DeviceTemplateData(
        type: DeviceType.camera,
        title: l10n.camera,
        description: l10n.cameraDescription,
        icon: Icons.videocam_rounded,
        color: const Color(0xFF81D4FA),
      ),
      _DeviceTemplateData(
        type: DeviceType.socket,
        title: l10n.socket,
        description: l10n.socketDescription,
        icon: Icons.power_rounded,
        color: const Color(0xFF4CAF50),
      ),
      _DeviceTemplateData(
        type: DeviceType.lock,
        title: l10n.lock,
        description: l10n.lockDescription,
        icon: Icons.lock_rounded,
        color: const Color(0xFF9E9E9E),
      ),
      _DeviceTemplateData(
        type: DeviceType.iphone,
        title: 'آیفون درب',
        description: 'کنترل آیفون درب و اینترکام',
        icon: Icons.doorbell_rounded,
        color: const Color(0xFF007AFF),
      ),
    ];
  }
}

class _DeviceTemplateData {
  final DeviceType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _DeviceTemplateData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

