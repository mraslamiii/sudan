import '../../repositories/floor_repository.dart';
import '../../entities/floor_entity.dart';

/// Get Floor By ID Use Case
/// Retrieves a single floor by its ID
/// 
/// Usage:
/// ```dart
/// final floor = await getFloorByIdUseCase('floor_1');
/// ```
class GetFloorByIdUseCase {
  final FloorRepository repository;

  GetFloorByIdUseCase(this.repository);

  Future<FloorEntity> call(String id) async {
    return await repository.getFloorById(id);
  }
}

