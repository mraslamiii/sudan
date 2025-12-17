import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Update Device Use Case
/// Updates a device's state
/// 
/// Usage:
/// ```dart
/// final updatedDevice = device.copyWith(
///   state: LightState(isOn: true, brightness: 80, color: Colors.white),
/// );
/// await updateDeviceUseCase(updatedDevice);
/// ```
class UpdateDeviceUseCase {
  final DeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  Future<DeviceEntity> call(DeviceEntity device) async {
    return await repository.updateDevice(device);
  }
}

