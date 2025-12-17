import '../../repositories/floor_repository.dart';
import '../../entities/floor_entity.dart';

/// Update Floor Use Case
/// Updates an existing floor's information
/// 
/// Usage:
/// ```dart
/// final updatedFloor = floor.copyWith(name: 'Updated Name');
/// await updateFloorUseCase(updatedFloor);
/// ```
class UpdateFloorUseCase {
  final FloorRepository repository;

  UpdateFloorUseCase(this.repository);

  Future<FloorEntity> call(FloorEntity floor) async {
    return await repository.updateFloor(floor);
  }
}

