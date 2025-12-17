import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Get Device By ID Use Case
/// Retrieves a specific device by its ID
/// 
/// Usage:
/// ```dart
/// final device = await getDeviceByIdUseCase('light_001');
/// ```
class GetDeviceByIdUseCase {
  final DeviceRepository repository;

  GetDeviceByIdUseCase(this.repository);

  Future<DeviceEntity> call(String deviceId) async {
    return await repository.getDeviceById(deviceId);
  }
}

