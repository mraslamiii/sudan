import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/dashboard_card_model.dart';
import '../../data/models/dashboard_layout_model.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/dashboard/dashboard_card_factory.dart';
import '../widgets/dashboard/dashboard_background.dart';
import '../widgets/dashboard/scenarios_section.dart';
import '../widgets/dashboard/led_control_panel.dart';
import '../widgets/dashboard/thermostat_control_panel.dart';
import '../widgets/dashboard/tablet_charger_control_panel.dart';
import '../widgets/dashboard/dynamic_masonry_grid.dart';
import '../widgets/dashboard/dashboard_masonry_layout.dart';
import '../widgets/common/premium_empty_state.dart';
import '../widgets/dashboard/onboarding_guide_widget.dart';
import '../widgets/shared/squircle_clipper.dart';
import '../widgets/shared/animated_card_wrapper.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/room_viewmodel.dart';
import '../viewmodels/device_viewmodel.dart';
import '../viewmodels/floor_viewmodel.dart';
import '../viewmodels/scenario_viewmodel.dart';
import 'setup/module_setup_page.dart';
import 'setup/room_setup_flow.dart';
import 'setup/scenario_setup_flow.dart';
import 'floor_selection_view.dart';
import 'detail/scenarios_detail_page.dart';
import 'detail/music_player_detail_page.dart';
import 'detail/lighting_detail_page.dart';
import 'detail/thermostat_detail_page.dart';
import 'detail/devices_detail_page.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pin_protection.dart';
import '../widgets/dashboard/iphone_alert_dialog.dart';

class AdvancedDashboardView extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final String? selectedFloorId;

  const AdvancedDashboardView({
    super.key,
    this.onThemeChanged,
    this.selectedFloorId,
  });

  @override
  State<AdvancedDashboardView> createState() => _AdvancedDashboardViewState();
}

class _DeviceTemplateData {
  final CardType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _DeviceTemplateData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _AdvancedDashboardViewState extends State<AdvancedDashboardView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Filter rooms by selected floor and load dashboard for selected room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomVM = context.read<RoomViewModel>();
      final dashboardVM = context.read<DashboardViewModel>();
      final deviceVM = context.read<DeviceViewModel>();
      
      if (widget.selectedFloorId != null) {
        roomVM.loadRooms(floorId: widget.selectedFloorId).then((_) {
          // Load devices and set selected room
          deviceVM.loadDevices().then((_) {
            // Load dashboard for the selected room
            if (roomVM.selectedRoomId != null) {
              deviceVM.selectRoom(roomVM.selectedRoomId);
              dashboardVM.loadDashboard(roomId: roomVM.selectedRoomId);
            } else {
              // If floor has no rooms, load empty dashboard to avoid showing default cards
              dashboardVM.loadDashboard(roomId: 'floor_${widget.selectedFloorId}_empty');
            }
          });
        });
      }
      
