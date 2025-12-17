import '../../repositories/dashboard_repository.dart';
import '../../../data/models/dashboard_layout_model.dart';

/// Use case for loading dashboard layout configuration.
class LoadDashboardLayoutUseCase {
  final DashboardRepository _repository;

  LoadDashboardLayoutUseCase(this._repository);

  Future<DashboardLayoutModel> call() async {
    return await _repository.loadDashboardLayout();
  }
}
