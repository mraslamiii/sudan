import 'package:flutter/material.dart';
import '../../../domain/entities/scenario_entity.dart';
import '../../../domain/repositories/scenario_repository.dart';
import '../../../domain/repositories/device_repository.dart';
import '../../data_sources/local/scenario/scenario_local_data_source.dart';
import '../../data_sources/local/preferences/preferences_service.dart';
import '../../models/scenario_model.dart';

/// Scenario Repository Implementation
/// Handles scenario CRUD operations and execution
/// 
/// For future developers:
/// - Scenario execution triggers device state changes through DeviceRepository
/// - Can be extended with cloud sync for multi-device scenarios
/// - Can add automation triggers (time-based, sensor-based, etc.)
class ScenarioRepositoryImpl implements ScenarioRepository {
  final ScenarioLocalDataSource _localDataSource;
  final DeviceRepository _deviceRepository;
  final PreferencesService _preferencesService;

  ScenarioRepositoryImpl(
    this._localDataSource,
    this._deviceRepository,
    this._preferencesService,
  );

  @override
  Future<List<ScenarioEntity>> getAllScenarios() async {
    print('🟡 [SCENARIO_REPO] getAllScenarios called');
    final scenarios = await _localDataSource.getCachedScenarios();
    print('🟡 [SCENARIO_REPO] Retrieved ${scenarios.length} scenarios from cache');
    for (var scenario in scenarios) {
      print('   - ${scenario.name} (ID: ${scenario.id}, RoomId: ${scenario.roomId})');
    }
    return scenarios;
  }

  @override
  Future<ScenarioEntity> getScenarioById(String id) async {
    final scenarios = await _localDataSource.getCachedScenarios();
    return scenarios.firstWhere(
      (scenario) => scenario.id == id,
      orElse: () => throw Exception('Scenario not found: $id'),
    );
  }

  @override
  Future<ScenarioEntity> createScenario(ScenarioEntity scenario) async {
    print('🟡 [SCENARIO_REPO] createScenario called');
    print('   - ID: ${scenario.id}');
    print('   - Name: ${scenario.name}');
    print('   - RoomId: ${scenario.roomId}');
    print('   - Actions: ${scenario.actions.length}');
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    final scenarioModel = ScenarioModel(
      id: scenario.id,
      name: scenario.name,
      icon: scenario.icon,
      color: scenario.color,
      actions: scenario.actions,
      description: scenario.description,
      isActive: scenario.isActive,
      createdAt: scenario.createdAt,
      lastExecuted: scenario.lastExecuted,
      conditions: scenario.conditions,
      roomId: scenario.roomId,
      appSettings: scenario.appSettings,
    );
    
    print('🟡 [SCENARIO_REPO] Created ScenarioModel, adding to data source');
    await _localDataSource.addScenario(scenarioModel);
    print('🟡 [SCENARIO_REPO] Scenario added to data source successfully');
    return scenarioModel;
  }

  @override
  Future<ScenarioEntity> updateScenario(ScenarioEntity scenario) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final scenarioModel = ScenarioModel(
      id: scenario.id,
      name: scenario.name,
      icon: scenario.icon,
      color: scenario.color,
      actions: scenario.actions,
      description: scenario.description,
      isActive: scenario.isActive,
      createdAt: scenario.createdAt,
      lastExecuted: scenario.lastExecuted,
      conditions: scenario.conditions,
      roomId: scenario.roomId,
      appSettings: scenario.appSettings,
    );
    
    await _localDataSource.updateScenario(scenarioModel);
    return scenarioModel;
  }

  @override
  Future<void> deleteScenario(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _localDataSource.deleteScenario(id);
  }

  @override
  Future<void> executeScenario(String id) async {
    final scenario = await getScenarioById(id);
    
    // Apply app settings first (if any)
    if (scenario.appSettings != null) {
      await _applyAppSettings(scenario.appSettings!);
    }
    
    // Execute each action with its delay
    for (final action in scenario.actions) {
      if (action.delayMs > 0) {
        await Future.delayed(Duration(milliseconds: action.delayMs));
      }
      
      try {
        // Get the device and update its state
        final device = await _deviceRepository.getDeviceById(action.deviceId);
        final updatedDevice = device.copyWith(state: action.targetState);
        await _deviceRepository.updateDevice(updatedDevice);
      } catch (e) {
        // Continue with other actions even if one fails
        print('Failed to execute action for device ${action.deviceId}: $e');
      }
    }
    
    // Mark scenario as executed
    final updatedScenario = scenario.markAsExecuted();
    await updateScenario(updatedScenario);
  }

  /// Apply app settings from scenario
  Future<void> _applyAppSettings(ScenarioAppSettings settings) async {
    // Apply theme mode if specified
    if (settings.themeMode != null) {
      String modeString;
      switch (settings.themeMode!) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await _preferencesService.setThemeMode(modeString);
    }

    // Apply language if specified
    if (settings.language != null) {
      await _preferencesService.setLanguage(settings.language!);
    }
  }

  @override
  Future<List<ScenarioEntity>> getRecentScenarios({int limit = 5}) async {
    final scenarios = await getAllScenarios();
    
    // Filter scenarios that have been executed
    final executedScenarios = scenarios
        .where((s) => s.lastExecuted != null)
        .toList();
    
    // Sort by last executed time (most recent first)
    executedScenarios.sort((a, b) {
      final aTime = a.lastExecuted ?? DateTime(0);
      final bTime = b.lastExecuted ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
    
    // Return top N
    return executedScenarios.take(limit).toList();
  }

  @override
  Stream<List<ScenarioEntity>>? watchScenarios() {
    // TODO: Implement real-time scenario updates
    // For now, returning null (not implemented)
    return null;
  }

  @override
  Future<bool> isNameAvailable(String name, {String? excludeId}) async {
    final scenarios = await getAllScenarios();
    
    return !scenarios.any((scenario) =>
        scenario.name.toLowerCase() == name.toLowerCase() &&
        scenario.id != excludeId);
  }
}

