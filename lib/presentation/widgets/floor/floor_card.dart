import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/floor_entity.dart';

/// Floor Card Widget
/// Displays a single floor with a luxurious, minimal design
/// Inspired by PS5 and iOS 26 design language
class FloorCard extends StatefulWidget {
  final FloorEntity floor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const FloorCard({
    super.key,
    required this.floor,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  State<FloorCard> createState() => _FloorCardState();
}

class _FloorCardState extends State<FloorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        accentColor.withOpacity(isDark ? 0.28 : 0.22),
                        accentColor.withOpacity(isDark ? 0.18 : 0.14),
                      ]
                    : [
                        isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.white.withOpacity(0.9),
                        isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: widget.isSelected
                    ? accentColor.withOpacity(0.7)
                    : AppTheme.getSectionBorderColor(isDark)
                        .withOpacity(isDark ? 0.35 : 0.25),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                // Main shadow
                BoxShadow(
                  color: widget.isSelected
                      ? accentColor.withOpacity(isDark ? 0.4 : 0.3)
                      : Colors.black.withOpacity(isDark ? 0.25 : 0.1),
                  blurRadius: widget.isSelected ? 40 : 28,
                  spreadRadius: widget.isSelected ? 3 : 0,
                  offset: Offset(0, widget.isSelected ? 20 : 14),
                ),
                // Inner glow
                if (widget.isSelected)
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                children: [
                  // Background glassmorphism overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(isDark ? 0.08 : 0.3),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Glow effect for selected
                  if (widget.isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.8,
                            colors: [
                              accentColor.withOpacity(0.15),
                              accentColor.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with enhanced design
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(isDark ? 0.35 : 0.28),
                                accentColor.withOpacity(isDark ? 0.2 : 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: accentColor.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(isDark ? 0.3 : 0.2),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                                blurRadius: 8,
                                spreadRadius: -2,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.floor.icon,
                            color: accentColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Floor name
                        Text(
                          widget.floor.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor1(isDark),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Room count
                        Row(
                          children: [
                            Icon(
                              Icons.door_front_door_rounded,
                              size: 14,
                              color: widget.isSelected
                                  ? accentColor.withOpacity(0.8)
                                  : AppTheme.getSecondaryGray(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.floor.roomCount} ${widget.floor.roomCount == 1 ? AppLocalizations.of(context)!.room : AppLocalizations.of(context)!.rooms}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: widget.isSelected
                                    ? accentColor.withOpacity(0.9)
                                    : AppTheme.getSecondaryGray(isDark),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  if (widget.isSelected)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

