import '../../data/models/dashboard_card_model.dart';
import '../../data/models/dashboard_layout_model.dart';

/// Dashboard Repository interface
/// Defines the contract for dashboard data operations
abstract class DashboardRepository {
  /// Load dashboard cards for a specific room
  Future<List<DashboardCardModel>> loadDashboardCards({String? roomId});

  /// Save dashboard cards for a specific room
  Future<bool> saveDashboardCards(
    List<DashboardCardModel> cards, {
    String? roomId,
  });

  /// Load dashboard layout (column + section arrangement)
  Future<DashboardLayoutModel> loadDashboardLayout();

  /// Save dashboard layout
  Future<bool> saveDashboardLayout(DashboardLayoutModel layout);

  /// Clear dashboard settings
  Future<bool> clearSettings();

  /// Clear all room-specific dashboard cards
  Future<bool> clearAllRoomCards();

  /// Get default cards
  List<DashboardCardModel> getDefaultCards();

  /// Get default layout
  DashboardLayoutModel getDefaultLayout();
}
