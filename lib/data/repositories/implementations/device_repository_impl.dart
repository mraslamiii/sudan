import '../../../domain/entities/device_entity.dart';
import '../../../domain/repositories/device_repository.dart';
import '../../data_sources/local/device/device_local_data_source.dart';
import '../../models/device_model.dart';

/// Device Repository Implementation
/// This is the concrete implementation of the DeviceRepository interface
/// Currently uses local data source, but can be extended to use remote API
/// 
/// For future developers:
/// To add real API support:
/// 1. Create a DeviceRemoteDataSource class
/// 2. Inject it alongside the local data source
/// 3. Try remote first, fallback to local on failure
/// 4. Cache remote data locally for offline support
/// 
/// Example with API:
/// ```dart
/// class DeviceRepositoryImpl implements DeviceRepository {
///   final DeviceRemoteDataSource _remoteDataSource;
///   final DeviceLocalDataSource _localDataSource;
///   
///   @override
///   Future<List<DeviceEntity>> getAllDevices() async {
///     try {
///       final devices = await _remoteDataSource.getDevices();
///       await _localDataSource.cacheDevices(devices);
///       return devices;
///     } catch (e) {
///       return await _localDataSource.getCachedDevices();
///     }
///   }
/// }
/// ```
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource _localDataSource;

  DeviceRepositoryImpl(this._localDataSource);

  @override
  Future<List<DeviceEntity>> getAllDevices() async {
    return await _localDataSource.getCachedDevices();
  }

  @override
  Future<List<DeviceEntity>> getDevicesByRoom(String roomId) async {
    final allDevices = await _localDataSource.getCachedDevices();
    // Return only devices that belong to this room (including general room)
    return allDevices.where((device) => device.roomId == roomId).toList();
  }

  @override
  Future<DeviceEntity> getDeviceById(String id) async {
    final allDevices = await _localDataSource.getCachedDevices();
    return allDevices.firstWhere(
      (device) => device.id == id,
      orElse: () => throw Exception('Device not found: $id'),
    );
  }

  @override
  Future<List<DeviceEntity>> getDevicesByType(DeviceType type) async {
    final allDevices = await _localDataSource.getCachedDevices();
    return allDevices.where((device) => device.type == type).toList();
  }

  @override
  Future<DeviceEntity> updateDevice(DeviceEntity device) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final deviceModel = DeviceModel(
      id: device.id,
      name: device.name,
      type: device.type,
      roomId: device.roomId,
      state: device.state,
      icon: device.icon,
      isOnline: device.isOnline,
      lastUpdated: DateTime.now(),
    );
    
    await _localDataSource.updateDevice(deviceModel);
    return deviceModel;
  }

  @override
  Future<DeviceEntity> toggleDevice(String deviceId) async {
    final device = await getDeviceById(deviceId);
    
    // Create toggled state based on device type
    DeviceState newState;
    final currentState = device.state;
    
    if (currentState is LightState) {
      newState = currentState.copyWith(isOn: !currentState.isOn);
    } else if (currentState is ThermostatState) {
      newState = currentState.copyWith(isOn: !currentState.isOn);
    } else if (currentState is CameraState) {
      newState = currentState.copyWith(isOn: !currentState.isOn);
    } else if (currentState is SimpleState) {
      newState = currentState.copyWith(isOn: !currentState.isOn);
    } else if (currentState is MusicState) {
      newState = currentState.copyWith(isPlaying: !currentState.isPlaying);
    } else if (currentState is SecurityState) {
      newState = currentState.copyWith(isActive: !currentState.isActive);
    } else if (currentState is CurtainState) {
      newState = currentState.copyWith(
        isOpen: !currentState.isOpen,
        position: currentState.isOpen ? 0 : 100,
      );
    } else {
      newState = currentState;
    }
    
    return await updateDevice(device.copyWith(state: newState));
  }

  @override
  Future<DeviceEntity> addDevice(DeviceEntity device) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final deviceModel = DeviceModel(
      id: device.id,
      name: device.name,
      type: device.type,
      roomId: device.roomId,
      state: device.state,
      icon: device.icon,
      isOnline: device.isOnline,
      lastUpdated: DateTime.now(),
    );
    
    await _localDataSource.updateDevice(deviceModel);
    return deviceModel;
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _localDataSource.deleteDevice(deviceId);
  }

  @override
  Future<DeviceEntity> updateDeviceInfo({
    required String deviceId,
    String? name,
    String? roomId,
  }) async {
    final device = await getDeviceById(deviceId);
    final updatedDevice = device.copyWith(
      name: name,
      roomId: roomId,
    );
    return await updateDevice(updatedDevice);
  }

  @override
  Future<bool> checkDeviceStatus(String deviceId) async {
    try {
      final device = await getDeviceById(deviceId);
      return device.isOnline;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<DeviceEntity>? watchDevice(String deviceId) {
    // TODO: Implement real-time device updates with WebSocket or Firebase
    // For now, returning null (not implemented)
    return null;
  }

  @override
  Stream<List<DeviceEntity>>? watchAllDevices() {
    // TODO: Implement real-time device updates with WebSocket or Firebase
    // For now, returning null (not implemented)
    return null;
  }
}

