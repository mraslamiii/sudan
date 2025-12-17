import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/use_cases/room/create_room_use_case.dart';
import '../../domain/use_cases/room/get_all_rooms_use_case.dart';
import '../../domain/use_cases/device/create_device_use_case.dart';
import '../../domain/use_cases/device/add_device_to_room_use_case.dart';
import '../../domain/use_cases/floor/add_room_to_floor_use_case.dart';

/// Room Setup ViewModel
/// Manages the step-by-step room creation flow
/// 
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<RoomSetupViewModel>();
/// final currentStep = viewModel.currentStep;
/// 
/// // Navigate to next step
/// viewModel.nextStep();
/// 
/// // Save room
/// await viewModel.saveRoom();
/// ```
class RoomSetupViewModel extends BaseViewModel {
  final CreateRoomUseCase _createRoomUseCase;
  final GetAllRoomsUseCase _getAllRoomsUseCase;
  final CreateDeviceUseCase _createDeviceUseCase;
  final AddDeviceToRoomUseCase _addDeviceToRoomUseCase;
  final AddRoomToFloorUseCase _addRoomToFloorUseCase;

  String? _floorId; // Floor ID for the room being created
  bool _isSaving = false; // Flag to prevent multiple simultaneous saves

  int _currentStep = 0;
  String? _roomName;
  String? _roomDescription;
  IconData? _selectedIcon;
  List<DeviceEntity> _selectedDevices = [];
  final List<DeviceEntity> _newDevicesToCreate = [];

  RoomSetupViewModel(
    this._createRoomUseCase,
    this._getAllRoomsUseCase,
    this._createDeviceUseCase,
    this._addDeviceToRoomUseCase,
    this._addRoomToFloorUseCase,
  );

  // Floor ID getter/setter
  String? get floorId => _floorId;
  
  void setFloorId(String? floorId) {
    _floorId = floorId;
    notifyListeners();
  }

  // Getters
  int get currentStep => _currentStep;
  String? get roomName => _roomName;
  String? get roomDescription => _roomDescription;
  IconData? get selectedIcon => _selectedIcon;
  List<DeviceEntity> get selectedDevices => _selectedDevices;
  List<DeviceEntity> get newDevicesToCreate => _newDevicesToCreate;
  bool get canGoNext => validateCurrentStep();
  bool get canGoBack => _currentStep > 0;
  bool get isLastStep => _currentStep >= 3;

  /// Set room name
  void setRoomName(String? name) {
    _roomName = name;
    notifyListeners();
  }

  /// Set room description
  void setRoomDescription(String? description) {
    _roomDescription = description;
    notifyListeners();
  }

  /// Set selected icon
  void setSelectedIcon(IconData icon) {
    _selectedIcon = icon;
    notifyListeners();
  }

  /// Add device to selection
  void addDevice(DeviceEntity device) {
    if (!_selectedDevices.any((d) => d.id == device.id)) {
      _selectedDevices.add(device);
      notifyListeners();
    }
  }

  /// Remove device from selection
  void removeDevice(String deviceId) {
    _selectedDevices.removeWhere((d) => d.id == deviceId);
    _newDevicesToCreate.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  /// Add new device to be created
  void addNewDevice(DeviceEntity device) {
    _newDevicesToCreate.add(device);
    addDevice(device);
  }

  /// Remove new device by type (for checkbox-based selection)
  void removeNewDeviceByType(DeviceType type) {
    final deviceToRemove = _newDevicesToCreate.firstWhere(
      (d) => d.type == type,
      orElse: () => _selectedDevices.firstWhere(
        (d) => d.type == type,
        orElse: () => throw StateError('Device not found'),
      ),
    );
    removeDevice(deviceToRemove.id);
  }

  /// Navigate to next step
  void nextStep() {
    if (!validateCurrentStep()) return;
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        return _roomName != null && _roomName!.trim().isNotEmpty;
      case 1: // Icon selection
        return _selectedIcon != null;
      case 2: // Device selection (optional)
        return true; // Devices are optional
      case 3: // Review
        return true;
      default:
        return false;
    }
  }

