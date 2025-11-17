import '../../../core/base/base_viewmodel.dart';
import '../../../domain/entities/home_entity.dart';
import '../../../domain/use_cases/get_home_data_use_case.dart';

class HomeViewModel extends BaseViewModel {
  final GetHomeDataUseCase _getHomeDataUseCase;

  HomeViewModel(this._getHomeDataUseCase);

  List<HomeEntity> _homeItems = [];
  List<HomeEntity> get homeItems => _homeItems;

  @override
  void init() {
    super.init();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    setLoading(true);
    clearError();

    try {
      _homeItems = await _getHomeDataUseCase();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}


