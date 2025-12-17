import 'package:flutter/material.dart';
import '../../data/data_sources/local/pin/pin_service.dart';
import '../../core/di/injection_container.dart' as di;
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../../presentation/widgets/pin/pin_entry_dialog.dart';

/// PIN Protection Utility
/// Helper functions for protecting definition screens with PIN verification
class PinProtection {
  static final PinService _pinService = di.getIt<PinService>();

  /// Check if PIN verification is required and show dialog if needed
  /// Returns true if verified or not required, false if cancelled
  /// 
  /// [pinType] specifies which type of PIN to verify:
  /// - PinType.admin: For sensitive operations (default)
  /// - PinType.user: For user settings (accepts both admin and user PINs)
  static Future<bool> requirePinVerification(
    BuildContext context, {
    String? title,
    String? subtitle,
    PinType pinType = PinType.admin,
  }) async {
    print('🔵 [PIN_PROTECTION] requirePinVerification called');
    
    if (!context.mounted) {
      print('🔴 [PIN_PROTECTION] Context not mounted, returning false');
      return false;
    }

    print('🟢 [PIN_PROTECTION] Initializing PIN service (type: $pinType)');
    // Initialize PIN service if needed
    if (pinType == PinType.admin) {
      await _pinService.initializeAdminPinsIfNeeded();
    } else {
      await _pinService.initializeAdminPinsIfNeeded();
      await _pinService.initializeUserPinIfNeeded();
    }

    if (!context.mounted) {
      print('🔴 [PIN_PROTECTION] Context not mounted after init, returning false');
      return false;
    }

    // Check if PINs are configured based on type
    bool hasPinsConfigured;
    if (pinType == PinType.admin) {
      final adminPins = _pinService.getAllowedAdminPins();
      hasPinsConfigured = adminPins.isNotEmpty;
      print('🟢 [PIN_PROTECTION] Admin PINs count: ${adminPins.length}');
    } else {
      // For user PIN, we accept both admin and user PINs
      final adminPins = _pinService.getAllowedAdminPins();
      final userPin = _pinService.getUserPin();
      hasPinsConfigured = adminPins.isNotEmpty || (userPin.isNotEmpty && userPin != '');
      print('🟢 [PIN_PROTECTION] Admin PINs: ${adminPins.length}, User PIN configured: ${userPin.isNotEmpty}');
    }
    
    if (!hasPinsConfigured) {
      print('🟡 [PIN_PROTECTION] No PINs configured, showing warning dialog');
      if (!context.mounted) {
        print('🔴 [PIN_PROTECTION] Context not mounted before warning dialog, returning false');
        return false;
      }
      // No PINs configured, show warning but allow access
      final l10n = AppLocalizations.of(context)!;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      
      final shouldConfigure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.getSectionGradient(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(isDark ? 0.7 : 0.55),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.configurePinsFirst,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor1(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: AppTheme.getSecondaryGray(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryBlue(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.settings,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      print('🟡 [PIN_PROTECTION] Warning dialog result: $shouldConfigure');
      
      if (shouldConfigure == true) {
        // Navigate to PIN management (will be handled by caller)
        print('🟡 [PIN_PROTECTION] User wants to configure PINs, returning false');
        return false;
      }
      
      // Allow access without PIN if user cancels
      print('🟢 [PIN_PROTECTION] User cancelled warning, allowing access');
      return true;
    }

    if (!context.mounted) {
      print('🔴 [PIN_PROTECTION] Context not mounted before PIN dialog, returning false');
      return false;
    }

    print('🟢 [PIN_PROTECTION] Showing PIN entry dialog (type: $pinType)');
    // Show PIN entry dialog
    final verified = await PinEntryDialog.show(
      context,
      title: title ?? AppLocalizations.of(context)!.enterPin,
      subtitle: subtitle ?? AppLocalizations.of(context)!.pinRequiredForAction,
      pinType: pinType,
    );

    print('🟢 [PIN_PROTECTION] PIN dialog returned: $verified');
    print('🟢 [PIN_PROTECTION] Context mounted after dialog: ${context.mounted}');
    
    return verified;
  }
}

