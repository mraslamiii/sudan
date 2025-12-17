import '../../repositories/scenario_repository.dart';
import '../../entities/scenario_entity.dart';

/// Update Scenario Use Case
/// Updates an existing scenario
/// 
/// Usage:
/// ```dart
/// final updatedScenario = scenario.copyWith(name: 'New Name');
/// await updateScenarioUseCase(updatedScenario);
/// ```
class UpdateScenarioUseCase {
  final ScenarioRepository repository;

  UpdateScenarioUseCase(this.repository);

  Future<ScenarioEntity> call(ScenarioEntity scenario) async {
    return await repository.updateScenario(scenario);
  }
}

