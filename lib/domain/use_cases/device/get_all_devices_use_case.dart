import '../../repositories/device_repository.dart';
import '../../entities/device_entity.dart';

/// Get All Devices Use Case
/// Retrieves all devices from the repository
/// 
/// Usage:
/// ```dart
/// final devices = await getAllDevicesUseCase();
/// ```
class GetAllDevicesUseCase {
  final DeviceRepository repository;

  GetAllDevicesUseCase(this.repository);

  Future<List<DeviceEntity>> call() async {
    return await repository.getAllDevices();
  }
}

