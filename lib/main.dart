import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sudan/presentation/views/floor_selection_view.dart';
import 'package:sudan/presentation/widgets/micro_connection_status_bar.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'data/data_sources/local/preferences/preferences_service.dart';
import 'presentation/viewmodels/device_viewmodel.dart';
import 'presentation/viewmodels/scenario_viewmodel.dart';
import 'presentation/viewmodels/room_viewmodel.dart';
import 'presentation/viewmodels/floor_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/usb_serial_viewmodel.dart';
import 'core/utils/usb_serial_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable full screen immersive mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Set preferred orientations (landscape for tablet)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize dependency injection
  await di.initDependencies();

  // Clear all dashboard cards cache on app start
  try {
    final dashboardVM = di.getIt<DashboardViewModel>();
    await dashboardVM.clearAllDashboardCards();
    print('🧹 [MAIN] Cleared all dashboard cards cache');
  } catch (e) {
    print('⚠️ [MAIN] Could not clear dashboard cache: $e');
  }

  // Initialize USB Serial connection
  try {
    await UsbSerialInitializer.initialize();
  } catch (e) {
    print('⚠️ [MAIN] USB Serial initialization failed: $e');
    // Continue app startup even if USB Serial fails
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en', 'US');
  PreferencesService? _preferencesService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _preferencesService = di.getIt<PreferencesService>();

      // Load theme mode
      final savedTheme = _preferencesService?.getThemeMode();
      if (savedTheme != null) {
        setState(() {
          _themeMode = _parseThemeMode(savedTheme);
        });
      }

      // Load language
      final savedLanguage = _preferencesService?.getLanguage();
      if (savedLanguage != null) {
        setState(() {
          _locale = _parseLocale(savedLanguage);
        });
      }
    } catch (e) {
      // If service not available, use system default
    }
  }

  Locale _parseLocale(String language) {
    switch (language) {
      case 'fa':
        return const Locale('fa', 'IR');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      if (_preferencesService == null) {
        _preferencesService = di.getIt<PreferencesService>();
      }
      final modeString = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system';
      await _preferencesService?.setThemeMode(modeString);
    } catch (e) {
      // Handle error silently
    }
  }

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = _parseLocale(languageCode);
    });
    _saveLanguage(languageCode);
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      if (_preferencesService == null) {
        _preferencesService = di.getIt<PreferencesService>();
      }
      await _preferencesService?.setLanguage(languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Re-enable full screen when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.getIt<UsbSerialViewModel>()),
        ChangeNotifierProvider(
          create: (_) => di.getIt<DeviceViewModel>()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.getIt<ScenarioViewModel>()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.getIt<RoomViewModel>()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.getIt<FloorViewModel>()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.getIt<DashboardViewModel>()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Home',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: _themeMode,

        locale: _locale,
        supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: FloorSelectionView(
          onThemeChanged: changeThemeMode,
          onLanguageChanged: changeLanguage,
        ),

        builder: (context, child) {
          return Column(
            children: [
              const MicroConnectionStatusBar(atTop: true),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}
