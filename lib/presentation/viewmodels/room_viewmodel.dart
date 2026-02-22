import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/use_cases/room/get_all_rooms_use_case.dart';
import '../../domain/use_cases/room/get_room_by_id_use_case.dart';

/// Room ViewModel
/// Manages room selection and room-related state
///
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<RoomViewModel>();
/// final rooms = viewModel.rooms;
/// final selectedRoom = viewModel.selectedRoom;
///
/// // Switch to a different room
/// await viewModel.selectRoom('room_bedroom');
/// ```
class RoomViewModel extends BaseViewModel {
  final GetAllRoomsUseCase _getAllRoomsUseCase;
  final GetRoomByIdUseCase _getRoomByIdUseCase;

  List<RoomEntity> _allRooms = []; // All rooms from repository
  List<RoomEntity> _rooms = []; // Filtered rooms by floor
  String? _selectedRoomId;
  RoomEntity? _selectedRoom;
  String? _selectedFloorId; // Current floor filter
  bool _loadRoomsInProgress = false;

  RoomViewModel(this._getAllRoomsUseCase, this._getRoomByIdUseCase);

  // Getters
  List<RoomEntity> get rooms => _rooms; // Returns filtered rooms
  List<RoomEntity> get allRooms => _allRooms; // Returns all rooms
  String? get selectedRoomId => _selectedRoomId;
  RoomEntity? get selectedRoom => _selectedRoom;
  String? get selectedFloorId => _selectedFloorId;

  @override
  void init() {
    super.init();
    loadRooms();
  }

  /// Load all rooms
  Future<void> loadRooms({String? floorId}) async {
    if (_loadRoomsInProgress) return;
    _loadRoomsInProgress = true;
    print('🟡 [ROOM_VM] loadRooms called with floorId: $floorId');
    try {
      setLoading(true);
      clearError();

      _allRooms = await _getAllRoomsUseCase();
      print('🟡 [ROOM_VM] Loaded ${_allRooms.length} total rooms');
      for (var room in _allRooms) {
        print('   - ${room.name} (ID: ${room.id}, FloorId: ${room.floorId})');
      }

      // Filter rooms by floor if floorId is provided
      if (floorId != null) {
        print('🟡 [ROOM_VM] Filtering rooms for floor: $floorId');
        // Always reset selected room when loading rooms for a specific floor
        // This ensures we don't show dashboard from a different floor
        final isFloorChanging =
            _selectedFloorId != null && _selectedFloorId != floorId;
        if (isFloorChanging) {
          _selectedRoomId = null;
          _selectedRoom = null;
        }

        _selectedFloorId = floorId;
        // Include general room and rooms for this floor
        _rooms = _allRooms
            .where((r) => r.isGeneral || r.floorId == floorId)
            .toList();
        // Sort: general room first, then by order
        _rooms.sort((a, b) {
          if (a.isGeneral) return -1;
          if (b.isGeneral) return 1;
          return a.order.compareTo(b.order);
        });
        print(
          '🟡 [ROOM_VM] Filtered ${_rooms.length} rooms for floor $floorId',
        );
        for (var room in _rooms) {
          print(
            '   - ${room.name} (ID: ${room.id}, isGeneral: ${room.isGeneral})',
          );
        }

        // Also reset if selected room doesn't belong to the new floor
        if (_selectedRoomId != null) {
          final selectedRoomBelongsToFloor = _rooms.any(
            (r) => r.id == _selectedRoomId,
          );
          if (!selectedRoomBelongsToFloor) {
            print(
              '🟡 [ROOM_VM] Selected room does not belong to floor, resetting',
            );
            _selectedRoomId = null;
            _selectedRoom = null;
          }
        }
      } else {
        // When floorId is null, show general room and rooms that don't belong to any floor
        _selectedFloorId = null;
        _rooms = _allRooms
            .where((r) => r.isGeneral || r.floorId == null)
            .toList();
        // Sort: general room first, then by order
        _rooms.sort((a, b) {
          if (a.isGeneral) return -1;
          if (b.isGeneral) return 1;
          return a.order.compareTo(b.order);
        });
        print(
          '🟡 [ROOM_VM] No floorId provided, showing general room and rooms without floor (${_rooms.length} rooms)',
        );
        for (var room in _rooms) {
          print(
            '   - ${room.name} (ID: ${room.id}, FloorId: ${room.floorId}, isGeneral: ${room.isGeneral})',
          );
        }
      }

      // Select first room by default if none selected
      if (_selectedRoomId == null && _rooms.isNotEmpty) {
        _selectedRoomId = _rooms.first.id;
        _selectedRoom = _rooms.first;
        print(
          '🟡 [ROOM_VM] No room selected, selecting first: ${_selectedRoom!.name}',
        );
      } else if (_selectedRoomId != null) {
        // Update selected room object if it changed
        try {
          _selectedRoom = _rooms.firstWhere((r) => r.id == _selectedRoomId);
          print('🟡 [ROOM_VM] Updated selected room: ${_selectedRoom!.name}');
        } catch (e) {
          print(
            '🟡 [ROOM_VM] Selected room not found in list, selecting first available',
          );
          // If selected room not in filtered list, select first available or clear
          if (_rooms.isNotEmpty) {
            _selectedRoomId = _rooms.first.id;
            _selectedRoom = _rooms.first;
            print(
              '🟡 [ROOM_VM] Selected first available: ${_selectedRoom!.name}',
            );
          } else {
            _selectedRoomId = null;
            _selectedRoom = null;
            print('🟡 [ROOM_VM] No rooms available, cleared selection');
          }
        }
      }

      print('🟡 [ROOM_VM] Final state:');
      print('   - Total rooms: ${_allRooms.length}');
      print('   - Filtered rooms: ${_rooms.length}');
      print(
        '   - Selected room: ${_selectedRoom?.name ?? "null"} (${_selectedRoomId ?? "null"})',
      );
      notifyListeners();
    } catch (e) {
      setError('Failed to load rooms: ${e.toString()}');
    } finally {
      setLoading(false);
      _loadRoomsInProgress = false;
    }
  }

