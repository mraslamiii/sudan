import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

/// Step Navigation Bar
/// Provides Back and Next/Save buttons for the setup flow
/// 
/// Usage:
/// ```dart
/// StepNavigationBar(
///   canGoBack: true,
///   canGoNext: true,
///   isLastStep: false,
///   onBack: () => viewModel.previousStep(),
///   onNext: () => viewModel.nextStep(),
///   onSave: () => viewModel.saveRoom(),
/// )
/// ```
class StepNavigationBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoNext;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSave;

  const StepNavigationBar({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.isLastStep,
    this.isLoading = false,
    this.onBack,
    this.onNext,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getSectionGradient(isDark),
        border: Border(
          top: BorderSide(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.7 : 0.55),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            TextButton(
              onPressed: canGoBack && !isLoading ? onBack : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: canGoBack && !isLoading
                        ? AppTheme.getTextColor1(isDark)
                        : AppTheme.getSecondaryGray(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.back,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: canGoBack && !isLoading
                          ? AppTheme.getTextColor1(isDark)
                          : AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Next/Save Button
            ElevatedButton(
              onPressed: (canGoNext || isLastStep) && !isLoading
                  ? (isLastStep ? onSave : onNext)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ).copyWith(
                elevation: MaterialStateProperty.all(0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: (canGoNext || isLastStep) && !isLoading
                      ? AppTheme.getPrimaryButtonGradient(isDark)
                      : null,
                  color: (canGoNext || isLastStep) && !isLoading
                      ? null
                      : AppTheme.getSoftButtonBackground(isDark),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: (canGoNext || isLastStep) && !isLoading
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLastStep ? Colors.white : accentColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastStep ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.next,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: (canGoNext || isLastStep) && !isLoading
                                  ? Colors.white
                                  : AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                          if (!isLastStep) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: (canGoNext || isLastStep) && !isLoading
                                  ? Colors.white
                                  : AppTheme.getSecondaryGray(isDark),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

