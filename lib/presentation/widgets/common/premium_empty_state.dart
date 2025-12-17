import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Premium empty state widget used across dashboard modules.
/// Provides a consistent minimal design with icon, highlights, and CTAs.
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? caption;
  final List<String> highlights;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? accentColor;
  final bool isCompact;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.caption,
    this.highlights = const [],
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppTheme.getAccentTeal(isDark);
    final iconSize = isCompact ? 36.0 : 54.0;
    final iconPadding = isCompact ? 8.0 : 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isVeryCompact = availableHeight < 200;
        final adjustedIconSize = isVeryCompact ? 32.0 : iconSize;
        final adjustedPadding = isVeryCompact ? 6.0 : iconPadding;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isCompact ? 160 : 220,
                maxWidth: isCompact ? 260 : 340,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8.0 : 12.0,
                  vertical: isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: adjustedIconSize + adjustedPadding,
                      height: adjustedIconSize + adjustedPadding,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withOpacity(isDark ? 0.45 : 0.35),
                            accent.withOpacity(isDark ? 0.18 : 0.14),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.45), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(isDark ? 0.32 : 0.25),
                            blurRadius: isVeryCompact ? 20 : 28,
                            spreadRadius: isVeryCompact ? 1.5 : 2,
                            offset: Offset(0, isVeryCompact ? 10 : 14),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: adjustedIconSize),
                    ),
                    SizedBox(height: isVeryCompact ? 10 : (isCompact ? 12 : 16)),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isVeryCompact ? 14 : (isCompact ? 16 : 20),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isVeryCompact ? 4 : (isCompact ? 5 : 7)),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: isVeryCompact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isVeryCompact ? 11 : (isCompact ? 12 : 13.5),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getSecondaryGray(isDark),
                        height: 1.4,
                      ),
                    ),
                    if (caption != null && !isVeryCompact) ...[
                      SizedBox(height: isCompact ? 5 : 6),
                      Text(
                        caption!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 12,
                          color: AppTheme.getSecondaryGray(isDark).withOpacity(0.8),
                        ),
                      ),
                    ],
                    if (highlights.isNotEmpty && !isVeryCompact) ...[
                      SizedBox(height: isCompact ? 10 : 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isCompact ? 6 : 8,
                        runSpacing: isCompact ? 6 : 8,
                        children: highlights
                            .take(isVeryCompact ? 2 : highlights.length)
                            .map((label) => _HighlightChip(
                                  label: label,
                                  accent: accent,
                                  isDark: isDark,
                                  compact: isCompact || isVeryCompact,
                                ))
                            .toList(),
                      ),
                    ],
                    SizedBox(height: isVeryCompact ? 10 : (isCompact ? 12 : 18)),
                    _PrimaryButton(
                      label: primaryActionLabel,
                      accent: accent,
                      compact: isCompact || isVeryCompact,
                      onPressed: onPrimaryAction,
                    ),
                    if (secondaryActionLabel != null && 
                        onSecondaryAction != null && 
                        !isVeryCompact) ...[
                      SizedBox(height: isCompact ? 6 : 10),
                      TextButton(
                        onPressed: onSecondaryAction,
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          textStyle: TextStyle(
                            fontSize: isCompact ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 12,
                            vertical: isCompact ? 4 : 6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(secondaryActionLabel!),
                            const SizedBox(width: 4),
                            Icon(Icons.north_east_rounded, size: isCompact ? 14 : 16),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool isDark;
  final bool compact;

  const _HighlightChip({
    required this.label,
    required this.accent,
    required this.isDark,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4.5 : 5.5,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.45), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(isDark ? 0.6 : 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w600,
              color: accent.withOpacity(isDark ? 0.9 : 0.8),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final Color accent;
  final bool compact;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.accent,
    required this.compact,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _setHovered(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 18 : 24,
              vertical: widget.compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accent,
                  widget.accent.withOpacity(0.82),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withOpacity(_isHovered ? 0.42 : 0.32),
                  blurRadius: _isHovered ? 32 : 24,
                  spreadRadius: _isHovered ? 3 : 1.5,
                  offset: Offset(0, _isHovered ? 14 : 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.compact ? 13 : 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: widget.compact ? 8 : 10),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white,
                  size: widget.compact ? 16 : 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


