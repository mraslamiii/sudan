import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Loading Overlay Widget
/// Displays a loading indicator overlay
/// 
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     if (isLoading) LoadingOverlay(),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppTheme.getSectionGradient(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(isDark)
                  .withOpacity(isDark ? 0.7 : 0.55),
              width: 1.2,
            ),
            boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTextColor1(isDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

