import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/data_sources/local/preferences/preferences_service.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../views/pin_management_view.dart';
import '../../views/user_pin_settings_view.dart';

/// Settings Panel
/// Luxurious settings panel with PS5/iOS 26 design
class SettingsPanel extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onClose;

  const SettingsPanel({
    super.key,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    Function(ThemeMode)? onThemeChanged,
    Function(String)? onLanguageChanged,
  }) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => SettingsPanel(
        onThemeChanged: onThemeChanged,
        onLanguageChanged: onLanguageChanged,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ThemeMode _currentTheme = ThemeMode.system;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadSettings();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = di.getIt<PreferencesService>();
      final theme = prefs.getThemeMode();
      final lang = prefs.getLanguage();

      setState(() {
        if (theme != null) {
          _currentTheme = theme == 'light'
              ? ThemeMode.light
              : theme == 'dark'
                  ? ThemeMode.dark
                  : ThemeMode.system;
        }
        _currentLanguage = lang ?? 'en';
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    setState(() => _currentTheme = mode);
    widget.onThemeChanged?.call(mode);
    
    try {
      final prefs = di.getIt<PreferencesService>();
      final modeString = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await prefs.setThemeMode(modeString);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _changeLanguage(String lang) async {
    setState(() => _currentLanguage = lang);
    widget.onLanguageChanged?.call(lang);
    
    try {
      final prefs = di.getIt<PreferencesService>();
      await prefs.setLanguage(lang);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: size.height * 0.85,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF141414),
                      const Color(0xFF0A0A0A),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F5F5),
                    ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(40),
            ),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(isDark)
                  .withOpacity(isDark ? 0.5 : 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(40),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getSecondaryGray(isDark)
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.getSectionShadows(
                            isDark,
                            elevated: true,
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextColor1(isDark),
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customize your experience',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.getTextColor1(isDark),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        _buildSection(
                          'Appearance',
                          [
                            _buildThemeSelector(isDark),
                            const SizedBox(height: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSection(
                          'Language',
                          [
                            _buildLanguageSelector(isDark),
                            const SizedBox(height: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSection(
                          'Security',
                          [
                            _buildPinManagementButton(isDark),
                            const SizedBox(height: 12),
                            _buildUserPinButton(isDark),
                            const SizedBox(height: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSection(
                          'About',
                          [
                            _buildAboutItem(
                              'Version',
                              '1.0.0',
                              Icons.info_outline_rounded,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildAboutItem(
                              'App Name',
                              'Sudan Smart Home',
                              Icons.home_rounded,
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.04),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.black.withOpacity(0.03),
                  Colors.black.withOpacity(0.01),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.getSectionBorderColor(isDark)
              .withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryGray(isDark),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            'Light',
            ThemeMode.light,
            Icons.light_mode_rounded,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            'Dark',
            ThemeMode.dark,
            Icons.dark_mode_rounded,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            'System',
            ThemeMode.system,
            Icons.brightness_auto_rounded,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    String label,
    ThemeMode mode,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _currentTheme == mode;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return GestureDetector(
      onTap: () => _changeTheme(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.getPrimaryButtonGradient(isDark)
              : null,
          color: isSelected
              ? null
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(0.3),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppTheme.getTextColor1(isDark),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppTheme.getTextColor1(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildLanguageOption('English', 'en', isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildLanguageOption('فارسی', 'fa', isDark),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String label, String code, bool isDark) {
    final isSelected = _currentLanguage == code;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.getPrimaryButtonGradient(isDark)
              : null,
          color: isSelected
              ? null
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(0.3),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : AppTheme.getTextColor1(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.getPrimaryBlue(isDark),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSecondaryGray(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinManagementButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PinManagementView(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ]
                : [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: AppTheme.getPrimaryBlue(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PIN Management',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage allowed PIN codes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.getSecondaryGray(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPinButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserPinSettingsView(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ]
                : [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.getPrimaryBlue(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User PIN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Change your personal PIN',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.getSecondaryGray(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

