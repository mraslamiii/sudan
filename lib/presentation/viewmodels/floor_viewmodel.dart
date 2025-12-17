import 'package:flutter/material.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/floor_entity.dart';
import '../../domain/use_cases/floor/get_all_floors_use_case.dart';
import '../../domain/use_cases/floor/get_floor_by_id_use_case.dart';
import '../../domain/use_cases/floor/create_floor_use_case.dart';
import '../../domain/use_cases/floor/update_floor_use_case.dart';
import '../../domain/use_cases/floor/delete_floor_use_case.dart';

/// Floor ViewModel
/// Manages floor selection and floor-related state
/// 
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<FloorViewModel>();
/// final floors = viewModel.floors;
/// final selectedFloor = viewModel.selectedFloor;
/// 
/// // Switch to a different floor
/// await viewModel.selectFloor('floor_1');
/// ```
class FloorViewModel extends BaseViewModel {
  final GetAllFloorsUseCase _getAllFloorsUseCase;
  final GetFloorByIdUseCase _getFloorByIdUseCase;
  final CreateFloorUseCase _createFloorUseCase;
  final UpdateFloorUseCase _updateFloorUseCase;
  final DeleteFloorUseCase _deleteFloorUseCase;

  List<FloorEntity> _floors = [];
  String? _selectedFloorId;
  FloorEntity? _selectedFloor;

  FloorViewModel(
    this._getAllFloorsUseCase,
    this._getFloorByIdUseCase,
    this._createFloorUseCase,
    this._updateFloorUseCase,
    this._deleteFloorUseCase,
  );

  // Getters
  List<FloorEntity> get floors => _floors;
  String? get selectedFloorId => _selectedFloorId;
  FloorEntity? get selectedFloor => _selectedFloor;

  @override
  void init() {
    super.init();
    loadFloors();
  }

  /// Load all floors
  Future<void> loadFloors() async {
    try {
      setLoading(true);
      clearError();
      
      _floors = await _getAllFloorsUseCase();
      
      // Select first floor by default if none selected
      if (_selectedFloorId == null && _floors.isNotEmpty) {
        _selectedFloorId = _floors.first.id;
        _selectedFloor = _floors.first;
      } else if (_selectedFloorId != null && _floors.isNotEmpty) {
        // Update selected floor object if it changed
        try {
          _selectedFloor = _floors.firstWhere(
            (f) => f.id == _selectedFloorId,
          );
        } catch (e) {
          // If selected floor not found, select first available
          _selectedFloorId = _floors.first.id;
          _selectedFloor = _floors.first;
        }
      } else if (_floors.isEmpty) {
        // No floors available
        _selectedFloorId = null;
        _selectedFloor = null;
      }
      
      notifyListeners();
    } catch (e) {
      setError('Failed to load floors: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Select a floor
  Future<void> selectFloor(String floorId) async {
    if (_selectedFloorId == floorId) return;
    
    try {
      _selectedFloorId = floorId;
      _selectedFloor = await _getFloorByIdUseCase(floorId);
      notifyListeners();
    } catch (e) {
      setError('Failed to select floor: ${e.toString()}');
    }
  }

  /// Create a new floor
  Future<FloorEntity?> createFloor({
    required String name,
    required IconData icon,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final newFloor = FloorEntity(
        id: 'floor_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        roomIds: [],
        order: _floors.length,
      );
      
      final createdFloor = await _createFloorUseCase(newFloor);
      await loadFloors(); // Reload to get updated list
      
      notifyListeners();
      return createdFloor;
    } catch (e) {
      setError('Failed to create floor: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Update a floor
  Future<bool> updateFloor(FloorEntity floor) async {
    try {
      setLoading(true);
      clearError();
      
      await _updateFloorUseCase(floor);
      await loadFloors(); // Reload to get updated list
      
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update floor: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete a floor
  Future<bool> deleteFloor(String floorId) async {
    try {
      setLoading(true);
      clearError();
      
      await _deleteFloorUseCase(floorId);
      
      // If deleted floor was selected, select first available
      if (_selectedFloorId == floorId) {
        _selectedFloorId = null;
        _selectedFloor = null;
      }
      
      await loadFloors(); // Reload to get updated list
      
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete floor: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get a specific floor by ID
  FloorEntity? getFloorById(String floorId) {
    try {
      return _floors.firstWhere((f) => f.id == floorId);
    } catch (e) {
      return null;
    }
  }

  /// Get floor name by ID
  String getFloorName(String floorId) {
    final floor = getFloorById(floorId);
    return floor?.name ?? 'Unknown Floor';
  }

  /// Refresh floors
  Future<void> refresh() async {
    await loadFloors();
  }
}

