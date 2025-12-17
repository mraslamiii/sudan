import '../../repositories/dashboard_repository.dart';
import '../../../data/models/dashboard_layout_model.dart';

/// Use case for persisting dashboard layout configuration.
class SaveDashboardLayoutUseCase {
  final DashboardRepository _repository;

  SaveDashboardLayoutUseCase(this._repository);

  Future<bool> call(DashboardLayoutModel layout) async {
    return await _repository.saveDashboardLayout(layout);
  }
}
