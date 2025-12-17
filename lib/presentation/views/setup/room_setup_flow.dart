import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/di/injection_container.dart' as di;
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/domain/entities/room_entity.dart';
import 'package:sudan/presentation/viewmodels/room_setup_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/room_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/device_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/floor_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/step_indicator.dart';
import 'package:sudan/presentation/widgets/setup/step_navigation_bar.dart';
import 'package:sudan/presentation/widgets/setup/loading_overlay.dart';
import 'steps/room_basic_info_step.dart';
import 'steps/room_icon_selection_step.dart';
import 'steps/room_device_selection_step.dart';
import 'steps/room_review_step.dart';

/// Room Setup Flow
/// Main page for step-by-step room creation
/// Optimized for tablet landscape (11-inch)
class RoomSetupFlow extends StatefulWidget {
  final String? floorId;

  const RoomSetupFlow({
    super.key,
    this.floorId,
  });

  @override
  State<RoomSetupFlow> createState() => _RoomSetupFlowState();
}

class _RoomSetupFlowState extends State<RoomSetupFlow> {
  bool _isSaving = false;
  Completer<void>? _saveLock;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    return ChangeNotifierProvider(
      create: (ctx) {
        final viewModel = di.getIt<RoomSetupViewModel>();
        // Prefer explicit floorId from caller; otherwise fallback to currently selected floor
        final fallbackFloorId = widget.floorId ??
            ctx.read<FloorViewModel?>()?.selectedFloorId;
        if (fallbackFloorId != null) {
          viewModel.setFloorId(fallbackFloorId);
        }
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        resizeToAvoidBottomInset: false, // Prevent layout shift when keyboard appears
        body: Consumer<RoomSetupViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                // Main Content
                    SafeArea(
                  child: isTabletLandscape
                      ? _buildTabletLayout(context, viewModel, isDark)
                      : _buildMobileLayout(context, viewModel, isDark),
                ),

                // Loading Overlay
                if (viewModel.isLoading)
                  LoadingOverlay(
                    message: AppLocalizations.of(context)!.savingRoom,
                  ),

                // Error SnackBar
                if (viewModel.hasError)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage ?? AppLocalizations.of(context)!.anErrorOccurred,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              tooltip: AppLocalizations.of(context)!.close,
                              onPressed: () => viewModel.clearError(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    RoomSetupViewModel viewModel,
    bool isDark,
  ) {
    return Row(
      children: [
        // Left Sidebar - Step Indicator & Close Button
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppTheme.getTextColor1(isDark),
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: StepIndicator(
                      currentStep: viewModel.currentStep,
                      totalSteps: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content Area - Centered Card
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
                maxHeight: 800,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: AppTheme.getSectionGradient(isDark),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.getSectionBorderColor(isDark)
                        .withOpacity(isDark ? 0.7 : 0.55),
                    width: 1.2,
                  ),
                  boxShadow: AppTheme.getSectionShadows(isDark),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.getSectionBorderColor(isDark)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
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
                              Icons.add_home_rounded,
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
                                  AppLocalizations.of(context)!.createNewRoom,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.getTextColor1(isDark),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppLocalizations.of(context)!.stepOf} ${viewModel.currentStep + 1} ${AppLocalizations.of(context)!.ofText} 4',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.getSecondaryGray(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step Content - Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: _buildStepContent(context, viewModel),
                      ),
                    ),

                    // Navigation Bar
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.getSectionBorderColor(isDark)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: StepNavigationBar(
                        canGoBack: viewModel.canGoBack,
                        canGoNext: viewModel.canGoNext,
                        isLastStep: viewModel.isLastStep,
                        isLoading: viewModel.isLoading || _isSaving,
                        onBack: () => viewModel.previousStep(),
                        onNext: () => viewModel.nextStep(),
                        onSave: () => _handleSave(context, viewModel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right Spacer
        const SizedBox(width: 120),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    RoomSetupViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      children: [
        // AppBar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppTheme.getTextColor1(isDark),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.createRoom,
                  style: TextStyle(
                    color: AppTheme.getTextColor1(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance for close button
            ],
          ),
        ),

        // Step Indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: StepIndicator(
            currentStep: viewModel.currentStep,
            totalSteps: 4,
          ),
        ),

        // Current Step Content - Scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildStepContent(context, viewModel),
          ),
        ),

