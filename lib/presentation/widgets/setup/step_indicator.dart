import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Step Indicator Widget
/// Displays progress through the setup flow with 4 steps
/// 
/// Usage:
/// ```dart
/// StepIndicator(
///   currentStep: 2,
///   totalSteps: 4,
/// )
/// ```
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final isLast = index == totalSteps - 1;

        return Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              // Step Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isActive || isCompleted
                      ? AppTheme.getPrimaryButtonGradient(isDark)
                      : null,
                  color: isActive || isCompleted
                      ? null
                      : isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? Colors.transparent
                        : AppTheme.getSectionBorderColor(isDark)
                            .withOpacity(0.3),
                    width: isActive || isCompleted ? 0 : 1.5,
                  ),
                  boxShadow: isActive || isCompleted
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
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isActive || isCompleted
                                ? Colors.white
                                : AppTheme.getTextColor1(isDark),
                          ),
                        ),
                ),
              ),

              // Connector Line
              if (!isLast)
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? LinearGradient(
                              colors: [
                                accentColor,
                                accentColor.withOpacity(0.3),
                              ],
                            )
                          : null,
                      color: isCompleted
                          ? null
                          : AppTheme.getSectionBorderColor(isDark)
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

