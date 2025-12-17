import '../../repositories/floor_repository.dart';

/// Delete Floor Use Case
/// Deletes a floor from the system
/// 
/// Usage:
/// ```dart
/// await deleteFloorUseCase('floor_1');
/// ```
class DeleteFloorUseCase {
  final FloorRepository repository;

  DeleteFloorUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteFloor(id);
  }
}

