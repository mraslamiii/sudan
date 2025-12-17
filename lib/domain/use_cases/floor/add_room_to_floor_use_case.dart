import '../../repositories/floor_repository.dart';
import '../../entities/floor_entity.dart';

/// Add Room To Floor Use Case
/// Adds a room to a floor by updating the floor's room list
/// 
/// Usage:
/// ```dart
/// final updatedFloor = await addRoomToFloorUseCase(
///   floorId: 'floor_1',
///   roomId: 'room_living',
/// );
/// ```
class AddRoomToFloorUseCase {
  final FloorRepository repository;

  AddRoomToFloorUseCase(this.repository);

  Future<FloorEntity> call({
    required String floorId,
    required String roomId,
  }) async {
    return await repository.addRoomToFloor(
      floorId: floorId,
      roomId: roomId,
    );
  }
}