        // Navigation Bar
        StepNavigationBar(
          canGoBack: viewModel.canGoBack,
          canGoNext: viewModel.canGoNext,
          isLastStep: viewModel.isLastStep,
          isLoading: viewModel.isLoading || _isSaving,
          onBack: () => viewModel.previousStep(),
          onNext: () => viewModel.nextStep(),
          onSave: () => _handleSave(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    RoomSetupViewModel viewModel,
  ) {
    switch (viewModel.currentStep) {
      case 0:
        return const RoomBasicInfoStep();
      case 1:
        return const RoomIconSelectionStep();
      case 2:
        return const RoomDeviceSelectionStep();
      case 3:
        return const RoomReviewStep();
      default:
        return const RoomBasicInfoStep();
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    RoomSetupViewModel viewModel,
  ) async {
    // Wait for any ongoing save operation to complete
    if (_saveLock != null) {
      await _saveLock!.future;
      return;
    }

    // Prevent multiple simultaneous saves
    if (_isSaving) {
      return;
    }

    // Create a new lock for this operation
    _saveLock = Completer<void>();
    _isSaving = true;
    
    if (mounted) {
      setState(() {});
    }

    try {
      print('🔵 [ROOM_FLOW] Calling saveRoom...');
      print('   - Room Name: ${viewModel.roomName}');
      print('   - Floor ID: ${viewModel.floorId}');
      final success = await viewModel.saveRoom();
      print('🔵 [ROOM_FLOW] saveRoom returned: $success');

      if (!context.mounted) {
        print('🔵 [ROOM_FLOW] Context not mounted, returning');
        return;
      }

      if (success) {
        print('🔵 [ROOM_FLOW] Room saved successfully, refreshing viewmodels...');
        // Refresh viewmodels
        final roomVM = context.read<RoomViewModel>();
        final deviceVM = context.read<DeviceViewModel>();
        final dashboardVM = context.read<DashboardViewModel>();
        final floorId = viewModel.floorId;
        
        print('🔵 [ROOM_FLOW] Loading rooms for floor: $floorId');
        await roomVM.loadRooms(floorId: floorId);
        print('🔵 [ROOM_FLOW] Rooms loaded. Count: ${roomVM.rooms.length}');
        for (var room in roomVM.rooms) {
          print('   - ${room.name} (ID: ${room.id}, FloorId: ${room.floorId})');
        }
        
        await deviceVM.refresh();
        print('🔵 [ROOM_FLOW] Devices refreshed');
        
        // Get the created room
        RoomEntity createdRoom;
        try {
          print('🔵 [ROOM_FLOW] Looking for room with name: ${viewModel.roomName}');
          createdRoom = roomVM.rooms.firstWhere(
            (r) => r.name == viewModel.roomName,
          );
          print('🔵 [ROOM_FLOW] Found created room: ${createdRoom.name} (ID: ${createdRoom.id})');
        } catch (e) {
          print('🔵 [ROOM_FLOW] Could not find room by name, using first room');
          if (roomVM.rooms.isNotEmpty) {
            createdRoom = roomVM.rooms.first;
            print('🔵 [ROOM_FLOW] Using first room: ${createdRoom.name} (ID: ${createdRoom.id})');
          } else {
            print('🔴 [ROOM_FLOW] ERROR: No rooms found!');
            throw Exception('Room not found');
          }
        }
        
        // Select the newly created room
        print('🔵 [ROOM_FLOW] Selecting room: ${createdRoom.id}');
        await roomVM.selectRoom(createdRoom.id);
        await deviceVM.selectRoom(createdRoom.id);
        print('🔵 [ROOM_FLOW] Room selected');
        
        // Reload dashboard for the selected room
        // This will automatically sync cards with devices via syncCardsWithDevices
        print('🔵 [ROOM_FLOW] Loading dashboard for room: ${createdRoom.id}');
        await dashboardVM.loadDashboard(roomId: createdRoom.id);
        print('🔵 [ROOM_FLOW] Dashboard loaded');

        if (!context.mounted) return;

        // Show success message
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.roomCreatedSuccessfully(viewModel.roomName ?? ''),
            ),
            backgroundColor: AppTheme.getPrimaryBlue(isDark),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.of(context).pop(true);
      } else {
        // Error is already shown in the overlay
      }
    } finally {
      // Release the lock
      _isSaving = false;
      _saveLock?.complete();
      _saveLock = null;
      
      if (mounted) {
        setState(() {});
      }
    }
  }
}

