import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../data/data_sources/remote/api/api_client.dart';
import '../../data/data_sources/local/preferences/preferences_service.dart';
import '../../data/data_sources/local/dashboard/dashboard_settings_service.dart';
import '../../data/data_sources/remote/socket/socket_service.dart';
import '../../data/repositories/implementations/home_repository_impl.dart';
import '../../data/repositories/implementations/socket_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/socket_repository.dart';
import '../../domain/use_cases/get_home_data_use_case.dart';
import '../../domain/use_cases/connect_socket_use_case.dart';
import '../../domain/use_cases/send_socket_command_use_case.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/socket_viewmodel.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> initDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Dio client
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>()),
  );

  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<DashboardSettingsService>(
    () => DashboardSettingsService(getIt<PreferencesService>()),
  );

  // Socket Service (Singleton)
  getIt.registerLazySingleton<SocketService>(
    () => SocketService.instance,
  );

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      apiClient: getIt<ApiClient>(),
      preferencesService: getIt<PreferencesService>(),
    ),
  );

  getIt.registerLazySingleton<SocketRepository>(
    () => SocketRepositoryImpl(getIt<SocketService>()),
  );

  // Use cases
  getIt.registerLazySingleton<GetHomeDataUseCase>(
    () => GetHomeDataUseCase(getIt<HomeRepository>()),
  );

  getIt.registerLazySingleton<ConnectSocketUseCase>(
    () => ConnectSocketUseCase(getIt<SocketRepository>()),
  );

  getIt.registerLazySingleton<SendSocketCommandUseCase>(
    () => SendSocketCommandUseCase(getIt<SocketRepository>()),
  );

  // ViewModels
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(getIt<GetHomeDataUseCase>()),
  );

  getIt.registerFactory<SocketViewModel>(
    () => SocketViewModel(
      getIt<SocketRepository>(),
      getIt<ConnectSocketUseCase>(),
      getIt<SendSocketCommandUseCase>(),
    ),
  );
}

