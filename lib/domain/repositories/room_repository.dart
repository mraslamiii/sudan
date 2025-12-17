import '../entities/room_entity.dart';

/// Room Repository Interface  
/// This defines the contract for room data operations
/// 
/// Usage example for future developers:
/// ```dart
/// // Getting all rooms:
/// final rooms = await roomRepository.getAllRooms();
/// 
/// // Adding a device to a room:
/// await roomRepository.addDeviceToRoom(
///   roomId: 'room_living',
///   deviceId: 'light_001',
/// );
/// 
/// // Creating a new room:
/// final newRoom = RoomEntity(
///   id: uuid.v4(),
///   name: 'Office',
///   icon: Icons.work_rounded,
///   deviceIds: [],
/// );
/// await roomRepository.createRoom(newRoom);
/// ```
abstract class RoomRepository {
  /// Get all rooms in the system
  Future<List<RoomEntity>> getAllRooms();

  /// Get a single room by ID
  Future<RoomEntity> getRoomById(String id);

  /// Create a new room
  Future<RoomEntity> createRoom(RoomEntity room);

  /// Update room information (name, icon, order)
  Future<RoomEntity> updateRoom(RoomEntity room);

  /// Delete a room
  /// Note: This should handle moving devices to a default room or removing them
  Future<void> deleteRoom(String id);

  /// Delete all rooms belonging to a specific floor
  /// This is called when a floor is deleted
  Future<void> deleteRoomsByFloorId(String floorId);

  /// Add a device to a room
  Future<RoomEntity> addDeviceToRoom({
    required String roomId,
    required String deviceId,
  });

  /// Remove a device from a room
  Future<RoomEntity> removeDeviceFromRoom({
    required String roomId,
    required String deviceId,
  });

  /// Reorder rooms (for custom sorting)
  Future<void> reorderRooms(List<String> roomIds);

  /// Get room with device count
  Future<Map<String, int>> getRoomDeviceCounts();

  /// Stream of room updates (for real-time updates)
  Stream<List<RoomEntity>>? watchRooms();
}

