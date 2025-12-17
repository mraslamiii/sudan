import '../../repositories/scenario_repository.dart';

/// Execute Scenario Use Case
/// Executes a scenario (applies all its device actions)
/// 
/// Usage:
/// ```dart
/// await executeScenarioUseCase('scenario_movie_night');
/// ```
class ExecuteScenarioUseCase {
  final ScenarioRepository repository;

  ExecuteScenarioUseCase(this.repository);

  Future<void> call(String scenarioId) async {
    return await repository.executeScenario(scenarioId);
  }
}

