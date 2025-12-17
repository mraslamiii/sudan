import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../domain/entities/floor_entity.dart';
import '../viewmodels/floor_viewmodel.dart';
import '../widgets/floor/floor_card.dart';
import '../widgets/floor/add_floor_dialog.dart';
import '../widgets/floor/settings_panel.dart';
import '../widgets/common/premium_empty_state.dart';
import '../widgets/dashboard/dashboard_background.dart';
import 'advanced_dashboard_view.dart';

/// Floor Selection View
/// Luxurious and minimal floor selection page (PS5/iOS 26 style)
/// Displays all floors and allows navigation to dashboard
class FloorSelectionView extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final String? selectedFloorId;

  const FloorSelectionView({
    super.key,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.selectedFloorId,
  });

  @override
  State<FloorSelectionView> createState() => _FloorSelectionViewState();
}

class _FloorSelectionViewState extends State<FloorSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

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

    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      
      // Set selected floor if provided
      if (widget.selectedFloorId != null) {
        final floorVM = context.read<FloorViewModel>();
        floorVM.selectFloor(widget.selectedFloorId!);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleFloorTap(FloorEntity floor) {
    // Navigate to dashboard with selected floor
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdvancedDashboardView(
          onThemeChanged: widget.onThemeChanged,
          selectedFloorId: floor.id,
        ),
      ),
    );
  }

  void _handleAddFloor() {
    AddFloorDialog.show(
      context,
      (name, icon) async {
        final viewModel = context.read<FloorViewModel>();
        await viewModel.createFloor(name: name, icon: icon);
        if (mounted && viewModel.hasError) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? l10n.failedToCreateFloor),
              backgroundColor: ThemeColors.errorRed,
            ),
          );
        }
      },
    );
  }

  void _handleDeleteFloor(FloorEntity floor) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.getSectionGradient(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(isDark ? 0.7 : 0.55),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.deleteFloor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextColor1(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.deleteFloorConfirmWithName(floor.name),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSecondaryGray(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: AppTheme.getSecondaryGray(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final viewModel = context.read<FloorViewModel>();
                        await viewModel.deleteFloor(floor.id);
                        if (mounted && viewModel.hasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.errorMessage ?? l10n.failedToCreateFloor,
                              ),
                              backgroundColor: ThemeColors.errorRed,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return Consumer<FloorViewModel>(
      builder: (context, viewModel, _) {
        // Show error in snackbar if there's an error
        if (viewModel.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage ?? AppLocalizations.of(context)!.anErrorOccurred),
                  backgroundColor: ThemeColors.errorRed,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Clear error after showing
              viewModel.clearError();
            }
          });
        }

        if (viewModel.isLoading && viewModel.floors.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.getPrimaryBlue(isDark),
            ),
          );
        }

        final floors = viewModel.floors;

        return Column(
          children: [
            // Header
            _buildHeader(isDark),
            const SizedBox(height: 32),
            // Content
            Expanded(
              child: floors.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildFloorsGrid(floors, viewModel, isDark),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: _slideController,
        child: Row(
          children: [
            // App Title with enhanced design
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryButtonGradient(isDark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.home_rounded, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sudan',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor1(isDark),
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
                Builder(
                  builder: (context) => Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getSecondaryGray(isDark),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Settings Button
            _buildSettingsButton(isDark),
            const SizedBox(width: 12),
            // Add Floor Button
            _buildAddButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(bool isDark) {
    return GestureDetector(
      onTap: () => SettingsPanel.show(
        context,
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ]
                : [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.4 : 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.settings_rounded,
          color: AppTheme.getTextColor1(isDark),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: _handleAddFloor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.getPrimaryButtonGradient(isDark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!.addFloor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: PremiumEmptyState(
        icon: Icons.layers_rounded,
        title: l10n.noFloorsYet,
        message: l10n.createNewFloor,
        highlights: [
          l10n.organizeByFloor,
          l10n.multipleRoomsPerFloor,
          l10n.easyNavigation,
        ],
        primaryActionLabel: l10n.addYourFirstFloor,
        onPrimaryAction: _handleAddFloor,
        accentColor: AppTheme.getPrimaryBlue(isDark),
      ),
    );
  }

  Widget _buildFloorsGrid(
    List<FloorEntity> floors,
    FloorViewModel viewModel,
    bool isDark,
  ) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate grid layout based on available space
          final crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : constraints.maxWidth > 800
                  ? 3
                  : 2;
          final spacing = 20.0;
          final itemWidth = (constraints.maxWidth -
                  spacing * (crossAxisCount - 1)) /
              crossAxisCount;
          final itemHeight = itemWidth * 0.75; // 4:3 aspect ratio

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: itemWidth / itemHeight,
            ),
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: floors.length,
            itemBuilder: (context, index) {
              final floor = floors[index];
              return AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeController.value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - _fadeController.value),
                      ),
                      child: child,
                    ),
                  );
                },
                child: FloorCard(
                  floor: floor,
                  isSelected: viewModel.selectedFloorId == floor.id,
                  onTap: () => _handleFloorTap(floor),
                  onLongPress: () => _handleDeleteFloor(floor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