  /// Save room and devices
  Future<bool> saveRoom() async {
    print('🟢 [ROOM_SETUP_VM] saveRoom called');
    print('   - _isSaving: $_isSaving');
    print('   - isLoading: $isLoading');
    print('   - Room Name: $_roomName');
    print('   - Floor ID: $_floorId');
    
    // Prevent multiple simultaneous saves
    if (_isSaving || isLoading) {
      print('🟢 [ROOM_SETUP_VM] Already saving or loading, returning false');
      return false;
    }
    
    if (!validateCurrentStep()) {
      print('🟢 [ROOM_SETUP_VM] Validation failed');
      setError('Please complete all required fields');
      return false;
    }

    _isSaving = true;
    print('🟢 [ROOM_SETUP_VM] Set _isSaving = true');
    try {
      setLoading(true);
      clearError();

      // Generate room ID
      final roomId = const Uuid().v4();
      print('🟢 [ROOM_SETUP_VM] Generated room ID: $roomId');
      final existingRooms = await _getExistingRoomsCount();
      print('🟢 [ROOM_SETUP_VM] Existing rooms count: $existingRooms');
      
      // Create room entity
      final room = RoomEntity(
        id: roomId,
        name: _roomName!.trim(),
        icon: _selectedIcon!,
        deviceIds: [],
        order: existingRooms,
        floorId: _floorId, // Set floor ID
      );
      print('🟢 [ROOM_SETUP_VM] Created room entity:');
      print('   - ID: ${room.id}');
      print('   - Name: ${room.name}');
      print('   - FloorId: ${room.floorId}');
      print('   - Order: ${room.order}');

      // Create room
      print('🟢 [ROOM_SETUP_VM] Calling createRoomUseCase...');
      final createdRoom = await _createRoomUseCase(room);
      print('🟢 [ROOM_SETUP_VM] Room created in repository:');
      print('   - ID: ${createdRoom.id}');
      print('   - Name: ${createdRoom.name}');
      print('   - FloorId: ${createdRoom.floorId}');

      // Add room to floor if floorId is provided
      if (_floorId != null) {
        print('🟢 [ROOM_SETUP_VM] Adding room to floor: $_floorId');
        await _addRoomToFloorUseCase(
          floorId: _floorId!,
          roomId: createdRoom.id,
        );
        print('🟢 [ROOM_SETUP_VM] Room added to floor');
      } else {
        print('🟢 [ROOM_SETUP_VM] No floorId, skipping addRoomToFloor');
      }

      // Create new devices first
      for (final device in _newDevicesToCreate) {
        final deviceWithRoom = device.copyWith(roomId: createdRoom.id);
        final createdDevice = await _createDeviceUseCase(deviceWithRoom);
        
        // Add device to room
        await _addDeviceToRoomUseCase(
          roomId: createdRoom.id,
          deviceId: createdDevice.id,
        );
      }

      // Add existing devices to room
      for (final device in _selectedDevices) {
        if (!_newDevicesToCreate.any((d) => d.id == device.id)) {
          await _addDeviceToRoomUseCase(
            roomId: createdRoom.id,
            deviceId: device.id,
          );
        }
      }

      setLoading(false);
      _isSaving = false;
      return true;
    } catch (e) {
      setLoading(false);
      _isSaving = false;
      setError('Failed to save room: ${e.toString()}');
      return false;
    }
  }

  /// Get count of existing rooms (for order)
  Future<int> _getExistingRoomsCount() async {
    final rooms = await _getAllRoomsUseCase();
    return rooms.length;
  }

  /// Reset viewmodel state
  void reset() {
    _currentStep = 0;
    _roomName = null;
    _roomDescription = null;
    _selectedIcon = null;
    _selectedDevices.clear();
    _newDevicesToCreate.clear();
    _floorId = null;
    _isSaving = false;
    clearError();
    notifyListeners();
  }
}

