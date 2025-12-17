import '../entities/floor_entity.dart';

/// Floor Repository Interface  
/// This defines the contract for floor data operations
/// 
/// Usage example for future developers:
/// ```dart
/// // Getting all floors:
/// final floors = await floorRepository.getAllFloors();
/// 
/// // Adding a room to a floor:
/// await floorRepository.addRoomToFloor(
///   floorId: 'floor_1',
///   roomId: 'room_living',
/// );
/// 
/// // Creating a new floor:
/// final newFloor = FloorEntity(
///   id: uuid.v4(),
///   name: 'Second Floor',
///   icon: Icons.layers_rounded,
///   roomIds: [],
/// );
/// await floorRepository.createFloor(newFloor);
/// ```
abstract class FloorRepository {
  /// Get all floors in the system
  Future<List<FloorEntity>> getAllFloors();

  /// Get a single floor by ID
  Future<FloorEntity> getFloorById(String id);

  /// Create a new floor
  Future<FloorEntity> createFloor(FloorEntity floor);

  /// Update floor information (name, icon, order)
  Future<FloorEntity> updateFloor(FloorEntity floor);

  /// Delete a floor
  /// Note: This should handle moving rooms to a default floor or removing them
  Future<void> deleteFloor(String id);

  /// Add a room to a floor
  Future<FloorEntity> addRoomToFloor({
    required String floorId,
    required String roomId,
  });

  /// Remove a room from a floor
  Future<FloorEntity> removeRoomFromFloor({
    required String floorId,
    required String roomId,
  });

  /// Reorder floors (for custom sorting)
  Future<void> reorderFloors(List<String> floorIds);

  /// Get floor with room count
  Future<Map<String, int>> getFloorRoomCounts();

  /// Stream of floor updates (for real-time updates)
  Stream<List<FloorEntity>>? watchFloors();
}

