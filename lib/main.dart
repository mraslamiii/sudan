import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudan/presentation/views/advanced_dashboard_view.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'data/data_sources/local/preferences/preferences_service.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  PreferencesService? _preferencesService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      _preferencesService = di.getIt<PreferencesService>();
      final savedTheme = _preferencesService?.getThemeMode();
      if (savedTheme != null) {
        setState(() {
          _themeMode = _parseThemeMode(savedTheme);
        });
      }
    } catch (e) {
      // If service not available, use system default
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
    return MaterialApp(
      title: 'خانه هوشمند',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: _themeMode,

      // LTR Support for tablet design
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: AdvancedDashboardView(
        onThemeChanged: changeThemeMode,
      ),
    );
  }
}
