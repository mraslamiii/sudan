import '../../repositories/scenario_repository.dart';
import '../../entities/scenario_entity.dart';

/// Create Scenario Use Case
/// Creates a new scenario
/// 
/// Usage:
/// ```dart
/// final scenario = ScenarioEntity(...);
/// await createScenarioUseCase(scenario);
/// ```
class CreateScenarioUseCase {
  final ScenarioRepository repository;

  CreateScenarioUseCase(this.repository);

  Future<ScenarioEntity> call(ScenarioEntity scenario) async {
    return await repository.createScenario(scenario);
  }
}

