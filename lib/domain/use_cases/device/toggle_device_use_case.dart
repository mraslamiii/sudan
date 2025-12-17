import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Toggle Device Use Case
/// Toggles a device on/off
/// 
/// Usage:
/// ```dart
/// final toggledDevice = await toggleDeviceUseCase('light_001');
/// ```
class ToggleDeviceUseCase {
  final DeviceRepository repository;

  ToggleDeviceUseCase(this.repository);

  Future<DeviceEntity> call(String deviceId) async {
    return await repository.toggleDevice(deviceId);
  }
}

