import '../../../core/constants/usb_serial_constants.dart';
import '../../../domain/entities/floor_entity.dart';
import '../../../domain/repositories/floor_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/usb_serial_repository.dart';
import '../../data_sources/local/floor/floor_local_data_source.dart';
import '../../models/floor_model.dart';

/// Floor Repository Implementation
/// Handles floor CRUD operations and room-floor associations.
/// When USB is connected to microcontroller, floor list is fetched from micro first.
///
/// For future developers:
/// - Floor management affects room filtering in the UI
/// - Can be extended with floor-based automation (e.g. "Turn off all First Floor devices")
/// - Can add floor templates for quick setup
class FloorRepositoryImpl implements FloorRepository {
  final FloorLocalDataSource _localDataSource;
  final RoomRepository _roomRepository;
  final UsbSerialRepository? _usbSerialRepository;

  FloorRepositoryImpl(
    this._localDataSource,
    this._roomRepository, [
    this._usbSerialRepository,
  ]);

  @override
  Future<List<FloorEntity>> getAllFloors() async {
    try {
      final usb = _usbSerialRepository;
      if (usb != null && usb.isConnected()) {
        final fromMicro = await usb.requestFloors();
        if (fromMicro != null && fromMicro.isNotEmpty) {
          final floors = fromMicro
              .map((e) => FloorModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          await _localDataSource.setFloorsFromMicro(floors);
          floors.sort((a, b) => a.order.compareTo(b.order));
          return floors;
        }
      }
      final floors = await _localDataSource.getCachedFloors();
      floors.sort((a, b) => a.order.compareTo(b.order));
      return floors;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FloorEntity> getFloorById(String id) async {
    final floors = await _localDataSource.getCachedFloors();
    return floors.firstWhere(
      (floor) => floor.id == id,
      orElse: () => throw Exception('Floor not found: $id'),
    );
  }

  @override
  Future<FloorEntity> createFloor(FloorEntity floor) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final floorModel = FloorModel(
      id: floor.id,
      name: floor.name,
      icon: floor.icon,
      roomIds: floor.roomIds,
      imageUrl: floor.imageUrl,
      order: floor.order,
    );

    await _localDataSource.addFloor(floorModel);

    final usb = _usbSerialRepository;
    if (usb != null && usb.isConnected()) {
      final payload = Map<String, dynamic>.from(floorModel.toJson())
        ..['action'] = UsbSerialConstants.actionCreateFloor;
      await usb.createFloorOnMicro(payload);
    }

    return floorModel;
  }

  @override
  Future<FloorEntity> updateFloor(FloorEntity floor) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final floorModel = FloorModel(
      id: floor.id,
      name: floor.name,
      icon: floor.icon,
      roomIds: floor.roomIds,
      imageUrl: floor.imageUrl,
      order: floor.order,
    );

    await _localDataSource.updateFloor(floorModel);
    return floorModel;
  }

  @override
  Future<void> deleteFloor(String id) async {
    print('🟡 [FLOOR_REPO] deleteFloor called for floorId: $id');
    await Future.delayed(const Duration(milliseconds: 200));

    // Delete all rooms belonging to this floor
    print('🟡 [FLOOR_REPO] Deleting all rooms for floor $id');
    await _roomRepository.deleteRoomsByFloorId(id);

    // Delete the floor itself
    await _localDataSource.deleteFloor(id);
    print('🟡 [FLOOR_REPO] Floor $id deleted successfully');
  }

  @override
  Future<FloorEntity> addRoomToFloor({
    required String floorId,
    required String roomId,
  }) async {
    final floor = await getFloorById(floorId);
    final updatedFloor = floor.addRoom(roomId);
    return await updateFloor(updatedFloor);
  }

  @override
  Future<FloorEntity> removeRoomFromFloor({
    required String floorId,
    required String roomId,
  }) async {
    final floor = await getFloorById(floorId);
    final updatedFloor = floor.removeRoom(roomId);
    return await updateFloor(updatedFloor);
  }

  @override
  Future<void> reorderFloors(List<String> floorIds) async {
    final floors = await getAllFloors();

    // Update order for each floor
    for (int i = 0; i < floorIds.length; i++) {
      final floorId = floorIds[i];
      final floor = floors.firstWhere((f) => f.id == floorId);
      final updatedFloor = floor.copyWith(order: i);
      await updateFloor(updatedFloor);
    }
  }

  @override
  Future<Map<String, int>> getFloorRoomCounts() async {
    final floors = await getAllFloors();
    return Map.fromEntries(
      floors.map((floor) => MapEntry(floor.id, floor.roomCount)),
    );
  }

  @override
  Stream<List<FloorEntity>>? watchFloors() {
    // TODO: Implement real-time floor updates
    // For now, returning null (not implemented)
    return null;
  }
}
