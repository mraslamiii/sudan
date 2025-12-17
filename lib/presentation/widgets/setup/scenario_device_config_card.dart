import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../domain/entities/scenario_entity.dart';
import '../../viewmodels/scenario_setup_viewmodel.dart';

/// Scenario Device Config Card
/// Beautiful card for configuring device state in a scenario
/// 
/// Usage:
/// ```dart
/// ScenarioDeviceConfigCard(
///   device: device,
///   action: existingAction,
///   onActionChanged: (action) => viewModel.updateAction(device.id, action),
/// )
/// ```
class ScenarioDeviceConfigCard extends StatefulWidget {
  final DeviceEntity device;
  final ScenarioAction? action;
  final VoidCallback? onRemove;

  const ScenarioDeviceConfigCard({
    super.key,
    required this.device,
    this.action,
    this.onRemove,
  });

  @override
  State<ScenarioDeviceConfigCard> createState() => _ScenarioDeviceConfigCardState();
}

class _ScenarioDeviceConfigCardState extends State<ScenarioDeviceConfigCard> {
  late DeviceState _targetState;
  int _delayMs = 0;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
    // Defer _updateAction() to after build completes to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateAction();
      }
    });
  }

  void _initializeState() {
    if (widget.action != null) {
      _targetState = widget.action!.targetState;
      _delayMs = widget.action!.delayMs;
      _isEnabled = true;
    } else {
      // Create default state based on current device state
      final currentState = widget.device.state;
      if (currentState is LightState) {
        _targetState = LightState(
          isOn: true,
          brightness: 80,
          color: currentState.color,
        );
      } else if (currentState is ThermostatState) {
        _targetState = ThermostatState(
          isOn: true,
          temperature: currentState.temperature,
          targetTemperature: 22,
          mode: currentState.mode,
        );
      } else if (currentState is CurtainState) {
        _targetState = const CurtainState(isOpen: true, position: 100);
      } else if (currentState is CameraState) {
        _targetState = CameraState(
          isOn: true,
          isRecording: false,
          resolution: currentState.resolution,
        );
      } else if (currentState is MusicState) {
        _targetState = MusicState(
          isPlaying: true,
          volume: 50,
        );
      } else if (currentState is SecurityState) {
        _targetState = const SecurityState(
          isActive: true,
          status: 'Armed',
        );
      } else if (currentState is ElevatorState) {
        _targetState = ElevatorState(
          currentFloor: currentState.currentFloor,
          targetFloor: currentState.currentFloor,
          isMoving: false,
          availableFloors: currentState.availableFloors,
        );
      } else if (currentState is DoorLockState) {
        _targetState = const DoorLockState(
          isLocked: false,
          isUnlocking: false,
        );
      } else {
        _targetState = const SimpleState(isOn: true);
      }
    }
    // Don't call _updateAction() here - it will be called after build completes
  }

  void _updateAction() {
    if (!mounted) return;
    final viewModel = context.read<ScenarioSetupViewModel>();
    final action = ScenarioAction(
      deviceId: widget.device.id,
      targetState: _targetState,
      delayMs: _delayMs,
    );
    
    if (_isEnabled) {
      viewModel.updateAction(widget.device.id, action);
    } else {
      viewModel.removeAction(widget.device.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: _isEnabled
            ? LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              )
            : null,
        color: _isEnabled
            ? null
            : AppTheme.getSectionBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEnabled
              ? accentColor.withOpacity(0.3)
              : AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          width: _isEnabled ? 1.5 : 1,
        ),
        boxShadow: _isEnabled
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? accentColor.withOpacity(0.2)
                        : AppTheme.getSectionBackground(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.device.icon ?? Icons.device_unknown,
                    color: _isEnabled
                        ? accentColor
                        : AppTheme.getSecondaryGray(isDark),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _isEnabled
                              ? AppTheme.getTextColor1(isDark)
                              : AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.device.type.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                // Enable/Disable Toggle
                Switch(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value;
                    });
                    _updateAction();
                  },
                  activeColor: accentColor,
                ),
                if (widget.onRemove != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.redAccent,
                    iconSize: 20,
                  ),
                ],
              ],
            ),
          ),

          // Device-specific controls
          if (_isEnabled) ...[
            Divider(
              height: 1,
              color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDeviceControls(isDark, accentColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceControls(bool isDark, Color accentColor) {
    if (_targetState is LightState) {
      return _buildLightControls(isDark, accentColor);
    } else if (_targetState is ThermostatState) {
      return _buildThermostatControls(isDark, accentColor);
    } else if (_targetState is CurtainState) {
      return _buildCurtainControls(isDark, accentColor);
    } else if (_targetState is CameraState) {
      return _buildCameraControls(isDark, accentColor);
    } else if (_targetState is MusicState) {
      return _buildMusicControls(isDark, accentColor);
    } else if (_targetState is SecurityState) {
      return _buildSecurityControls(isDark, accentColor);
    } else if (_targetState is ElevatorState) {
      return _buildElevatorControls(isDark, accentColor);
    } else if (_targetState is DoorLockState) {
      return _buildDoorLockControls(isDark, accentColor);
    } else {
      return _buildSimpleControls(isDark, accentColor);
    }
  }

  Widget _buildLightControls(bool isDark, Color accentColor) {
    final state = _targetState as LightState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // On/Off Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isOn,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isOn: value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        if (state.isOn) ...[
          const SizedBox(height: 16),
          // Brightness Slider
            Text(
              '${AppLocalizations.of(context)!.brightness}: ${state.brightness}%',
              style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.brightness.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: accentColor,
            onChanged: (value) {
              setState(() {
                _targetState = state.copyWith(brightness: value.toInt());
              });
              _updateAction();
            },
          ),
        ],
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildThermostatControls(bool isDark, Color accentColor) {
    final state = _targetState as ThermostatState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isOn,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isOn: value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        if (state.isOn) ...[
          const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.targetTemperature}: ${state.targetTemperature}°C',
              style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.targetTemperature.toDouble(),
            min: 10,
            max: 35,
            divisions: 25,
            activeColor: accentColor,
            onChanged: (value) {
              setState(() {
                _targetState = state.copyWith(targetTemperature: value.toInt());
              });
              _updateAction();
            },
          ),
        ],
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildCurtainControls(bool isDark, Color accentColor) {
    final state = _targetState as CurtainState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isOpen,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(
                    isOpen: value,
                    position: value ? 100 : 0,
                  );
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        if (state.isOpen) ...[
          const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.position}: ${state.position}%',
              style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.position.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: accentColor,
            onChanged: (value) {
              setState(() {
                _targetState = state.copyWith(position: value.toInt());
              });
              _updateAction();
            },
          ),
        ],
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildCameraControls(bool isDark, Color accentColor) {
    final state = _targetState as CameraState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isOn,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isOn: value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildMusicControls(bool isDark, Color accentColor) {
    final state = _targetState as MusicState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isPlaying,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isPlaying: value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        if (state.isPlaying) ...[
          const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.volume}: ${state.volume}%',
              style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.volume.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: accentColor,
            onChanged: (value) {
              setState(() {
                _targetState = state.copyWith(volume: value.toInt());
              });
              _updateAction();
            },
          ),
        ],
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildSecurityControls(bool isDark, Color accentColor) {
    final state = _targetState as SecurityState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isActive,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(
                    isActive: value,
                    status: value ? 'Armed' : 'Disarmed',
                  );
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildElevatorControls(bool isDark, Color accentColor) {
    final state = _targetState as ElevatorState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              '${AppLocalizations.of(context)!.targetFloor}: ${state.targetFloor ?? state.currentFloor}',
              style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildDoorLockControls(bool isDark, Color accentColor) {
    final state = _targetState as DoorLockState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: !state.isLocked,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isLocked: !value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildSimpleControls(bool isDark, Color accentColor) {
    final state = _targetState as SimpleState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.state,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            Switch(
              value: state.isOn,
              onChanged: (value) {
                setState(() {
                  _targetState = state.copyWith(isOn: value);
                });
                _updateAction();
              },
              activeColor: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDelayControl(isDark, accentColor),
      ],
    );
  }

  Widget _buildDelayControl(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              '${AppLocalizations.of(context)!.delay}: ${_delayMs}ms',
              style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _delayMs.toDouble(),
          min: 0,
          max: 5000,
          divisions: 50,
          activeColor: accentColor,
          onChanged: (value) {
            setState(() {
              _delayMs = value.toInt();
            });
            _updateAction();
          },
        ),
      ],
    );
  }
}