  /// Filter rooms by floor
  void filterRoomsByFloor(String? floorId) {
    _selectedFloorId = floorId;
    if (floorId == null) {
      // When floorId is null, show general room and rooms that don't belong to any floor
      _rooms = _allRooms
          .where((r) => r.isGeneral || r.floorId == null)
          .toList();
    } else {
      // Include general room and rooms for this floor
      _rooms = _allRooms
          .where((r) => r.isGeneral || r.floorId == floorId)
          .toList();
    }

    // Sort: general room first, then by order
    _rooms.sort((a, b) {
      if (a.isGeneral) return -1;
      if (b.isGeneral) return 1;
      return a.order.compareTo(b.order);
    });

    // Update selected room if current selection is not in filtered list
    if (_selectedRoomId != null) {
      final isInFiltered = _rooms.any((r) => r.id == _selectedRoomId);
      if (!isInFiltered && _rooms.isNotEmpty) {
        _selectedRoomId = _rooms.first.id;
        _selectedRoom = _rooms.first;
      } else if (!isInFiltered) {
        _selectedRoomId = null;
        _selectedRoom = null;
      } else {
        _selectedRoom = _rooms.firstWhere((r) => r.id == _selectedRoomId);
      }
    }

    notifyListeners();
  }

  /// Select a room
  Future<void> selectRoom(String roomId) async {
    if (_selectedRoomId == roomId) return;

    try {
      _selectedRoomId = roomId;
      _selectedRoom = await _getRoomByIdUseCase(roomId);
      notifyListeners();
    } catch (e) {
      setError('Failed to select room: ${e.toString()}');
    }
  }

  /// Select next room (for navigation)
  Future<void> selectNextRoom() async {
    if (_rooms.isEmpty) return;

    final currentIndex = _selectedRoomId != null
        ? _rooms.indexWhere((r) => r.id == _selectedRoomId)
        : -1;

    final nextIndex = (currentIndex + 1) % _rooms.length;
    await selectRoom(_rooms[nextIndex].id);
  }

  /// Select previous room (for navigation)
  Future<void> selectPreviousRoom() async {
    if (_rooms.isEmpty) return;

    final currentIndex = _selectedRoomId != null
        ? _rooms.indexWhere((r) => r.id == _selectedRoomId)
        : 0;

    final previousIndex = currentIndex > 0
        ? currentIndex - 1
        : _rooms.length - 1;
    await selectRoom(_rooms[previousIndex].id);
  }

  /// Get a specific room by ID
  RoomEntity? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  /// Get room name by ID
  String getRoomName(String roomId) {
    final room = getRoomById(roomId);
    return room?.name ?? 'Unknown Room';
  }

  /// Refresh rooms
  /// Preserves current floor filter if set
  Future<void> refresh() async {
    await loadRooms(floorId: _selectedFloorId);
  }
}
