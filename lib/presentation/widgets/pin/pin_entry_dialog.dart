import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/data_sources/local/pin/pin_service.dart';
import '../../../core/di/injection_container.dart' as di;

/// PIN Entry Dialog
/// Dialog for entering PIN code to access definition screens
class PinEntryDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Function(String pin)? onVerified;
  final Function()? onCancel;
  final PinType pinType;

  const PinEntryDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.onVerified,
    this.onCancel,
    this.pinType = PinType.admin,
  });

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    PinType pinType = PinType.admin,
  }) async {
    print('🔵 [PIN_DIALOG] show() called');
    
    if (!context.mounted) {
      print('🔴 [PIN_DIALOG] Context not mounted, returning false');
      return false;
    }

    print('🟢 [PIN_DIALOG] Context is mounted, showing dialog');

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (dialogContext) {
          print('🟢 [PIN_DIALOG] Builder called, creating PinEntryDialog');
          return PinEntryDialog(
            title: title ?? AppLocalizations.of(context)!.enterPin,
            subtitle: subtitle,
            pinType: pinType,
            onVerified: (pin) {
              print('🟢 [PIN_DIALOG] onVerified callback called with pin: $pin');
              if (dialogContext.mounted) {
                try {
                  final navigator = Navigator.of(dialogContext, rootNavigator: false);
                  if (navigator.canPop()) {
                    print('🟢 [PIN_DIALOG] Popping dialog with true');
                    navigator.pop(true);
                    print('🟢 [PIN_DIALOG] Dialog popped successfully');
                  } else {
                    print('🔴 [PIN_DIALOG] Cannot pop - canPop: false');
                  }
                } catch (e, stackTrace) {
                  print('🔴 [PIN_DIALOG] Error in onVerified: $e');
                  print('🔴 [PIN_DIALOG] Stack: $stackTrace');
                }
              } else {
                print('🔴 [PIN_DIALOG] Context not mounted in onVerified');
              }
            },
            onCancel: () {
              print('🟡 [PIN_DIALOG] onCancel callback called');
              if (dialogContext.mounted) {
                try {
                  final navigator = Navigator.of(dialogContext, rootNavigator: false);
                  if (navigator.canPop()) {
                    print('🟢 [PIN_DIALOG] Popping dialog with false');
                    navigator.pop(false);
                    print('🟢 [PIN_DIALOG] Dialog popped successfully');
                  } else {
                    print('🔴 [PIN_DIALOG] Cannot pop - canPop: false');
                  }
                } catch (e, stackTrace) {
                  print('🔴 [PIN_DIALOG] Error in onCancel: $e');
                  print('🔴 [PIN_DIALOG] Stack: $stackTrace');
                }
              } else {
                print('🔴 [PIN_DIALOG] Context not mounted in onCancel');
              }
            },
          );
        },
      );
      
      print('🟢 [PIN_DIALOG] Dialog closed, result: $result');
      // Return result, default to false if null
      final finalResult = result ?? false;
      print('🟢 [PIN_DIALOG] Returning: $finalResult');
      return finalResult;
    } catch (e, stackTrace) {
      // Handle any navigation errors - return false on error
      print('🔴 [PIN_DIALOG] Error occurred: $e');
      print('🔴 [PIN_DIALOG] Stack trace: $stackTrace');
      return false;
    }
  }

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredDigits = [];
  final PinService _pinService = di.getIt<PinService>();
  bool _isError = false;
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
      _isError = false;
    });

    HapticFeedback.lightImpact();

    if (_enteredDigits.length == 4) {
      _verifyPin();
    }
  }

  void _handleBackspace() {
    if (_enteredDigits.isNotEmpty) {
      setState(() {
        _enteredDigits.removeLast();
        _isError = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _verifyPin() {
    if (!mounted) return;
    
    final enteredPin = _enteredDigits.join('');
    
    // Verify PIN based on type
    // For user PIN type, accept both admin and user PINs
    bool isValid;
    if (widget.pinType == PinType.user) {
      // Accept both admin and user PINs for user operations
      isValid = _pinService.verifyAdminPin(enteredPin) || 
                _pinService.verifyUserPin(enteredPin);
    } else {
      // Admin PIN type - only accept admin PINs
      isValid = _pinService.verifyAdminPin(enteredPin);
    }

    if (isValid) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        widget.onVerified?.call(enteredPin);
      }
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _isError = true;
          _enteredDigits.clear();
        });
        _shakeController.forward(from: 0).then((_) {
          if (mounted) {
            _shakeController.reset();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        print('🟡 [PIN_DIALOG] PopScope onPopInvoked: didPop=$didPop');
        if (!didPop && mounted) {
          widget.onCancel?.call();
        }
      },
      child: Dialog(
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
            boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.getPrimaryButtonGradient(isDark),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.getSectionShadows(
                          isDark,
                          elevated: true,
                        ),
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
                            widget.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor1(isDark),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppTheme.getTextColor1(isDark),
                      ),
                      onPressed: () {
                        print('🟡 [PIN_DIALOG] Close button pressed');
                        print('🟡 [PIN_DIALOG] mounted: $mounted');
                        if (mounted) {
                          try {
                            final navigator = Navigator.of(context, rootNavigator: false);
                            if (navigator.canPop()) {
                              print('🟢 [PIN_DIALOG] Calling onCancel callback (will pop dialog)');
                              widget.onCancel?.call();
                              // Don't pop here - onCancel callback will handle it
                            } else {
                              print('🔴 [PIN_DIALOG] Cannot pop');
                            }
                          } catch (e, stackTrace) {
                            print('🔴 [PIN_DIALOG] Error: $e');
                            print('🔴 [PIN_DIALOG] Stack: $stackTrace');
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // PIN Dots
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: _buildPinDots(isDark),
                    );
                  },
                ),
                const SizedBox(height: 6),
                if (_isError)
                  Text(
                    AppLocalizations.of(context)!.incorrectPin,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),

                // Number Pad - Scrollable
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNumberPad(isDark, accentColor),
                        const SizedBox(height: 12),
                        // Cancel Button
                        TextButton(
                          onPressed: () {
                            print('🟡 [PIN_DIALOG] Cancel button pressed');
                            print('🟡 [PIN_DIALOG] mounted: $mounted');
                            if (mounted) {
                              try {
                                final navigator = Navigator.of(context, rootNavigator: false);
                                if (navigator.canPop()) {
                                  print('🟢 [PIN_DIALOG] Calling onCancel callback (will pop dialog)');
                                  widget.onCancel?.call();
                                  // Don't pop here - onCancel callback will handle it
                                } else {
                                  print('🔴 [PIN_DIALOG] Cannot pop');
                                }
                              } catch (e, stackTrace) {
                                print('🔴 [PIN_DIALOG] Error: $e');
                                print('🔴 [PIN_DIALOG] Stack: $stackTrace');
                              }
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),),
    );
  }

  Widget _buildPinDots(bool isDark) {
    return Row(
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
                ? (_isError
                    ? ThemeColors.errorRed
                    : AppTheme.getPrimaryBlue(isDark))
                : AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(isDark ? 0.3 : 0.2),
            border: Border.all(
              color: isFilled
                  ? Colors.transparent
                  : AppTheme.getSectionBorderColor(isDark)
                      .withOpacity(isDark ? 0.4 : 0.3),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad(bool isDark, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNumberRow(['1', '2', '3'], isDark, accentColor),
        const SizedBox(height: 10),
        _buildNumberRow(['4', '5', '6'], isDark, accentColor),
        const SizedBox(height: 10),
        _buildNumberRow(['7', '8', '9'], isDark, accentColor),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80), // Spacer
            _buildNumberButton('0', isDark, accentColor),
            const SizedBox(width: 10),
            _buildBackspaceButton(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(
    List<String> numbers,
    bool isDark,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: _buildNumberButton(number, isDark, accentColor),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String digit, bool isDark, Color accentColor) {
    return GestureDetector(
      onTap: () => _handleDigitTap(digit),
      child: Container(
        width: 70,
        height: 70,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.4 : 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
                        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return GestureDetector(
      onTap: _handleBackspace,
      child: Container(
        width: 70,
        height: 70,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.4 : 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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

