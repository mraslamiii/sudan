import '../entities/scenario_entity.dart';

/// Scenario Repository Interface
/// This defines the contract for scenario data operations
/// 
/// Usage example for future developers:
/// ```dart
/// // Creating a new scenario:
/// final scenario = ScenarioEntity(
///   id: uuid.v4(),
///   name: 'Good Night',
///   icon: Icons.bedtime_rounded,
///   color: Colors.purple,
///   actions: [
///     ScenarioAction(deviceId: 'light_001', targetState: LightState(isOn: false)),
///     ScenarioAction(deviceId: 'tv_001', targetState: SimpleState(isOn: false)),
///   ],
///   createdAt: DateTime.now(),
/// );
/// await scenarioRepository.createScenario(scenario);
/// 
/// // Executing a scenario:
/// await scenarioRepository.executeScenario(scenario.id);
/// ```
abstract class ScenarioRepository {
  /// Get all scenarios
  Future<List<ScenarioEntity>> getAllScenarios();

  /// Get a single scenario by ID
  Future<ScenarioEntity> getScenarioById(String id);

  /// Create a new scenario
  Future<ScenarioEntity> createScenario(ScenarioEntity scenario);

  /// Update an existing scenario
  Future<ScenarioEntity> updateScenario(ScenarioEntity scenario);

  /// Delete a scenario
  Future<void> deleteScenario(String id);

  /// Execute a scenario (apply all its actions)
  /// This should trigger device state changes through the device repository
  Future<void> executeScenario(String id);

  /// Get recently executed scenarios
  Future<List<ScenarioEntity>> getRecentScenarios({int limit = 5});

  /// Stream of scenario updates (for real-time updates)
  Stream<List<ScenarioEntity>>? watchScenarios();

  /// Check if a scenario name already exists
  Future<bool> isNameAvailable(String name, {String? excludeId});
}

