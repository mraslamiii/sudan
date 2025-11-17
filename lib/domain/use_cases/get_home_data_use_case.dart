import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository _repository;

  GetHomeDataUseCase(this._repository);

  Future<List<HomeEntity>> call() async {
    return await _repository.getHomeData();
  }
}


