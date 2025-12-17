import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/room_viewmodel.dart';

typedef ModuleSetupAction = Future<void> Function(BuildContext context);

class ModuleSetupContent {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> highlights;
  final List<String> steps;
  final String primaryActionLabel;
  final ModuleSetupAction? onPrimaryAction;
  final String? secondaryActionLabel;
  final ModuleSetupAction? onSecondaryAction;
  final Color? accentColor;
  final WidgetBuilder? extraSectionBuilder;

  const ModuleSetupContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.highlights,
    required this.steps,
    required this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.extraSectionBuilder,
  });

  ModuleSetupContent copyWith({
    IconData? icon,
    String? title,
    String? subtitle,
    String? description,
    List<String>? highlights,
    List<String>? steps,
    String? primaryActionLabel,
    ModuleSetupAction? onPrimaryAction,
    String? secondaryActionLabel,
    ModuleSetupAction? onSecondaryAction,
    Color? accentColor,
    WidgetBuilder? extraSectionBuilder,
  }) {
    return ModuleSetupContent(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      steps: steps ?? this.steps,
      primaryActionLabel: primaryActionLabel ?? this.primaryActionLabel,
      onPrimaryAction: onPrimaryAction ?? this.onPrimaryAction,
      secondaryActionLabel: secondaryActionLabel ?? this.secondaryActionLabel,
      onSecondaryAction: onSecondaryAction ?? this.onSecondaryAction,
      accentColor: accentColor ?? this.accentColor,
      extraSectionBuilder: extraSectionBuilder ?? this.extraSectionBuilder,
    );
  }
}

/// Reusable setup page with premium hero card, highlights, step list, and CTAs.
class ModuleSetupPage extends StatelessWidget {
  final ModuleSetupContent content;

  const ModuleSetupPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = content.accentColor ?? AppTheme.getPrimaryBlue(isDark);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: AppTheme.getTextColor1(isDark)),
        title: Text(
          content.title,
          style: TextStyle(
            color: AppTheme.getTextColor1(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(content: content, accent: accent),
            const SizedBox(height: 28),
            Text(
              content.description,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: AppTheme.getSecondaryGray(isDark),
              ),
            ),
            if (content.highlights.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Why you’ll love it',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: content.highlights
                    .map((label) => _TagChip(label: label, accent: accent, isDark: isDark))
                    .toList(),
              ),
            ],
            if (content.steps.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(
                'Setup steps',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: content.steps
                    .asMap()
                    .entries
                    .map((entry) => _StepRow(
                          index: entry.key + 1,
                          text: entry.value,
                          accent: accent,
                          isDark: isDark,
                        ))
                    .toList(),
              ),
            ],
            if (content.extraSectionBuilder != null) ...[
              const SizedBox(height: 28),
              content.extraSectionBuilder!(context),
            ],
            const SizedBox(height: 36),
            _ActionButtons(content: content, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ModuleSetupContent content;
  final Color accent;

  const _HeroCard({
    required this.content,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  accent.withOpacity(0.75),
                  accent.withOpacity(0.55),
                ]
              : [
                  accent.withOpacity(0.65),
                  accent.withOpacity(0.45),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.5 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.4 : 0.28),
            blurRadius: 36,
            spreadRadius: 3,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.1),
            ),
            child: Icon(
              content.icon,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Consumer2<RoomViewModel, DashboardViewModel>(
                  builder: (context, roomVM, dashboardVM, _) {
                    final rooms = roomVM.rooms;
                    final currentRoomName = roomVM.selectedRoom?.name ??
                        (rooms.isNotEmpty ? rooms.first.name : 'your space');
                    final cardsCount = dashboardVM.cards.length;

                    return Row(
                      children: [
                        _HeroStat(
                          label: 'Active rooms',
                          value: rooms.isEmpty ? '—' : rooms.length.toString(),
                        ),
                        const SizedBox(width: 22),
                        _HeroStat(
                          label: 'Dashboard cards',
                          value: cardsCount.toString(),
                        ),
                        const SizedBox(width: 22),
                        Flexible(
                          child: Text(
                            'Current focus: $currentRoomName',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool isDark;

  const _TagChip({
    required this.label,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(isDark ? 0.2 : 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: accent.withOpacity(isDark ? 0.95 : 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  final Color accent;
  final bool isDark;

  const _StepRow({
    required this.index,
    required this.text,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(isDark).withOpacity(isDark ? 0.35 : 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.25 : 0.2),
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  accent.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.2,
                height: 1.45,
                color: AppTheme.getSecondaryGray(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ModuleSetupContent content;
  final Color accent;

  const _ActionButtons({
    required this.content,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: content.onPrimaryAction == null
                ? null
                : () => _runAction(context, content.onPrimaryAction),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: accent.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  content.primaryActionLabel,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        if (content.secondaryActionLabel != null && content.onSecondaryAction != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _runAction(context, content.onSecondaryAction),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getTextColor1(isDark),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(content.secondaryActionLabel!),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded, size: 16),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _runAction(BuildContext context, ModuleSetupAction? action) async {
    if (action == null) return;
    try {
      await action(context);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
          backgroundColor: Colors.redAccent.shade200,
        ),
      );
    }
  }
}


