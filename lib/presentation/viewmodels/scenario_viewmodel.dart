import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/scenario_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/use_cases/scenario/get_all_scenarios_use_case.dart';
import '../../domain/use_cases/scenario/create_scenario_use_case.dart';
import '../../domain/use_cases/scenario/update_scenario_use_case.dart';
import '../../domain/use_cases/scenario/delete_scenario_use_case.dart';
import '../../domain/use_cases/scenario/execute_scenario_use_case.dart';

/// Scenario ViewModel
/// Manages all scenario-related state and operations
/// 
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<ScenarioViewModel>();
/// final scenarios = viewModel.scenarios;
/// 
/// // Execute a scenario
/// await viewModel.executeScenario('scenario_movie_night');
/// 
/// // Create a new scenario
/// await viewModel.createScenario(newScenario);
/// 
/// // Get available icons/colors for dialog
/// final icons = viewModel.availableIcons;
/// final colors = viewModel.availableColors;
/// 
/// // Create default action for a device
/// final action = viewModel.createDefaultAction(device);
/// ```
class ScenarioViewModel extends BaseViewModel {
  final GetAllScenariosUseCase _getAllScenariosUseCase;
  final CreateScenarioUseCase _createScenarioUseCase;
  final UpdateScenarioUseCase _updateScenarioUseCase;
  final DeleteScenarioUseCase _deleteScenarioUseCase;
  final ExecuteScenarioUseCase _executeScenarioUseCase;

  List<ScenarioEntity> _scenarios = [];
  String? _executingScenarioId;

  ScenarioViewModel(
    this._getAllScenariosUseCase,
    this._createScenarioUseCase,
    this._updateScenarioUseCase,
    this._deleteScenarioUseCase,
    this._executeScenarioUseCase,
  );

  // ==================== GETTERS ====================

  List<ScenarioEntity> get scenarios => _scenarios;
  String? get executingScenarioId => _executingScenarioId;
  bool isExecuting(String scenarioId) => _executingScenarioId == scenarioId;

  // ==================== DIALOG HELPERS ====================

  /// Available icons for scenarios
  static const List<IconData> availableIcons = [
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
    Icons.auto_awesome_rounded,
    Icons.music_note_rounded,
    Icons.coffee_rounded,
    Icons.nights_stay_rounded,
    Icons.wb_twilight_rounded,
  ];

  /// Available colors for scenarios
  static const List<Color> availableColors = [
    Color(0xFFFFB84D), // Orange
    Color(0xFF5B8DEF), // Blue
    Color(0xFF7B68EE), // Purple
    Color(0xFF68F0C4), // Mint
    Color(0xFFFF6B9D), // Pink
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Amber
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Rose
  ];

  /// Default icon for new scenarios
  static const IconData defaultIcon = Icons.auto_awesome_rounded;

  /// Default color for new scenarios
  static const Color defaultColor = Color(0xFF5B8DEF);

  /// Create default action for a device
  ScenarioAction createDefaultAction(DeviceEntity device) {
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
    } else if (currentState is MusicState) {
      targetState = const MusicState(
        isPlaying: true,
        volume: 50,
      );
    } else if (currentState is SecurityState) {
      targetState = const SecurityState(
        isActive: true,
        status: 'Armed',
      );
    } else {
      targetState = const SimpleState(isOn: true);
    }

