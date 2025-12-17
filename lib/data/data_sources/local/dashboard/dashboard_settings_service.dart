import '../../../models/dashboard_card_model.dart';
import '../../../models/dashboard_layout_model.dart';
import '../preferences/preferences_service.dart';

class DashboardSettingsService {
  final PreferencesService _preferencesService;
  static const String _dashboardCardsKey = 'dashboard_cards';
  static const String _dashboardLayoutKey = 'dashboard_layout';

  DashboardSettingsService(this._preferencesService);

  /// Get key for room-specific cards
  String _getRoomCardsKey(String? roomId) {
    if (roomId == null) return _dashboardCardsKey;
    return '${_dashboardCardsKey}_$roomId';
  }

  /// Save dashboard cards configuration for a specific room
  Future<bool> saveDashboardCards(
    List<DashboardCardModel> cards, {
    String? roomId,
  }) async {
    try {
      final jsonString = DashboardCardModel.toJsonString(cards);
      return await _preferencesService.setString(
        _getRoomCardsKey(roomId),
        jsonString,
      );
    } catch (e) {
      return false;
    }
  }

  /// Load dashboard cards configuration for a specific room
  Future<List<DashboardCardModel>> loadDashboardCards({String? roomId}) async {
    try {
      final jsonString = _preferencesService.getString(_getRoomCardsKey(roomId));
      if (jsonString == null || jsonString.isEmpty) {
        // Return empty list for new rooms, default cards only for legacy/global
        if (roomId != null) {
          return [];
        }
        return _getDefaultCards();
      }
      return DashboardCardModel.fromJsonString(jsonString);
    } catch (e) {
      if (roomId != null) {
        return [];
      }
      return _getDefaultCards();
    }
  }

  /// Get default cards configuration
  List<DashboardCardModel> _getDefaultCards() {
    return [
      DashboardCardModel(
        id: '1',
        type: CardType.music,
        size: CardSize.large,
        position: 0,
        data: {
          'title': 'Night Drive',
          'artist': 'Daniel Avery',
          'isPlaying': false,
          'volume': 50,
        },
      ),
      DashboardCardModel(
        id: '2',
        type: CardType.light,
        size: CardSize.medium,
        position: 1,
        data: {
          'name': 'LED Lights',
          'isOn': true,
          'brightness': 70,
          'color': '#FF6B6B',
        },
      ),
      DashboardCardModel(
        id: '3',
        type: CardType.security,
        size: CardSize.medium,
        position: 2,
        data: {'status': 'Armed', 'isActive': true},
      ),
      DashboardCardModel(
        id: '4',
        type: CardType.tv,
        size: CardSize.medium,
        position: 3,
        data: {'name': 'TV', 'isOn': false, 'channel': 1},
      ),
      DashboardCardModel(
        id: '5',
        type: CardType.light,
        size: CardSize.medium,
        position: 4,
        data: {
          'name': 'Floor Lamp',
          'isOn': true,
          'brightness': 60,
          'color': '#FFD93D',
        },
      ),
      DashboardCardModel(
        id: '6',
        type: CardType.thermostat,
        size: CardSize.medium,
        position: 5,
        data: {'temperature': 22, 'targetTemperature': 22, 'mode': 'cool'},
      ),
      DashboardCardModel(
        id: '7',
        type: CardType.fan,
        size: CardSize.medium,
        position: 6,
        data: {'name': 'Fan', 'isOn': false, 'speed': 0},
      ),
      DashboardCardModel(
        id: '8',
        type: CardType.curtain,
        size: CardSize.medium,
        position: 7,
        data: {'name': 'Living Room Curtains', 'isOpen': false, 'position': 0},
      ),
    ];
  }

  /// Clear all dashboard settings
  Future<bool> clearSettings() async {
    final cardsCleared = await _preferencesService.remove(_dashboardCardsKey);
    final layoutCleared = await _preferencesService.remove(_dashboardLayoutKey);
    return cardsCleared && layoutCleared;
  }

  /// Clear all room-specific dashboard cards
  /// This removes all keys that match the pattern 'dashboard_cards_*'
  Future<bool> clearAllRoomCards() async {
    try {
      final prefs = _preferencesService;
      
      // Get all keys from SharedPreferences
      final allKeys = prefs.getAllKeys();
      
      // Find all keys that start with 'dashboard_cards'
      final dashboardCardKeys = allKeys.where((key) => 
        key.startsWith(_dashboardCardsKey)
      ).toList();
      
      // Remove all dashboard card keys
      for (final key in dashboardCardKeys) {
        await prefs.remove(key);
      }
      
      // Clear layout (shared across all rooms)
      await prefs.remove(_dashboardLayoutKey);
      
      print('🧹 [DASHBOARD_DS] Cleared ${dashboardCardKeys.length} dashboard card keys');
      
      return true;
    } catch (e) {
      print('🔴 [DASHBOARD_DS] Error clearing dashboard cards: $e');
      return false;
    }
  }

  /// Save dashboard section layout configuration
  Future<bool> saveDashboardLayout(DashboardLayoutModel layout) async {
    try {
      return await _preferencesService.setString(
        _dashboardLayoutKey,
        layout.toJsonString(),
      );
    } catch (_) {
      return false;
    }
  }

  /// Load dashboard section layout configuration
  Future<DashboardLayoutModel> loadDashboardLayout() async {
    try {
      final jsonString = _preferencesService.getString(_dashboardLayoutKey);
      if (jsonString == null || jsonString.isEmpty) {
        return DashboardLayoutModel.defaultLayout();
      }
      return DashboardLayoutModel.fromJsonString(jsonString);
    } catch (_) {
      return DashboardLayoutModel.defaultLayout();
    }
  }
}
