import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Get Devices By Room Use Case
/// Retrieves all devices in a specific room
/// 
/// Usage:
/// ```dart
/// final livingRoomDevices = await getDevicesByRoomUseCase('room_living');
/// ```
class GetDevicesByRoomUseCase {
  final DeviceRepository repository;

  GetDevicesByRoomUseCase(this.repository);

  Future<List<DeviceEntity>> call(String roomId) async {
    return await repository.getDevicesByRoom(roomId);
  }
}

