import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/card_aspect_ratio_helper.dart';
import '../../data/models/dashboard_card_model.dart';
import '../../data/models/dashboard_layout_model.dart';
import '../../data/models/masonry_layout_state.dart';
import '../../domain/use_cases/dashboard/load_dashboard_cards_use_case.dart';
import '../../domain/use_cases/dashboard/save_dashboard_cards_use_case.dart';
import '../../domain/use_cases/dashboard/load_dashboard_layout_use_case.dart';
import '../../domain/use_cases/dashboard/save_dashboard_layout_use_case.dart';
import '../../domain/use_cases/dashboard/clear_all_dashboard_cards_use_case.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/use_cases/device/get_devices_by_room_use_case.dart';
import '../../domain/use_cases/device/create_device_use_case.dart';
import '../../domain/use_cases/device/add_device_to_room_use_case.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/use_cases/scenario/get_all_scenarios_use_case.dart';
import '../widgets/dashboard/iphone_alert_dialog.dart';
import 'usb_serial_viewmodel.dart';

/// Dashboard ViewModel
/// Manages all dashboard card state and operations
///
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<DashboardViewModel>();
/// final cards = viewModel.cards;
///
/// // Toggle edit mode
/// viewModel.toggleEditMode();
///
/// // Add a new card
/// viewModel.addCard(CardType.light, roomName, availableRooms);
///
/// // Update card data
/// viewModel.updateCardData(cardId, {'isOn': true});
/// ```
class DashboardViewModel extends BaseViewModel {
  final LoadDashboardCardsUseCase _loadDashboardCardsUseCase;
  final SaveDashboardCardsUseCase _saveDashboardCardsUseCase;
  final LoadDashboardLayoutUseCase _loadDashboardLayoutUseCase;
  final SaveDashboardLayoutUseCase _saveDashboardLayoutUseCase;
  final GetDevicesByRoomUseCase _getDevicesByRoomUseCase;
  final CreateDeviceUseCase _createDeviceUseCase;
  final AddDeviceToRoomUseCase _addDeviceToRoomUseCase;
  final RoomRepository _roomRepository;
  final GetAllScenariosUseCase _getAllScenariosUseCase;
  final ClearAllDashboardCardsUseCase _clearAllDashboardCardsUseCase;
  final UsbSerialViewModel? _usbSerialViewModel;
  static const _uuid = Uuid();

  List<DashboardCardModel> _cards = [];
  DashboardLayoutModel _layout = DashboardLayoutModel.defaultLayout();
  bool _isEditMode = false;
  String? _currentRoomId; // Current room ID for filtering cards
  MasonryLayoutState? _preservedLayoutState; // Preserved layout state when entering edit mode

  DashboardViewModel(
    this._loadDashboardCardsUseCase,
    this._saveDashboardCardsUseCase,
    this._loadDashboardLayoutUseCase,
    this._saveDashboardLayoutUseCase,
    this._getDevicesByRoomUseCase,
    this._createDeviceUseCase,
    this._addDeviceToRoomUseCase,
    this._roomRepository,
    this._getAllScenariosUseCase,
    this._clearAllDashboardCardsUseCase,
    this._usbSerialViewModel,
  );

  // Getters
  List<DashboardCardModel> get cards => _cards;
  DashboardLayoutModel get layout => _layout;
  bool get isEditMode => _isEditMode;
  String? get currentRoomId => _currentRoomId;
  MasonryLayoutState? get preservedLayoutState => _preservedLayoutState;

  /// Get camera cards
  List<DashboardCardModel> get cameraCards =>
      _cards.where((c) => c.type == CardType.camera).toList();

  /// Get device cards (excluding camera, thermostat, light, music, security, curtain, elevator, and doorLock)
  /// These special cards are shown in their own sections
  List<DashboardCardModel> get deviceCards => _cards
      .where((c) => 
        c.type != CardType.camera && 
        c.type != CardType.thermostat &&
        c.type != CardType.light && // Light cards go to LED section
        c.type != CardType.music && // Music cards go to music section
        c.type != CardType.security && // Security cards go to security section
        c.type != CardType.curtain && // Curtain cards go to curtain section
        c.type != CardType.elevator && // Elevator cards have their own section
        c.type != CardType.doorLock) // Door lock cards have their own section
      .toList();

  /// Get thermostat cards
  List<DashboardCardModel> get thermostatCards =>
      _cards.where((c) => c.type == CardType.thermostat).toList();

  @override
  void init() {
    super.init();
    // Don't load dashboard in init - wait for room selection
    // loadDashboard() will be called from AdvancedDashboardView
  }

  /// Load dashboard cards for a specific room
  Future<void> loadDashboard({String? roomId}) async {
    print('🔵 [DASHBOARD_VM] loadDashboard called with roomId: $roomId');
    try {
      setLoading(true);
      clearError();

      _currentRoomId = roomId;
      final cards = await _loadDashboardCardsUseCase(roomId: roomId);
      print('🔵 [DASHBOARD_VM] Loaded ${cards.length} cards');
      final layout = await _loadDashboardLayoutUseCase();
      print('🔵 [DASHBOARD_VM] Loaded layout');

      // Ensure all cards have the roomId set and filter out cards from other rooms
      _cards = cards
          .where((card) => card.roomId == null || card.roomId == roomId)
          .map((card) => card.copyWith(roomId: roomId))
          .toList();
      _layout = _normalizeLayout(layout);
      print('🔵 [DASHBOARD_VM] Normalized layout');
      
      // Log all columns and their sections
      for (var i = 0; i < _layout.columns.length; i++) {
        final col = _layout.columns[i];
        print('🔵 [DASHBOARD_VM] Column $i has ${col.sections.length} sections: ${col.sections.map((s) => s.type).toList()}');
      }
      
      // Ensure scenarios section exists in layout (always visible)
      final hasScenarios = _layout.columns
          .expand((col) => col.sections)
          .any((s) => s.type == DashboardSectionType.scenarios);
      
      print('🔵 [DASHBOARD_VM] Has scenarios in layout: $hasScenarios');
      
      if (!hasScenarios) {
        print('🔵 [DASHBOARD_VM] Scenarios section not found in layout, adding it now');
        await addScenariosSectionIfNeeded();
        // Log again after adding
        for (var i = 0; i < _layout.columns.length; i++) {
          final col = _layout.columns[i];
          print('🔵 [DASHBOARD_VM] After add - Column $i: ${col.sections.map((s) => s.type).toList()}');
        }
      }
      
      // Sync cards with actual devices in the room
      if (roomId != null) {
        print('🔵 [DASHBOARD_VM] Syncing cards with devices for room: $roomId');
        await syncCardsWithDevices(roomId);
        print('🔵 [DASHBOARD_VM] Cards synced. Final count: ${_cards.length}');
      }
      
      notifyListeners();
      print('🔵 [DASHBOARD_VM] Dashboard loaded and listeners notified');
    } catch (e) {
      print('🔴 [DASHBOARD_VM] Error loading dashboard: $e');
      setError('Failed to load dashboard: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Save dashboard cards
  Future<void> saveDashboard() async {
    try {
      await _saveDashboardCardsUseCase(_cards, roomId: _currentRoomId);
      await _saveDashboardLayoutUseCase(_layout);
    } catch (e) {
      setError('Failed to save dashboard: ${e.toString()}');
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    
    // When entering edit mode, preserve layout state will be set by DynamicMasonryGrid
    // When exiting edit mode, clear preserved state
    if (!_isEditMode) {
      _preservedLayoutState = null;
      saveDashboard();
    }
    
    notifyListeners();
  }
  
  /// Preserve the current masonry layout state
  /// Called by DynamicMasonryGrid when entering edit mode
  void preserveLayoutState(MasonryLayoutState state) {
    if (_isEditMode && state.isValidFor(_cards)) {
      _preservedLayoutState = state;
      notifyListeners();
    }
  }
  
  /// Clear preserved layout state
  void clearPreservedLayoutState() {
    _preservedLayoutState = null;
    notifyListeners();
  }
  
  /// Update card position in preserved layout state
  void updateCardPositionInLayout(
    String cardId,
    int newColumnIndex,
    int newPositionInColumn,
  ) {
    if (_preservedLayoutState == null) return;
    
    final currentPosition = _preservedLayoutState!.getPosition(cardId);
    if (currentPosition == null) return;
    
    final newPosition = currentPosition.copyWith(
      columnIndex: newColumnIndex,
      positionInColumn: newPositionInColumn,
    );
    
    _preservedLayoutState = _preservedLayoutState!.copyWithCardPosition(
      cardId,
      newPosition,
    );
    notifyListeners();
  }

  /// Set edit mode
  void setEditMode(bool value) {
    if (_isEditMode != value) {
      _isEditMode = value;
      notifyListeners();

      if (!_isEditMode) {
        saveDashboard();
      }
    }
  }

  /// Reorder cards (legacy method for non-masonry layouts)
  void reorderCards(int oldIndex, int newIndex) {
    final deviceIndices = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      if (card.type != CardType.camera && card.type != CardType.thermostat) {
        deviceIndices.add(i);
      }
    }

    if (oldIndex < 0 || oldIndex >= deviceIndices.length) {
      return;
    }

    var targetIndex = newIndex;
    if (targetIndex > deviceIndices.length) {
      targetIndex = deviceIndices.length;
    }

    final originalIndex = deviceIndices[oldIndex];
    final movingCard = _cards.removeAt(originalIndex);
    deviceIndices.removeAt(oldIndex);

    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }

    int insertionIndex;
    if (deviceIndices.isEmpty) {
      insertionIndex = 0;
    } else if (targetIndex >= deviceIndices.length) {
      insertionIndex = deviceIndices.last + 1;
    } else {
      insertionIndex = deviceIndices[targetIndex];
    }

    if (insertionIndex < 0) {
      insertionIndex = 0;
    }
    if (insertionIndex > _cards.length) {
      insertionIndex = _cards.length;
    }

    _cards.insert(insertionIndex, movingCard);

    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].copyWith(position: i);
    }

    notifyListeners();
    saveDashboard();
  }
  
