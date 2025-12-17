import '../../repositories/scenario_repository.dart';
import '../../entities/scenario_entity.dart';

/// Get All Scenarios Use Case
/// Retrieves all scenarios from the repository
/// 
/// Usage:
/// ```dart
/// final scenarios = await getAllScenariosUseCase();
/// ```
class GetAllScenariosUseCase {
  final ScenarioRepository repository;

  GetAllScenariosUseCase(this.repository);

  Future<List<ScenarioEntity>> call() async {
    return await repository.getAllScenarios();
  }
}

