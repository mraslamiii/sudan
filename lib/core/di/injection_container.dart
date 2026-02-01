import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../data/data_sources/remote/api/api_client.dart';
import '../../data/data_sources/local/preferences/preferences_service.dart';
import '../../data/data_sources/local/dashboard/dashboard_settings_service.dart';
import '../../data/data_sources/local/pin/pin_service.dart';
import '../../data/data_sources/remote/socket/socket_service.dart';
import '../../data/data_sources/remote/usb_serial/usb_serial_service.dart';
import '../../data/data_sources/local/device/device_local_data_source.dart';
import '../../data/data_sources/local/scenario/scenario_local_data_source.dart';
import '../../data/data_sources/local/room/room_local_data_source.dart';
import '../../data/data_sources/local/floor/floor_local_data_source.dart';
import '../../data/repositories/implementations/home_repository_impl.dart';
import '../../data/repositories/implementations/socket_repository_impl.dart';
import '../../data/repositories/implementations/usb_serial_repository_impl.dart';
import '../../data/repositories/implementations/mock_usb_serial_repository_impl.dart';
import '../../data/repositories/implementations/device_repository_impl.dart';
import '../../data/repositories/implementations/scenario_repository_impl.dart';
import '../../data/repositories/implementations/room_repository_impl.dart';
import '../../data/repositories/implementations/floor_repository_impl.dart';
import '../../data/repositories/implementations/dashboard_repository_impl.dart';
import '../../data/repositories/implementations/config_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/socket_repository.dart';
import '../../domain/repositories/usb_serial_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/repositories/floor_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/config_repository.dart';
import '../../domain/use_cases/get_home_data_use_case.dart';
import '../../domain/use_cases/connect_socket_use_case.dart';
import '../../domain/use_cases/send_socket_command_use_case.dart';
import '../../domain/use_cases/connect_usb_serial_use_case.dart';
import '../../domain/use_cases/send_usb_serial_command_use_case.dart';
import '../../domain/use_cases/device/get_all_devices_use_case.dart';
import '../../domain/use_cases/device/get_devices_by_room_use_case.dart';
import '../../domain/use_cases/device/get_device_by_id_use_case.dart';
import '../../domain/use_cases/device/update_device_use_case.dart';
import '../../domain/use_cases/device/toggle_device_use_case.dart';
import '../../domain/use_cases/scenario/get_all_scenarios_use_case.dart';
import '../../domain/use_cases/scenario/create_scenario_use_case.dart';
import '../../domain/use_cases/scenario/update_scenario_use_case.dart';
import '../../domain/use_cases/scenario/delete_scenario_use_case.dart';
import '../../domain/use_cases/scenario/execute_scenario_use_case.dart';
import '../../domain/use_cases/room/get_all_rooms_use_case.dart';
import '../../domain/use_cases/room/get_room_by_id_use_case.dart';
import '../../domain/use_cases/room/create_room_use_case.dart';
import '../../domain/use_cases/room/update_room_use_case.dart';
import '../../domain/use_cases/device/create_device_use_case.dart';
import '../../domain/use_cases/device/add_device_to_room_use_case.dart';
import '../../presentation/viewmodels/room_setup_viewmodel.dart';
import '../../presentation/viewmodels/scenario_setup_viewmodel.dart';
import '../../domain/use_cases/floor/get_all_floors_use_case.dart';
import '../../domain/use_cases/floor/get_floor_by_id_use_case.dart';
import '../../domain/use_cases/floor/create_floor_use_case.dart';
import '../../domain/use_cases/floor/update_floor_use_case.dart';
import '../../domain/use_cases/floor/delete_floor_use_case.dart';
import '../../domain/use_cases/floor/add_room_to_floor_use_case.dart';
import '../../domain/use_cases/dashboard/load_dashboard_cards_use_case.dart';
import '../../domain/use_cases/dashboard/save_dashboard_cards_use_case.dart';
import '../../domain/use_cases/dashboard/get_default_cards_use_case.dart';
import '../../domain/use_cases/dashboard/load_dashboard_layout_use_case.dart';
import '../../domain/use_cases/dashboard/save_dashboard_layout_use_case.dart';
import '../../domain/use_cases/dashboard/clear_all_dashboard_cards_use_case.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/socket_viewmodel.dart';
import '../../presentation/viewmodels/usb_serial_viewmodel.dart';
import '../../presentation/viewmodels/device_viewmodel.dart';
import '../../presentation/viewmodels/scenario_viewmodel.dart';
import '../../presentation/viewmodels/room_viewmodel.dart';
import '../../presentation/viewmodels/floor_viewmodel.dart';
import '../../presentation/viewmodels/dashboard_viewmodel.dart';

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
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<DashboardSettingsService>(
    () => DashboardSettingsService(getIt<PreferencesService>()),
  );

  getIt.registerLazySingleton<PinService>(
    () => PinService(getIt<PreferencesService>()),
  );

  // Socket Service (Singleton)
  getIt.registerLazySingleton<SocketService>(() => SocketService.instance);

  // USB Serial Service (Singleton)
  getIt.registerLazySingleton<UsbSerialService>(
    () => UsbSerialService.instance,
  );

  // Smart Home Local Data Sources
  getIt.registerLazySingleton<DeviceLocalDataSource>(
    () => DeviceLocalDataSource(getIt<PreferencesService>()),
  );

  getIt.registerLazySingleton<ScenarioLocalDataSource>(
    () => ScenarioLocalDataSource(getIt<PreferencesService>()),
  );

  getIt.registerLazySingleton<RoomLocalDataSource>(
    () => RoomLocalDataSource(getIt<PreferencesService>()),
  );

  getIt.registerLazySingleton<FloorLocalDataSource>(
    () => FloorLocalDataSource(getIt<PreferencesService>()),
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

  getIt.registerLazySingleton<UsbSerialRepository>(
    () => kDebugMode
        ? MockUsbSerialRepositoryImpl()
        : UsbSerialRepositoryImpl(getIt<UsbSerialService>()),
  );

  // Smart Home Repositories
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(getIt<DeviceLocalDataSource>()),
  );

  getIt.registerLazySingleton<ScenarioRepository>(
    () => ScenarioRepositoryImpl(
      getIt<ScenarioLocalDataSource>(),
      getIt<DeviceRepository>(),
      getIt<PreferencesService>(),
    ),
  );

  getIt.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(
      getIt<RoomLocalDataSource>(),
      getIt<UsbSerialRepository>(),
    ),
  );

  getIt.registerLazySingleton<FloorRepository>(
    () => FloorRepositoryImpl(
      getIt<FloorLocalDataSource>(),
      getIt<RoomRepository>(),
      getIt<UsbSerialRepository>(),
    ),
  );

  // Dashboard Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardSettingsService>()),
  );

  // Config Repository
  getIt.registerLazySingleton<ConfigRepository>(() => ConfigRepositoryImpl());

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

  getIt.registerLazySingleton<ConnectUsbSerialUseCase>(
    () => ConnectUsbSerialUseCase(getIt<UsbSerialRepository>()),
  );

  getIt.registerLazySingleton<SendUsbSerialCommandUseCase>(
    () => SendUsbSerialCommandUseCase(getIt<UsbSerialRepository>()),
  );

  // Device Use Cases
  getIt.registerLazySingleton<GetAllDevicesUseCase>(
    () => GetAllDevicesUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<GetDevicesByRoomUseCase>(
    () => GetDevicesByRoomUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<GetDeviceByIdUseCase>(
    () => GetDeviceByIdUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<UpdateDeviceUseCase>(
    () => UpdateDeviceUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<ToggleDeviceUseCase>(
    () => ToggleDeviceUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<CreateDeviceUseCase>(
    () => CreateDeviceUseCase(getIt<DeviceRepository>()),
  );

  getIt.registerLazySingleton<AddDeviceToRoomUseCase>(
    () => AddDeviceToRoomUseCase(
      getIt<RoomRepository>(),
      getIt<DeviceRepository>(),
    ),
  );

  // Scenario Use Cases
  getIt.registerLazySingleton<GetAllScenariosUseCase>(
    () => GetAllScenariosUseCase(getIt<ScenarioRepository>()),
  );

  getIt.registerLazySingleton<CreateScenarioUseCase>(
    () => CreateScenarioUseCase(getIt<ScenarioRepository>()),
  );

  getIt.registerLazySingleton<UpdateScenarioUseCase>(
    () => UpdateScenarioUseCase(getIt<ScenarioRepository>()),
  );

  getIt.registerLazySingleton<DeleteScenarioUseCase>(
    () => DeleteScenarioUseCase(getIt<ScenarioRepository>()),
  );

  getIt.registerLazySingleton<ExecuteScenarioUseCase>(
    () => ExecuteScenarioUseCase(getIt<ScenarioRepository>()),
  );

  // Room Use Cases
  getIt.registerLazySingleton<GetAllRoomsUseCase>(
    () => GetAllRoomsUseCase(getIt<RoomRepository>()),
  );

  getIt.registerLazySingleton<GetRoomByIdUseCase>(
    () => GetRoomByIdUseCase(getIt<RoomRepository>()),
  );

  getIt.registerLazySingleton<CreateRoomUseCase>(
    () => CreateRoomUseCase(getIt<RoomRepository>()),
  );

  getIt.registerLazySingleton<UpdateRoomUseCase>(
    () => UpdateRoomUseCase(getIt<RoomRepository>()),
  );

  // Floor Use Cases
  getIt.registerLazySingleton<GetAllFloorsUseCase>(
    () => GetAllFloorsUseCase(getIt<FloorRepository>()),
  );

  getIt.registerLazySingleton<GetFloorByIdUseCase>(
    () => GetFloorByIdUseCase(getIt<FloorRepository>()),
  );

  getIt.registerLazySingleton<CreateFloorUseCase>(
    () => CreateFloorUseCase(getIt<FloorRepository>()),
  );

  getIt.registerLazySingleton<UpdateFloorUseCase>(
    () => UpdateFloorUseCase(getIt<FloorRepository>()),
  );

  getIt.registerLazySingleton<DeleteFloorUseCase>(
    () => DeleteFloorUseCase(getIt<FloorRepository>()),
  );

  getIt.registerLazySingleton<AddRoomToFloorUseCase>(
    () => AddRoomToFloorUseCase(getIt<FloorRepository>()),
  );

  // Dashboard Use Cases
  getIt.registerLazySingleton<LoadDashboardCardsUseCase>(
    () => LoadDashboardCardsUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<SaveDashboardCardsUseCase>(
    () => SaveDashboardCardsUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<GetDefaultCardsUseCase>(
    () => GetDefaultCardsUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<LoadDashboardLayoutUseCase>(
    () => LoadDashboardLayoutUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<SaveDashboardLayoutUseCase>(
    () => SaveDashboardLayoutUseCase(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<ClearAllDashboardCardsUseCase>(
    () => ClearAllDashboardCardsUseCase(getIt<DashboardRepository>()),
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

  getIt.registerFactory<UsbSerialViewModel>(
    () => UsbSerialViewModel(
      getIt<UsbSerialRepository>(),
      getIt<ConnectUsbSerialUseCase>(),
      getIt<SendUsbSerialCommandUseCase>(),
    ),
  );

  // Smart Home ViewModels
  getIt.registerFactory<DeviceViewModel>(
    () => DeviceViewModel(
      getIt<GetAllDevicesUseCase>(),
      getIt<GetDevicesByRoomUseCase>(),
      getIt<UpdateDeviceUseCase>(),
      getIt<ToggleDeviceUseCase>(),
      getIt<GetDeviceByIdUseCase>(),
    ),
  );

  getIt.registerFactory<ScenarioViewModel>(
    () => ScenarioViewModel(
      getIt<GetAllScenariosUseCase>(),
      getIt<CreateScenarioUseCase>(),
      getIt<UpdateScenarioUseCase>(),
      getIt<DeleteScenarioUseCase>(),
      getIt<ExecuteScenarioUseCase>(),
    ),
  );

  getIt.registerFactory<RoomViewModel>(
    () =>
        RoomViewModel(getIt<GetAllRoomsUseCase>(), getIt<GetRoomByIdUseCase>()),
  );

  getIt.registerFactory<RoomSetupViewModel>(
    () => RoomSetupViewModel(
      getIt<CreateRoomUseCase>(),
      getIt<GetAllRoomsUseCase>(),
      getIt<CreateDeviceUseCase>(),
      getIt<AddDeviceToRoomUseCase>(),
      getIt<AddRoomToFloorUseCase>(),
    ),
  );

  getIt.registerFactory<ScenarioSetupViewModel>(() => ScenarioSetupViewModel());

  getIt.registerFactory<FloorViewModel>(
    () => FloorViewModel(
      getIt<GetAllFloorsUseCase>(),
      getIt<GetFloorByIdUseCase>(),
      getIt<CreateFloorUseCase>(),
      getIt<UpdateFloorUseCase>(),
      getIt<DeleteFloorUseCase>(),
    ),
  );

  // Dashboard ViewModel
  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getIt<LoadDashboardCardsUseCase>(),
      getIt<SaveDashboardCardsUseCase>(),
      getIt<LoadDashboardLayoutUseCase>(),
      getIt<SaveDashboardLayoutUseCase>(),
      getIt<GetDevicesByRoomUseCase>(),
      getIt<CreateDeviceUseCase>(),
      getIt<AddDeviceToRoomUseCase>(),
      getIt<RoomRepository>(),
      getIt<GetAllScenariosUseCase>(),
      getIt<ClearAllDashboardCardsUseCase>(),
      getIt<UsbSerialViewModel>(), // USB Serial for sending commands
    ),
  );
}
