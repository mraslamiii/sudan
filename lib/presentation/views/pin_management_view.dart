import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/data_sources/local/pin/pin_service.dart';
import '../../core/di/injection_container.dart' as di;
import '../widgets/pin/pin_entry_dialog.dart';

/// PIN Management View
/// Screen for managing allowed PIN codes
class PinManagementView extends StatefulWidget {
  const PinManagementView({super.key});

  @override
  State<PinManagementView> createState() => _PinManagementViewState();
}

class _PinManagementViewState extends State<PinManagementView> {
  final PinService _pinService = di.getIt<PinService>();
  List<String> _allowedPins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    setState(() {
      _isLoading = true;
    });
    await _pinService.initializeAdminPinsIfNeeded();
    setState(() {
      _allowedPins = _pinService.getAllowedAdminPins();
      _isLoading = false;
    });
  }

  Future<void> _addPin() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show PIN entry dialog for new PIN
    final enteredPin = await _showPinEntryDialog(
      title: l10n.enterNewPin,
      subtitle: l10n.pinMustBe4Digits,
    );

    if (enteredPin == null) return;

    // Validate PIN strength
    if (!_pinService.isValidAdminPin(enteredPin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinTooWeak),
          backgroundColor: ThemeColors.errorRed,
        ),
      );
      return;
    }

    // Add PIN
    final success = await _pinService.addAdminPin(enteredPin);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinAdded),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
        ),
      );
      _loadPins();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToAddPin),
          backgroundColor: ThemeColors.errorRed,
        ),
      );
    }
  }

  Future<void> _removePin(String pin) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Confirm removal
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                Text(
                  l10n.removePinConfirm,
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
                        backgroundColor: ThemeColors.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.removePin,
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
        );
      },
    );

    if (confirmed != true) return;

    // Remove PIN
    final success = await _pinService.removeAdminPin(pin);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinRemoved),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
        ),
      );
      _loadPins();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToRemovePin),
          backgroundColor: ThemeColors.errorRed,
        ),
      );
    }
  }

  Future<String?> _showPinEntryDialog({
    required String title,
    String? subtitle,
  }) async {
    final completer = Completer<String?>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
        builder: (dialogContext) => PinEntryDialog(
        title: title,
        subtitle: subtitle,
        onVerified: (pin) {
          Navigator.of(dialogContext).pop();
          completer.complete(pin);
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
          completer.complete(null);
        },
      ),
    );

    return await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.getTextColor1(isDark),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.pinManagement,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.getPrimaryBlue(isDark),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.getSectionGradient(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.getSectionBorderColor(isDark)
                              .withOpacity(isDark ? 0.7 : 0.55),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.getPrimaryButtonGradient(isDark),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.manageAllowedPins,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.getTextColor1(isDark),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.pinMustBe4Digits,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.getSecondaryGray(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add PIN Button
                    GestureDetector(
                      onTap: _addPin,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getPrimaryBlue(isDark)
                                  .withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addPin,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PINs List
                    Text(
                      l10n.allowedPins,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _allowedPins.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 64,
                                    color: AppTheme.getSecondaryGray(isDark),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noPinsConfigured,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.getSecondaryGray(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _allowedPins.length,
                              itemBuilder: (context, index) {
                                final pin = _allowedPins[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.getSectionGradient(isDark),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.getSectionBorderColor(isDark)
                                          .withOpacity(isDark ? 0.7 : 0.55),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.lock_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '••••',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.getTextColor1(isDark),
                                                letterSpacing: 4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              pin,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.getSecondaryGray(isDark),
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: ThemeColors.errorRed,
                                        ),
                                        onPressed: () => _removePin(pin),
                                        tooltip: l10n.removePin,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