    return ScenarioAction(
      deviceId: device.id,
      targetState: targetState,
    );
  }

  /// Get action description for display
  String getActionDescription(ScenarioAction action) {
    final state = action.targetState;
    if (state is LightState) {
      return state.isOn ? 'Turn on (${state.brightness}%)' : 'Turn off';
    } else if (state is ThermostatState) {
      return state.isOn ? 'Set to ${state.targetTemperature}°C' : 'Turn off';
    } else if (state is CurtainState) {
      return state.isOpen ? 'Open' : 'Close';
    } else if (state is CameraState) {
      return state.isOn ? 'Turn on' : 'Turn off';
    } else if (state is MusicState) {
      return state.isPlaying ? 'Play' : 'Stop';
    } else if (state is SecurityState) {
      return state.isActive ? 'Arm' : 'Disarm';
    } else if (state is SimpleState) {
      return state.isOn ? 'Turn on' : 'Turn off';
    }
    return 'Set state';
  }

  /// Validate scenario before saving
  String? validateScenario({
    required String name,
    required List<ScenarioAction> actions,
  }) {
    if (name.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (actions.isEmpty) {
      return 'Please add at least one device action';
    }
    return null; // No error
  }

  /// Create a new scenario from form data
  ScenarioEntity createScenarioFromForm({
    String? existingId,
    required String name,
    String? description,
    required IconData icon,
    required Color color,
    required List<ScenarioAction> actions,
    DateTime? existingCreatedAt,
    DateTime? existingLastExecuted,
  }) {
    return ScenarioEntity(
      id: existingId ?? const Uuid().v4(),
      name: name.trim(),
      icon: icon,
      color: color,
      actions: actions,
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      createdAt: existingCreatedAt ?? DateTime.now(),
      lastExecuted: existingLastExecuted,
    );
  }

  // ==================== CRUD OPERATIONS ====================

  @override
  void init() {
    super.init();
    loadScenarios();
  }

  /// Load all scenarios
  Future<void> loadScenarios() async {
    print('🟢 [SCENARIO_VM] loadScenarios called');
    try {
      setLoading(true);
      clearError();
      
      _scenarios = await _getAllScenariosUseCase();
      print('🟢 [SCENARIO_VM] Loaded ${_scenarios.length} scenarios');
      for (var scenario in _scenarios) {
        print('   - ${scenario.name} (ID: ${scenario.id}, RoomId: ${scenario.roomId})');
      }
      notifyListeners();
    } catch (e) {
      print('🔴 [SCENARIO_VM] Error loading scenarios: $e');
      setError('Failed to load scenarios: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Create a new scenario
  Future<void> createScenario(ScenarioEntity scenario) async {
    print('🟢 [SCENARIO_VM] createScenario called');
    print('   - ID: ${scenario.id}');
    print('   - Name: ${scenario.name}');
    print('   - RoomId: ${scenario.roomId}');
    print('   - Actions: ${scenario.actions.length}');
    print('   - Current scenarios count before: ${_scenarios.length}');
    
    try {
      setLoading(true);
      clearError();
      
      final created = await _createScenarioUseCase(scenario);
      print('🟢 [SCENARIO_VM] Scenario created in repository');
      print('   - Created ID: ${created.id}');
      print('   - Created Name: ${created.name}');
      print('   - Created RoomId: ${created.roomId}');
      
      _scenarios.add(created);
      print('🟢 [SCENARIO_VM] Added to local list. New count: ${_scenarios.length}');
      notifyListeners();
      print('🟢 [SCENARIO_VM] Notified listeners');
    } catch (e) {
      print('🔴 [SCENARIO_VM] Error creating scenario: $e');
      setError('Failed to create scenario: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Update an existing scenario
  Future<void> updateScenario(ScenarioEntity scenario) async {
    try {
      setLoading(true);
      clearError();
      
      final updated = await _updateScenarioUseCase(scenario);
      _updateScenarioInList(updated);
      notifyListeners();
    } catch (e) {
      setError('Failed to update scenario: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Delete a scenario
  Future<void> deleteScenario(String scenarioId) async {
    try {
      setLoading(true);
      clearError();
      
      await _deleteScenarioUseCase(scenarioId);
      _scenarios.removeWhere((s) => s.id == scenarioId);
      notifyListeners();
    } catch (e) {
      setError('Failed to delete scenario: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Execute a scenario
  Future<void> executeScenario(String scenarioId) async {
    print('🟢 [SCENARIO_VM] executeScenario called: $scenarioId');
    try {
      _executingScenarioId = scenarioId;
      notifyListeners();
      
      await _executeScenarioUseCase(scenarioId);
      print('🟢 [SCENARIO_VM] Scenario executed successfully');
      
      // Reload scenarios to get updated lastExecuted time
      print('🟢 [SCENARIO_VM] Reloading scenarios after execution');
      await loadScenarios();
    } catch (e) {
      print('🔴 [SCENARIO_VM] Error executing scenario: $e');
      setError('Failed to execute scenario: ${e.toString()}');
      rethrow;
    } finally {
      _executingScenarioId = null;
      notifyListeners();
    }
  }

  /// Get a specific scenario by ID
  ScenarioEntity? getScenarioById(String scenarioId) {
    try {
      return _scenarios.firstWhere((s) => s.id == scenarioId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh scenarios
  Future<void> refresh() async {
    await loadScenarios();
  }

  // Helper method to update scenario in local list
  void _updateScenarioInList(ScenarioEntity updatedScenario) {
    final index = _scenarios.indexWhere((s) => s.id == updatedScenario.id);
    if (index != -1) {
      _scenarios[index] = updatedScenario;
    }
  }
}
