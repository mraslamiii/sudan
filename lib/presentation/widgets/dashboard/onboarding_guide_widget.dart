import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../viewmodels/room_viewmodel.dart';
import '../../viewmodels/scenario_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../views/setup/room_setup_flow.dart';
import '../../views/setup/scenario_setup_flow.dart';
import '../../../core/utils/pin_protection.dart';

/// Onboarding Guide Widget
/// Displays a step-by-step guide for setting up the smart home
/// Shows completion status for each step with action buttons
class OnboardingGuideWidget extends StatefulWidget {
  final List<DashboardCardModel> deviceCards;

  const OnboardingGuideWidget({
    super.key,
    required this.deviceCards,
  });

  @override
  State<OnboardingGuideWidget> createState() => _OnboardingGuideWidgetState();
}

class _OnboardingGuideWidgetState extends State<OnboardingGuideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create fade animations for each step
    _fadeAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.3 + index * 0.2,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final roomVM = context.watch<RoomViewModel>();
    final scenarioVM = context.watch<ScenarioViewModel>();
    final dashboardVM = context.watch<DashboardViewModel>();
    final currentRoomId = roomVM.selectedRoomId;

    // Check completion status for each step
    final hasRooms = roomVM.rooms.isNotEmpty;
    final hasDevices = widget.deviceCards.isNotEmpty;
    final hasScenarios = currentRoomId != null
        ? scenarioVM.scenarios.any((s) => s.roomId == currentRoomId)
        : false;
    final hasCustomized = dashboardVM.isEditMode; // Optional check

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getSectionBackground(isDark),
                  AppTheme.getSectionBackground(isDark).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.getPrimaryBlue(isDark),
                            AppTheme.getPrimaryBlue(isDark).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryBlue(isDark)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.onboardingTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.getTextColor1(isDark),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.onboardingSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Steps
                _buildStep(
                  context: context,
                  isDark: isDark,
                  l10n: l10n,
                  index: 0,
                  animation: _fadeAnimations[0],
                  icon: Icons.home_rounded,
                  iconColor: AppTheme.getPrimaryBlue(isDark),
                  title: l10n.stepCreateRoom,
                  description: l10n.stepCreateRoomDescription,
                  isCompleted: hasRooms,
                  onAction: () async {
                    // Check PIN protection
                    final verified = await PinProtection.requirePinVerification(
                      context,
                      title: l10n.pinRequired,
                      subtitle: l10n.pinRequiredForAction,
                    );

                    if (!verified) {
                      return; // User cancelled or PIN verification failed
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RoomSetupFlow(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _buildStep(
                  context: context,
                  isDark: isDark,
                  l10n: l10n,
                  index: 1,
                  animation: _fadeAnimations[1],
                  icon: Icons.devices_other_rounded,
                  iconColor: AppTheme.getAccentTeal(isDark),
                  title: l10n.stepAddDevice,
                  description: l10n.stepAddDeviceDescription,
                  isCompleted: hasDevices,
                  onAction: () async {
                    // Check PIN protection
                    final verified = await PinProtection.requirePinVerification(
                      context,
                      title: l10n.pinRequired,
                      subtitle: l10n.pinRequiredForAction,
                    );

                    if (!verified) {
                      return; // User cancelled or PIN verification failed
                    }

                    // Navigate to room setup which includes device selection
                    if (!hasRooms) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RoomSetupFlow(),
                        ),
                      );
                    } else {
                      // Navigate to room setup to add devices
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RoomSetupFlow(),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                _buildStep(
                  context: context,
                  isDark: isDark,
                  l10n: l10n,
                  index: 2,
                  animation: _fadeAnimations[2],
                  icon: Icons.auto_awesome_rounded,
                  iconColor: AppTheme.getAccentAmber(isDark),
                  title: l10n.stepCreateScenario,
                  description: l10n.stepCreateScenarioDescription,
                  isCompleted: hasScenarios,
                  onAction: () {
                    final roomVM = context.read<RoomViewModel>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ScenarioSetupFlow(
                          roomId: roomVM.selectedRoomId,
                        ),
                      ),
                    ).then((result) {
                      if (result == true && context.mounted) {
                        final dashboardVM = context.read<DashboardViewModel>();
                        dashboardVM.refresh();
                      }
                    });
                  },
                ),

                const SizedBox(height: 16),

                _buildStep(
                  context: context,
                  isDark: isDark,
                  l10n: l10n,
                  index: 3,
                  animation: _fadeAnimations[3],
                  icon: Icons.dashboard_customize_rounded,
                  iconColor: AppTheme.getAccentRose(isDark),
                  title: l10n.stepCustomizeDashboard,
                  description: l10n.stepCustomizeDashboardDescription,
                  isCompleted: hasCustomized,
                  onAction: () {
                    final dashboardVM = context.read<DashboardViewModel>();
                    dashboardVM.setEditMode(true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required bool isDark,
    required AppLocalizations l10n,
    required int index,
    required Animation<double> animation,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isCompleted,
    required VoidCallback onAction,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.2, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.2,
              0.3 + index * 0.2,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? iconColor.withOpacity(isDark ? 0.15 : 0.1)
                : AppTheme.getSectionBackground(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? iconColor.withOpacity(0.4)
                  : AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? iconColor.withOpacity(0.2)
                    : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Checkbox or Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? iconColor
                      : iconColor.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: iconColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor1(isDark),
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.completed,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: iconColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getSecondaryGray(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Button
              _buildActionButton(
                context: context,
                isDark: isDark,
                l10n: l10n,
                iconColor: iconColor,
                isCompleted: isCompleted,
                onAction: onAction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool isDark,
    required AppLocalizations l10n,
    required Color iconColor,
    required bool isCompleted,
    required VoidCallback onAction,
  }) {
    return GestureDetector(
      onTap: isCompleted ? null : onAction,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor,
                    iconColor.withOpacity(0.8),
                  ],
                ),
          color: isCompleted
              ? AppTheme.getSecondaryGray(isDark).withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              color: isCompleted
                  ? AppTheme.getSecondaryGray(isDark)
                  : Colors.white,
              size: 18,
            ),
            if (!isCompleted) ...[
              const SizedBox(width: 6),
              Text(
                l10n.startAction,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

