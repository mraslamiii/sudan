import '../../repositories/room_repository.dart';
import '../../repositories/device_repository.dart';
import '../../entities/room_entity.dart';

/// Add Device To Room Use Case
/// Adds a device to a room by updating both the room's device list and the device's roomId
/// 
/// Usage:
/// ```dart
/// final updatedRoom = await addDeviceToRoomUseCase(
///   roomId: 'room_living',
///   deviceId: 'light_001',
/// );
/// ```
class AddDeviceToRoomUseCase {
  final RoomRepository roomRepository;
  final DeviceRepository deviceRepository;

  AddDeviceToRoomUseCase(this.roomRepository, this.deviceRepository);

  Future<RoomEntity> call({
    required String roomId,
    required String deviceId,
  }) async {
    // Update the device's roomId
    await deviceRepository.updateDeviceInfo(
      deviceId: deviceId,
      roomId: roomId,
    );
    
    // Update the room's device list
    return await roomRepository.addDeviceToRoom(
      roomId: roomId,
      deviceId: deviceId,
    );
  }
}

