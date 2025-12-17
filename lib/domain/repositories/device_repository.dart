import '../entities/device_entity.dart';

/// Device Repository Interface
/// This defines the contract for device data operations
/// Implementations can use local storage, remote API, or mock data
/// 
/// Usage example for future developers:
/// ```dart
/// // In your repository implementation:
/// class DeviceRepositoryImpl implements DeviceRepository {
///   final DeviceRemoteDataSource remoteDataSource;
///   final DeviceLocalDataSource localDataSource;
///   
///   @override
///   Future<List<DeviceEntity>> getAllDevices() async {
///     try {
///       // Try to fetch from remote API
///       final devices = await remoteDataSource.getDevices();
///       // Cache locally
///       await localDataSource.cacheDevices(devices);
///       return devices;
///     } catch (e) {
///       // Fallback to local cache
///       return await localDataSource.getCachedDevices();
///     }
///   }
/// }
/// ```
abstract class DeviceRepository {
  /// Get all devices in the system
  Future<List<DeviceEntity>> getAllDevices();

  /// Get devices filtered by room
  Future<List<DeviceEntity>> getDevicesByRoom(String roomId);

  /// Get a single device by ID
  Future<DeviceEntity> getDeviceById(String id);

  /// Get devices by type
  Future<List<DeviceEntity>> getDevicesByType(DeviceType type);

  /// Update device state
  /// This is the main method for controlling devices
  Future<DeviceEntity> updateDevice(DeviceEntity device);

  /// Toggle device on/off
  /// Convenience method for simple on/off operations
  Future<DeviceEntity> toggleDevice(String deviceId);

  /// Add a new device to the system
  Future<DeviceEntity> addDevice(DeviceEntity device);

  /// Remove a device from the system
  Future<void> removeDevice(String deviceId);

  /// Update device name or room
  Future<DeviceEntity> updateDeviceInfo({
    required String deviceId,
    String? name,
    String? roomId,
  });

  /// Check if device is online/responsive
  Future<bool> checkDeviceStatus(String deviceId);

  /// Stream of device updates (for real-time updates)
  /// Optional: Can be implemented if you need real-time device state updates
  Stream<DeviceEntity>? watchDevice(String deviceId);

  /// Stream of all devices (for real-time updates)
  Stream<List<DeviceEntity>>? watchAllDevices();
}

