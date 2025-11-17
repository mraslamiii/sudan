import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/home_entity.dart';
import '../../../../domain/repositories/home_repository.dart';
import '../../data_sources/remote/api/api_client.dart';
import '../../data_sources/local/preferences/preferences_service.dart';
import '../../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient apiClient;
  final PreferencesService preferencesService;

  HomeRepositoryImpl({
    required this.apiClient,
    required this.preferencesService,
  });

  @override
  Future<List<HomeEntity>> getHomeData() async {
    try {
      // Example: Fetch from API
      // final response = await apiClient.get('/home');
      // final List<dynamic> data = response['data'] ?? [];
      // return data.map((json) => HomeModel.fromJson(json)).toList();

      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return [
        HomeModel.mock(
          id: '1',
          title: 'Welcome to Smart Home',
          description: 'Control your home devices',
        ),
        HomeModel.mock(
          id: '2',
          title: 'Living Room',
          description: 'Manage living room devices',
        ),
      ];
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to fetch home data: ${e.toString()}');
    }
  }

  @override
  Future<HomeEntity> getHomeItemById(String id) async {
    try {
      // Example: Fetch from API
      // final response = await apiClient.get('/home/$id');
      // return HomeModel.fromJson(response['data']);

      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return HomeModel.mock(
        id: id,
        title: 'Item $id',
        description: 'Description for item $id',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Failed to fetch home item: ${e.toString()}');
    }
  }
}

