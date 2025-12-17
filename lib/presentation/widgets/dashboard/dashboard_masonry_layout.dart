import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/dashboard_layout_model.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/room_viewmodel.dart';
import '../../viewmodels/scenario_viewmodel.dart';

/// Section item for masonry grid
class _SectionItem {
  final DashboardSectionModel section;
  final DashboardColumnModel column;
  final int sectionIndex;
  final double width;
  final double height;

  const _SectionItem({
    required this.section,
    required this.column,
    required this.sectionIndex,
    required this.width,
    required this.height,
  });
}

/// Masonry grid layout for dashboard sections
/// Similar to Instagram Explore - devices column on left, other sections in masonry grid on right
class DashboardMasonryLayout extends StatelessWidget {
  final DashboardViewModel dashboardVM;
  final List<DashboardCardModel> deviceCards;
  final List<DashboardCardModel> cameraCards;
  final Size availableSize;
  final Widget Function({
    required DashboardViewModel dashboardVM,
    required DashboardColumnModel column,
    required int columnIndex,
    required DashboardSectionModel section,
    required int sectionIndex,
    required double sectionHeight,
    required double availableWidth,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
    required bool enableInteractions,
  }) buildSection;

  const DashboardMasonryLayout({
    super.key,
    required this.dashboardVM,
    required this.deviceCards,
    required this.cameraCards,
    required this.availableSize,
    required this.buildSection,
  });

  /// Calculate optimal number of columns for masonry grid
  int _calculateGridColumns(double availableWidth, double minSectionWidth) {
    if (availableWidth <= 0) return 2;
    
    // Calculate how many columns can fit
    final columns = (availableWidth / minSectionWidth).floor();
    
    // Clamp to 2-3 columns for tablet landscape
    return columns.clamp(2, 3);
  }

