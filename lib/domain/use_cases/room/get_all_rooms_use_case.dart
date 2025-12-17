import '../../repositories/room_repository.dart';
import '../../entities/room_entity.dart';

/// Get All Rooms Use Case
/// Retrieves all rooms from the repository
/// 
/// Usage:
/// ```dart
/// final rooms = await getAllRoomsUseCase();
/// ```
class GetAllRoomsUseCase {
  final RoomRepository repository;

  GetAllRoomsUseCase(this.repository);

  Future<List<RoomEntity>> call() async {
    return await repository.getAllRooms();
  }
}

