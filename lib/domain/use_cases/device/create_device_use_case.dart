import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Create Device Use Case
/// Creates a new device in the system
/// 
/// Usage:
/// ```dart
/// final newDevice = DeviceEntity(
///   id: uuid.v4(),
///   name: 'Living Room Light',
///   type: DeviceType.light,
///   roomId: 'room_living',
///   state: LightState(isOn: false, brightness: 80, color: Colors.white),
///   lastUpdated: DateTime.now(),
/// );
/// final createdDevice = await createDeviceUseCase(newDevice);
/// ```
class CreateDeviceUseCase {
  final DeviceRepository repository;

  CreateDeviceUseCase(this.repository);

  Future<DeviceEntity> call(DeviceEntity device) async {
    return await repository.addDevice(device);
  }
}

