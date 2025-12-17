import '../../repositories/dashboard_repository.dart';
import '../../../data/models/dashboard_card_model.dart';

/// Use case for saving dashboard cards
class SaveDashboardCardsUseCase {
  final DashboardRepository _repository;

  SaveDashboardCardsUseCase(this._repository);

  Future<bool> call(
    List<DashboardCardModel> cards, {
    String? roomId,
  }) async {
    return await _repository.saveDashboardCards(cards, roomId: roomId);
  }
}

