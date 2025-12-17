import '../../repositories/dashboard_repository.dart';
import '../../../data/models/dashboard_card_model.dart';

/// Use case for loading dashboard cards
class LoadDashboardCardsUseCase {
  final DashboardRepository _repository;

  LoadDashboardCardsUseCase(this._repository);

  Future<List<DashboardCardModel>> call({String? roomId}) async {
    return await _repository.loadDashboardCards(roomId: roomId);
  }
}

