import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'card_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_colors.dart';

/// Simple Elevator Control Panel - Just call elevator
class ElevatorControlPanel extends StatefulWidget {
  final int currentFloor;
  final int? targetFloor;
  final bool isMoving;
  final String? direction;
  final List<int> availableFloors;
  final Function(int)? onFloorSelected;
  final Function(bool)? onToggle;

  const ElevatorControlPanel({
    super.key,
    this.currentFloor = 1,
    this.targetFloor,
    this.isMoving = false,
    this.direction,
    this.availableFloors = const [1, 2, 3, 4, 5],
    this.onFloorSelected,
    this.onToggle,
  });

  @override
  State<ElevatorControlPanel> createState() => _ElevatorControlPanelState();
}

class _ElevatorControlPanelState extends State<ElevatorControlPanel> {
  int? _selectedFloor;
  bool _hasArrived = false;
  DateTime? _movementStartTime;
  bool _wasArrived = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current floor selected
    _selectedFloor = widget.currentFloor;
  }

  @override
  void didUpdateWidget(ElevatorControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When current floor changes, always update selected floor to match
    if (oldWidget.currentFloor != widget.currentFloor) {
      setState(() {
        _selectedFloor = widget.currentFloor;
        _hasArrived = false;
        _movementStartTime = null;
        _wasArrived = false;
      });
    }
    
    // Reset state when movement stops (elevator arrives)
    if (oldWidget.isMoving && !widget.isMoving) {
      setState(() {
        // Reset all state when elevator arrives
        _hasArrived = false;
        _movementStartTime = null;
        _wasArrived = false;
        // Always select the current floor when elevator arrives
        _selectedFloor = widget.currentFloor;
      });
    }
    
    // Track movement start time and show "arrived" message
    if (!oldWidget.isMoving && widget.isMoving && _selectedFloor != widget.currentFloor) {
      _movementStartTime = DateTime.now();
      _hasArrived = false;
      _wasArrived = false;
      // Set timer to show "arrived" after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && widget.isMoving && _selectedFloor == widget.targetFloor) {
          setState(() {
            _hasArrived = true;
          });
        }
      });
    }
    
    // Reset state after "arrived" message is shown and movement has stopped
    if (_hasArrived && !widget.isMoving && !_wasArrived) {
      _wasArrived = true;
      // Wait a bit for user to see "arrived" message, then reset state
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted && !widget.isMoving) {
          setState(() {
            _selectedFloor = widget.currentFloor;
            _hasArrived = false;
            _wasArrived = false;
          });
        }
      });
    }
    
    // Reset _wasArrived flag when movement starts again
    if (widget.isMoving && _wasArrived) {
      _wasArrived = false;
    }
  }

  void _callElevator(int floor) {
    if (floor != widget.currentFloor && !widget.isMoving) {
      HapticFeedback.mediumImpact();
      widget.onFloorSelected?.call(floor);
      setState(() {
        _selectedFloor = floor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CardStyles.elevatorAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 200;
        final isVeryCompact = constraints.maxHeight < 150;

        return Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current floor indicator
              if (!isVeryCompact) ...[
                Text(
                  'طبقه ${widget.currentFloor}',
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getSecondaryGray(isDark),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Call button
              Expanded(
                child: Center(
                  child: _buildCallButton(isDark, isCompact, accentColor),
                ),
              ),

              // Floor selection buttons
              if (!isVeryCompact) ...[
                const SizedBox(height: 12),
                _buildFloorButtons(isDark, isCompact, accentColor),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallButton(bool isDark, bool isCompact, Color accentColor) {
    final isCalling = widget.isMoving && _selectedFloor != widget.currentFloor;
    final showArrived = isCalling && _hasArrived;
    
    return GestureDetector(
      onTap: isCalling
          ? null
          : () {
              if (_selectedFloor != null && _selectedFloor != widget.currentFloor) {
                _callElevator(_selectedFloor!);
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(
          minHeight: isCompact ? 80 : 100,
          maxHeight: isCompact ? 120 : 140,
        ),
        decoration: BoxDecoration(
          color: showArrived
              ? ThemeColors.successGreen
              : isCalling
                  ? accentColor.withOpacity(isDark ? 0.2 : 0.15)
                  : accentColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (showArrived ? ThemeColors.successGreen : accentColor).withOpacity(0.3),
              blurRadius: isCalling ? 20 : 12,
              spreadRadius: isCalling ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showArrived
                  ? Icons.check_circle_rounded
                  : isCalling
                      ? (widget.direction == 'up'
                          ? Icons.arrow_upward_rounded
                          : widget.direction == 'down'
                              ? Icons.arrow_downward_rounded
                              : Icons.elevator_rounded)
                      : Icons.elevator_rounded,
              size: isCompact ? 32 : 40,
              color: showArrived || isCalling
                  ? (showArrived ? Colors.white : accentColor)
                  : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              showArrived
                  ? 'رسید'
                  : isCalling
                      ? 'در حال حرکت...'
                      : _selectedFloor == widget.currentFloor
                          ? 'احضار آسانسور'
                          : 'احضار به طبقه $_selectedFloor',
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: showArrived || isCalling
                    ? (showArrived ? Colors.white : accentColor)
                    : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorButtons(bool isDark, bool isCompact, Color accentColor) {
    final sortedFloors = List<int>.from(widget.availableFloors)
      ..sort((a, b) => b.compareTo(a));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: sortedFloors.map((floor) {
        final isCurrentFloor = floor == widget.currentFloor;
        // Floor is selected if it matches the selected floor (including current floor)
        final isSelected = floor == _selectedFloor;

        return GestureDetector(
          onTap: widget.isMoving
              ? null
              : () {
                  // If clicking on current floor, don't change selection
                  if (floor == widget.currentFloor) {
                    return;
                  }
                  // Set new selection (only one can be selected)
                  setState(() {
                    _selectedFloor = floor;
                  });
                  HapticFeedback.lightImpact();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isCompact ? 40 : 48,
            height: isCompact ? 40 : 48,
            decoration: BoxDecoration(
              color: isCurrentFloor
                  ? accentColor.withOpacity(isDark ? 0.25 : 0.2)
                  : isSelected
                      ? accentColor.withOpacity(isDark ? 0.15 : 0.1)
                      : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentFloor || isSelected
                    ? accentColor.withOpacity(0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$floor',
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: isCurrentFloor || isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isCurrentFloor || isSelected
                      ? accentColor
                      : AppTheme.getTextColor1(isDark),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
