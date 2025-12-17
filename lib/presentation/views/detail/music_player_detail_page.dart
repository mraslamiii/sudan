import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/dashboard/music_player_control_panel.dart';
import '../../widgets/dashboard/card_styles.dart' as detail_styles;

/// Full-screen detail page for music player - Optimized for 9" tablet landscape
class MusicPlayerDetailPage extends StatelessWidget {
  const MusicPlayerDetailPage({super.key});

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
            
            // Content - horizontal layout, no scroll
            Expanded(
              child: Consumer<DashboardViewModel>(
                builder: (context, dashboardVM, _) {
                  final musicCards = dashboardVM.cards
                      .where((c) => c.type == CardType.music)
                      .toList();
                  
                  if (musicCards.isEmpty) {
                    return _buildEmptyState(context, isDark, l10n);
                  }
                  
                  final musicCard = musicCards.first;
                  final isPlaying = musicCard.data['isPlaying'] as bool? ?? false;
                  final title = musicCard.data['title'] as String?;
                  final artist = musicCard.data['artist'] as String?;
                  final volume = musicCard.data['volume'] as int? ?? 50;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Left: Album art visualizer
                        Expanded(
                          flex: 5,
                          child: _buildAlbumVisualizer(
                            context,
                            isDark,
                            dashboardVM,
                            musicCard,
                            isPlaying,
                            title,
                            artist,
                            volume,
                            screenSize,
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Right: Controls and info
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Song info
                              _buildSongInfo(context, isDark, title, artist),
                              
                              const SizedBox(height: 32),
                              
                              // Playback controls
                              _buildPlaybackControls(
                                context,
                                isDark,
                                dashboardVM,
                                musicCard,
                                isPlaying,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Volume control
                              _buildVolumeControl(
                                context,
                                isDark,
                                dashboardVM,
                                musicCard,
                                volume,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
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
              color: detail_styles.CardStyles.musicAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 18,
              color: detail_styles.CardStyles.musicAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.musicPlayer ?? 'Music Player',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
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
              Icons.music_note_rounded,
              size: 48,
              color: detail_styles.CardStyles.musicAccent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No music player',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a music player device to control playback',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getSecondaryGray(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumVisualizer(
    BuildContext context,
    bool isDark,
    DashboardViewModel dashboardVM,
    DashboardCardModel musicCard,
    bool isPlaying,
    String? title,
    String? artist,
    int volume,
    Size screenSize,
  ) {
    final size = math.min(screenSize.height * 0.6, screenSize.width * 0.4);
    
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: MusicPlayerControlPanel(
          isPlaying: isPlaying,
          title: title,
          artist: artist,
          volume: volume,
          onPlayPause: (playing) {
            dashboardVM.updateCardData(musicCard.id, {'isPlaying': playing});
          },
          onPrevious: () {},
          onNext: () {},
          onVolumeChanged: (newVolume) {
            dashboardVM.updateCardData(musicCard.id, {'volume': newVolume});
          },
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, bool isDark, String? title, String? artist) {
    return Column(
      children: [
        Text(
          title ?? 'No track playing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor1(isDark),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (artist != null) ...[
          const SizedBox(height: 8),
          Text(
            artist,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getSecondaryGray(isDark),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    bool isDark,
    DashboardViewModel dashboardVM,
    DashboardCardModel musicCard,
    bool isPlaying,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          context: context,
          icon: Icons.skip_previous_rounded,
          onTap: () {},
          isDark: isDark,
        ),
        const SizedBox(width: 20),
        _buildPlayButton(context, isDark, dashboardVM, musicCard, isPlaying),
        const SizedBox(width: 20),
        _buildControlButton(
          context: context,
          icon: Icons.skip_next_rounded,
          onTap: () {},
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(
    BuildContext context,
    bool isDark,
    DashboardViewModel dashboardVM,
    DashboardCardModel musicCard,
    int volume,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.volume_down_rounded,
              size: 20,
              color: AppTheme.getSecondaryGray(isDark),
            ),
            Text(
              '$volume%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: detail_styles.CardStyles.musicAccent,
              ),
            ),
            Icon(
              Icons.volume_up_rounded,
              size: 20,
              color: detail_styles.CardStyles.musicAccent,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: detail_styles.CardStyles.musicAccent,
            inactiveTrackColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            thumbColor: detail_styles.CardStyles.musicAccent,
          ),
          child: Slider(
            value: volume.toDouble(),
            min: 0,
            max: 100,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              dashboardVM.updateCardData(musicCard.id, {'volume': value.toInt()});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.getSectionBackground(isDark),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppTheme.getTextColor1(isDark),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    bool isDark,
    DashboardViewModel dashboardVM,
    DashboardCardModel musicCard,
    bool isPlaying,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        dashboardVM.updateCardData(musicCard.id, {'isPlaying': !isPlaying});
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: isPlaying
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    detail_styles.CardStyles.musicAccent,
                    detail_styles.CardStyles.musicAccent.withOpacity(0.7),
                  ],
                )
              : null,
          color: isPlaying
              ? null
              : AppTheme.getSectionBackground(isDark),
          shape: BoxShape.circle,
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: detail_styles.CardStyles.musicAccent.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isPlaying ? Colors.white : detail_styles.CardStyles.musicAccent,
          size: 36,
        ),
      ),
    );
  }
}
