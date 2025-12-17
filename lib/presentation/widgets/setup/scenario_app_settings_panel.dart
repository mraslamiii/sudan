import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/scenario_entity.dart';

/// Scenario App Settings Panel
/// Panel for configuring app-level settings in a scenario
/// 
/// Usage:
/// ```dart
/// ScenarioAppSettingsPanel(
///   settings: currentSettings,
///   onSettingsChanged: (settings) => viewModel.setAppSettings(settings),
/// )
/// ```
class ScenarioAppSettingsPanel extends StatelessWidget {
  final ScenarioAppSettings? settings;
  final ValueChanged<ScenarioAppSettings?> onSettingsChanged;

  const ScenarioAppSettingsPanel({
    super.key,
    this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme Mode Section
        _buildSectionHeader(
          context,
          isDark,
          Icons.palette_rounded,
          AppLocalizations.of(context)!.themeMode,
        ),
        const SizedBox(height: 12),
        _buildThemeModeSelector(context, isDark, accentColor),
        
        const SizedBox(height: 24),
        
        // Language Section (Optional)
        _buildSectionHeader(
          context,
          isDark,
          Icons.language_rounded,
          AppLocalizations.of(context)!.language,
        ),
        const SizedBox(height: 12),
        _buildLanguageSelector(context, isDark, accentColor),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.getTextColor1(isDark),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    bool isDark,
    Color accentColor,
  ) {
    final currentThemeMode = settings?.themeMode;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSectionBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildThemeModeOption(
            context,
            isDark,
            accentColor,
            null,
            AppLocalizations.of(context)!.dontChange,
            currentThemeMode == null,
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: null,
                  language: settings?.language,
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          ),
          _buildThemeModeOption(
            context,
            isDark,
            accentColor,
            ThemeMode.light,
            AppLocalizations.of(context)!.light,
            currentThemeMode == ThemeMode.light,
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: ThemeMode.light,
                  language: settings?.language,
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          ),
          _buildThemeModeOption(
            context,
            isDark,
            accentColor,
            ThemeMode.dark,
            AppLocalizations.of(context)!.dark,
            currentThemeMode == ThemeMode.dark,
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: ThemeMode.dark,
                  language: settings?.language,
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          ),
          _buildThemeModeOption(
            context,
            isDark,
            accentColor,
            ThemeMode.system,
            AppLocalizations.of(context)!.system,
            currentThemeMode == ThemeMode.system,
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: ThemeMode.system,
                  language: settings?.language,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    bool isDark,
    Color accentColor,
    ThemeMode? mode,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? accentColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : AppTheme.getTextColor1(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    bool isDark,
    Color accentColor,
  ) {
    final currentLanguage = settings?.language;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSectionBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildLanguageOption(
            context,
            isDark,
            accentColor,
            null,
            AppLocalizations.of(context)!.dontChange,
            currentLanguage == null,
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: settings?.themeMode,
                  language: null,
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          ),
          _buildLanguageOption(
            context,
            isDark,
            accentColor,
            'en',
            'English',
            currentLanguage == 'en',
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: settings?.themeMode,
                  language: 'en',
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.2),
          ),
          _buildLanguageOption(
            context,
            isDark,
            accentColor,
            'fa',
            'فارسی',
            currentLanguage == 'fa',
            () {
              onSettingsChanged(
                ScenarioAppSettings(
                  themeMode: settings?.themeMode,
                  language: 'fa',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    bool isDark,
    Color accentColor,
    String? language,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? accentColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : AppTheme.getTextColor1(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

