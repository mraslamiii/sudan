import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../models/dashboard_card_model.dart';
import '../preferences/preferences_service.dart';

class DashboardSettingsService {
  final PreferencesService _preferencesService;
  static const String _dashboardCardsKey = 'dashboard_cards';

  DashboardSettingsService(this._preferencesService);

  /// Save dashboard cards configuration
  Future<bool> saveDashboardCards(List<DashboardCardModel> cards) async {
    try {
      final jsonString = DashboardCardModel.toJsonString(cards);
      return await _preferencesService.setString(_dashboardCardsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Load dashboard cards configuration
  Future<List<DashboardCardModel>> loadDashboardCards() async {
    try {
      final jsonString = _preferencesService.getString(_dashboardCardsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultCards();
      }
      return DashboardCardModel.fromJsonString(jsonString);
    } catch (e) {
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
        data: {
          'status': 'Armed',
          'isActive': true,
        },
      ),
      DashboardCardModel(
        id: '4',
        type: CardType.tv,
        size: CardSize.medium,
        position: 3,
        data: {
          'name': 'TV',
          'isOn': false,
          'channel': 1,
        },
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
        data: {
          'temperature': 22,
          'targetTemperature': 22,
          'mode': 'cool',
        },
      ),
      DashboardCardModel(
        id: '7',
        type: CardType.fan,
        size: CardSize.medium,
        position: 6,
        data: {
          'name': 'Fan',
          'isOn': false,
          'speed': 0,
        },
      ),
      DashboardCardModel(
        id: '8',
        type: CardType.curtain,
        size: CardSize.medium,
        position: 7,
        data: {
          'name': 'Living Room Curtains',
          'isOpen': false,
          'position': 0,
        },
      ),
    ];
  }

  /// Clear all dashboard settings
  Future<bool> clearSettings() async {
    return await _preferencesService.remove(_dashboardCardsKey);
  }
}

