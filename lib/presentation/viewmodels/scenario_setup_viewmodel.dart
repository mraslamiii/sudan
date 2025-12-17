import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/scenario_entity.dart';

/// Scenario Setup ViewModel
/// Manages the step-by-step scenario creation flow
/// 
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<ScenarioSetupViewModel>();
/// final currentStep = viewModel.currentStep;
/// 
/// // Navigate to next step
/// viewModel.nextStep();
/// 
/// // Save scenario
/// await viewModel.saveScenario();
/// ```
class ScenarioSetupViewModel extends BaseViewModel {
  String? _roomId; // Room ID for the scenario being created

  int _currentStep = 0;
  String? _scenarioName;
  String? _scenarioDescription;
  IconData? _selectedIcon;
  Color? _selectedColor;
  final List<ScenarioAction> _actions = [];
  ScenarioAppSettings? _appSettings;

  ScenarioSetupViewModel();

  // Room ID getter/setter
  String? get roomId => _roomId;
  
  void setRoomId(String? roomId) {
    _roomId = roomId;
    notifyListeners();
  }

  // Getters
  int get currentStep => _currentStep;
  String? get scenarioName => _scenarioName;
  String? get scenarioDescription => _scenarioDescription;
  IconData? get selectedIcon => _selectedIcon;
  Color? get selectedColor => _selectedColor;
  List<ScenarioAction> get actions => _actions;
  ScenarioAppSettings? get appSettings => _appSettings;
  bool get canGoNext => validateCurrentStep();
  bool get canGoBack => _currentStep > 0;
  bool get isLastStep => _currentStep >= 3;

  /// Set scenario name
  void setScenarioName(String? name) {
    _scenarioName = name;
    notifyListeners();
  }

  /// Set scenario description
  void setScenarioDescription(String? description) {
    _scenarioDescription = description;
    notifyListeners();
  }

  /// Set selected icon
  void setSelectedIcon(IconData icon) {
    _selectedIcon = icon;
    notifyListeners();
  }

  /// Set selected color
  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  /// Add action to scenario
  void addAction(ScenarioAction action) {
    if (!_actions.any((a) => a.deviceId == action.deviceId)) {
      _actions.add(action);
      notifyListeners();
    }
  }

  /// Remove action from scenario
  void removeAction(String deviceId) {
    _actions.removeWhere((a) => a.deviceId == deviceId);
    notifyListeners();
  }

  /// Update action in scenario
  void updateAction(String deviceId, ScenarioAction updatedAction) {
    final index = _actions.indexWhere((a) => a.deviceId == deviceId);
    if (index != -1) {
      _actions[index] = updatedAction;
      notifyListeners();
    }
  }

  /// Get action by device ID
  ScenarioAction? getActionByDeviceId(String deviceId) {
    try {
      return _actions.firstWhere((a) => a.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Set app settings
  void setAppSettings(ScenarioAppSettings? settings) {
    _appSettings = settings;
    notifyListeners();
  }

  /// Navigate to next step
  void nextStep() {
    if (!validateCurrentStep()) return;
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        return _scenarioName != null && 
               _scenarioName!.trim().isNotEmpty &&
               _selectedIcon != null &&
               _selectedColor != null;
      case 1: // Device configuration
        return true; // Devices are optional but recommended
      case 2: // App settings
        return true; // App settings are optional
      case 3: // Review
        return true;
      default:
        return false;
    }
  }

  /// Create scenario entity from current state
  ScenarioEntity createScenarioEntity({String? existingId}) {
    print('🟢 [SCENARIO_SETUP_VM] createScenarioEntity called');
    print('   - existingId: $existingId');
    print('   - _roomId: $_roomId');
    print('   - _scenarioName: $_scenarioName');
    print('   - _actions count: ${_actions.length}');
    
    final scenario = ScenarioEntity(
      id: existingId ?? const Uuid().v4(),
      name: _scenarioName!.trim(),
      icon: _selectedIcon!,
      color: _selectedColor!,
      actions: List.from(_actions),
      description: _scenarioDescription?.trim().isEmpty == true 
          ? null 
          : _scenarioDescription?.trim(),
      createdAt: DateTime.now(),
      roomId: _roomId,
      appSettings: _appSettings?.hasSettings == true ? _appSettings : null,
    );
    
    print('🟢 [SCENARIO_SETUP_VM] Created scenario entity:');
    print('   - ID: ${scenario.id}');
    print('   - Name: ${scenario.name}');
    print('   - RoomId: ${scenario.roomId}');
    print('   - Actions: ${scenario.actions.length}');
    
    return scenario;
  }

  /// Load existing scenario for editing
  void loadScenario(ScenarioEntity scenario) {
    _scenarioName = scenario.name;
    _scenarioDescription = scenario.description;
    _selectedIcon = scenario.icon;
    _selectedColor = scenario.color;
    _actions.clear();
    _actions.addAll(scenario.actions);
    _appSettings = scenario.appSettings;
    _roomId = scenario.roomId;
    notifyListeners();
  }

  /// Initialize room ID without notifying listeners (for use during build)
  void initializeRoomId(String? roomId) {
    _roomId = roomId;
  }

  /// Initialize scenario data without notifying listeners (for use during build)
  void initializeScenario(ScenarioEntity scenario) {
    _scenarioName = scenario.name;
    _scenarioDescription = scenario.description;
    _selectedIcon = scenario.icon;
    _selectedColor = scenario.color;
    _actions.clear();
    _actions.addAll(scenario.actions);
    _appSettings = scenario.appSettings;
    _roomId = scenario.roomId;
  }

  /// Initialize viewmodel with room ID and scenario (for use during build)
  /// Call this during create, then call notifyAfterInitialization() after build
  void initializeWithData(String? roomId, ScenarioEntity? scenario) {
    if (roomId != null) {
      _roomId = roomId;
    }
    if (scenario != null) {
      initializeScenario(scenario);
    }
  }

  /// Notify listeners after initialization (call this after build completes)
  void notifyAfterInitialization() {
    notifyListeners();
  }

  /// Reset viewmodel state
  void reset() {
    _currentStep = 0;
    _scenarioName = null;
    _scenarioDescription = null;
    _selectedIcon = null;
    _selectedColor = null;
    _actions.clear();
    _appSettings = null;
    _roomId = null;
    clearError();
    notifyListeners();
  }
}