  /// Reorder card in masonry layout (preserves column structure)
  void reorderCardInMasonry(
    String cardId,
    int newColumnIndex,
    int newPositionInColumn,
  ) {
    if (_preservedLayoutState == null) return;
    
    // Update the preserved layout state
    updateCardPositionInLayout(cardId, newColumnIndex, newPositionInColumn);
    
    // Update card positions in the list to reflect new order
    // This is mainly for consistency, the actual layout is controlled by preserved state
    notifyListeners();
    saveDashboard();
  }

  /// Delete a card
  void deleteCard(String cardId) {
    _cards.removeWhere((card) => card.id == cardId);

    // Update positions
    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].copyWith(position: i);
    }

    notifyListeners();
    saveDashboard();
  }

  /// Resize a card
  void resizeCard(String cardId, CardSize newSize) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(size: newSize);
      notifyListeners();
      saveDashboard();
    }
  }

  /// Update card data
  void updateCardData(String cardId, Map<String, dynamic> newData) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      final card = _cards[index];
      final deviceId = card.data['deviceId'] as String?;
      
      // Send USB Serial commands if deviceId exists and USB is connected
      if (deviceId != null && _usbSerialViewModel?.isUsbConnected == true) {
        _sendUsbSerialCommands(card.type, deviceId, newData, card.data);
      }
      
      final currentData = Map<String, dynamic>.from(card.data);
      currentData.addAll(newData);
      _cards[index] = _cards[index].copyWith(data: currentData);
      notifyListeners();
      saveDashboard();
    }
  }

  /// Send USB Serial commands based on card type and data changes
  void _sendUsbSerialCommands(
    CardType cardType,
    String deviceId,
    Map<String, dynamic> newData,
    Map<String, dynamic> currentData,
  ) {
    if (_usbSerialViewModel == null) return;

    try {
      switch (cardType) {
        case CardType.light:
          // LED Control Panel commands
          if (newData.containsKey('isOn')) {
            _usbSerialViewModel!.sendLightCommand(deviceId, newData['isOn'] as bool);
          }
          if (newData.containsKey('color')) {
            final colorHex = newData['color'] as String?;
            if (colorHex != null) {
              _usbSerialViewModel!.sendLEDColorCommand(deviceId, colorHex);
            }
          }
          if (newData.containsKey('brightness')) {
            final brightness = newData['brightness'] as int?;
            if (brightness != null) {
              _usbSerialViewModel!.sendLEDBrightnessCommand(deviceId, brightness);
            }
          }
          break;

        case CardType.curtain:
          // Curtain Control Panel commands
          if (newData.containsKey('position')) {
            final position = newData['position'] as int?;
            if (position != null) {
              _usbSerialViewModel!.sendCurtainPositionCommand(deviceId, position);
            }
          } else if (newData.containsKey('isOpen')) {
            final isOpen = newData['isOpen'] as bool?;
            if (isOpen != null) {
              _usbSerialViewModel!.sendCurtainCommand(deviceId, isOpen ? 'open' : 'close');
            }
          }
          break;

        case CardType.thermostat:
        case CardType.airConditioner:
          // Thermostat Control Panel commands
          if (newData.containsKey('targetTemperature')) {
            final temp = newData['targetTemperature'] as int?;
            if (temp != null) {
              _usbSerialViewModel!.sendThermostatTemperatureCommand(deviceId, temp);
            }
          }
          if (newData.containsKey('mode')) {
            final mode = newData['mode'] as String?;
            if (mode != null) {
              _usbSerialViewModel!.sendThermostatModeCommand(deviceId, mode);
            }
          }
          if (newData.containsKey('isOn')) {
            // Thermostat on/off might need a specific command
            // For now, we can use temperature command with 0 or a specific value
          }
          break;

        case CardType.music:
          // Music Player Control Panel commands
          if (newData.containsKey('isPlaying')) {
            final isPlaying = newData['isPlaying'] as bool?;
            if (isPlaying != null) {
              _usbSerialViewModel!.sendMusicPlayPauseCommand(deviceId, isPlaying);
            }
          }
          if (newData.containsKey('volume')) {
            final volume = newData['volume'] as int?;
            if (volume != null) {
              _usbSerialViewModel!.sendMusicVolumeCommand(deviceId, volume);
            }
          }
          // Note: Previous/Next commands are handled separately in the widget
          break;

        case CardType.security:
          // Security Control Panel commands
          if (newData.containsKey('isActive')) {
            final isActive = newData['isActive'] as bool?;
            if (isActive != null) {
              _usbSerialViewModel!.sendSecurityCommand(deviceId, isActive);
            }
          }
          break;

        case CardType.elevator:
          // Elevator Control Panel commands
          if (newData.containsKey('targetFloor')) {
            final targetFloor = newData['targetFloor'] as int?;
            if (targetFloor != null) {
              _usbSerialViewModel!.sendElevatorCallCommand(deviceId, targetFloor);
            }
          }
          break;

        case CardType.doorLock:
          // Door Lock Control Panel commands
          if (newData.containsKey('isLocked')) {
            final isLocked = newData['isLocked'] as bool?;
            if (isLocked != null) {
              _usbSerialViewModel!.sendDoorLockCommand(deviceId, isLocked);
            }
          }
          break;

        case CardType.iphone:
          // iPhone Control Panel commands
          if (newData.containsKey('isActive')) {
            final isActive = newData['isActive'] as bool?;
            if (isActive != null) {
              _usbSerialViewModel!.sendIPhoneCommand(deviceId, isActive);
            }
          }
          break;

        case CardType.tv:
        case CardType.fan:
        case CardType.window:
        case CardType.door:
        case CardType.humidifier:
          // Simple on/off devices
          if (newData.containsKey('isOn')) {
            final isOn = newData['isOn'] as bool?;
            if (isOn != null) {
              // Use socket command for these devices
              _usbSerialViewModel!.sendSocketCommand(deviceId, isOn);
            }
          }
          break;

        case CardType.camera:
          // Camera commands might be handled differently
          // For now, we can use socket command for on/off
          if (newData.containsKey('isOn')) {
            final isOn = newData['isOn'] as bool?;
            if (isOn != null) {
              _usbSerialViewModel!.sendSocketCommand(deviceId, isOn);
            }
          }
          break;

        // Tablet Charger - uses socket commands
        // Note: Tablet Charger might not have a specific CardType
        // If it does, add it here with charge/discharge commands
        default:
          // For any other device types, try socket commands for on/off
          if (newData.containsKey('isOn')) {
            final isOn = newData['isOn'] as bool?;
            if (isOn != null) {
              _usbSerialViewModel!.sendSocketCommand(deviceId, isOn);
            }
          }
          // Handle charge/discharge for tablet charger
          if (newData.containsKey('isCharging')) {
            final isCharging = newData['isCharging'] as bool?;
            if (isCharging != null && isCharging) {
              _usbSerialViewModel!.sendSocketChargeCommand(deviceId);
            }
          }
          if (newData.containsKey('isDischarging')) {
            final isDischarging = newData['isDischarging'] as bool?;
            if (isDischarging != null && isDischarging) {
              _usbSerialViewModel!.sendSocketDischargeCommand(deviceId);
            }
          }
          break;
      }
    } catch (e) {
      print('❌ [DASHBOARD_VM] Failed to send USB Serial command: $e');
      // Don't throw - allow UI to update even if command fails
    }
  }

  /// Send music previous track command
  void sendMusicPreviousCommand(String cardId) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      final card = _cards[index];
      final deviceId = card.data['deviceId'] as String?;
      if (deviceId != null && _usbSerialViewModel?.isUsbConnected == true) {
        try {
          _usbSerialViewModel!.sendMusicPreviousCommand(deviceId);
        } catch (e) {
          print('❌ [DASHBOARD_VM] Failed to send music previous command: $e');
        }
      }
    }
  }

  /// Send music next track command
  void sendMusicNextCommand(String cardId) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      final card = _cards[index];
      final deviceId = card.data['deviceId'] as String?;
      if (deviceId != null && _usbSerialViewModel?.isUsbConnected == true) {
        try {
          _usbSerialViewModel!.sendMusicNextCommand(deviceId);
        } catch (e) {
          print('❌ [DASHBOARD_VM] Failed to send music next command: $e');
        }
      }
    }
  }

  DashboardLayoutModel _normalizeLayout(DashboardLayoutModel layout) {
    if (layout.columns.isEmpty) {
      return DashboardLayoutModel.defaultLayout();
    }

    // Separate devices section from other sections
    final List<DashboardSectionModel> devicesSections = [];
    final List<DashboardSectionModel> otherSections = [];

    for (final column in layout.columns) {
      for (final section in column.sections) {
        if (section.type == DashboardSectionType.devices) {
          devicesSections.add(section.copyWith(isLocked: true));
        } else {
          otherSections.add(section);
        }
      }
    }

    // Ensure devices section exists
    if (devicesSections.isEmpty) {
      devicesSections.add(
        DashboardSectionModel.defaultFor(DashboardSectionType.devices),
      );
    }

    // Build normalized columns
    final normalizedColumns = <DashboardColumnModel>[];

    // First column: ONLY devices section
    normalizedColumns.add(
      DashboardColumnModel(
        id: 'column_devices',
        flex: 60.0,
        sections: devicesSections,
      ),
    );

    // Other columns: distribute other sections
    if (otherSections.isNotEmpty) {
      // Group sections by type for better organization
      final controlSections = otherSections.where((s) =>
          s.type == DashboardSectionType.led ||
          s.type == DashboardSectionType.thermostat ||
          s.type == DashboardSectionType.tabletCharger ||
          s.type == DashboardSectionType.music ||
          s.type == DashboardSectionType.security ||
          s.type == DashboardSectionType.curtain ||
          s.type == DashboardSectionType.elevator ||
          s.type == DashboardSectionType.doorLock ||
          s.type == DashboardSectionType.scenarios).toList();

      final cameraSections = otherSections
          .where((s) => s.type == DashboardSectionType.camera)
          .toList();

      // Add control sections to second column
      if (controlSections.isNotEmpty) {
        normalizedColumns.add(
          DashboardColumnModel(
            id: 'column_controls',
            flex: 40.0,
            sections: controlSections,
          ),
        );
      }

      // Add camera sections to separate column if exists
      if (cameraSections.isNotEmpty) {
        normalizedColumns.add(
          DashboardColumnModel(
            id: 'column_camera',
            flex: 30.0,
            sections: cameraSections,
          ),
        );
      }
    }

    // If no other sections, keep only devices column
    if (normalizedColumns.length == 1) {
      return DashboardLayoutModel(columns: normalizedColumns);
    }

    // Normalize flex values to ensure proper distribution
    final totalFlex = normalizedColumns.fold<double>(
      0,
      (sum, column) => sum + column.flex,
    );

    if (totalFlex <= 0) {
      return DashboardLayoutModel.defaultLayout();
    }

    return DashboardLayoutModel(columns: normalizedColumns);
  }

  List<DashboardColumnModel> _cloneColumns() {
    return _layout.columns
        .map(
          (column) => column.copyWith(
            sections: List<DashboardSectionModel>.from(column.sections),
          ),
        )
        .toList();
  }

  void moveColumnToIndex(String columnId, int targetIndex) {
    final columns = _cloneColumns();
    final currentIndex = columns.indexWhere((column) => column.id == columnId);
    if (currentIndex == -1) {
      return;
    }

    final column = columns.removeAt(currentIndex);
    var insertIndex = targetIndex;
    if (insertIndex > currentIndex) {
      insertIndex -= 1;
    }
    if (insertIndex < 0) {
      insertIndex = 0;
    }
    if (insertIndex > columns.length) {
      insertIndex = columns.length;
    }

    columns.insert(insertIndex, column);

    _layout = _layout.copyWith(columns: columns);
    notifyListeners();
    saveDashboard();
  }

  void moveColumnAfter(String columnId, String referenceColumnId) {
    final targetIndex = _layout.columns.indexWhere(
      (column) => column.id == referenceColumnId,
    );
    if (targetIndex == -1) return;
    moveColumnToIndex(columnId, targetIndex + 1);
  }

  void moveSection({
    required String sectionId,
    required String targetColumnId,
    required int targetIndex,
  }) {
    final columns = _cloneColumns();
    DashboardSectionModel? movingSection;
    int fromColumnIndex = -1;
    int fromSectionIndex = -1;

    for (
      var colIndex = 0;
      colIndex < columns.length && movingSection == null;
      colIndex++
    ) {
      final sectionIndex = columns[colIndex].sections.indexWhere(
        (section) => section.id == sectionId,
      );
      if (sectionIndex != -1) {
        movingSection = columns[colIndex].sections.removeAt(sectionIndex);
        fromColumnIndex = colIndex;
        fromSectionIndex = sectionIndex;
      }
    }

    if (movingSection == null) {
      return;
    }

    final destinationColumnIndex = columns.indexWhere(
      (column) => column.id == targetColumnId,
    );
    if (destinationColumnIndex == -1) {
      // Restore original position if destination missing
      columns[fromColumnIndex].sections.insert(fromSectionIndex, movingSection);
      return;
    }

    var insertIndex = targetIndex;
    if (destinationColumnIndex == fromColumnIndex &&
        insertIndex > fromSectionIndex) {
      insertIndex -= 1;
    }
    if (insertIndex < 0) {
      insertIndex = 0;
    }
    final maxIndex = columns[destinationColumnIndex].sections.length;
    if (insertIndex > maxIndex) {
      insertIndex = maxIndex;
    }

    columns[destinationColumnIndex].sections.insert(insertIndex, movingSection);

    _layout = _layout.copyWith(columns: columns);
    notifyListeners();
    saveDashboard();
  }

  void cycleSectionSize(String sectionId) {
    final columns = _cloneColumns();
    for (var colIndex = 0; colIndex < columns.length; colIndex++) {
      final column = columns[colIndex];
      for (
        var sectionIndex = 0;
        sectionIndex < column.sections.length;
        sectionIndex++
      ) {
        final section = column.sections[sectionIndex];
        if (section.id == sectionId) {
          columns[colIndex].sections[sectionIndex] = section.copyWith(
            size: section.nextSize(),
          );
          _layout = _layout.copyWith(columns: columns);
          notifyListeners();
          saveDashboard();
          return;
        }
      }
    }
  }

  void resizeColumns(int leftColumnIndex, double deltaRatio) {
    if (leftColumnIndex < 0 || leftColumnIndex >= _layout.columns.length - 1) {
      return;
    }

    final columns = _cloneColumns();
    final totalFlex = _layout.totalFlex;
    if (totalFlex <= 0) {
      return;
    }

    final leftColumn = columns[leftColumnIndex];
    final rightColumn = columns[leftColumnIndex + 1];

    final deltaFlex = deltaRatio * totalFlex;
    var proposedLeft = leftColumn.flex + deltaFlex;
    var proposedRight = rightColumn.flex - deltaFlex;

    const double minFlex = 18.0;

    if (proposedLeft < minFlex) {
      final correction = minFlex - proposedLeft;
      proposedLeft = minFlex;
      proposedRight -= correction;
    }

    if (proposedRight < minFlex) {
      final correction = minFlex - proposedRight;
      proposedRight = minFlex;
      proposedLeft -= correction;
    }

    if (proposedLeft < minFlex || proposedRight < minFlex) {
      return;
    }

    columns[leftColumnIndex] = leftColumn.copyWith(flex: proposedLeft);
    columns[leftColumnIndex + 1] = rightColumn.copyWith(flex: proposedRight);

    _layout = _layout.copyWith(columns: columns);
    notifyListeners();
    saveDashboard();
  }

  /// Handle card tap - business logic for different card types
  void handleCardTap(DashboardCardModel card, [BuildContext? context]) {
    if (_isEditMode) return;

    switch (card.type) {
      case CardType.light:
        final isOn = card.data['isOn'] as bool? ?? false;
        updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.curtain:
        final isOpen = card.data['isOpen'] as bool? ?? false;
        updateCardData(card.id, {
          'isOpen': !isOpen,
          'position': !isOpen ? 100 : 0,
        });
        break;
      case CardType.tv:
        final isOn = card.data['isOn'] as bool? ?? false;
        updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.fan:
        final isOn = card.data['isOn'] as bool? ?? false;
        updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.security:
        final isActive = card.data['isActive'] as bool? ?? false;
        updateCardData(card.id, {
          'isActive': !isActive,
          'status': !isActive ? 'Armed' : 'Disarmed',
        });
        break;
      case CardType.music:
        final isPlaying = card.data['isPlaying'] as bool? ?? false;
        updateCardData(card.id, {'isPlaying': !isPlaying});
        break;
      case CardType.camera:
        final isOn = card.data['isOn'] as bool? ?? true;
        final isRecording = card.data['isRecording'] as bool? ?? false;
        updateCardData(card.id, {
          'isOn': !isOn,
          'isRecording': !isOn ? false : isRecording,
        });
        break;
      case CardType.iphone:
        // Show door phone alert dialog instead of toggling
        if (context != null) {
          final deviceName = card.data['name'] as String? ?? 'آیفون درب';
          final imageUrl = card.data['imageUrl'] as String?;
          IPhoneAlertDialog.show(
            context,
            deviceName: deviceName,
            imageUrl: imageUrl,
            onOpen: () {
              // Handle open door action
              updateCardData(card.id, {'isActive': true});
            },
            onDismiss: () {
              // Handle dismiss
            },
          );
        }
        break;
      default:
        break;
    }
  }

  /// Add a new card
  void addCard(
    CardType type,
    String currentRoomName,
    List<String> availableRoomNames,
  ) {
    // Use the helper to get the appropriate size for this card type
    final defaultSize = CardAspectRatioHelper.getDefaultSizeForType(type);
    
    final newCard = DashboardCardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      size: defaultSize,
      position: _cards.length,
      data: getDefaultDataForType(type, currentRoomName, availableRoomNames),
      roomId: _currentRoomId, // Set roomId for the new card
    );

    _cards.add(newCard);
    notifyListeners();
    saveDashboard();
  }

  /// Add a device to the room and automatically create a card for it
  /// This is the proper way to add devices - creates actual device entity
  Future<bool> addDeviceToRoom(
    CardType cardType,
    String roomId,
    String roomName,
  ) async {
    try {
      print('🔵 [DASHBOARD_VM] addDeviceToRoom called: cardType=$cardType, roomId=$roomId');
      
      // Convert CardType to DeviceType
      final deviceType = _cardTypeToDeviceType(cardType);
      if (deviceType == null) {
        print('🔴 [DASHBOARD_VM] No device type mapping for card type: $cardType');
        return false;
      }

      // Get default name for device type
      final deviceName = _getDefaultDeviceName(cardType, roomName);
      
      // Create default state for device
      final deviceState = _getDefaultStateForDeviceType(deviceType);

      // Create device entity
      final device = DeviceEntity(
        id: _uuid.v4(),
        name: deviceName,
        type: deviceType,
        roomId: roomId,
        state: deviceState,
        icon: _getIconForDeviceType(deviceType),
        isOnline: true,
        lastUpdated: DateTime.now(),
      );

      print('🔵 [DASHBOARD_VM] Creating device: ${device.name} (${device.type})');
      
      // Create the device
      final createdDevice = await _createDeviceUseCase(device);
      print('🔵 [DASHBOARD_VM] Device created: ${createdDevice.id}');

      // Add device to room
      await _addDeviceToRoomUseCase(
        roomId: roomId,
        deviceId: createdDevice.id,
      );
      print('🔵 [DASHBOARD_VM] Device added to room');

      // Sync cards with devices - this will automatically create the card
      await syncCardsWithDevices(roomId);
      print('🔵 [DASHBOARD_VM] Dashboard synced, card should be created');

      return true;
    } catch (e) {
      print('🔴 [DASHBOARD_VM] Error adding device to room: $e');
      setError('Failed to add device: ${e.toString()}');
      return false;
    }
  }

  /// Convert CardType to DeviceType
  DeviceType? _cardTypeToDeviceType(CardType cardType) {
    switch (cardType) {
      case CardType.light:
        return DeviceType.light;
      case CardType.thermostat:
      case CardType.airConditioner:
      case CardType.humidifier:
        return DeviceType.thermostat;
      case CardType.curtain:
      case CardType.window:
        return DeviceType.curtain;
      case CardType.camera:
        return DeviceType.camera;
      case CardType.security:
        return DeviceType.security;
      case CardType.music:
        return DeviceType.music;
      case CardType.tv:
        return DeviceType.tv;
      case CardType.fan:
        return DeviceType.fan;
      case CardType.door:
        return DeviceType.lock;
      case CardType.elevator:
        return DeviceType.elevator;
      case CardType.doorLock:
        return DeviceType.doorLock;
      case CardType.iphone:
        return DeviceType.iphone;
    }
  }

  /// Get default device name based on card type and room name
  String _getDefaultDeviceName(CardType cardType, String roomName) {
    switch (cardType) {
      case CardType.light:
        return '$roomName Light';
      case CardType.thermostat:
        return '$roomName Thermostat';
      case CardType.curtain:
        return '$roomName Curtains';
      case CardType.camera:
        return '$roomName Camera';
      case CardType.security:
        return '$roomName Security';
      case CardType.music:
        return '$roomName Music Player';
      case CardType.tv:
        return '$roomName TV';
      case CardType.fan:
        return '$roomName Fan';
      case CardType.door:
        return '$roomName Door Lock';
      case CardType.elevator:
        return 'Elevator';
      case CardType.doorLock:
        return '$roomName Intercom';
      case CardType.airConditioner:
        return '$roomName Air Conditioner';
      case CardType.window:
        return '$roomName Window';
      case CardType.humidifier:
        return '$roomName Humidifier';
      case CardType.iphone:
        return '$roomName آیفون درب';
    }
  }

  /// Get default state for device type
  DeviceState _getDefaultStateForDeviceType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.light:
        return const LightState(
          isOn: false,
          brightness: 80,
          color: Color(0xFFFFFFFF),
        );
      case DeviceType.thermostat:
        return const ThermostatState(
          isOn: true,
          temperature: 22,
          targetTemperature: 22,
          mode: 'Auto',
        );
      case DeviceType.curtain:
        return const CurtainState(isOpen: false, position: 0);
      case DeviceType.camera:
        return const CameraState(
          isOn: true,
          isRecording: false,
          resolution: '4K',
        );
      case DeviceType.music:
        return const MusicState(
          isPlaying: false,
          volume: 50,
        );
      case DeviceType.security:
        return const SecurityState(
          isActive: false,
          status: 'Disarmed',
        );
      case DeviceType.elevator:
        return const ElevatorState(
          currentFloor: 0,
          isMoving: false,
          availableFloors: [0, 1, 2, 3, 4],
        );
      case DeviceType.doorLock:
        return const DoorLockState(
          isLocked: true,
          isUnlocking: false,
        );
      case DeviceType.iphone:
        return const IPhoneState(
          isActive: false,
          batteryLevel: 100,
          isCharging: false,
        );
      case DeviceType.fan:
      case DeviceType.tv:
      case DeviceType.socket:
      case DeviceType.lock:
        return const SimpleState(isOn: false);
    }
  }

  /// Get icon for device type
  IconData? _getIconForDeviceType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.light:
        return Icons.lightbulb_rounded;
      case DeviceType.thermostat:
        return Icons.thermostat_rounded;
      case DeviceType.curtain:
        return Icons.curtains_rounded;
      case DeviceType.camera:
        return Icons.videocam_rounded;
      case DeviceType.security:
        return Icons.shield_rounded;
      case DeviceType.music:
        return Icons.music_note_rounded;
      case DeviceType.tv:
        return Icons.tv_rounded;
      case DeviceType.fan:
        return Icons.toys_rounded;
      case DeviceType.lock:
        return Icons.lock_rounded;
      case DeviceType.elevator:
        return Icons.elevator_rounded;
      case DeviceType.doorLock:
        return Icons.door_front_door_rounded;
      case DeviceType.socket:
        return Icons.power_rounded;
      case DeviceType.iphone:
        return Icons.doorbell_rounded;
    }
  }

  /// Get default data for a card type
  Map<String, dynamic> getDefaultDataForType(
    CardType type,
    String currentRoom,
    List<String> availableRooms,
  ) {
    switch (type) {
      case CardType.light:
        return {
          'name': 'New Light',
          'isOn': false,
          'brightness': 80,
          'intensity': 80,
          'color': '#FF9500', // Default orange color matching LEDControlPanel
          'preset': 'Working', // Default preset
          'deviceId': null, // Will be set if synced with device
        };
      case CardType.curtain:
        return {'name': 'New Curtains', 'isOpen': false, 'position': 0};
      case CardType.thermostat:
        return {'temperature': 22, 'targetTemperature': 22, 'mode': 'Auto'};
      case CardType.security:
        return {'status': 'Disarmed', 'isActive': false};
      case CardType.music:
        return {
          'title': 'No Track',
          'artist': 'Unknown Artist',
          'isPlaying': false,
          'volume': 50,
        };
      case CardType.tv:
        return {'name': 'TV', 'isOn': false, 'channel': 1};
      case CardType.fan:
        return {'name': 'Fan', 'isOn': false, 'speed': 0};
      case CardType.camera:
        return {
          'name': 'Camera',
          'isOn': true,
          'location': currentRoom,
          'availableRooms': availableRooms,
          'isRecording': false,
          'resolution': '4K',
        };
      case CardType.elevator:
        return {
          'currentFloor': 1,
          'targetFloor': null,
          'isMoving': false,
          'direction': null,
          'availableFloors': [1, 2, 3, 4, 5],
        };
      case CardType.doorLock:
        return {
          'isLocked': true,
          'isUnlocking': false,
        };
      case CardType.airConditioner:
        return {
          'temperature': 22,
          'targetTemperature': 22,
          'mode': 'Cool',
          'isOn': false,
        };
      case CardType.door:
        return {
          'name': 'Smart Lock',
          'isLocked': true,
          'isOn': false,
        };
      case CardType.window:
        return {
          'name': 'Window',
          'isOpen': false,
          'position': 0,
        };
      case CardType.humidifier:
        return {
          'name': 'Humidifier',
          'temperature': 22,
          'targetTemperature': 22,
          'humidity': 50,
          'isOn': false,
        };
      case CardType.iphone:
        return {
          'name': 'آیفون درب',
          'isActive': false,
          'batteryLevel': 100,
          'isCharging': false,
        };
    }
  }

  /// Convert DeviceType to CardType
  static CardType? deviceTypeToCardType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.light:
        return CardType.light;
      case DeviceType.thermostat:
        return CardType.thermostat;
      case DeviceType.curtain:
        return CardType.curtain;
      case DeviceType.camera:
        return CardType.camera;
      case DeviceType.security:
        return CardType.security;
      case DeviceType.music:
        return CardType.music;
      case DeviceType.tv:
        return CardType.tv;
      case DeviceType.fan:
        return CardType.fan;
      case DeviceType.lock:
        return CardType.door;
      case DeviceType.socket:
        return null; // Socket doesn't have a card type
      case DeviceType.elevator:
        return CardType.elevator;
      case DeviceType.doorLock:
        return CardType.doorLock;
      case DeviceType.iphone:
        return CardType.iphone;
    }
    return null;
  }

  /// Create dashboard cards from devices
  Future<void> createCardsFromDevices(
    List<DeviceEntity> devices,
    String roomId,
    String roomName,
    List<String> availableRoomNames,
  ) async {
    final existingCards = await _loadDashboardCardsUseCase(roomId: roomId);
    final existingDeviceIds = existingCards
        .where((c) => c.data['deviceId'] != null)
        .map((c) => c.data['deviceId'] as String)
        .toSet();

    for (final device in devices) {
      // Skip if card already exists for this device
      if (existingDeviceIds.contains(device.id)) continue;

      final cardType = deviceTypeToCardType(device.type);
      if (cardType == null) continue; // Skip unsupported device types

      // Get device-specific data
      final deviceData = _getDeviceData(device, roomName, availableRoomNames);

      final newCard = DashboardCardModel(
        id: '${device.id}_card',
        type: cardType,
        size: _getDefaultSizeForType(cardType),
        position: existingCards.length + _cards.length,
        data: {
          ...deviceData,
          'deviceId': device.id, // Store device ID for reference
        },
        roomId: roomId,
      );

      _cards.add(newCard);
    }

    if (_cards.isNotEmpty) {
      notifyListeners();
      await saveDashboard();
    }
  }

  /// Get device-specific data for card
  Map<String, dynamic> _getDeviceData(
    DeviceEntity device,
    String roomName,
    List<String> availableRoomNames,
  ) {
    final state = device.state;
    final baseData = {'name': device.name};

    switch (device.type) {
      case DeviceType.light:
        if (state is LightState) {
          return {
            ...baseData,
            'isOn': state.isOn,
            'brightness': state.brightness,
            'intensity': state.brightness, // Use brightness as intensity if not available
            'color': '#${state.color.value.toRadixString(16).substring(2)}',
            'preset': 'Working', // Default preset if not available
          };
        }
        break;
      case DeviceType.thermostat:
        if (state is ThermostatState) {
          return {
            ...baseData,
            'temperature': state.temperature,
            'targetTemperature': state.targetTemperature,
            'mode': state.mode,
          };
        }
        break;
      case DeviceType.curtain:
        if (state is CurtainState) {
          return {
            ...baseData,
            'isOpen': state.isOpen,
            'position': state.position,
          };
        }
        break;
      case DeviceType.camera:
        if (state is CameraState) {
          return {
            ...baseData,
            'isOn': state.isOn,
            'isRecording': state.isRecording,
            'location': roomName,
            'availableRooms': availableRoomNames,
            'resolution': state.resolution,
          };
        }
        break;
      case DeviceType.security:
        if (state is SecurityState) {
          return {
            ...baseData,
            'status': state.status,
            'isActive': state.isActive,
          };
        }
        break;
      case DeviceType.music:
        if (state is MusicState) {
          return {
            ...baseData,
            'title': state.title ?? 'No Track',
            'artist': state.artist ?? 'Unknown Artist',
            'isPlaying': state.isPlaying,
            'volume': state.volume,
          };
        }
        break;
      case DeviceType.tv:
        if (state is SimpleState) {
          return {
            ...baseData,
            'isOn': state.isOn,
            'channel': 1,
          };
        }
        break;
      case DeviceType.fan:
        if (state is SimpleState) {
          return {
            ...baseData,
            'isOn': state.isOn,
            'speed': 0,
          };
        }
        break;
      case DeviceType.elevator:
        if (state is ElevatorState) {
          return {
            ...baseData,
            'currentFloor': state.currentFloor,
            'targetFloor': state.targetFloor,
            'isMoving': state.isMoving,
            'direction': state.direction,
            'availableFloors': state.availableFloors,
          };
        }
        break;
      case DeviceType.doorLock:
        if (state is DoorLockState) {
          return {
            ...baseData,
            'isLocked': state.isLocked,
            'isUnlocking': state.isUnlocking,
          };
        }
        break;
      case DeviceType.iphone:
        if (state is IPhoneState) {
          return {
            ...baseData,
            'isActive': state.isActive,
            'batteryLevel': state.batteryLevel,
            'isCharging': state.isCharging,
            'deviceName': state.deviceName,
          };
        }
        break;
      case DeviceType.socket:
      case DeviceType.lock:
        if (state is SimpleState) {
          return {
            ...baseData,
            'isOn': state.isOn,
          };
        }
        break;
    }

    return baseData;
  }

  /// Get default size for card type
  CardSize _getDefaultSizeForType(CardType type) {
    // Import and use the helper class
    return CardAspectRatioHelper.getDefaultSizeForType(type);
  }

  /// Get default camera card data
  Map<String, dynamic> getDefaultCameraData(
    String roomName,
    List<String> availableRooms,
  ) {
    return {
      'name': 'Security Camera',
      'isOn': true,
      'location': roomName,
      'availableRooms': availableRooms.isEmpty
          ? ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom']
          : availableRooms,
      'isRecording': false,
      'resolution': '4K',
    };
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    if (_currentRoomId != null) {
      // Sync cards with devices first to ensure all devices have cards
      await syncCardsWithDevices(_currentRoomId!);
    }
    await loadDashboard(roomId: _currentRoomId);
  }

  /// Clear all dashboard cards cache
  Future<bool> clearAllDashboardCards() async {
    try {
      final success = await _clearAllDashboardCardsUseCase();
      if (success) {
        // Clear current cards and reload
        _cards = [];
        _layout = DashboardLayoutModel.defaultLayout();
        notifyListeners();
      }
      return success;
    } catch (e) {
      setError('Failed to clear dashboard cache: ${e.toString()}');
      return false;
    }
  }

  /// Sync dashboard cards with actual devices in the room
  /// This ensures the dashboard reflects the current state of devices
  Future<void> syncCardsWithDevices(String roomId) async {
    try {
      print('🔵 [DASHBOARD_VM] syncCardsWithDevices called for room: $roomId');
      print('🔵 [DASHBOARD_VM] Current cards before sync: ${_cards.length}');
      // Get all devices for this room
      final devices = await _getDevicesByRoomUseCase(roomId);
      print('🔵 [DASHBOARD_VM] Found ${devices.length} devices in room');
      for (var device in devices) {
        print('   - ${device.name} (${device.type})');
      }
      
      // Get room name for card data
      String roomName = 'Room';
      List<String> availableRoomNames = [];
      try {
        final room = await _roomRepository.getRoomById(roomId);
        roomName = room.name;
        final allRooms = await _roomRepository.getAllRooms();
        availableRoomNames = allRooms.map((r) => r.name).toList();
      } catch (e) {
        // Room not found, use defaults
      }

      // Get existing device IDs from cards
      final existingDeviceIds = _cards
          .where((c) => c.data['deviceId'] != null)
          .map((c) => c.data['deviceId'] as String)
          .toSet();

      // Get current device IDs
      final currentDeviceIds = devices.map((d) => d.id).toSet();

      // Remove cards for devices that no longer exist in the room
      _cards.removeWhere((card) {
        final deviceId = card.data['deviceId'] as String?;
        if (deviceId != null && !currentDeviceIds.contains(deviceId)) {
          return true; // Remove card
        }
        return false;
      });

      // Add cards for new devices
      for (final device in devices) {
        // Skip if card already exists for this device
        if (existingDeviceIds.contains(device.id)) {
          // Update existing card data with current device state
          final cardIndex = _cards.indexWhere(
            (c) => c.data['deviceId'] == device.id,
          );
          if (cardIndex != -1) {
            final deviceData = _getDeviceData(device, roomName, availableRoomNames);
            _cards[cardIndex] = _cards[cardIndex].copyWith(
              data: {
                ...deviceData,
                'deviceId': device.id,
              },
            );
          }
          continue;
        }

        final cardType = deviceTypeToCardType(device.type);
        if (cardType == null) {
          print('🔵 [DASHBOARD_VM] Skipping device ${device.id} (${device.type}) - no card type mapping');
          continue; // Skip unsupported device types
        }

        print('🔵 [DASHBOARD_VM] Creating card for device ${device.id} (${device.type}) -> ${cardType}');

        // Get device-specific data
        final deviceData = _getDeviceData(device, roomName, availableRoomNames);

        final newCard = DashboardCardModel(
          id: '${device.id}_card',
          type: cardType,
          size: _getDefaultSizeForType(cardType),
          position: _cards.length,
          data: {
            ...deviceData,
            'deviceId': device.id, // Store device ID for reference
          },
          roomId: roomId,
        );

        _cards.add(newCard);
        print('🔵 [DASHBOARD_VM] Added card ${newCard.id} (${newCard.type}). Total cards: ${_cards.length}');
      }

      // Update positions
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(position: i);
      }

      // Update layout based on available devices and content
      await _updateLayoutBasedOnContent(devices, roomId);

      // Save changes
      // Normalize layout to ensure devices section is in first column only
      _layout = _normalizeLayout(_layout);
      
      await saveDashboard();
      
      print('🔵 [DASHBOARD_VM] Final cards after sync: ${_cards.length}');
      for (var card in _cards) {
        print('   - Card ${card.id} (${card.type}, roomId: ${card.roomId})');
      }
      
      notifyListeners();
      print('🔵 [DASHBOARD_VM] Notified listeners after sync');
    } catch (e) {
      // Silently fail - don't break dashboard loading
      print('🔴 [DASHBOARD_VM] Failed to sync cards with devices: ${e.toString()}');
      print('🔴 [DASHBOARD_VM] Stack trace: ${StackTrace.current}');
    }
  }

  /// Update layout sections based on available content (devices, scenarios)
  Future<void> _updateLayoutBasedOnContent(
    List<DeviceEntity> devices,
    String roomId,
  ) async {
    try {
      // Get current sections in layout
      final currentSections = _layout.columns
          .expand((column) => column.sections)
          .map((s) => s.type)
          .toSet();
      
      print('🔵 [DASHBOARD_VM] _updateLayoutBasedOnContent called');
      print('🔵 [DASHBOARD_VM] Current sections in layout at start: $currentSections');

      // Determine which sections should exist based on content
      final shouldHaveSections = <DashboardSectionType>{};

      // Always have devices section
      shouldHaveSections.add(DashboardSectionType.devices);

      // Check for LED devices
      if (devices.any((d) => d.type == DeviceType.light)) {
        shouldHaveSections.add(DashboardSectionType.led);
      }

      // Check for thermostat devices
      if (devices.any((d) => d.type == DeviceType.thermostat)) {
        shouldHaveSections.add(DashboardSectionType.thermostat);
      }

      // Check for camera devices
      if (devices.any((d) => d.type == DeviceType.camera)) {
        shouldHaveSections.add(DashboardSectionType.camera);
      }

      // Check for socket/tablet charger devices
      if (devices.any((d) => d.type == DeviceType.socket)) {
        shouldHaveSections.add(DashboardSectionType.tabletCharger);
      }

      // Check for music devices
      if (devices.any((d) => d.type == DeviceType.music)) {
        shouldHaveSections.add(DashboardSectionType.music);
      }

      // Check for security devices - only add security section for general room
      if (roomId == 'room_general' && devices.any((d) => d.type == DeviceType.security)) {
        shouldHaveSections.add(DashboardSectionType.security);
      }

      // Check for curtain devices
      if (devices.any((d) => d.type == DeviceType.curtain)) {
        shouldHaveSections.add(DashboardSectionType.curtain);
      }

      // Check for elevator devices
      if (devices.any((d) => d.type == DeviceType.elevator)) {
        shouldHaveSections.add(DashboardSectionType.elevator);
      }

      // Check for door lock devices
      if (devices.any((d) => d.type == DeviceType.doorLock)) {
        shouldHaveSections.add(DashboardSectionType.doorLock);
      }

      // Always show scenarios section (even when empty, shows empty state)
      try {
        print('🔵 [DASHBOARD_VM] Adding scenarios section (always visible)');
        shouldHaveSections.add(DashboardSectionType.scenarios);
        
        // For logging purposes, check scenarios count
        final allScenarios = await _getAllScenariosUseCase();
        print('🔵 [DASHBOARD_VM] Total scenarios: ${allScenarios.length}');
        final roomScenarios = allScenarios.where((s) => s.roomId == roomId).toList();
        print('🔵 [DASHBOARD_VM] Scenarios for room $roomId: ${roomScenarios.length}');
      } catch (e) {
        print('🔴 [DASHBOARD_VM] Error checking scenarios: $e');
        // Still add scenarios section even if there's an error
        shouldHaveSections.add(DashboardSectionType.scenarios);
      }

      // Remove sections that shouldn't exist
      final columns = _cloneColumns();
      bool layoutChanged = false;

      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];
        final sectionsToKeep = column.sections.where((section) {
          // Always keep devices section
          if (section.type == DashboardSectionType.devices) {
            return true;
          }
          // Keep scenarios section (will be managed separately)
          if (section.type == DashboardSectionType.scenarios) {
            return true;
          }
          // Keep other sections only if they should exist
          return shouldHaveSections.contains(section.type);
        }).toList();

        if (sectionsToKeep.length != column.sections.length) {
          columns[columnIndex] = column.copyWith(sections: sectionsToKeep);
          layoutChanged = true;
        }
      }

      // Add missing sections
      final missingSections = shouldHaveSections
          .where((type) => !currentSections.contains(type))
          .toList();
      
      print('🔵 [DASHBOARD_VM] Current sections in layout: $currentSections');
      print('🔵 [DASHBOARD_VM] Should have sections: $shouldHaveSections');
      print('🔵 [DASHBOARD_VM] Missing sections to add: $missingSections');

      if (missingSections.isNotEmpty) {
        // Ensure we have at least 2 columns: first for devices, others for other sections
        if (columns.length == 1) {
          // Create second column for other sections
          columns.add(
            DashboardColumnModel(
              id: 'column_controls',
              flex: 40.0,
              sections: [],
            ),
          );
          // Adjust first column flex to maintain balance
          columns[0] = columns[0].copyWith(flex: 60.0);
        }

        // Add missing sections to appropriate columns
        for (final sectionType in missingSections) {
          if (sectionType == DashboardSectionType.devices) {
            continue; // Already handled - devices always in first column
          }

          // Determine which column to add to
          // NEVER add non-device sections to first column (index 0)
          int targetColumnIndex = 1; // Default to second column
          
          if (sectionType == DashboardSectionType.led ||
              sectionType == DashboardSectionType.thermostat ||
              sectionType == DashboardSectionType.tabletCharger ||
              sectionType == DashboardSectionType.music ||
              sectionType == DashboardSectionType.security ||
              sectionType == DashboardSectionType.curtain ||
              sectionType == DashboardSectionType.elevator ||
              sectionType == DashboardSectionType.doorLock ||
              sectionType == DashboardSectionType.scenarios) {
            // Add to second column (or create if doesn't exist)
            targetColumnIndex = 1;
          } else if (sectionType == DashboardSectionType.camera) {
            // Add camera to last column (or create new one)
            targetColumnIndex = columns.length - 1;
            // If last column is first column, create a new one
            if (targetColumnIndex == 0) {
              targetColumnIndex = columns.length;
            }
          }

          // Ensure column exists (create if needed)
          if (targetColumnIndex >= columns.length) {
            // Create new column
            columns.add(
              DashboardColumnModel(
                id: 'column_${sectionType.name}',
                flex: 30.0,
                sections: [],
              ),
            );
            targetColumnIndex = columns.length - 1;
          }

          // Ensure we're not adding to first column (devices only)
          if (targetColumnIndex == 0 && sectionType != DashboardSectionType.devices) {
            // Move to second column or create one
            if (columns.length > 1) {
              targetColumnIndex = 1;
            } else {
              columns.add(
                DashboardColumnModel(
                  id: 'column_${sectionType.name}',
                  flex: 40.0,
                  sections: [],
                ),
              );
              targetColumnIndex = 1;
              // Adjust first column flex
              columns[0] = columns[0].copyWith(flex: 60.0);
            }
          }

          // Add section to column
          final newSection = DashboardSectionModel.defaultFor(sectionType);
          columns[targetColumnIndex] = columns[targetColumnIndex].copyWith(
            sections: [...columns[targetColumnIndex].sections, newSection],
          );
          layoutChanged = true;
        }
      }

      // Normalize flex values
      if (layoutChanged) {
        final totalFlex = columns.fold<double>(
          0,
          (sum, column) => sum + column.flex,
        );

        if (totalFlex > 0) {
          // Redistribute flex values proportionally
          final newColumns = columns.map((column) {
            final newFlex = (column.flex / totalFlex) * 100;
            return column.copyWith(flex: newFlex);
          }).toList();

          _layout = DashboardLayoutModel(columns: newColumns);
        } else {
          // Set default flex values
          final newColumns = columns.map((column) {
            return column.copyWith(flex: 100.0 / columns.length);
          }).toList();

          _layout = DashboardLayoutModel(columns: newColumns);
        }
      }
    } catch (e) {
      // Silently fail
      print('Failed to update layout based on content: ${e.toString()}');
    }
  }

  /// Add scenarios section to layout when first scenario is created
  Future<void> addScenariosSectionIfNeeded() async {
    print('🔵 [DASHBOARD_VM] addScenariosSectionIfNeeded called');
    final currentSections = _layout.columns
        .expand((column) => column.sections)
        .map((s) => s.type)
        .toSet();
    print('🔵 [DASHBOARD_VM] Current sections: $currentSections');

    if (currentSections.contains(DashboardSectionType.scenarios)) {
      print('🔵 [DASHBOARD_VM] Scenarios section already exists, returning');
      return; // Already exists
    }
    print('🔵 [DASHBOARD_VM] Scenarios section not found, adding it');

    // Add scenarios section to last column or create new column
    final columns = _cloneColumns();
    int targetColumnIndex = columns.length - 1;

    if (targetColumnIndex < 0) {
      // Create new column
      columns.add(
        DashboardColumnModel(
          id: 'column_scenarios',
          flex: 30.0,
          sections: [
            DashboardSectionModel.defaultFor(DashboardSectionType.scenarios),
          ],
        ),
      );
    } else {
      // Add to last column
      columns[targetColumnIndex] = columns[targetColumnIndex].copyWith(
        sections: [
          ...columns[targetColumnIndex].sections,
          DashboardSectionModel.defaultFor(DashboardSectionType.scenarios),
        ],
      );
    }

    // Normalize flex
    final totalFlex = columns.fold<double>(
      0,
      (sum, column) => sum + column.flex,
    );

    if (totalFlex > 0) {
      final newColumns = columns.map((column) {
        final newFlex = (column.flex / totalFlex) * 100;
        return column.copyWith(flex: newFlex);
      }).toList();

      _layout = DashboardLayoutModel(columns: newColumns);
    }

    // Normalize layout to ensure proper column distribution
    _layout = _normalizeLayout(_layout);

    await saveDashboard();
    print('🔵 [DASHBOARD_VM] Dashboard saved with scenarios section');
    notifyListeners();
    print('🔵 [DASHBOARD_VM] Listeners notified');
  }

  /// Remove scenarios section from layout when all scenarios are deleted
  /// NOTE: This method is now a no-op - scenarios section should always remain visible
  Future<void> removeScenariosSectionIfNeeded() async {
    print('🔵 [DASHBOARD_VM] removeScenariosSectionIfNeeded called - but scenarios section is always kept');
    // Do nothing - scenarios section should always remain visible even when empty
    return;
  }

  /// Add a section manually to the layout
  /// Maximum 8 sections (excluding devices) to prevent layout overflow
  Future<void> addSectionManually(DashboardSectionType sectionType) async {
    // Check maximum limit (8 sections excluding devices)
    final currentSections = _layout.columns
        .expand((column) => column.sections)
        .where((s) => s.type != DashboardSectionType.devices)
        .toList();
    
    if (currentSections.length >= 8) {
      throw Exception('Maximum 8 sections allowed');
    }

    // Check if section already exists
    final existingTypes = currentSections.map((s) => s.type).toSet();
    if (existingTypes.contains(sectionType)) {
      throw Exception('Section already exists');
    }

    final columns = _cloneColumns();
    
    // Ensure we have at least 2 columns
    if (columns.length == 1) {
      columns.add(
        DashboardColumnModel(
          id: 'column_controls',
          flex: 40.0,
          sections: [],
        ),
      );
      columns[0] = columns[0].copyWith(flex: 60.0);
    }

    // Add section to second column (or last if second is full)
    int targetColumnIndex = 1;
    if (targetColumnIndex >= columns.length) {
      columns.add(
        DashboardColumnModel(
          id: 'column_${sectionType.name}',
          flex: 30.0,
          sections: [],
        ),
      );
      targetColumnIndex = columns.length - 1;
    }

    // Add section to target column
    final newSection = DashboardSectionModel.defaultFor(sectionType);
    columns[targetColumnIndex] = columns[targetColumnIndex].copyWith(
      sections: [...columns[targetColumnIndex].sections, newSection],
    );

    // Normalize layout
    _layout = _normalizeLayout(DashboardLayoutModel(columns: columns));
    await saveDashboard();
    notifyListeners();
  }
}
