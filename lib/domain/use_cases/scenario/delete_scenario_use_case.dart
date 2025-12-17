import '../../repositories/scenario_repository.dart';

/// Delete Scenario Use Case
/// Deletes a scenario
/// 
/// Usage:
/// ```dart
/// await deleteScenarioUseCase('scenario_001');
/// ```
class DeleteScenarioUseCase {
  final ScenarioRepository repository;

  DeleteScenarioUseCase(this.repository);

  Future<void> call(String scenarioId) async {
    return await repository.deleteScenario(scenarioId);
  }
}

