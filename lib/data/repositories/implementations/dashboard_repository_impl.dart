import '../../../domain/repositories/dashboard_repository.dart';
import '../../models/dashboard_card_model.dart';
import '../../models/dashboard_layout_model.dart';
import '../../data_sources/local/dashboard/dashboard_settings_service.dart';

/// Implementation of DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardSettingsService _dashboardSettingsService;

  DashboardRepositoryImpl(this._dashboardSettingsService);

  @override
  Future<List<DashboardCardModel>> loadDashboardCards({String? roomId}) async {
    return await _dashboardSettingsService.loadDashboardCards(roomId: roomId);
  }

  @override
  Future<bool> saveDashboardCards(
    List<DashboardCardModel> cards, {
    String? roomId,
  }) async {
    return await _dashboardSettingsService.saveDashboardCards(
      cards,
      roomId: roomId,
    );
  }

  @override
  Future<DashboardLayoutModel> loadDashboardLayout() async {
    return await _dashboardSettingsService.loadDashboardLayout();
  }

  @override
  Future<bool> saveDashboardLayout(DashboardLayoutModel layout) async {
    return await _dashboardSettingsService.saveDashboardLayout(layout);
  }

  @override
  Future<bool> clearSettings() async {
    return await _dashboardSettingsService.clearSettings();
  }

  @override
  Future<bool> clearAllRoomCards() async {
    return await _dashboardSettingsService.clearAllRoomCards();
  }

  @override
  List<DashboardCardModel> getDefaultCards() {
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

  @override
  DashboardLayoutModel getDefaultLayout() {
    return DashboardLayoutModel.defaultLayout();
  }
}
