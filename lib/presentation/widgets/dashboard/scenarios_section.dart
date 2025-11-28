import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScenariosSection extends StatelessWidget {
  final List<ScenarioItem> scenarios;
  final Function(ScenarioItem)? onScenarioTap;

  const ScenariosSection({
    super.key,
    this.scenarios = const [],
    this.onScenarioTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultScenarios = scenarios.isEmpty
        ? [
            ScenarioItem(
              id: '1',
              name: 'Good Morning',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFFB84D),
            ),
            ScenarioItem(
              id: '2',
              name: 'Movie Night',
              icon: Icons.movie_rounded,
              color: const Color(0xFF5B8DEF),
            ),
            ScenarioItem(
              id: '3',
              name: 'Sleep',
              icon: Icons.bedtime_rounded,
              color: const Color(0xFF7B68EE),
            ),
            ScenarioItem(
              id: '4',
              name: 'Away',
              icon: Icons.home_rounded,
              color: const Color(0xFF68F0C4),
            ),
          ]
        : scenarios;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header با اندازه بزرگتر
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.getIconBackground(isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 24,
                          color: AppTheme.getPrimaryBlue(isDark),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Scenarios',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor1(isDark),
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // کارت‌ها که از فضای باقیمانده استفاده می‌کنند
            Expanded(
              child: LayoutBuilder(
                builder: (context, cardConstraints) {
                  final availableHeight = cardConstraints.maxHeight;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: false,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: defaultScenarios.length,
                    itemBuilder: (context, index) {
                      final scenario = defaultScenarios[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < defaultScenarios.length - 1 ? 14.0 : 0,
                        ),
                        child: _ScenarioCard(
                          scenario: scenario,
                          availableHeight: availableHeight,
                          onTap: () => onScenarioTap?.call(scenario),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScenarioItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ScenarioItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _ScenarioCard extends StatefulWidget {
  final ScenarioItem scenario;
  final double availableHeight;
  final VoidCallback? onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.availableHeight,
    this.onTap,
  });

  @override
  State<_ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<_ScenarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    final gradientStart = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF);
    final gradientEnd = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8F8FA);
    
    // محاسبه دقیق اندازه‌ها بر اساس فضای موجود
    final cardHeight = widget.availableHeight;
    final horizontalPadding = 12.0;
    
    // اندازه‌های پایه (بزرگتر)
    const baseIconSize = 24.0;
    const baseIconPadding = 8.0;
    const baseSpacing = 8.0;
    const baseFontSize = 13.0;
    const baseLineHeight = baseFontSize * 1.2; // 15.6px
    const baseIconContainerSize = baseIconSize + (baseIconPadding * 2); // 40px
    const baseContentHeight = baseIconContainerSize + baseSpacing + baseLineHeight; // 63.6px
    
    // حداقل padding (بیشتر)
    const minPadding = 6.0;
    
    // محاسبه scale factor و padding
    double scaleFactor = 1.0;
    double topPadding = minPadding;
    double bottomPadding = minPadding;
    
    // محاسبه فضای موجود برای محتوا
    final availableForContent = cardHeight - (minPadding * 2);
    
    if (availableForContent < baseContentHeight) {
      // اگر فضای کافی نیست، scale می‌کنیم
      scaleFactor = (availableForContent / baseContentHeight).clamp(0.6, 1.0);
      topPadding = minPadding;
      bottomPadding = minPadding;
    } else {
      // اگر فضای اضافی داریم، padding را افزایش می‌دهیم
      final extraSpace = availableForContent - baseContentHeight;
      final extraPadding = (extraSpace / 2).clamp(0.0, 8.0);
      topPadding = minPadding + extraPadding;
      bottomPadding = minPadding + extraPadding;
    }
    
    // محاسبه اندازه‌های نهایی
    final iconSize = (baseIconSize * scaleFactor).clamp(12.0, baseIconSize);
    final iconPadding = (baseIconPadding * scaleFactor).clamp(3.0, baseIconPadding);
    final iconContainerSize = iconSize + (iconPadding * 2);
    final spacing = (baseSpacing * scaleFactor).clamp(3.0, baseSpacing);
    final fontSize = (baseFontSize * scaleFactor).clamp(8.0, baseFontSize);
    final lineHeight = fontSize * 1.2;
    
    // محاسبه نهایی برای اطمینان از عدم overflow
    final finalContentHeight = iconContainerSize + spacing + lineHeight;
    final finalAvailableHeight = cardHeight - (topPadding + bottomPadding);
    
    // اگر هنوز overflow داریم، padding را کاهش می‌دهیم
    if (finalContentHeight > finalAvailableHeight) {
      final overflow = finalContentHeight - finalAvailableHeight;
      topPadding = (topPadding - overflow / 2).clamp(2.0, topPadding);
      bottomPadding = (bottomPadding - overflow / 2).clamp(2.0, bottomPadding);
    }
    
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final hoverValue = _controller.value;
            final activeGradientStart = Color.lerp(
              gradientStart,
              widget.scenario.color.withOpacity(isDark ? 0.2 : 0.1),
              hoverValue * 0.5,
            ) ?? gradientStart;
            final activeGradientEnd = Color.lerp(
              gradientEnd,
              widget.scenario.color.withOpacity(isDark ? 0.15 : 0.08),
              hoverValue * 0.5,
            ) ?? gradientEnd;
            
            return Transform.scale(
              scale: 1.0 + (hoverValue * 0.02),
              child: Container(
                width: 110,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [activeGradientStart, activeGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color.lerp(
                      isDark 
                          ? Colors.white.withOpacity(0.08) 
                          : Colors.black.withOpacity(0.06),
                      widget.scenario.color.withOpacity(0.4),
                      hoverValue,
                    ) ?? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.3 + (hoverValue * 0.2))
                          : Colors.black.withOpacity(0.06 + (hoverValue * 0.06)),
                      blurRadius: 8 + (hoverValue * 8),
                      offset: Offset(0, 2 + (hoverValue * 2)),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: topPadding,
                    bottom: bottomPadding,
                  ),
                  child: SizedBox(
                    height: cardHeight - (topPadding + bottomPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                widget.scenario.color.withOpacity(0.2),
                                widget.scenario.color.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.scenario.color.withOpacity(0.2 * hoverValue),
                                blurRadius: 8 * hoverValue,
                                spreadRadius: 1 * hoverValue,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.scenario.icon,
                            size: iconSize,
                            color: widget.scenario.color,
                          ),
                        ),
                        SizedBox(height: spacing),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            widget.scenario.name,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor1(isDark),
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

