import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<List<HomeEntity>> getHomeData();
  Future<HomeEntity> getHomeItemById(String id);
}


