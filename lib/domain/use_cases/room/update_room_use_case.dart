import '../../repositories/room_repository.dart';
import '../../entities/room_entity.dart';

/// Update Room Use Case
/// Updates an existing room in the system
/// 
/// Usage:
/// ```dart
/// final updatedRoom = room.copyWith(name: 'New Name');
/// final result = await updateRoomUseCase(updatedRoom);
/// ```
class UpdateRoomUseCase {
  final RoomRepository repository;

  UpdateRoomUseCase(this.repository);

  Future<RoomEntity> call(RoomEntity room) async {
    return await repository.updateRoom(room);
  }
}

