import '../../../domain/entities/room_entity.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/usb_serial_repository.dart';
import '../../data_sources/local/room/room_local_data_source.dart';
import '../../models/room_model.dart';

/// Room Repository Implementation
/// Handles room CRUD operations and device-room associations.
/// When USB is connected to microcontroller, room list is fetched from micro and cached locally.
///
/// For future developers:
/// - Room management affects device filtering in the UI
/// - Can be extended with room-based automation (e.g. "Turn off all Living Room devices")
/// - Can add room templates for quick setup
class RoomRepositoryImpl implements RoomRepository {
  final RoomLocalDataSource _localDataSource;
  final UsbSerialRepository? _usbSerialRepository;

  RoomRepositoryImpl(this._localDataSource, [this._usbSerialRepository]);

  @override
  Future<List<RoomEntity>> getAllRooms() async {
    // When USB is connected, try to get room list from microcontroller
    final usb = _usbSerialRepository;
    if (usb != null && usb.isConnected()) {
      final fromMicro = await usb.requestRooms();
      if (fromMicro != null && fromMicro.isNotEmpty) {
        final rooms = fromMicro
            .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        await _localDataSource.setRoomsFromMicro(rooms);
        rooms.sort((a, b) => a.order.compareTo(b.order));
        return rooms;
      }
    }
    final rooms = await _localDataSource.getCachedRooms();
    rooms.sort((a, b) => a.order.compareTo(b.order));
    return rooms;
  }

  @override
  Future<RoomEntity> getRoomById(String id) async {
    final rooms = await _localDataSource.getCachedRooms();
    return rooms.firstWhere(
      (room) => room.id == id,
      orElse: () => throw Exception('Room not found: $id'),
    );
  }

  @override
  Future<RoomEntity> createRoom(RoomEntity room) async {
    print('🟡 [ROOM_REPO] createRoom called');
    print('   - ID: ${room.id}');
    print('   - Name: ${room.name}');
    print('   - FloorId: ${room.floorId}');
    print('   - Order: ${room.order}');

    await Future.delayed(const Duration(milliseconds: 200));

    final roomModel = RoomModel(
      id: room.id,
      name: room.name,
      icon: room.icon,
      deviceIds: room.deviceIds,
      imageUrl: room.imageUrl,
      order: room.order,
      floorId: room.floorId,
    );

    print('🟡 [ROOM_REPO] Created RoomModel, calling addRoom...');
    await _localDataSource.addRoom(roomModel);

    final usb = _usbSerialRepository;
    if (usb != null && usb.isConnected()) {
      await usb.createRoomOnMicro(roomModel.toJson());
    }

    print('🟡 [ROOM_REPO] Room added to data source successfully');
    return roomModel;
  }

  @override
  Future<RoomEntity> updateRoom(RoomEntity room) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final roomModel = RoomModel(
      id: room.id,
      name: room.name,
      icon: room.icon,
      deviceIds: room.deviceIds,
      imageUrl: room.imageUrl,
      order: room.order,
      floorId: room.floorId,
    );

    await _localDataSource.updateRoom(roomModel);

    final usb = _usbSerialRepository;
    if (usb != null && usb.isConnected()) {
      await usb.updateRoomOnMicro(roomModel.toJson());
    }

    return roomModel;
  }

  @override
  Future<void> deleteRoom(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final usb = _usbSerialRepository;
    if (usb != null && usb.isConnected()) {
      await usb.deleteRoomOnMicro(id);
    }

    await _localDataSource.deleteRoom(id);
  }

  @override
  Future<void> deleteRoomsByFloorId(String floorId) async {
    print('🟡 [ROOM_REPO] deleteRoomsByFloorId called for floorId: $floorId');
    await Future.delayed(const Duration(milliseconds: 200));
    await _localDataSource.deleteRoomsByFloorId(floorId);
    print('🟡 [ROOM_REPO] Deleted all rooms for floor $floorId');
  }

  @override
  Future<RoomEntity> addDeviceToRoom({
    required String roomId,
    required String deviceId,
  }) async {
    final room = await getRoomById(roomId);
    final updatedRoom = room.addDevice(deviceId);
    return await updateRoom(updatedRoom);
  }

  @override
  Future<RoomEntity> removeDeviceFromRoom({
    required String roomId,
    required String deviceId,
  }) async {
    final room = await getRoomById(roomId);
    final updatedRoom = room.removeDevice(deviceId);
    return await updateRoom(updatedRoom);
  }

  @override
  Future<void> reorderRooms(List<String> roomIds) async {
    final rooms = await getAllRooms();

    // Update order for each room
    for (int i = 0; i < roomIds.length; i++) {
      final roomId = roomIds[i];
      final room = rooms.firstWhere((r) => r.id == roomId);
      final updatedRoom = room.copyWith(order: i);
      await updateRoom(updatedRoom);
    }
  }

  @override
  Future<Map<String, int>> getRoomDeviceCounts() async {
    final rooms = await getAllRooms();
    return Map.fromEntries(
      rooms.map((room) => MapEntry(room.id, room.deviceCount)),
    );
  }

  @override
  Stream<List<RoomEntity>>? watchRooms() {
    // TODO: Implement real-time room updates
    // For now, returning null (not implemented)
    return null;
  }
}
