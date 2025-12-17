import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/data_sources/local/pin/pin_service.dart';
import '../../core/di/injection_container.dart' as di;
import '../widgets/pin/pin_entry_dialog.dart';

/// User PIN Settings View
/// Allows users to change their User PIN
class UserPinSettingsView extends StatefulWidget {
  const UserPinSettingsView({super.key});

  @override
  State<UserPinSettingsView> createState() => _UserPinSettingsViewState();
}

class _UserPinSettingsViewState extends State<UserPinSettingsView> {
  final PinService _pinService = di.getIt<PinService>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _changeUserPin() async {
    if (!mounted) return;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // First, verify current PIN (user or admin)
    final verified = await PinEntryDialog.show(
      context,
      title: l10n.enterPin,
      subtitle: 'Enter your current PIN to change User PIN',
      pinType: PinType.user, // Accept both admin and user PINs
    );
    
    if (!verified || !mounted) {
      return;
    }
    
    // Now get new PIN
    final newPin = await _showPinEntryDialog(
      context,
      title: 'Enter New User PIN',
      subtitle: 'Enter a 4-digit PIN for user settings',
      allowSimplePin: true, // User PIN can be simple like 1234
    );
    
    if (newPin == null || !mounted) {
      return;
    }
    
    // Validate new PIN (must be 4 digits)
    if (newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(newPin)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN must be exactly 4 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Confirm new PIN
    final confirmPin = await _showPinEntryDialog(
      context,
      title: 'Confirm New User PIN',
      subtitle: 'Re-enter the new PIN to confirm',
      allowSimplePin: true,
    );
    
    if (confirmPin == null || !mounted) {
      return;
    }
    
    if (newPin != confirmPin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PINs do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Save new PIN
    final success = await _pinService.setUserPin(newPin);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User PIN changed successfully'),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change User PIN'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showPinEntryDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool allowSimplePin = false,
  }) async {
    final completer = Completer<String?>();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SimplePinEntryDialog(
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
    
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
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
          'User PIN Settings',
          style: TextStyle(
            color: AppTheme.getTextColor1(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
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
                              'User PIN',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextColor1(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PIN for personal settings',
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current PIN',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '••••',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextColor1(isDark),
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _changeUserPin,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Change PIN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryBlue(isDark),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.getPrimaryBlue(isDark),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'User PIN can be simple (like 1234) and is used for personal settings. Admin PIN is required for sensitive operations.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple PIN Entry Dialog (without PIN validation)
class _SimplePinEntryDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(String pin)? onVerified;
  final Function()? onCancel;

  const _SimplePinEntryDialog({
    required this.title,
    required this.subtitle,
    this.onVerified,
    this.onCancel,
  });

  @override
  State<_SimplePinEntryDialog> createState() => _SimplePinEntryDialogState();
}

class _SimplePinEntryDialogState extends State<_SimplePinEntryDialog>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredDigits = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleDigitTap(String digit) {
    if (_enteredDigits.length >= 4) return;

    setState(() {
      _enteredDigits.add(digit);
    });

    if (_enteredDigits.length == 4) {
      widget.onVerified?.call(_enteredDigits.join(''));
    }
  }

  void _handleBackspace() {
    if (_enteredDigits.isNotEmpty) {
      setState(() {
        _enteredDigits.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: AppTheme.getSectionGradient(isDark),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.7 : 0.55),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.getSecondaryGray(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // PIN Dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _enteredDigits.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? AppTheme.getPrimaryBlue(isDark)
                                : AppTheme.getSecondaryGray(isDark)
                                    .withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Number Pad
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (int i = 1; i <= 9; i++)
                    _buildNumberButton(i.toString(), isDark),
                  _buildEmptyButton(),
                  _buildNumberButton('0', isDark),
                  _buildBackspaceButton(isDark),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.getSecondaryGray(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String digit, bool isDark) {
    return GestureDetector(
      onTap: () => _handleDigitTap(digit),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: AppTheme.getPrimaryButtonGradient(isDark),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyButton() {
    return Container(
      width: 70,
      height: 70,
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return GestureDetector(
      onTap: _handleBackspace,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.getSecondaryGray(isDark).withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.backspace_rounded,
          color: AppTheme.getTextColor1(isDark),
          size: 24,
        ),
      ),
    );
  }
}