      _headerController.forward();
      _fadeController.forward();
    });
  }

  /// Check if a section should be shown based on available devices/cards
  bool _shouldShowSection(
    BuildContext context,
    DashboardSectionType sectionType,
    List<DashboardCardModel> deviceCards,
    List<DashboardCardModel> cameraCards,
  ) {
    switch (sectionType) {
      case DashboardSectionType.devices:
        // Always show devices section (even if empty, shows empty state)
        return true;
      case DashboardSectionType.led:
        // Always show LED section so the empty-state prompts appear in view mode too
        return true;
      case DashboardSectionType.thermostat:
        // Always show thermostat section to surface pairing guidance even outside edit mode
        return true;
      case DashboardSectionType.scenarios:
        // Always show scenarios section (even if empty, shows empty state)
        return true;
      case DashboardSectionType.camera:
        // Always show camera section so users see the setup CTA when no cameras are linked
        return true;
      case DashboardSectionType.tabletCharger:
        // Always show tablet charger section; it renders a safe empty state when unlinked
        return true;
      case DashboardSectionType.music:
        // Always show music section to expose the onboarding state in view mode
        return true;
      case DashboardSectionType.security:
        // Only show security section for general room
        final roomVM = context.read<RoomViewModel>();
        return roomVM.selectedRoom?.isGeneral ?? false;
      case DashboardSectionType.curtain:
        // Always show curtain section so the empty-state guidance is visible
        return true;
      case DashboardSectionType.elevator:
        // Always show elevator section so the empty-state guidance is visible
        return true;
      case DashboardSectionType.doorLock:
        // Always show door lock section so the empty-state guidance is visible
        return true;
    }
  }

  Widget _buildSectionBody({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required DashboardSectionType sectionType,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
  }) {
    print('🟠 [DASHBOARD_VIEW] _buildSectionBody called for section: $sectionType');
    switch (sectionType) {
      case DashboardSectionType.devices:
        return _buildDevicesSection(dashboardVM, deviceCards);
      case DashboardSectionType.led:
        return _buildCompactLEDControl();
      case DashboardSectionType.thermostat:
        return _buildCompactThermostatControl();
      case DashboardSectionType.scenarios:
        print('🟠 [DASHBOARD_VIEW] Building ScenariosSection widget');
        return const ScenariosSection();
      case DashboardSectionType.camera:
        return _buildCameraSection(context, dashboardVM, cameraCards);
      case DashboardSectionType.tabletCharger:
        return _buildCompactTabletChargerControl();
      case DashboardSectionType.music:
        final musicCards =
            dashboardVM.cards.where((c) => c.type == CardType.music).toList();
        return _buildMusicSection(context, dashboardVM, musicCards);
      case DashboardSectionType.security:
        // Only show security section for general room
        final roomVM = context.read<RoomViewModel>();
        if (roomVM.selectedRoom?.isGeneral != true) {
          return const SizedBox.shrink();
        }
        // Filter security cards only from general room
        final securityCards = dashboardVM.cards
            .where((c) => c.type == CardType.security && c.roomId == 'room_general')
            .toList();
        return _buildSecuritySection(context, dashboardVM, securityCards);
      case DashboardSectionType.curtain:
        final curtainCards = dashboardVM.cards
            .where((c) => c.type == CardType.curtain)
            .toList();
        return _buildCurtainSection(context, dashboardVM, curtainCards);
      case DashboardSectionType.elevator:
        final elevatorCards = dashboardVM.cards
            .where((c) => c.type == CardType.elevator)
            .toList();
        return _buildElevatorSection(context, dashboardVM, elevatorCards);
      case DashboardSectionType.doorLock:
        final doorLockCards = dashboardVM.cards
            .where((c) => c.type == CardType.doorLock)
            .toList();
        return _buildDoorLockSection(context, dashboardVM, doorLockCards);
    }
  }

  Widget _buildCameraSection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> cameraCards,
  ) {
    if (cameraCards.isNotEmpty) {
      final cameraCard = cameraCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(cameraCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: cameraCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(cameraCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(cameraCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(cameraCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(cameraCard.id, newData),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    return PremiumEmptyState(
      icon: Icons.videocam_rounded,
      title: l10n.cameraNotLinked,
      message: l10n.secureRoomsWithCamera,
      highlights: [
        l10n.liveFeedSnapshots,
        l10n.roomSwitching,
        l10n.recordingIndicators,
      ],
      primaryActionLabel: l10n.openCameraSetup,
      onPrimaryAction: () => _openSetupPage(context, _cameraSetupContent()),
      isCompact: true,
    );
  }

  Widget _buildSectionEditToolbar({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required DashboardSectionModel section,
  }) {
    final theme = Theme.of(context);
    final icon = _sectionIcon(section.type);
    final label = _sectionTitle(section.type);
    final sizeLabel = _sizeLabel(section.size);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => dashboardVM.cycleSectionSize(section.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.aspect_ratio,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sizeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnSeparator({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required int columnIndex,
    required double width,
    required double height,
    required double totalWidth,
  }) {
    final theme = Theme.of(context);
    final isEditMode = dashboardVM.isEditMode;

    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 1.2,
              height: height * 0.72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    theme.colorScheme.primary.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ),
          if (isEditMode)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                if (totalWidth == 0) return;
                final deltaRatio = details.delta.dx / totalWidth;
                dashboardVM.resizeColumns(columnIndex, deltaRatio);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: height * 0.28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrailingColumnDropZone({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required double width,
    required double height,
  }) {
    final theme = Theme.of(context);
    return DragTarget<String>(
      onWillAccept: (_) => true,
      onAccept: (draggedId) {
        dashboardVM.moveColumnToIndex(
          draggedId,
          dashboardVM.layout.columns.length,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        final color = theme.colorScheme.primary;

        return SizedBox(
          width: width,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: math.max(width * 0.55, 18),
              height: math.max(height * 0.22, 60),
              decoration: BoxDecoration(
                color: color.withOpacity(isActive ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withOpacity(isActive ? 0.55 : 0.25),
                  width: 1.6,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: color.withOpacity(isActive ? 0.9 : 0.55),
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _sectionPadding(DashboardSectionType type) {
    // Optimized padding - minimal and efficient use of space
    switch (type) {
      case DashboardSectionType.devices:
        return const EdgeInsets.all(12);
      case DashboardSectionType.led:
        return const EdgeInsets.all(12);
      case DashboardSectionType.thermostat:
        return const EdgeInsets.all(12);
      case DashboardSectionType.scenarios:
        return const EdgeInsets.all(12);
      case DashboardSectionType.camera:
        return const EdgeInsets.all(12);
      case DashboardSectionType.tabletCharger:
        return const EdgeInsets.all(12);
      case DashboardSectionType.music:
      case DashboardSectionType.security:
      case DashboardSectionType.curtain:
      case DashboardSectionType.elevator:
      case DashboardSectionType.doorLock:
        return const EdgeInsets.all(12);
    }
  }

  String _sectionTitle(DashboardSectionType type) {
    switch (type) {
      case DashboardSectionType.devices:
        return 'Devices';
      case DashboardSectionType.led:
        return 'Ambient Lighting';
      case DashboardSectionType.thermostat:
        return 'Thermostat';
      case DashboardSectionType.scenarios:
        return 'Scenarios';
      case DashboardSectionType.camera:
        return 'Camera';
      case DashboardSectionType.tabletCharger:
        return 'Tablet Charger';
      case DashboardSectionType.music:
        return 'Music Player';
      case DashboardSectionType.security:
        return 'Security';
      case DashboardSectionType.curtain:
        return 'Curtains';
      case DashboardSectionType.elevator:
        return 'Elevator';
      case DashboardSectionType.doorLock:
        return 'Door Lock';
    }
  }

  IconData _sectionIcon(DashboardSectionType type) {
    switch (type) {
      case DashboardSectionType.devices:
        return Icons.devices_other_rounded;
      case DashboardSectionType.led:
        return Icons.brightness_6_rounded;
      case DashboardSectionType.thermostat:
        return Icons.thermostat_rounded;
      case DashboardSectionType.scenarios:
        return Icons.auto_awesome_rounded;
      case DashboardSectionType.camera:
        return Icons.videocam_rounded;
      case DashboardSectionType.tabletCharger:
        return Icons.battery_charging_full_rounded;
      case DashboardSectionType.music:
        return Icons.music_note_rounded;
      case DashboardSectionType.security:
        return Icons.shield_rounded;
      case DashboardSectionType.curtain:
        return Icons.curtains_rounded;
      case DashboardSectionType.elevator:
        return Icons.elevator_rounded;
      case DashboardSectionType.doorLock:
        return Icons.door_front_door_rounded;
    }
  }

  String _sizeLabel(DashboardSectionSize size) {
    switch (size) {
      case DashboardSectionSize.compact:
        return 'Compact';
      case DashboardSectionSize.regular:
        return 'Regular';
      case DashboardSectionSize.expanded:
        return 'Expanded';
    }
  }

  /// Get maximum content height for a section based on its type and size
  /// Reduced heights to match actual content needs
  double _getMaxContentHeightForSection(DashboardSectionType type, DashboardSectionSize size) {
    final baseHeight = switch (type) {
      DashboardSectionType.led => 200.0, // Reduced from 280
      DashboardSectionType.thermostat => 220.0, // Reduced from 300
      DashboardSectionType.tabletCharger => 200.0, // Reduced from 250
      DashboardSectionType.music => 200.0, // Reduced from 280
      DashboardSectionType.security => 220.0, // Reduced from 300
      DashboardSectionType.curtain => 200.0, // Reduced from 280
      _ => double.infinity, // Other sections can use full height
    };

    final multiplier = switch (size) {
      DashboardSectionSize.compact => 0.85,
      DashboardSectionSize.regular => 1.0,
      DashboardSectionSize.expanded => 1.05, // Reduced from 1.2
    };

    return baseHeight * multiplier;
  }

  Widget _buildDashboardCanvas({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
    required Size availableSize,
  }) {
    // Use the new masonry layout widget
    return DashboardMasonryLayout(
                  dashboardVM: dashboardVM,
                  deviceCards: deviceCards,
                  cameraCards: cameraCards,
      availableSize: availableSize,
      buildSection: _buildDashboardSection,
    );
  }

  Widget _buildHorizontalSectionsGrid({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required List<DashboardSectionModel> sections,
    required double availableWidth,
    required double availableHeight,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
    required List<DashboardColumnModel> columns,
  }) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final spacing = 16.0;
    
    // Calculate optimal item width for horizontal grid
    final screenSize = MediaQuery.of(context).size;
    final isTabletLandscape = screenSize.width > 900;
    final itemWidth = isTabletLandscape 
        ? math.min(350.0, (availableWidth - spacing * 2) / 3)
        : math.min(300.0, (availableWidth - spacing) / 2);
    
    // Use Wrap for dynamic horizontal grid
    return SizedBox(
      width: availableWidth,
      height: availableHeight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            final column = columns.firstWhere(
              (c) => c.sections.contains(section),
              orElse: () => columns.first,
            );
            
            // Calculate section height based on its weight
            final sectionHeight = _calculateSectionHeightForGrid(
              section: section,
              availableHeight: availableHeight,
              itemWidth: itemWidth,
              spacing: spacing,
            );
            
            return SizedBox(
              width: itemWidth,
              height: sectionHeight,
              child: _buildDashboardSection(
                dashboardVM: dashboardVM,
                column: column,
                columnIndex: 0,
                section: section,
                sectionIndex: index,
                sectionHeight: sectionHeight,
                availableWidth: itemWidth,
                deviceCards: deviceCards,
                cameraCards: cameraCards,
                enableInteractions: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  double _calculateSectionHeightForGrid({
    required DashboardSectionModel section,
    required double availableHeight,
    required double itemWidth,
    required double spacing,
  }) {
    // Calculate height based on section type and size
    final baseHeight = _getMaxContentHeightForSection(section.type, section.size);
    final weight = section.heightWeight;
    final avgWeight = 2.0;
    
    // Ensure minimum height
    final calculatedHeight = (baseHeight * weight / avgWeight);
    return math.max(calculatedHeight, 200.0);
  }

  Widget _buildDashboardColumn({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required DashboardColumnModel column,
    required int columnIndex,
    required double width,
    required double height,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
    required bool enableInteractions,
  }) {
    Widget buildColumnBody(bool interactionsEnabled) {
      return SizedBox(
        width: width,
        height: height,
        child: _buildDashboardColumnContent(
          context: context,
          dashboardVM: dashboardVM,
          column: column,
          columnIndex: columnIndex,
          availableWidth: width,
          availableHeight: height,
          deviceCards: deviceCards,
          cameraCards: cameraCards,
          enableInteractions: interactionsEnabled,
        ),
      );
    }

    if (!dashboardVM.isEditMode || !enableInteractions) {
      return buildColumnBody(enableInteractions);
    }

    return SizedBox(
      width: width,
      child: DragTarget<String>(
        onWillAccept: (draggedId) => draggedId != column.id,
        onAccept: (draggedId) {
          final targetIndex = dashboardVM.layout.columns.indexWhere(
            (candidate) => candidate.id == column.id,
          );
          dashboardVM.moveColumnToIndex(draggedId, targetIndex);
        },
        builder: (context, candidateData, rejectedData) {
          final highlight = candidateData.isNotEmpty;
          final themedBorder = Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.38);
          return LongPressDraggable<String>(
            data: column.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Opacity(opacity: 0.82, child: buildColumnBody(false)),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.22,
              child: buildColumnBody(false),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              decoration: highlight
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: themedBorder, width: 2),
                    )
                  : null,
              child: buildColumnBody(true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardColumnContent({
    required BuildContext context,
    required DashboardViewModel dashboardVM,
    required DashboardColumnModel column,
    required int columnIndex,
    required double availableWidth,
    required double availableHeight,
    required List<DashboardCardModel> deviceCards,
    required List<DashboardCardModel> cameraCards,
    required bool enableInteractions,
  }) {
    // Filter sections based on whether they have content
    // In edit mode, show all sections; otherwise, only show sections with devices
    final allSections = [...column.sections];
    // If layout is single-column (compact/mobile), make sure scenarios lives in that column too
    final isSingleColumnLayout = dashboardVM.layout.columns.length == 1;
    final hasScenariosHere =
        allSections.any((s) => s.type == DashboardSectionType.scenarios);
    if (isSingleColumnLayout && !hasScenariosHere) {
      allSections.add(DashboardSectionModel.defaultFor(DashboardSectionType.scenarios));
      print('🟠 [DASHBOARD_VIEW] Injected scenarios into single-column layout');
    }

    print('🟠 [DASHBOARD_VIEW] Column $columnIndex has ${allSections.length} sections: ${allSections.map((s) => s.type).toList()}');
    final sections = dashboardVM.isEditMode
        ? allSections
        : allSections.where((section) {
            final shouldShow = _shouldShowSection(
              context,
              section.type,
              deviceCards,
              cameraCards,
            );
            print('🟠 [DASHBOARD_VIEW] Section ${section.type} shouldShow: $shouldShow');
            return shouldShow;
          }).toList();
    // Ensure scenarios section is always present (especially in view mode) in the controls column
    final hasScenariosSection =
        sections.any((s) => s.type == DashboardSectionType.scenarios);
    if (!hasScenariosSection) {
      // Add it to the controls column (index 1) or to this column if controls not present
      if (columnIndex == 1 || dashboardVM.layout.columns.length == 1) {
        sections.insert(
          0,
          DashboardSectionModel.defaultFor(DashboardSectionType.scenarios),
        );
        print('🟠 [DASHBOARD_VIEW] Injected scenarios section into column $columnIndex');
      }
    }
    print(
      '🟠 [DASHBOARD_VIEW] After filtering, column $columnIndex has ${sections.length} sections: ${sections.map((s) => s.type).toList()}',
    );

    if (sections.isEmpty) {
      return Center(
        child: Text(
          dashboardVM.isEditMode ? 'Drop a section here' : '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    const spacing = 16.0;
    final editModeExtraHeight = dashboardVM.isEditMode && enableInteractions
        ? 38.0
        : 0.0; // 12 spacing + 26 drop zone
    final spacingHeight = sections.length > 1
        ? spacing * (sections.length - 1)
        : 0;
    final usableHeight = math.max(
      availableHeight - spacingHeight - editModeExtraHeight,
      160.0,
    );
    final totalWeight = sections.fold<double>(
      0,
      (sum, section) => sum + section.heightWeight,
    );

    final widgets = <Widget>[];

    for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      final section = sections[sectionIndex];
      final weight = section.heightWeight;
      final fraction = totalWeight <= 0
          ? (1 / sections.length)
          : (weight / totalWeight);
      final sectionHeight = usableHeight * fraction;

      widgets.add(
        SizedBox(
          height: sectionHeight,
          child: _buildDashboardSection(
            dashboardVM: dashboardVM,
            column: column,
            columnIndex: columnIndex,
            section: section,
            sectionIndex: sectionIndex,
            sectionHeight: sectionHeight,
            availableWidth: availableWidth,
            deviceCards: deviceCards,
            cameraCards: cameraCards,
            enableInteractions: enableInteractions,
          ),
        ),
      );

      if (sectionIndex < sections.length - 1) {
        widgets.add(const SizedBox(height: spacing));
      }
    }

    if (dashboardVM.isEditMode && enableInteractions) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        DragTarget<String>(
          onWillAccept: (_) => true,
          onAccept: (draggedId) {
            dashboardVM.moveSection(
              sectionId: draggedId,
              targetColumnId: column.id,
              targetIndex: column.sections.length,
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isActive = candidateData.isNotEmpty;
            final theme = Theme.of(context);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 26,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isActive
                    ? Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.48),
                        width: 1.4,
                      )
                    : null,
              ),
              child: isActive
                  ? Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: availableHeight, minHeight: 0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }

  Widget _buildDashboardSection({
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
  }) {
    Widget buildSurface() {
      // For LED and Thermostat sections, limit height to prevent stretching
      final maxContentHeight = _getMaxContentHeightForSection(section.type, section.size);
      final padding = _sectionPadding(section.type);
      final actualContentHeight = math.min(
        sectionHeight - padding.vertical,
        maxContentHeight - padding.vertical,
      );
      
      // Let content size itself based on actual needs - no forced height
      final sectionContent = (section.type == DashboardSectionType.led || 
                section.type == DashboardSectionType.thermostat ||
                section.type == DashboardSectionType.tabletCharger ||
                section.type == DashboardSectionType.music ||
                section.type == DashboardSectionType.security ||
                section.type == DashboardSectionType.curtain ||
                section.type == DashboardSectionType.scenarios)
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: math.max(actualContentHeight, 160.0), // Further reduced
                  minHeight: 0, // Let content decide minimum
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _buildSectionBody(
                    context: context,
                    dashboardVM: dashboardVM,
                    sectionType: section.type,
                    deviceCards: deviceCards,
                    cameraCards: cameraCards,
                  ),
                ),
              )
            : _buildSectionBody(
                context: context,
                dashboardVM: dashboardVM,
                sectionType: section.type,
                deviceCards: deviceCards,
                cameraCards: cameraCards,
              );

      // Wrap with tap handler for navigation to detail pages (only in view mode)
      final wrappedContent = !dashboardVM.isEditMode
          ? GestureDetector(
              onTap: () => _navigateToDetailPage(context, section.type),
              child: sectionContent,
            )
          : sectionContent;

      return _buildSectionBox(
        padding: padding,
        child: wrappedContent,
      );
    }

    if (!dashboardVM.isEditMode || !enableInteractions) {
      return buildSurface();
    }

    return DragTarget<String>(
      onWillAccept: (draggedId) => draggedId != section.id,
      onAccept: (draggedId) {
        dashboardVM.moveSection(
          sectionId: draggedId,
          targetColumnId: column.id,
          targetIndex: sectionIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final highlight = candidateData.isNotEmpty;
        final theme = Theme.of(context);
        final highlightColor = theme.colorScheme.primary.withOpacity(0.42);

        return SizedBox(
          width: availableWidth,
          height: sectionHeight,
          child: LongPressDraggable<String>(
            data: section.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: availableWidth,
                  height: sectionHeight,
                  child: Opacity(
                    opacity: 0.82,
                    child: IgnorePointer(child: buildSurface()),
                  ),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.22,
              child: IgnorePointer(child: buildSurface()),
            ),
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      decoration: highlight
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: highlightColor, width: 2),
                            )
                          : null,
                      child: buildSurface(),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _buildSectionEditToolbar(
                      context: context,
                      dashboardVM: dashboardVM,
                      section: section,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetailPage(BuildContext context, DashboardSectionType sectionType) {
    switch (sectionType) {
      case DashboardSectionType.scenarios:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScenariosDetailPage()),
        );
        break;
      case DashboardSectionType.music:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MusicPlayerDetailPage()),
        );
        break;
      case DashboardSectionType.led:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LightingDetailPage()),
        );
        break;
      case DashboardSectionType.thermostat:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ThermostatDetailPage()),
        );
        break;
      case DashboardSectionType.devices:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DevicesDetailPage()),
        );
        break;
      default:
        // Other sections don't have detail pages yet
        break;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: DashboardBackground(isDark: isDark)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildMainContent(isTabletLandscape, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isTabletLandscape, bool isDark) {
    return Consumer4<DashboardViewModel, RoomViewModel, ScenarioViewModel, DeviceViewModel>(
      builder: (context, dashboardVM, roomVM, scenarioVM, deviceVM, _) {
        if (dashboardVM.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.getPrimaryBlue(isDark),
            ),
          );
        }

        final cameraCards = dashboardVM.cameraCards;
        final deviceCards = dashboardVM.deviceCards;
        final currentRoomId = roomVM.selectedRoomId;
        final hasRooms = roomVM.rooms.isNotEmpty;
        // Check if there are any cards at all (not just deviceCards, which excludes special sections)
        final hasDevices = dashboardVM.cards.isNotEmpty;
        final hasScenarios = currentRoomId != null
            ? scenarioVM.scenarios.any((s) => s.roomId == currentRoomId)
            : false;

        // Show onboarding guide if everything is empty
        final showOnboarding = !hasRooms && !hasDevices && !hasScenarios;

        return Column(
          children: [
            // Top Navigation Bar
            _buildRoomNavigationBar(dashboardVM),
            const SizedBox(height: 16),

            // Main Content - adaptive freeform layout or onboarding guide
            Expanded(
              child: showOnboarding
                  ? OnboardingGuideWidget(deviceCards: deviceCards)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildDashboardCanvas(
                          context: context,
                          dashboardVM: dashboardVM,
                          deviceCards: deviceCards,
                          cameraCards: cameraCards,
                          availableSize: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactLEDControl() {
    return Consumer<DeviceViewModel>(
      builder: (context, deviceVM, _) {
        if (deviceVM.ledDevice == null) {
          final l10n = AppLocalizations.of(context)!;
          return PremiumEmptyState(
            icon: Icons.lightbulb_rounded,
            title: l10n.lightingNotPaired,
            message: l10n.connectSmartLighting,
            highlights: [
              l10n.ambientGradients,
              l10n.presetSceneCycles,
              l10n.realtimeDimming,
            ],
            primaryActionLabel: l10n.openLightingSetup,
            onPrimaryAction: () =>
                _openSetupPage(context, _lightingSetupContent()),
            isCompact: true,
          );
        }

        return LEDControlPanel(
          selectedColor: deviceVM.ledColor,
          brightness: deviceVM.ledBrightness,
          isOn: deviceVM.isLedOn,
          selectedPreset: deviceVM.ledPreset,
          onColorChanged: (color) => deviceVM.updateLEDColor(color),
          onBrightnessChanged: (brightness) =>
              deviceVM.updateLEDBrightness(brightness),
          onIntensityChanged: (intensity) =>
              deviceVM.updateLEDIntensity(intensity),
          onToggle: (isOn) => deviceVM.setLEDOn(isOn),
          onPresetChanged: (preset) => deviceVM.updateLEDPreset(preset),
        );
      },
    );
  }

  Widget _buildCompactThermostatControl() {
    return Consumer<DeviceViewModel>(
      builder: (context, deviceVM, _) {
        if (deviceVM.thermostatDevice == null) {
          final l10n = AppLocalizations.of(context)!;
          return PremiumEmptyState(
            icon: Icons.thermostat_rounded,
            title: l10n.thermostatOffline,
            message: l10n.linkClimateController,
            highlights: [
              l10n.modesAndScheduling,
              l10n.adaptiveComfortInsights,
              l10n.energyFriendlyPresets,
            ],
            primaryActionLabel: l10n.openThermostatSetup,
            onPrimaryAction: () =>
                _openSetupPage(context, _thermostatSetupContent()),
            isCompact: true,
          );
        }

        return ThermostatControlPanel(
          temperature: deviceVM.targetTemperature,
          mode: deviceVM.thermostatMode,
          isOn: deviceVM.isThermostatOn,
          onTemperatureChanged: (temp) => deviceVM.setTemperature(temp),
          onModeChanged: (mode) => deviceVM.updateThermostatMode(mode),
          onToggle: (isOn) => deviceVM.setThermostatOn(isOn),
        );
      },
    );
  }

  Widget _buildCompactTabletChargerControl() {
    return Consumer<DeviceViewModel>(
      builder: (context, deviceVM, _) {
        return TabletChargerControlPanel(
          batteryLevel: deviceVM.tabletBatteryLevel,
          isCharging: deviceVM.isTabletCharging,
          isDischarging: deviceVM.isTabletDischarging,
          isConnected: deviceVM.isTabletChargerConnected,
          onCharge: () => deviceVM.startTabletCharge(),
          onDischarge: () => deviceVM.startTabletDischarge(),
          onToggle: (isOn) => deviceVM.toggleTabletCharger(isOn),
        );
      },
    );
  }

  Widget _buildMusicSection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> musicCards,
  ) {
    if (musicCards.isNotEmpty) {
      final musicCard = musicCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(musicCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: musicCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(musicCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(musicCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(musicCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(musicCard.id, newData),
        ),
      );
    }

    return PremiumEmptyState(
      icon: Icons.music_note_rounded,
      title: 'Music Player Not Linked',
      message: 'Connect a music player to control playback and volume.',
      highlights: const [
        'Play/Pause control',
        'Volume adjustment',
        'Track navigation',
      ],
      primaryActionLabel: 'Add Music Player',
      onPrimaryAction: () {},
      isCompact: true,
    );
  }

  Widget _buildSecuritySection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> securityCards,
  ) {
    if (securityCards.isNotEmpty) {
      final securityCard = securityCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(securityCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: securityCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(securityCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(securityCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(securityCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(securityCard.id, newData),
        ),
      );
    }

    return PremiumEmptyState(
      icon: Icons.shield_rounded,
      title: 'Security System Not Linked',
      message: 'Connect a security system to monitor and control alarms.',
      highlights: const [
        'Arm/Disarm control',
        'Status monitoring',
        'Zone management',
      ],
      primaryActionLabel: 'Add Security System',
      onPrimaryAction: () {},
      isCompact: true,
    );
  }

  Widget _buildCurtainSection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> curtainCards,
  ) {
    if (curtainCards.isNotEmpty) {
      final curtainCard = curtainCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(curtainCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: curtainCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(curtainCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(curtainCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(curtainCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(curtainCard.id, newData),
        ),
      );
    }

    return PremiumEmptyState(
      icon: Icons.curtains_rounded,
      title: 'Curtains Not Linked',
      message: 'Connect smart curtains to control opening and closing.',
      highlights: const [
        'Position control',
        'Quick actions',
        'Smooth operation',
      ],
      primaryActionLabel: 'Add Curtains',
      onPrimaryAction: () {},
      isCompact: true,
    );
  }

  Widget _buildElevatorSection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> elevatorCards,
  ) {
    if (elevatorCards.isNotEmpty) {
      final elevatorCard = elevatorCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(elevatorCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: elevatorCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(elevatorCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(elevatorCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(elevatorCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(elevatorCard.id, newData),
        ),
      );
    }

    return PremiumEmptyState(
      icon: Icons.elevator_rounded,
      title: 'Elevator Not Linked',
      message: 'Connect an elevator system to control floor selection.',
      highlights: const [
        'Floor selection',
        'Call elevator',
        'Status monitoring',
      ],
      primaryActionLabel: 'Add Elevator',
      onPrimaryAction: () {},
      isCompact: true,
    );
  }

  Widget _buildDoorLockSection(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> doorLockCards,
  ) {
    if (doorLockCards.isNotEmpty) {
      final doorLockCard = doorLockCards.first;
      return AnimatedCardWrapper(
        key: ValueKey(doorLockCard.id),
        index: 0,
        animation: _fadeController,
        child: DashboardCardFactory.createCard(
          card: doorLockCard,
          isEditMode: dashboardVM.isEditMode,
          onTap: () => dashboardVM.handleCardTap(doorLockCard, context),
          onLongPress: dashboardVM.isEditMode
              ? null
              : dashboardVM.toggleEditMode,
          onDelete: () => dashboardVM.deleteCard(doorLockCard.id),
          onResize: (newSize) => dashboardVM.resizeCard(doorLockCard.id, newSize),
          onDataUpdate: (newData) =>
              dashboardVM.updateCardData(doorLockCard.id, newData),
        ),
      );
    }

    return PremiumEmptyState(
      icon: Icons.door_front_door_rounded,
      title: 'Door Lock Not Linked',
      message: 'Connect a smart door lock or intercom system.',
      highlights: const [
        'Lock/Unlock control',
        'Intercom support',
        'Status monitoring',
      ],
      primaryActionLabel: 'Add Door Lock',
      onPrimaryAction: () {},
      isCompact: true,
    );
  }

  Widget _buildRoomNavigationBar(DashboardViewModel dashboardVM) {
    return Consumer<RoomViewModel>(
      builder: (context, roomVM, _) {
        final rooms = roomVM.rooms;
        final selectedRoom = roomVM.selectedRoom;

        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _headerController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: FadeTransition(
            opacity: _headerController,
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  height: 92,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getSectionGradient(isDark),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppTheme.getSectionBorderColor(
                        isDark,
                      ).withOpacity(isDark ? 0.8 : 0.6),
                      width: 1.1,
                    ),
                    boxShadow: AppTheme.getSectionShadows(
                      isDark,
                      elevated: true,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildAppTitle(isDark),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRoomTabs(
                          rooms,
                          selectedRoom,
                          roomVM,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButtons(dashboardVM, roomVM, isDark),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle(bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToFloors(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryButtonGradient(isDark),
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
            ),
            child: const Icon(Icons.home_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'Sudan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFloors() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FloorSelectionView(
          onThemeChanged: widget.onThemeChanged,
          selectedFloorId: widget.selectedFloorId,
        ),
      ),
    );
  }

  Widget _buildRoomTabs(
    List rooms,
    dynamic selectedRoom,
    RoomViewModel roomVM,
    bool isDark,
  ) {
    if (rooms.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for tabs (accounting for padding)
        final availableWidth = constraints.maxWidth - 8; // Container padding
        final roomCount = rooms.length;
        
        // Calculate optimal width per tab
        // Use flexible sizing: minimum 70px, maximum 140px, or distribute evenly if space allows
        final minTabWidth = 70.0;
        final maxTabWidth = 140.0;
        final preferredWidth = (availableWidth / roomCount).clamp(minTabWidth, maxTabWidth);
        
        // If total preferred width exceeds available space, use scrollable layout
        final totalPreferredWidth = preferredWidth * roomCount;
        final needsScroll = totalPreferredWidth > availableWidth;

        return Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppTheme.getSectionGradient(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(
                isDark,
              ).withOpacity(isDark ? 0.6 : 0.4),
              width: 1,
            ),
          ),
          child: needsScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: rooms.map<Widget>((room) {
                      final isSelected = room.id == selectedRoom?.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                          width: preferredWidth,
                          child: _buildRoomTab(room.name, isSelected, () async {
                            await roomVM.selectRoom(room.id);
                            final deviceVM = context.read<DeviceViewModel>();
                            final dashboardVM = context.read<DashboardViewModel>();
                            
                            // Refresh devices and select room
                            await deviceVM.loadDevices();
                            await deviceVM.selectRoom(room.id);
                            
                            // Reload dashboard for the selected room (this will sync with devices)
                            await dashboardVM.loadDashboard(roomId: room.id);
                          }, isDark),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Row(
                  children: rooms.map<Widget>((room) {
                    final isSelected = room.id == selectedRoom?.id;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildRoomTab(room.name, isSelected, () async {
                          await roomVM.selectRoom(room.id);
                          final deviceVM = context.read<DeviceViewModel>();
                          final dashboardVM = context.read<DashboardViewModel>();
                          
                          // Refresh devices and select room
                          await deviceVM.loadDevices();
                          await deviceVM.selectRoom(room.id);
                          
                          // Reload dashboard for the selected room (this will sync with devices)
                          await dashboardVM.loadDashboard(roomId: room.id);
                        }, isDark),
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildRoomTab(
    String roomName,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(
          minHeight: 48,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.getPrimaryButtonGradient(isDark)
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getSectionBorderColor(
                    isDark,
                  ).withOpacity(isDark ? 0.45 : 0.35),
            width: 1,
          ),
          boxShadow: isSelected
              ? AppTheme.getSectionShadows(isDark, elevated: true)
              : const <BoxShadow>[],
        ),
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              roomName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppTheme.getSecondaryGray(isDark),
                fontFamily: 'IRANYekan',
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    DashboardViewModel dashboardVM,
    RoomViewModel roomVM,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditModeButton(dashboardVM, isDark),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.add_home_rounded,
          onTap: () => _handleAddRoom(context),
        ),
        const SizedBox(width: 8),
        _buildActionButton(icon: Icons.notifications_outlined, onTap: () {}),
        const SizedBox(width: 8),
        // Test Door Phone Dialog Button
        _buildActionButton(
          icon: Icons.doorbell_rounded,
          onTap: () => _testIPhoneDialog(context),
        ),
        const SizedBox(width: 8),
        _buildMainMenu(),
      ],
    );
  }

  void _testIPhoneDialog(BuildContext context) {
    IPhoneAlertDialog.show(
      context,
      deviceName: 'آیفون درب',
      imageUrl: null,
      onOpen: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درب باز شد'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onDismiss: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('نادیده گرفته شد'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _handleAddRoom(BuildContext context) async {
    print('🔵 [DASHBOARD] _handleAddRoom called');
    
    if (!context.mounted) {
      print('🔴 [DASHBOARD] Context not mounted at start, returning');
      return;
    }

    print('🟢 [DASHBOARD] Requesting PIN verification');
    // Check PIN protection
    final verified = await PinProtection.requirePinVerification(
      context,
      title: AppLocalizations.of(context)!.pinRequired,
      subtitle: AppLocalizations.of(context)!.pinRequiredForAction,
    );

    print('🟢 [DASHBOARD] PIN verification result: $verified');
    print('🟢 [DASHBOARD] Context mounted after PIN: ${context.mounted}');

    if (!context.mounted) {
      print('🔴 [DASHBOARD] Context not mounted after PIN verification, returning');
      return;
    }

    if (!verified) {
      print('🟡 [DASHBOARD] PIN verification failed or cancelled, returning');
      return; // User cancelled or PIN verification failed
    }

    if (!context.mounted) {
      print('🔴 [DASHBOARD] Context not mounted before navigation, returning');
      return;
    }

    print('🟢 [DASHBOARD] Navigating to RoomSetupFlow');
    final selectedFloorId = widget.selectedFloorId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomSetupFlow(floorId: selectedFloorId),
      ),
    ).then((success) {
      print('🟢 [DASHBOARD] RoomSetupFlow returned: $success');
      if (success == true && context.mounted) {
        // Refresh viewmodels
        final roomVM = context.read<RoomViewModel>();
        final floorVM = context.read<FloorViewModel>();
        final dashboardVM = context.read<DashboardViewModel>();
        roomVM.loadRooms(floorId: selectedFloorId).then((_) {
          context.read<DeviceViewModel>().refresh().then((_) {
            // Refresh dashboard to sync cards with devices and update layout
            if (roomVM.selectedRoomId != null) {
              dashboardVM.refresh();
            }
          });
        });
        floorVM.refresh();
      }
    });
  }

  Widget _buildEditModeButton(DashboardViewModel dashboardVM, bool isDark) {
    return GestureDetector(
      onTap: () {
        dashboardVM.toggleEditMode();
        if (dashboardVM.isEditMode) {
          _slideController.forward();
        } else {
          _slideController.reverse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: dashboardVM.isEditMode
              ? AppTheme.getPrimaryButtonGradient(isDark)
              : null,
          color: dashboardVM.isEditMode
              ? null
              : AppTheme.getSoftButtonBackground(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dashboardVM.isEditMode
                ? Colors.transparent
                : AppTheme.getSectionBorderColor(
                    isDark,
                  ).withOpacity(isDark ? 0.45 : 0.35),
            width: 1,
          ),
          boxShadow: dashboardVM.isEditMode
              ? AppTheme.getSectionShadows(isDark, elevated: true)
              : const <BoxShadow>[],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              dashboardVM.isEditMode ? Icons.check_rounded : Icons.tune_rounded,
              size: 14,
              color: dashboardVM.isEditMode
                  ? Colors.white
                  : AppTheme.getTextColor1(isDark),
            ),
            const SizedBox(width: 4),
            Text(
              dashboardVM.isEditMode ? 'Done' : 'Edit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dashboardVM.isEditMode
                    ? Colors.white
                    : AppTheme.getTextColor1(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getSoftButtonBackground(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(
                  isDark,
                ).withOpacity(isDark ? 0.4 : 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 16, color: AppTheme.getAccentTeal(isDark)),
          ),
        );
      },
    );
  }

  Widget _buildSectionBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    const double borderRadius = 36;
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getSectionGradient(isDark),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(
                isDark,
              ).withOpacity(isDark ? 0.7 : 0.55),
              width: 1.2,
            ),
            boxShadow: AppTheme.getSectionShadows(isDark),
          ),
          child: ClipPath(
            clipper: SquircleClipper(borderRadius: borderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.045)
                    : Colors.white.withOpacity(0.7),
              ),
              child: ClipRect(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevicesSection(
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> deviceCards,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final roomVM = context.read<RoomViewModel>();
        final scenarioVM = context.read<ScenarioViewModel>();
        final currentRoomId = roomVM.selectedRoomId;
        final hasScenarios = currentRoomId != null
            ? scenarioVM.scenarios.any((s) => s.roomId == currentRoomId)
            : false;

        if (deviceCards.isEmpty && !hasScenarios) {
          // Show centered empty state with both Add Device and Add Scenario buttons
          return _buildCenteredEmptyState(context, isDark, dashboardVM);
        }

        if (deviceCards.isEmpty) {
          // Only devices are empty, show Add Device button
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.getPrimaryBlue(isDark).withOpacity(0.15),
                        AppTheme.getPrimaryBlue(isDark).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.devices_other_rounded,
                        size: 48,
                        color: AppTheme.getPrimaryBlue(isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noDevicesYet,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextColor1(isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addDevicesToDashboard,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _handleAddDeviceAction(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ).copyWith(
                          elevation: MaterialStateProperty.all(0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.getPrimaryButtonGradient(isDark),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getPrimaryBlue(isDark)
                                    .withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.addDevice,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Allow column to size based on content
          children: [
            Row(
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.devices_rounded,
                    size: 16,
                    color: AppTheme.getPrimaryBlue(isDark),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    opacity: dashboardVM.isEditMode ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: AppTheme.getPrimaryBlue(isDark),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Drag to arrange',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getPrimaryBlue(isDark),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${deviceCards.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPrimaryBlue(isDark),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    backgroundColor: AppTheme.getPrimaryBlue(isDark),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _handleAddDeviceAction(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add device'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              fit: FlexFit.loose, // Allow child to size itself
              child: FadeTransition(
                opacity: _fadeController,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate optimal columns and base width based on available space
                    final availableWidth = constraints.maxWidth;
                    
                    // Optimize for tablet: use more columns if space allows
                    double baseWidth;
                    int minCols;
                    int maxCols;
                    
                    // Calculate optimal columns and base width based on available space
                    // For narrow devices column (320-360px), use 2 columns
                    // For wider spaces, use 3-4 columns
                    if (availableWidth >= 400) {
                      // Wide space: 3-4 columns
                      minCols = 3;
                      maxCols = 4;
                      baseWidth = math.max(180.0, (availableWidth - 36) / 4); // Account for spacing
                    } else if (availableWidth >= 300) {
                      // Medium space: 2-3 columns
                      minCols = 2;
                      maxCols = 3;
                      baseWidth = math.max(160.0, (availableWidth - 24) / 3); // Account for spacing
                    } else {
                      // Narrow space: 2 columns
                      minCols = 2;
                      maxCols = 2;
                      baseWidth = math.max(140.0, (availableWidth - 12) / 2); // Account for spacing
                    }
                    
                    // Use DynamicMasonryGrid for dynamic, scrollable layout
                    return DynamicMasonryGrid(
                      cards: deviceCards,
                      spacing: 12.0,
                      itemBaseWidth: baseWidth,
                      minColumns: minCols,
                      maxColumns: maxCols,
                      isEditMode: dashboardVM.isEditMode,
                      animation: _fadeController,
                      viewModel: dashboardVM,
                      onCardTap: (card) => dashboardVM.handleCardTap(card, context),
                      onCardLongPress: dashboardVM.isEditMode
                          ? null
                          : dashboardVM.toggleEditMode,
                      onCardDelete: (cardId) => dashboardVM.deleteCard(cardId),
                      onCardResize: (cardId, newSize) =>
                          dashboardVM.resizeCard(cardId, newSize),
                      onCardDataUpdate: (cardId, newData) =>
                          dashboardVM.updateCardData(cardId, newData),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openSetupPage(BuildContext context, ModuleSetupContent content) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ModuleSetupPage(content: content)),
    );
  }

  ModuleSetupContent _deviceSetupContent() {
    final l10n = AppLocalizations.of(context)!;
    return ModuleSetupContent(
      icon: Icons.dashboard_customize_rounded,
      title: l10n.deviceSetup,
      subtitle: l10n.buildPersonalizedControlBoard,
      description:
          'Populate the dashboard with the cards you reach for the most. Each card adapts to the selected room and learns your routines over time.',
      highlights: const [
        'Drag & drop layout',
        'Room-aware presets',
        'Inline automation triggers',
      ],
      steps: const [
        'Choose the device category that matches what you want at hand (lighting, curtains, media and more).',
        'Assign it to the active room or switch rooms from the top navigation to target other spaces.',
        'Fine-tune behaviour later in edit mode or by tapping the card for contextual controls.',
      ],
      primaryActionLabel: 'Add a device card',
      onPrimaryAction: (ctx) => _handleAddDeviceAction(ctx),
    );
  }

  ModuleSetupContent _lightingSetupContent() {
    final l10n = AppLocalizations.of(context)!;
    return ModuleSetupContent(
      icon: Icons.light_mode_rounded,
      title: l10n.lightingSetup,
      subtitle: l10n.paintEverySceneWithLight,
      description:
          'Pair your smart strips or bulbs to unlock the color wheel, presets, rhythms and sunrise fades directly from the dashboard.',
      highlights: const [
        'Full-spectrum color wheel',
        'Scene choreography',
        'Adaptive brightness curves',
      ],
      steps: const [
        'Power on the lighting controller and ensure it enters pairing mode (hold the pairing button for five seconds).',
        'Confirm the indicator LED pulses to signal discovery mode.',
        'Return to the dashboard and tap “Detect lights” inside the lighting panel to finalise the link.',
      ],
      primaryActionLabel: 'Start pairing walkthrough',
      onPrimaryAction: (ctx) async {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text(
              'Pairing wizard coming soon. In the meantime you can add a lighting card from device setup.',
            ),
            backgroundColor: Theme.of(ctx).colorScheme.primary,
          ),
        );
      },
    );
  }

  ModuleSetupContent _thermostatSetupContent() {
    final l10n = AppLocalizations.of(context)!;
    return ModuleSetupContent(
      icon: Icons.thermostat_auto_rounded,
      title: l10n.thermostatSetup,
      subtitle: l10n.stabilizeComfortWithPrecision,
      description:
          'Guide the homeowner through connecting the thermostat bridge so the control panel can read temperatures and modes in real time.',
      highlights: const [
        'Smart scheduling',
        'Mode automation',
        'Energy insights',
      ],
      steps: const [
        'Power cycle the thermostat hub and make sure Wi‑Fi credentials are updated.',
        'Press the pair button for three seconds until the display shows “discoverable”.',
        'Keep the thermostat near the main gateway while the dashboard syncs the device.',
      ],
      primaryActionLabel: 'Review pairing checklist',
      onPrimaryAction: (ctx) async {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text(
              'Thermostat pairing flow will arrive in the next release.',
            ),
            backgroundColor: Colors.deepOrangeAccent.shade200,
          ),
        );
      },
    );
  }

  ModuleSetupContent _cameraSetupContent() {
    final l10n = AppLocalizations.of(context)!;
    return ModuleSetupContent(
      icon: Icons.videocam_outlined,
      title: l10n.cameraSetup,
      subtitle: l10n.keepEyeOnEveryCorner,
      description:
          'Link your security cameras to stream live snapshots, toggle recording and swap monitored rooms on demand.',
      highlights: const [
        'Live timeline snapshots',
        'Instant room switching',
        'Recording toggles',
      ],
      steps: const [
        'Place the camera and confirm its network LED indicates a stable connection.',
        'Add the camera to the smart home gateway or vendor app and name the location.',
        'Return here and add a camera tile to pin the feed to your home dashboard.',
      ],
      primaryActionLabel: 'Add a camera tile',
      onPrimaryAction: (ctx) =>
          _handleAddDeviceAction(ctx, preselectedType: CardType.camera),
    );
  }

  Future<void> _handleAddDeviceAction(
    BuildContext context, {
    CardType? preselectedType,
  }) async {
    print('🔵 [DASHBOARD] _handleAddDeviceAction called');
    
    // Request PIN verification before adding device
    print('🟢 [DASHBOARD] Requesting PIN verification');
    if (!context.mounted) return;
    
    final verified = await PinProtection.requirePinVerification(
      context,
      title: AppLocalizations.of(context)!.pinRequired,
      subtitle: 'PIN is required to add a device',
    );
    
    print('🟢 [DASHBOARD] PIN verification result: $verified');
    if (!context.mounted) return;
    
    if (!verified) {
      print('🟡 [DASHBOARD] PIN verification failed or cancelled, returning');
      return;
    }
    
    print('🟢 [DASHBOARD] PIN verified, proceeding with add device');
    if (!context.mounted) return;
    
    final dashboardVM = context.read<DashboardViewModel>();
    final roomVM = context.read<RoomViewModel>();
    final rooms = roomVM.rooms;

    if (rooms.isEmpty) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addRoomBeforeCards),
        ),
      );
      return;
    }

    final selectedRoom = roomVM.selectedRoom ?? rooms.first;

    CardType? type = preselectedType;
    if (type == null) {
      type = await _showDeviceTypeSheet(context);
    }

    if (type == null) return;

    if (!context.mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Adding ${_cardTypeLabel(type)}...'),
          ],
        ),
        backgroundColor: AppTheme.getPrimaryBlue(isDark),
        duration: const Duration(seconds: 2),
      ),
    );

    // Add device to room (this creates the device and syncs the dashboard)
    final success = await dashboardVM.addDeviceToRoom(
      type,
      selectedRoom.id,
      selectedRoom.name,
    );

    if (!context.mounted) return;

    if (success) {
      // Refresh DeviceViewModel to pick up the new device
      final deviceVM = context.read<DeviceViewModel>();
      await deviceVM.loadDevices();
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_cardTypeLabel(type)} added to ${selectedRoom.name}.',
          ),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add ${_cardTypeLabel(type)}. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<CardType?> _showDeviceTypeSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardVM = context.read<DashboardViewModel>();
    
    // Get already added device types in the current room
    final roomVM = context.read<RoomViewModel>();
    final currentRoom = roomVM.selectedRoom;
    final addedDeviceTypes = currentRoom != null
        ? dashboardVM.cards
            .where((card) => card.roomId == currentRoom.id)
            .map((card) => card.type)
            .toSet()
        : <CardType>{};
    
    // Filter out already added devices
    final options = _deviceTemplates
        .where((template) => !addedDeviceTypes.contains(template.type))
        .toList();
    
    // If no options available, show a message
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All device types have been added to this room.'),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
        ),
      );
      return null;
    }

    return showModalBottomSheet<CardType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.getSectionGradient(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(
              color: AppTheme.getSectionBorderColor(
                isDark,
              ).withOpacity(isDark ? 0.7 : 0.55),
              width: 1.2,
            ),
            boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getSecondaryGray(
                                isDark,
                              ).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.getPrimaryButtonGradient(
                                  isDark,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppTheme.getSectionShadows(
                                  isDark,
                                  elevated: true,
                                ),
                              ),
                              child: Icon(
                                Icons.devices_other_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Device Card',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getTextColor1(isDark),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Choose a device type to add',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.getSecondaryGray(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return _buildDeviceOptionTile(
                        context: sheetContext,
                        option: option,
                        isDark: isDark,
                        onTap: () =>
                            Navigator.of(sheetContext).pop(option.type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceOptionTile({
    required BuildContext context,
    required _DeviceTemplateData option,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withOpacity(isDark ? 0.15 : 0.12),
                option.color.withOpacity(isDark ? 0.08 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: option.color.withOpacity(isDark ? 0.3 : 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: option.color.withOpacity(isDark ? 0.12 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      option.color.withOpacity(isDark ? 0.4 : 0.3),
                      option.color.withOpacity(isDark ? 0.25 : 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: option.color.withOpacity(isDark ? 0.25 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(option.icon, color: option.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppTheme.getSecondaryGray(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(isDark ? 0.2 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: option.color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cardTypeLabel(CardType type) {
    switch (type) {
      case CardType.light:
        return 'Lighting';
      case CardType.curtain:
        return 'Curtain';
      case CardType.security:
        return 'Security';
      case CardType.music:
        return 'Music';
      case CardType.tv:
        return 'TV';
      case CardType.fan:
        return 'Fan';
      case CardType.camera:
        return 'Camera';
      case CardType.door:
        return 'Smart Lock';
      case CardType.window:
        return 'Window';
      case CardType.airConditioner:
        return 'Air Conditioner';
      case CardType.humidifier:
        return 'Humidifier';
      case CardType.thermostat:
        return 'Thermostat';
      case CardType.elevator:
        return 'Elevator';
      case CardType.doorLock:
        return 'Intercom';
      case CardType.iphone:
        return 'آیفون درب';
      case CardType.usbSerial:
        return 'USB Serial';
    }
  }

  List<_DeviceTemplateData> get _deviceTemplates => const [
    _DeviceTemplateData(
      type: CardType.light,
      title: 'Ambient light',
      description: 'Color, brightness and presets at a glance.',
      icon: Icons.lightbulb_rounded,
      color: Color(0xFFFFB74D),
    ),
    _DeviceTemplateData(
      type: CardType.thermostat,
      title: 'Thermostat',
      description: 'Control temperature, heating and cooling modes.',
      icon: Icons.thermostat_rounded,
      color: Color(0xFF30D158),
    ),
    _DeviceTemplateData(
      type: CardType.curtain,
      title: 'Curtains',
      description: 'Open, close and set intermediate positions.',
      icon: Icons.curtains_rounded,
      color: Color(0xFF80CBC4),
    ),
    _DeviceTemplateData(
      type: CardType.tv,
      title: 'Media display',
      description: 'Toggle, switch channels and keep track of inputs.',
      icon: Icons.tv_rounded,
      color: Color(0xFF90CAF9),
    ),
    _DeviceTemplateData(
      type: CardType.music,
      title: 'Music player',
      description: 'Play, pause and adjust volume instantly.',
      icon: Icons.music_note_rounded,
      color: Color(0xFF9575CD),
    ),
    _DeviceTemplateData(
      type: CardType.fan,
      title: 'Ceiling fan',
      description: 'Control speed and oscillation in one tap.',
      icon: Icons.toys_rounded,
      color: Color(0xFF4FC3F7),
    ),
    _DeviceTemplateData(
      type: CardType.security,
      title: 'Security',
      description: 'Arm, disarm and monitor alarm status.',
      icon: Icons.shield_rounded,
      color: Color(0xFFEF9A9A),
    ),
    _DeviceTemplateData(
      type: CardType.camera,
      title: 'Camera',
      description: 'Live snapshots with recording controls.',
      icon: Icons.videocam_rounded,
      color: Color(0xFF81D4FA),
    ),
    _DeviceTemplateData(
      type: CardType.elevator,
      title: 'Elevator',
      description: 'Call elevator and select floor destination.',
      icon: Icons.elevator_rounded,
      color: Color(0xFF5E5CE6),
    ),
    _DeviceTemplateData(
      type: CardType.doorLock,
      title: 'Door Lock / Intercom',
      description: 'Lock, unlock and answer intercom calls.',
      icon: Icons.door_front_door_rounded,
      color: Color(0xFFFFD60A),
    ),
    _DeviceTemplateData(
      type: CardType.airConditioner,
      title: 'Air Conditioner',
      description: 'Control cooling, heating and fan speed.',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF64D2FF),
    ),
    _DeviceTemplateData(
      type: CardType.door,
      title: 'Smart Lock',
      description: 'Lock and unlock doors securely.',
      icon: Icons.lock_rounded,
      color: Color(0xFFFF9F0A),
    ),
  ];


  Widget _buildMainMenu() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.getCardBackground(isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.getAvatarBackground(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person_rounded,
                    color: AppTheme.getSecondaryGray(isDark),
                    size: 16,
                  );
                },
              ),
            ),
          ),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            _buildMenuHeader(isDark),
            PopupMenuDivider(color: AppTheme.getDividerColor(isDark)),
            _buildMenuOption(
              'profile',
              Icons.person_outline_rounded,
              'Profile',
              isDark,
            ),
            _buildMenuOption(
              'settings',
              Icons.settings_outlined,
              'Settings',
              isDark,
            ),
            _buildMenuOption(
              'theme',
              Icons.dark_mode_outlined,
              'Theme',
              isDark,
            ),
            PopupMenuDivider(color: AppTheme.getDividerColor(isDark)),
            _buildMenuOption(
              'logout',
              Icons.logout_rounded,
              'Logout',
              isDark,
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuHeader(bool isDark) {
    return PopupMenuItem<String>(
      enabled: false,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 36,
              height: 36,
              color: AppTheme.getAvatarBackground(isDark),
              child: Image.network(
                'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person_rounded,
                  color: AppTheme.getSecondaryGray(isDark),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
              Text(
                'john.doe@example.com',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.getSecondaryGray(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuOption(
    String value,
    IconData icon,
    String title,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDestructive
                ? ThemeColors.errorRed
                : AppTheme.getPrimaryBlue(isDark),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDestructive
                  ? ThemeColors.errorRed
                  : AppTheme.getTextColor1(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'theme':
        _toggleTheme();
        break;
      case 'about':
        _showAboutDialog();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _toggleTheme() {
    final currentBrightness = Theme.of(context).brightness;
    final isDark = currentBrightness == Brightness.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    widget.onThemeChanged?.call(newMode);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Home Dashboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.secondaryGrayLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: ThemeColors.primaryBlueLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ThemeColors.secondaryGrayLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }

  /// Build centered empty state with Add Device and Add Scenario buttons
  Widget _buildCenteredEmptyState(
    BuildContext context,
    bool isDark,
    DashboardViewModel dashboardVM,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Device Button
            Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getPrimaryBlue(isDark).withOpacity(0.15),
                    AppTheme.getPrimaryBlue(isDark).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getPrimaryButtonGradient(isDark),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.devices_other_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noDevicesYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addDevicesToDashboard,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _handleAddDeviceAction(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ).copyWith(
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.getPrimaryButtonGradient(isDark),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.addDevice,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Add Scenario Button
            Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getAccentAmber(isDark).withOpacity(0.15),
                    AppTheme.getAccentRose(isDark).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.getAccentAmber(isDark).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getAccentAmber(isDark).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.getAccentAmber(isDark),
                          AppTheme.getAccentRose(isDark),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getAccentAmber(isDark).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noScenariosYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.automateRoutine,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final roomVM = context.read<RoomViewModel>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScenarioSetupFlow(
                            roomId: roomVM.selectedRoomId,
                          ),
                        ),
                      ).then((result) {
                        if (result == true && context.mounted) {
                          // Refresh dashboard
                          dashboardVM.refresh();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ).copyWith(
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.getAccentAmber(isDark),
                            AppTheme.getAccentRose(isDark),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getAccentAmber(isDark).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.createScenario,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