  /// Calculate section dimensions based on type, size, and available width
  /// Returns minimal height based on actual content needs
  Size _calculateSectionDimensions({
    required DashboardSectionType type,
    required DashboardSectionSize size,
    required double columnWidth,
  }) {
    // Minimal content heights for different section types (based on actual content needs)
    // These are much smaller - just enough for content
    final minimalContentHeight = switch (type) {
      DashboardSectionType.led => 180.0, // Header (50) + color wheel (100) + slider (30)
      DashboardSectionType.thermostat => 200.0, // Header (50) + dial (120) + controls (30)
      DashboardSectionType.scenarios => 160.0, // Header (50) + scenarios list (110)
      DashboardSectionType.camera => 180.0, // Camera view
      DashboardSectionType.tabletCharger => 180.0, // Header (50) + battery (100) + buttons (30)
      DashboardSectionType.music => 180.0, // Music player controls
      DashboardSectionType.security => 200.0, // Security controls
      DashboardSectionType.curtain => 180.0, // Curtain controls
      DashboardSectionType.elevator => 200.0, // Elevator controls
      DashboardSectionType.doorLock => 180.0, // Door lock controls
      DashboardSectionType.devices => 200.0, // Not used in grid
    };

    // Size multiplier (very minimal range)
    final sizeMultiplier = switch (size) {
      DashboardSectionSize.compact => 0.85,
      DashboardSectionSize.regular => 1.0,
      DashboardSectionSize.expanded => 1.05, // Very small increase
    };

    // Calculate width (always fits column width)
    final width = columnWidth;
    
    // Calculate height based on minimal content + padding
    final padding = 24.0; // 12px top + 12px bottom
    final contentHeight = minimalContentHeight * sizeMultiplier;
    // Much smaller range - sections will size themselves based on actual content
    final height = (contentHeight + padding).clamp(160.0, 250.0);

    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    final columns = dashboardVM.layout.columns;
    if (columns.isEmpty) {
      return Center(
        child: Text(
          'No sections configured',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // Collect all sections from all columns
    final allSections = <DashboardSectionModel>[];
    for (final column in columns) {
      allSections.addAll(column.sections);
    }

    // Filter sections based on content
    final visibleSections = dashboardVM.isEditMode
        ? allSections
        : allSections.where((section) {
            return _shouldShowSection(
              context,
              section.type,
              deviceCards,
              cameraCards,
            );
          }).toList();

    if (visibleSections.isEmpty) {
      return Center(
        child: Text(
          'No sections to display',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // Separate devices section from other sections
    final devicesSection = visibleSections.firstWhere(
      (s) => s.type == DashboardSectionType.devices,
      orElse: () => visibleSections.first,
    );
    final otherSections = visibleSections
        .where((s) => s.type != DashboardSectionType.devices)
        .toList();

    const spacing = 12.0; // Reduced spacing for better space utilization
    
    // Calculate devices column width (optimized for 11-inch tablet landscape)
    // For 11-inch tablet (~1194px width), use ~400-450px for devices
    // For smaller screens, use responsive width
    final screenWidth = availableSize.width;
    final isTabletLandscape = screenWidth > 900;
    
    // Reduce devices column width to give more space to other sections
    final devicesColumnWidth = isTabletLandscape
        ? math.max(320.0, math.min(360.0, screenWidth * 0.30))
        : math.max(280.0, screenWidth * 0.28);
    
    final remainingWidth = math.max(300.0, screenWidth - devicesColumnWidth - spacing);
    
    // Calculate grid columns (optimized for tablet)
    // For tablet: 2-3 columns, for smaller: 2 columns
    const minSectionWidth = 300.0;
    final gridColumns = isTabletLandscape
        ? _calculateGridColumns(remainingWidth, minSectionWidth).clamp(2, 3)
        : 2;
    final columnWidth = (remainingWidth - spacing * (gridColumns - 1)) / gridColumns;

    // Build masonry grid items
    final sectionItems = <_SectionItem>[];
    for (final section in otherSections) {
      final column = columns.firstWhere(
        (c) => c.sections.contains(section),
        orElse: () => columns.first,
      );
      final sectionIndex = column.sections.indexOf(section);
      
      final dimensions = _calculateSectionDimensions(
        type: section.type,
        size: section.size,
        columnWidth: columnWidth,
      );
      
      sectionItems.add(_SectionItem(
        section: section,
        column: column,
        sectionIndex: sectionIndex,
        width: dimensions.width,
        height: dimensions.height,
      ));
    }

    // Build masonry layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Devices column - fixed width, full height
        SizedBox(
          width: devicesColumnWidth,
          child: _buildDevicesColumn(
            context: context,
            section: devicesSection,
            columns: columns,
            availableHeight: availableSize.height,
          ),
        ),
        
        if (otherSections.isNotEmpty) ...[
          SizedBox(width: spacing),
          
          // Masonry grid for other sections
          Expanded(
            child: _buildMasonryGrid(
              context: context,
              sectionItems: sectionItems,
              gridColumns: gridColumns,
              columnWidth: columnWidth,
              spacing: spacing,
              availableHeight: availableSize.height,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDevicesColumn({
    required BuildContext context,
    required DashboardSectionModel section,
    required List<DashboardColumnModel> columns,
    required double availableHeight,
  }) {
    final column = columns.firstWhere(
      (c) => c.sections.contains(section),
      orElse: () => columns.first,
    );
    final sectionIndex = column.sections.indexOf(section);

    // Calculate devices column width (use the same calculation as in build method)
    final screenWidth = availableSize.width;
    final isTabletLandscape = screenWidth > 900;
    final devicesColumnWidth = isTabletLandscape
        ? math.max(320.0, math.min(360.0, screenWidth * 0.30))
        : math.max(280.0, screenWidth * 0.28);

    return SizedBox(
      width: devicesColumnWidth,
      height: availableHeight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: buildSection(
          dashboardVM: dashboardVM,
          column: column,
          columnIndex: 0,
          section: section,
          sectionIndex: sectionIndex,
          sectionHeight: availableHeight,
          availableWidth: devicesColumnWidth,
          deviceCards: deviceCards,
          cameraCards: cameraCards,
          enableInteractions: true,
        ),
      ),
    );
  }

  Widget _buildMasonryGrid({
    required BuildContext context,
    required List<_SectionItem> sectionItems,
    required int gridColumns,
    required double columnWidth,
    required double spacing,
    required double availableHeight,
  }) {
    if (sectionItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Track height of each column for masonry algorithm
    final columnHeights = List<double>.filled(gridColumns, 0.0);
    final columnWidgets = List<List<Widget>>.generate(
      gridColumns,
      (_) => <Widget>[],
    );

    // Distribute sections across columns using masonry algorithm
    for (final item in sectionItems) {
      // Find the shortest column
      final shortestColumnIndex = columnHeights.indexOf(
        columnHeights.reduce(math.min),
      );

      // Build section widget - let it size itself based on content
      // Use ConstrainedBox with maxHeight instead of fixed height
      final sectionWidget = ClipRect(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: item.width,
            maxHeight: item.height, // Max height, but let content decide actual height
            minHeight: 0, // No minimum - let content decide
          ),
          child: buildSection(
            dashboardVM: dashboardVM,
            column: item.column,
            columnIndex: 0,
            section: item.section,
            sectionIndex: item.sectionIndex,
            sectionHeight: item.height, // Pass as max height hint
            availableWidth: item.width,
            deviceCards: deviceCards,
            cameraCards: cameraCards,
            enableInteractions: true,
          ),
        ),
      );

      // Add spacing before section (except first in column)
      if (columnWidgets[shortestColumnIndex].isNotEmpty) {
        columnWidgets[shortestColumnIndex].add(SizedBox(height: spacing));
      }

      // Add section to shortest column - it will size itself
      columnWidgets[shortestColumnIndex].add(sectionWidget);

      // Update column height - use estimated height for masonry algorithm
      // Actual height will be determined by content
      columnHeights[shortestColumnIndex] += item.height;
      if (columnWidgets[shortestColumnIndex].length > 1) {
        columnHeights[shortestColumnIndex] += spacing;
      }
    }

    // Build columns with overflow protection
    final columnChildren = <Widget>[];
    for (var i = 0; i < gridColumns; i++) {
      columnChildren.add(
        SizedBox(
          width: columnWidth,
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: columnWidgets[i],
            ),
          ),
        ),
      );

      // Add spacing between columns (except last)
      if (i < gridColumns - 1) {
        columnChildren.add(SizedBox(width: spacing));
      }
    }

    // Use SingleChildScrollView for vertical scrolling
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }

  /// Check if a section should be shown based on available devices/cards
  bool _shouldShowSection(
    BuildContext context,
    DashboardSectionType sectionType,
    List<DashboardCardModel> deviceCards,
    List<DashboardCardModel> cameraCards,
  ) {
    final allCards = dashboardVM.cards; // Get ALL cards, not just deviceCards
    
    switch (sectionType) {
      case DashboardSectionType.devices:
        // Always show devices section (even if empty, shows empty state)
        return true;
      case DashboardSectionType.led:
        // Always show LED section so users can see setup prompts
        return true;
      case DashboardSectionType.thermostat:
        // Always show thermostat section so users can see setup prompts
        return true;
      case DashboardSectionType.scenarios:
        // Show scenarios section only if there are scenarios in the current room
        final scenarioVM = context.read<ScenarioViewModel>();
        final roomVM = context.read<RoomViewModel>();
        final currentRoomId = roomVM.selectedRoomId;
        if (currentRoomId == null) return false;
        final roomScenarios = scenarioVM.scenarios
            .where((s) => s.roomId == currentRoomId)
            .toList();
        return roomScenarios.isNotEmpty;
      case DashboardSectionType.camera:
        // Always show camera section so users can see setup prompts
        return true;
      case DashboardSectionType.tabletCharger:
        // Always show tablet charger section so users can see setup prompts
        return true;
      case DashboardSectionType.music:
        // Always show music section if there's a music card OR to show setup prompt
        return allCards.any((card) => card.type == CardType.music) || true;
      case DashboardSectionType.security:
        // Always show security section if there's a security card OR to show setup prompt
        return allCards.any((card) => card.type == CardType.security) || true;
      case DashboardSectionType.curtain:
        // Always show curtain section if there's a curtain card OR to show setup prompt
        return allCards.any((card) => card.type == CardType.curtain) || true;
      case DashboardSectionType.elevator:
        // Always show elevator section if there's an elevator card OR to show setup prompt
        return allCards.any((card) => card.type == CardType.elevator) || true;
      case DashboardSectionType.doorLock:
        // Always show door lock section if there's a door lock card OR to show setup prompt
        return allCards.any((card) => card.type == CardType.doorLock) || true;
    }
  }
}

