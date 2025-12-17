import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/di/injection_container.dart' as di;
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/scenario_setup_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/scenario_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/step_indicator.dart';
import 'package:sudan/presentation/widgets/setup/step_navigation_bar.dart';
import 'package:sudan/presentation/widgets/setup/loading_overlay.dart';
import 'package:sudan/domain/entities/scenario_entity.dart';
import 'steps/scenario_basic_info_step.dart';
import 'steps/scenario_device_config_step.dart';
import 'steps/scenario_app_settings_step.dart';
import 'steps/scenario_review_step.dart';

/// Scenario Setup Flow
/// Main page for step-by-step scenario creation
/// Optimized for tablet landscape (11-inch)
class ScenarioSetupFlow extends StatelessWidget {
  final ScenarioEntity? existingScenario;
  final String? roomId;

  const ScenarioSetupFlow({
    super.key,
    this.existingScenario,
    this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    return ChangeNotifierProvider(
      create: (_) {
        print('🔵 [SCENARIO_FLOW] Creating ScenarioSetupViewModel');
        print('   - roomId: $roomId');
        print('   - existingScenario: ${existingScenario?.id ?? "null"}');
        final viewModel = di.getIt<ScenarioSetupViewModel>();
        // Initialize without notifying listeners during build
        viewModel.initializeWithData(roomId, existingScenario);
        // Notify listeners after the first frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.notifyAfterInitialization();
          print('🔵 [SCENARIO_FLOW] ViewModel initialized. Final roomId: ${viewModel.roomId}');
        });
        print('🔵 [SCENARIO_FLOW] ViewModel created. Initialization deferred.');
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        resizeToAvoidBottomInset: false,
        body: Consumer<ScenarioSetupViewModel>(
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
                    message: AppLocalizations.of(context)!.savingScenario,
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
                                viewModel.errorMessage ??
                                    AppLocalizations.of(context)!.anErrorOccurred,
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
    ScenarioSetupViewModel viewModel,
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
                tooltip: AppLocalizations.of(context)!.close,
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
                            child: Icon(
                              existingScenario != null
                                  ? Icons.edit_rounded
                                  : Icons.auto_awesome_rounded,
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
                                  existingScenario != null
                                      ? AppLocalizations.of(context)!.editScenario
                                      : AppLocalizations.of(context)!.createNewScenario,
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
                        isLoading: viewModel.isLoading,
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
    ScenarioSetupViewModel viewModel,
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
                  existingScenario != null
                      ? AppLocalizations.of(context)!.editScenario
                      : AppLocalizations.of(context)!.createScenarioTitle,
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
          isLoading: viewModel.isLoading,
          onBack: () => viewModel.previousStep(),
          onNext: () => viewModel.nextStep(),
          onSave: () => _handleSave(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    ScenarioSetupViewModel viewModel,
  ) {
    switch (viewModel.currentStep) {
      case 0:
        return const ScenarioBasicInfoStep();
      case 1:
        return const ScenarioDeviceConfigStep();
      case 2:
        return const ScenarioAppSettingsStep();
      case 3:
        return const ScenarioReviewStep();
      default:
        return const ScenarioBasicInfoStep();
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    ScenarioSetupViewModel viewModel,
  ) async {
    print('🔵 [SCENARIO_FLOW] _handleSave called');
    print('🔵 [SCENARIO_FLOW] existingScenario: ${existingScenario?.id ?? "null"}');
    
    final scenarioVM = context.read<ScenarioViewModel>();
    final dashboardVM = context.read<DashboardViewModel>();
    final scenario = viewModel.createScenarioEntity(
      existingId: existingScenario?.id,
    );

    print('🔵 [SCENARIO_FLOW] Created scenario entity:');
    print('   - ID: ${scenario.id}');
    print('   - Name: ${scenario.name}');
    print('   - RoomId: ${scenario.roomId}');
    print('   - Actions count: ${scenario.actions.length}');

    try {
      if (existingScenario != null) {
        print('🔵 [SCENARIO_FLOW] Updating existing scenario');
        await scenarioVM.updateScenario(scenario);
        print('🔵 [SCENARIO_FLOW] Scenario updated successfully');
      } else {
        print('🔵 [SCENARIO_FLOW] Creating new scenario');
        await scenarioVM.createScenario(scenario);
        print('🔵 [SCENARIO_FLOW] Scenario created successfully');
        // Add scenarios section to layout when first scenario is created
        print('🔵 [SCENARIO_FLOW] Adding scenarios section to dashboard');
        await dashboardVM.addScenariosSectionIfNeeded();
        print('🔵 [SCENARIO_FLOW] Scenarios section added');
      }

      if (!context.mounted) return;

      // Show success message
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingScenario != null
                ? l10n.scenarioUpdated(scenario.name)
                : l10n.scenarioCreated(scenario.name),
          ),
          backgroundColor: AppTheme.getPrimaryBlue(isDark),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      // Error is already shown in the overlay
    }
  }
}

