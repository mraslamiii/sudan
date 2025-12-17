import '../../repositories/dashboard_repository.dart';

/// Use case to clear all room-specific dashboard cards
class ClearAllDashboardCardsUseCase {
  final DashboardRepository _dashboardRepository;

  ClearAllDashboardCardsUseCase(this._dashboardRepository);

  Future<bool> call() async {
    return await _dashboardRepository.clearAllRoomCards();
  }
}

