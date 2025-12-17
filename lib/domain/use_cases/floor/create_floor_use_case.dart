import '../../repositories/floor_repository.dart';
import '../../entities/floor_entity.dart';

/// Create Floor Use Case
/// Creates a new floor in the system
/// 
/// Usage:
/// ```dart
/// final newFloor = FloorEntity(
///   id: uuid.v4(),
///   name: 'Second Floor',
///   icon: Icons.layers_rounded,
///   roomIds: [],
/// );
/// final createdFloor = await createFloorUseCase(newFloor);
/// ```
class CreateFloorUseCase {
  final FloorRepository repository;

  CreateFloorUseCase(this.repository);

  Future<FloorEntity> call(FloorEntity floor) async {
    return await repository.createFloor(floor);
  }
}

