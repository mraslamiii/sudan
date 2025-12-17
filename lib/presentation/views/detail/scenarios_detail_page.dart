import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/scenario_entity.dart';
import '../../viewmodels/scenario_viewmodel.dart';
import '../../viewmodels/room_viewmodel.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../setup/scenario_setup_flow.dart';

/// Full-screen detail page for scenarios - Optimized for 9" tablet landscape
class ScenariosDetailPage extends StatelessWidget {
  const ScenariosDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            _buildHeader(context, isDark, l10n),
            
            // Content - no scroll, fits screen
            Expanded(
              child: Consumer2<ScenarioViewModel, RoomViewModel>(
                builder: (context, scenarioVM, roomVM, _) {
                  final currentRoomId = roomVM.selectedRoomId;
                  final scenarios = scenarioVM.scenarios
                      .where((s) => s.roomId == currentRoomId)
                      .toList();

                  if (scenarios.isEmpty) {
                    return _buildEmptyState(context, isDark, l10n, scenarioVM);
                  }

                  return _buildScenariosGrid(context, scenarioVM, scenarios, isDark, screenSize);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSectionBackground(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.getTextColor1(isDark)),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getAccentAmber(isDark).withOpacity(0.85),
                  AppTheme.getAccentRose(isDark).withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.scenarios,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppTheme.getTextColor1(isDark)),
            onPressed: () => _showCreateScenarioDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ScenarioViewModel scenarioVM,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getSectionBackground(isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: AppTheme.getAccentAmber(isDark),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noScenariosYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.automateRoutine,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getSecondaryGray(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showCreateScenarioDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.createScenario),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: AppTheme.getAccentAmber(isDark),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenariosGrid(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    List<ScenarioEntity> scenarios,
    bool isDark,
    Size screenSize,
  ) {
    // Calculate optimal columns based on screen width
    final availableWidth = screenSize.width - 40; // padding
    final cardWidth = 180.0;
    final spacing = 16.0;
    final columns = ((availableWidth + spacing) / (cardWidth + spacing)).floor().clamp(4, 8);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.9,
        ),
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return _buildDetailScenarioCard(
            context,
            scenario,
            scenarioVM,
            isDark,
            screenSize,
          );
        },
      ),
    );
  }

  Widget _buildDetailScenarioCard(
    BuildContext context,
    ScenarioEntity scenario,
    ScenarioViewModel scenarioVM,
    bool isDark,
    Size screenSize,
  ) {
    final isExecuting = scenarioVM.isExecuting(scenario.id);

    return GestureDetector(
      onTap: isExecuting ? null : () => _executeScenario(context, scenarioVM, scenario),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scenario.color.withOpacity(0.15),
              scenario.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scenario.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scenario.color.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _ScenarioPatternPainter(
                    color: scenario.color.withOpacity(0.05),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and actions
                  Row(
                    children: [
                      // Icon container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scenario.color,
                              scenario.color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: scenario.color.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: -2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isExecuting
                            ? Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                              )
                            : Icon(
                                scenario.icon,
                                size: 22,
                                color: Colors.white,
                              ),
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      _buildActionButton(
                        context,
                        Icons.edit_rounded,
                        Colors.blue,
                        () => _showEditScenarioDialog(context, scenarioVM, scenario),
                        isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildActionButton(
                        context,
                        Icons.delete_rounded,
                        Colors.red,
                        () => _deleteScenario(context, scenarioVM, scenario),
                        isDark,
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Scenario name
                  Text(
                    scenario.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor1(isDark),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Execute button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scenario.color,
                          scenario.color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: scenario.color.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: -2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExecuting ? Icons.hourglass_empty_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isExecuting ? 'در حال اجرا...' : 'اجرا',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.getSectionBackground(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Future<void> _showCreateScenarioDialog(BuildContext context) async {
    final roomVM = context.read<RoomViewModel>();
    final roomId = roomVM.selectedRoomId;
    
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScenarioSetupFlow(roomId: roomId),
      ),
    );
  }

  Future<void> _showEditScenarioDialog(
    BuildContext context,
    ScenarioViewModel scenarioVM,
    ScenarioEntity scenario,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScenarioSetupFlow(
          existingScenario: scenario,
          roomId: scenario.roomId,
        ),
      ),
    );
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
          SnackBar(
            content: Text(l10n.scenarioExecuted(scenario.name)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToExecuteScenario}: $e'),
            backgroundColor: Colors.red,
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.scenarioDeleted(scenario.name)),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.failedToDeleteScenario}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Custom painter for scenario card background pattern
class _ScenarioPatternPainter extends CustomPainter {
  final Color color;

  _ScenarioPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines pattern
    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenarioPatternPainter oldDelegate) => oldDelegate.color != color;
}
