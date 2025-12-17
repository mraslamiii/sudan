import '../../repositories/room_repository.dart';
import '../../entities/room_entity.dart';

/// Create Room Use Case
/// Creates a new room in the system
/// 
/// Usage:
/// ```dart
/// final newRoom = RoomEntity(
///   id: uuid.v4(),
///   name: 'Living Room',
///   icon: Icons.living_rounded,
///   deviceIds: [],
/// );
/// final createdRoom = await createRoomUseCase(newRoom);
/// ```
class CreateRoomUseCase {
  final RoomRepository repository;

  CreateRoomUseCase(this.repository);

  Future<RoomEntity> call(RoomEntity room) async {
    return await repository.createRoom(room);
  }
}

