import '../../repositories/floor_repository.dart';
import '../../entities/floor_entity.dart';

/// Get All Floors Use Case
/// Retrieves all floors from the repository
/// 
/// Usage:
/// ```dart
/// final floors = await getAllFloorsUseCase();
/// ```
class GetAllFloorsUseCase {
  final FloorRepository repository;

  GetAllFloorsUseCase(this.repository);

  Future<List<FloorEntity>> call() async {
    return await repository.getAllFloors();
  }
}

