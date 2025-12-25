import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../data/models/device_model.dart';
import '../../../core/utils/pin_protection.dart';

/// Device Config Form
/// Dialog for configuring a new device
///
/// Usage:
/// ```dart
/// final device = await DeviceConfigForm.show(context, DeviceType.light);
/// ```
class DeviceConfigForm {
  static Future<DeviceEntity?> show(
    BuildContext context,
    DeviceType deviceType,
  ) async {
    if (!context.mounted) {
      return null;
    }

    // Check PIN protection
    final verified = await PinProtection.requirePinVerification(
      context,
      title: AppLocalizations.of(context)!.pinRequired,
      subtitle: AppLocalizations.of(context)!.pinRequiredForAction,
    );

    if (!context.mounted) {
      return null;
    }

    if (!verified) {
      return null; // User cancelled or PIN verification failed
    }

    if (!context.mounted) {
      return null;
    }

    return showDialog<DeviceEntity>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => _DeviceConfigDialog(deviceType: deviceType),
    );
  }
}

class _DeviceConfigDialog extends StatefulWidget {
  final DeviceType deviceType;

  const _DeviceConfigDialog({required this.deviceType});

  @override
  State<_DeviceConfigDialog> createState() => _DeviceConfigDialogState();
}

class _DeviceConfigDialogState extends State<_DeviceConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default name based on device type
    _nameController.text = _getDefaultNameForType(widget.deviceType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      final deviceId = const Uuid().v4();
      final deviceName = _nameController.text.trim();
      final defaultState = _getDefaultStateForType(widget.deviceType);

      final createdDevice = DeviceModel(
        id: deviceId,
        name: deviceName,
        type: widget.deviceType,
        roomId: '', // Will be set when added to room
        state: defaultState,
        icon: _getIconForType(widget.deviceType),
        isOnline: true,
        lastUpdated: DateTime.now(),
      );

      Navigator.of(context).pop(createdDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          gradient: AppTheme.getSectionGradient(isDark),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(
              isDark,
            ).withOpacity(isDark ? 0.7 : 0.55),
            width: 1.2,
          ),
          boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.getSectionShadows(
                            isDark,
                            elevated: true,
                          ),
                        ),
                        child: Icon(
                          _getIconForType(widget.deviceType),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.configureDevice,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextColor1(isDark),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.enterDeviceName,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Device name input
                  Text(
                    AppLocalizations.of(context)!.deviceName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.deviceNameHint,
                      hintStyle: TextStyle(
                        color: AppTheme.getSecondaryGray(isDark),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.getSectionBorderColor(
                            isDark,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.getSectionBorderColor(
                            isDark,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: accentColor.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.pleaseEnterDeviceName;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleConfirm(),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getSecondaryGray(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(elevation: MaterialStateProperty.all(0)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.getPrimaryButtonGradient(isDark),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.createFloor,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb_rounded;
      case DeviceType.thermostat:
        return Icons.thermostat_rounded;
      case DeviceType.curtain:
        return Icons.curtains_rounded;
      case DeviceType.tv:
        return Icons.tv_rounded;
      case DeviceType.fan:
        return Icons.toys_rounded;
      case DeviceType.security:
        return Icons.shield_rounded;
      case DeviceType.music:
        return Icons.music_note_rounded;
      case DeviceType.camera:
        return Icons.videocam_rounded;
      case DeviceType.socket:
        return Icons.power_rounded;
      case DeviceType.lock:
        return Icons.lock_rounded;
      case DeviceType.elevator:
        return Icons.elevator_rounded;
      case DeviceType.doorLock:
        return Icons.door_front_door_rounded;
      case DeviceType.iphone:
        return Icons.doorbell_rounded;
    }
  }

  String _getDefaultNameForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return 'Light';
      case DeviceType.thermostat:
        return 'Thermostat';
      case DeviceType.curtain:
        return 'Curtain';
      case DeviceType.tv:
        return 'TV';
      case DeviceType.fan:
        return 'Fan';
      case DeviceType.security:
        return 'Security System';
      case DeviceType.music:
        return 'Music Player';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.socket:
        return 'Tablet Charger';
      case DeviceType.lock:
        return 'Lock';
      case DeviceType.elevator:
        return 'Elevator';
      case DeviceType.doorLock:
        return 'Door Lock';
      case DeviceType.iphone:
        return 'iPhone';
    }
  }

  DeviceState _getDefaultStateForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return const LightState(
          isOn: false,
          brightness: 80,
          color: Color(0xFFFFFFFF),
        );
      case DeviceType.thermostat:
        return const ThermostatState(
          isOn: true,
          temperature: 22,
          targetTemperature: 22,
          mode: 'Auto',
        );
      case DeviceType.curtain:
        return const CurtainState(isOpen: false, position: 0);
      case DeviceType.camera:
        return const CameraState(
          isOn: true,
          isRecording: false,
          resolution: '4K',
        );
      case DeviceType.music:
        return const MusicState(isPlaying: false, volume: 50);
      case DeviceType.security:
        return const SecurityState(isActive: false, status: 'Disarmed');
      case DeviceType.elevator:
        return const ElevatorState(
          currentFloor: 1,
          isMoving: false,
          availableFloors: [1, 2, 3, 4, 5],
        );
      default:
        return const SimpleState(isOn: false);
    }
  }
}
