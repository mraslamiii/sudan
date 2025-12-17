import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/scenario_entity.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

/// Scenario Creation Dialog
/// Beautiful and functional dialog for creating/editing scenarios
/// 
/// Usage:
/// ```dart
/// final result = await showDialog<ScenarioEntity>(
///   context: context,
///   builder: (context) => ScenarioCreationDialog(
///     availableDevices: devices,
///     existingScenario: scenario, // for editing
///   ),
/// );
/// ```
class ScenarioCreationDialog extends StatefulWidget {
  final List<DeviceEntity> availableDevices;
  final ScenarioEntity? existingScenario; // null for create, non-null for edit

  const ScenarioCreationDialog({
    super.key,
    required this.availableDevices,
    this.existingScenario,
  });

  @override
  State<ScenarioCreationDialog> createState() => _ScenarioCreationDialogState();
}

class _ScenarioCreationDialogState extends State<ScenarioCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  IconData _selectedIcon = Icons.auto_awesome_rounded;
  Color _selectedColor = const Color(0xFF5B8DEF);
  final List<ScenarioAction> _actions = [];

  // Available icons for scenarios
  final List<IconData> _availableIcons = [
    Icons.wb_sunny_rounded,
    Icons.movie_rounded,
    Icons.bedtime_rounded,
    Icons.home_rounded,
    Icons.celebration_rounded,
    Icons.work_rounded,
    Icons.restaurant_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
  ];

  // Available colors
  final List<Color> _availableColors = [
    const Color(0xFFFFB84D),
    const Color(0xFF5B8DEF),
    const Color(0xFF7B68EE),
    const Color(0xFF68F0C4),
    const Color(0xFFFF6B9D),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingScenario != null) {
      _nameController.text = widget.existingScenario!.name;
      _descriptionController.text = widget.existingScenario!.description ?? '';
      _selectedIcon = widget.existingScenario!.icon;
      _selectedColor = widget.existingScenario!.color;
      _actions.addAll(widget.existingScenario!.actions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addDeviceAction(DeviceEntity device) {
    // Create default target state based on device type
    DeviceState targetState;
    final currentState = device.state;
    
    if (currentState is LightState) {
      targetState = const LightState(
        isOn: true,
        brightness: 80,
        color: Color(0xFFFFFFFF),
      );
    } else if (currentState is ThermostatState) {
      targetState = const ThermostatState(
        isOn: true,
        temperature: 22,
        targetTemperature: 22,
        mode: 'Auto',
      );
    } else if (currentState is CurtainState) {
      targetState = const CurtainState(isOpen: true, position: 100);
    } else if (currentState is CameraState) {
      targetState = const CameraState(
        isOn: true,
        isRecording: false,
        resolution: '1080p',
      );
    } else {
      targetState = const SimpleState(isOn: true);
    }

    setState(() {
      _actions.add(ScenarioAction(
        deviceId: device.id,
        targetState: targetState,
      ));
    });
  }

  void _removeAction(int index) {
    setState(() {
      _actions.removeAt(index);
    });
  }

  void _saveScenario() {
    if (!_formKey.currentState!.validate()) return;
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseAddDeviceAction),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scenario = ScenarioEntity(
      id: widget.existingScenario?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      actions: _actions,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: widget.existingScenario?.createdAt ?? DateTime.now(),
      lastExecuted: widget.existingScenario?.lastExecuted,
    );

    Navigator.of(context).pop(scenario);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingScenario != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppTheme.getCardBackground(isDark),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getSectionBackground(isDark),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_selectedIcon, color: _selectedColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? AppLocalizations.of(context)!.editScenario : AppLocalizations.of(context)!.createScenarioTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor1(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.controlMultipleDevices,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getSecondaryGray(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppTheme.getSecondaryGray(isDark)),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: AppTheme.getTextColor1(isDark)),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.scenarioName,
                          labelStyle: TextStyle(color: AppTheme.getSecondaryGray(isDark)),
                          hintText: AppLocalizations.of(context)!.scenarioNameHint,
                          filled: true,
                          fillColor: AppTheme.getSectionBackground(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.label_rounded, color: AppTheme.getSecondaryGray(isDark)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: AppTheme.getTextColor1(isDark)),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.descriptionOptionalScenario,
                          labelStyle: TextStyle(color: AppTheme.getSecondaryGray(isDark)),
                          hintText: AppLocalizations.of(context)!.describeScenario,
                          filled: true,
                          fillColor: AppTheme.getSectionBackground(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Icon Selection
                      Text(
                        'Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor1(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableIcons.map((icon) {
                          final isSelected = icon == _selectedIcon;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withOpacity(0.2)
                                    : AppTheme.getSectionBackground(isDark),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _selectedColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? _selectedColor
                                    : AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Color Selection
                      Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor1(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableColors.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Device Actions
                      Row(
                        children: [
                          Text(
                            'Device Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor1(isDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_actions.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Actions List
                      if (_actions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.getSectionBackground(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getSecondaryGray(isDark).withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.devices_rounded,
                                  size: 48,
                                  color: AppTheme.getSecondaryGray(isDark),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No devices added yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.getSecondaryGray(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._actions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final action = entry.value;
                          final device = widget.availableDevices.firstWhere(
                            (d) => d.id == action.deviceId,
                          );
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.getSectionBackground(isDark),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  device.icon ?? Icons.device_unknown,
                                  color: _selectedColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.getTextColor1(isDark),
                                        ),
                                      ),
                                      Text(
                                        _getActionDescription(action),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.getSecondaryGray(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeAction(index),
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                      const SizedBox(height: 12),

                      // Add Device Button
                      OutlinedButton.icon(
                        onPressed: () => _showDeviceSelectionSheet(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Device'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedColor,
                          side: BorderSide(color: _selectedColor),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getSectionBackground(isDark),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveScenario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isEditing ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.createScenarioTitle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionDescription(ScenarioAction action) {
    final state = action.targetState;
    if (state is LightState) {
      return state.isOn ? 'Turn on (${state.brightness}%)' : 'Turn off';
    } else if (state is ThermostatState) {
      return state.isOn ? 'Set to ${state.targetTemperature}°C' : 'Turn off';
    } else if (state is CurtainState) {
      return state.isOpen ? 'Open' : 'Close';
    } else if (state is CameraState) {
      return state.isOn ? 'Turn on' : 'Turn off';
    } else if (state is SimpleState) {
      return state.isOn ? 'Turn on' : 'Turn off';
    }
    return 'Set state';
  }

  void _showDeviceSelectionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addedDeviceIds = _actions.map((a) => a.deviceId).toSet();
    final availableDevices = widget.availableDevices
        .where((d) => !addedDeviceIds.contains(d.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardBackground(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            const SizedBox(height: 16),
            if (availableDevices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('All devices added')),
              )
            else
              ...availableDevices.map((device) {
                return ListTile(
                  leading: Icon(device.icon ?? Icons.device_unknown),
                  title: Text(device.name),
                  subtitle: Text(device.type.toString().split('.').last),
                  onTap: () {
                    Navigator.pop(context);
                    _addDeviceAction(device);
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

