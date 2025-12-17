import '../../repositories/dashboard_repository.dart';
import '../../../data/models/dashboard_card_model.dart';

/// Use case for getting default dashboard cards
class GetDefaultCardsUseCase {
  final DashboardRepository _repository;

  GetDefaultCardsUseCase(this._repository);

  List<DashboardCardModel> call() {
    return _repository.getDefaultCards();
  }
}

