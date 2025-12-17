import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/scenario_entity.dart';

/// Scenario Card Widget - Fully Responsive
class ScenarioCard extends StatefulWidget {
  final ScenarioEntity scenario;
  final double availableHeight;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isExecuting;

  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.availableHeight,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isExecuting = false,
  });

  @override
  State<ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<ScenarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = widget.availableHeight < 100;
    
    // Calculate responsive sizes
    final cardWidth = isCompact ? 80.0 : 100.0;
    final iconSize = isCompact ? 18.0 : 22.0;
    final iconPadding = isCompact ? 6.0 : 8.0;
    final fontSize = isCompact ? 10.0 : 12.0;
    final spacing = isCompact ? 4.0 : 8.0;
    final padding = isCompact ? 8.0 : 12.0;

    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
        setState(() => _showActions = true);
      },
      onExit: (_) {
        _controller.reverse();
        setState(() => _showActions = false);
      },
      child: GestureDetector(
        onTap: widget.isExecuting ? null : widget.onTap,
        onLongPress: () => setState(() => _showActions = !_showActions),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final hoverValue = _controller.value;
            
            return Transform.scale(
              scale: 1.0 + (hoverValue * 0.02),
              child: Stack(
                children: [
                  Container(
                    width: cardWidth,
                    height: widget.availableHeight,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF))
                              .withOpacity(1 - hoverValue * 0.1),
                          (isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8F8FA))
                              .withOpacity(1 - hoverValue * 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.scenario.color.withOpacity(0.2 + hoverValue * 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.scenario.color.withOpacity(0.1 + hoverValue * 0.15),
                          blurRadius: 8 + hoverValue * 8,
                          offset: Offset(0, 2 + hoverValue * 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            color: widget.scenario.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: widget.isExecuting
                              ? SizedBox(
                                  width: iconSize,
                                  height: iconSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(widget.scenario.color),
                                  ),
                                )
                              : Icon(
                                  widget.scenario.icon,
                                  size: iconSize,
                                  color: widget.scenario.color,
                                ),
                        ),
                        SizedBox(height: spacing),
                        // Name
                        Flexible(
                          child: Text(
                            widget.scenario.name,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor1(isDark),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  if (_showActions && !widget.isExecuting)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(Icons.edit, Colors.blue, widget.onEdit, isCompact),
                          SizedBox(width: isCompact ? 2 : 4),
                          _buildActionButton(Icons.delete, Colors.red, widget.onDelete, isCompact),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback? onTap, bool isCompact) {
    final size = isCompact ? 18.0 : 22.0;
    final iconSize = isCompact ? 10.0 : 12.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: iconSize, color: Colors.white),
      ),
    );
  }
}
