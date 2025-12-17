import '../../repositories/room_repository.dart';
import '../../entities/room_entity.dart';

/// Get Room By ID Use Case
/// Retrieves a specific room by its ID
/// 
/// Usage:
/// ```dart
/// final room = await getRoomByIdUseCase('room_living');
/// ```
class GetRoomByIdUseCase {
  final RoomRepository repository;

  GetRoomByIdUseCase(this.repository);

  Future<RoomEntity> call(String roomId) async {
    return await repository.getRoomById(roomId);
  }
}

