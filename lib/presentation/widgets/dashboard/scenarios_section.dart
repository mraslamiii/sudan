import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/scenario_entity.dart';
import '../../viewmodels/scenario_viewmodel.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../../viewmodels/room_viewmodel.dart';
import '../scenario/scenario_card.dart';
import '../common/premium_empty_state.dart';
import '../../views/setup/module_setup_page.dart';
import '../../views/setup/scenario_setup_flow.dart';

/// Scenarios Section - Fully Responsive
class ScenariosSection extends StatelessWidget {
  const ScenariosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScenarioViewModel, RoomViewModel>(
      builder: (context, scenarioVM, roomVM, _) {
        final currentRoomId = roomVM.selectedRoomId;
        print('🟣 [SCENARIOS_SECTION] build called');
        print('   - Current RoomId: $currentRoomId');
        print('   - Total scenarios in VM: ${scenarioVM.scenarios.length}');
        for (var s in scenarioVM.scenarios) {
          print('     * ${s.name} (RoomId: ${s.roomId})');
        }
        
        // Filter scenarios by current room
        final scenarios = scenarioVM.scenarios
            .where((s) => s.roomId == currentRoomId)
            .toList();
        print('   - Filtered scenarios for room: ${scenarios.length}');
        for (var s in scenarios) {
          print('     * ${s.name} (ID: ${s.id})');
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 200;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, scenarioVM, isCompact),
                SizedBox(height: isCompact ? 6 : 8),
                Expanded(
                  child: scenarios.isEmpty
                      ? _buildEmptyState(context, isCompact)
                      : _buildScenariosList(context, scenarioVM, scenarios, isCompact),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ScenarioViewModel scenarioVM, bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.getAccentAmber(isDark).withOpacity(0.85),
                AppTheme.getAccentRose(isDark).withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: isCompact ? 14 : 16,
            color: Colors.white,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 10),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.scenarios,
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showCreateScenarioDialog(context, scenarioVM),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 10,
              vertical: isCompact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.getAccentAmber(isDark),
                  AppTheme.getAccentRose(isDark),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getAccentAmber(isDark).withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: isCompact ? 12 : 14, color: Colors.white.withOpacity(0.95)),
                SizedBox(width: isCompact ? 2 : 4),
                Text(
                  AppLocalizations.of(context)!.add,
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isCompact) {
    final l10n = AppLocalizations.of(context)!;
    return PremiumEmptyState(
      icon: Icons.auto_awesome_rounded,
      title: l10n.noScenariosYet,
      message: l10n.automateRoutine,
      highlights: [
        l10n.multiDeviceOrchestration,
        l10n.schedulesAndQuickTriggers,
        l10n.reusableRoomPresets,
      ],
      primaryActionLabel: l10n.openScenarioSetup,
      onPrimaryAction: () => _openScenarioSetup(context),
      isCompact: isCompact,
    );
  }

  void _openScenarioSetup(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = ModuleSetupContent(
      icon: Icons.auto_awesome_rounded,
      title: l10n.scenarioSetup,
      subtitle: l10n.automateMomentsThatMatter,
      description: l10n.scenariosDescription,
      highlights: [
        l10n.roomAwareConditions,
        l10n.stackableTriggers,
        l10n.visualTimelineEditor,
      ],
      steps: [
        l10n.scenarioStep1,
        l10n.scenarioStep2,
        l10n.scenarioStep3,
      ],
      primaryActionLabel: l10n.createScenario,
      onPrimaryAction: (ctx) => _showCreateScenarioDialog(ctx, ctx.read<ScenarioViewModel>()),
      secondaryActionLabel: l10n.viewQuickTips,
      onSecondaryAction: (ctx) async {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(l10n.tipCombineDevices),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ModuleSetupPage(content: content)),
    );
  }

  Widget _buildScenariosList(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    List<ScenarioEntity> scenarios,
    bool isCompact,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          itemCount: scenarios.length,
          separatorBuilder: (context, index) => SizedBox(width: isCompact ? 6 : 8),
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            return ScenarioCard(
              scenario: scenario,
              availableHeight: constraints.maxHeight,
              onTap: () => _executeScenario(context, scenarioVM, scenario),
              onEdit: () => _showEditScenarioDialog(context, scenarioVM, scenario),
              onDelete: () => _deleteScenario(context, scenarioVM, scenario),
              isExecuting: scenarioVM.isExecuting(scenario.id),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateScenarioDialog(
    BuildContext context,
    ScenarioViewModel scenarioVM,
  ) async {
    print('🟣 [SCENARIOS_SECTION] _showCreateScenarioDialog called');
    final roomVM = context.read<RoomViewModel>();
    final roomId = roomVM.selectedRoomId;
    print('   - RoomId: $roomId');
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScenarioSetupFlow(
          roomId: roomId,
        ),
      ),
    );

    print('🟣 [SCENARIOS_SECTION] Dialog returned: $result');
    if (result == true && context.mounted) {
      print('🟣 [SCENARIOS_SECTION] Scenario created/updated successfully');
      print('   - Current scenarios count: ${scenarioVM.scenarios.length}');
      // Scenario was created/updated successfully
      // The success message is already shown in the flow
    }
  }

  Future<void> _showEditScenarioDialog(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    ScenarioEntity scenario,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScenarioSetupFlow(
          existingScenario: scenario,
          roomId: scenario.roomId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Scenario was updated successfully
      // The success message is already shown in the flow
    }
  }

  Future<void> _executeScenario(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    ScenarioEntity scenario,
  ) async {
    final deviceVM = context.read<DeviceViewModel>();
    try {
      await scenarioVM.executeScenario(scenario.id);
      await deviceVM.refresh();
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scenarioExecuted(scenario.name)), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToExecuteScenario}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteScenario(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    ScenarioEntity scenario,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteScenario),
        content: Text(l10n.deleteScenarioConfirm(scenario.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await scenarioVM.deleteScenario(scenario.id);
        
        // Scenarios section will remain visible and show empty state
        // No need to remove it from dashboard
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.scenarioDeleted(scenario.name)), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToDeleteScenario}: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
