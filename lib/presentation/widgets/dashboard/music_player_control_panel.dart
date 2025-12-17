import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import 'card_styles.dart';

/// Music Player Control Panel Widget - Apple-style Minimal Design
class MusicPlayerControlPanel extends StatefulWidget {
  final bool isPlaying;
  final String? title;
  final String? artist;
  final int volume; // 0-100
  final Function(bool)? onPlayPause;
  final Function()? onPrevious;
  final Function()? onNext;
  final Function(int)? onVolumeChanged;

  const MusicPlayerControlPanel({
    super.key,
    this.isPlaying = false,
    this.title,
    this.artist,
    this.volume = 50,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.onVolumeChanged,
  });

  @override
  State<MusicPlayerControlPanel> createState() => _MusicPlayerControlPanelState();
}

class _MusicPlayerControlPanelState extends State<MusicPlayerControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MusicPlayerControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _rotationController.stop();
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePlayPause() {
    HapticFeedback.lightImpact();
    widget.onPlayPause?.call(!widget.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CardStyles.musicAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 260;
        final isVeryCompact = constraints.maxHeight < 200;

        return Padding(
          padding: EdgeInsets.all(isCompact ? CardStyles.space12 : CardStyles.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CardStyles.buildHeader(
                context: context,
                title: AppLocalizations.of(context)?.musicPlayer ?? 'Music',
                subtitle: widget.title != null && widget.artist != null
                    ? '${widget.artist}'
                    : (widget.isPlaying ? 'Playing' : 'Paused'),
                isDark: isDark,
                isCompact: isCompact,
                accentColor: accentColor,
                isActive: widget.isPlaying,
                onPowerTap: _handlePlayPause,
                customIcon: widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              
              SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space20),

              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Album art / Visualizer
                    Expanded(
                      flex: isVeryCompact ? 3 : 4,
                      child: _buildAlbumVisualizer(isDark, isCompact, isVeryCompact, accentColor),
                    ),
                    SizedBox(width: isCompact ? CardStyles.space12 : CardStyles.space16),
                    // Controls
                    Expanded(
                      flex: isVeryCompact ? 4 : 5,
                      child: _buildControls(isDark, isCompact, isVeryCompact, accentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumVisualizer(bool isDark, bool isCompact, bool isVeryCompact, Color accentColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _pulseAnimation]),
            builder: (context, child) {
              final scale = widget.isPlaying ? _pulseAnimation.value : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: _handlePlayPause,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentColor.withOpacity(widget.isPlaying ? 0.3 : 0.1),
                          accentColor.withOpacity(widget.isPlaying ? 0.1 : 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Vinyl disc
                        Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: size * 0.85,
                            height: size * 0.85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                                  isDark ? const Color(0xFF1C1C1E) : const Color(0xFFD1D1D6),
                                  isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                                  isDark ? const Color(0xFF1C1C1E) : const Color(0xFFD1D1D6),
                                  isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                                ],
                              ),
                              border: Border.all(
                                color: accentColor.withOpacity(widget.isPlaying ? 0.4 : 0.15),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // Center label
                        Container(
                          width: size * 0.35,
                          height: size * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isPlaying
                                ? accentColor
                                : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
                            boxShadow: widget.isPlaying
                                ? [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.4),
                                      blurRadius: 16,
                                      spreadRadius: -2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            widget.isPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                            size: size * 0.15,
                            color: widget.isPlaying ? Colors.white : CardStyles.iconColor(isDark),
                          ),
                        ),
                        // Sound waves when playing
                        if (widget.isPlaying)
                          CustomPaint(
                            size: Size(size * 0.85, size * 0.85),
                            painter: _SoundWavesPainter(
                              color: accentColor,
                              progress: _rotationController.value,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isDark, bool isCompact, bool isVeryCompact, Color accentColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Song info
        if (widget.title != null && !isVeryCompact) ...[
          Text(
            widget.title!,
            style: CardStyles.valueStyle(isDark, null, isCompact: isCompact),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (widget.artist != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.artist!,
              style: CardStyles.labelStyle(isDark, isCompact: isCompact),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: isCompact ? CardStyles.space8 : CardStyles.space12),
        ],

        // Playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.skip_previous_rounded,
              onTap: widget.onPrevious,
              isDark: isDark,
              isCompact: isCompact,
              accentColor: accentColor,
            ),
            SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
            _buildPlayButton(isDark, isCompact, accentColor),
            SizedBox(width: isCompact ? CardStyles.space8 : CardStyles.space12),
            _buildControlButton(
              icon: Icons.skip_next_rounded,
              onTap: widget.onNext,
              isDark: isDark,
              isCompact: isCompact,
              accentColor: accentColor,
            ),
          ],
        ),
        
        SizedBox(height: isCompact ? CardStyles.space12 : CardStyles.space16),
        
        // Volume control
        _buildVolumeControl(isDark, isCompact, accentColor),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    required bool isCompact,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: isCompact ? 36 : 42,
        height: isCompact ? 36 : 42,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: CardStyles.iconColor(isDark),
          size: isCompact ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildPlayButton(bool isDark, bool isCompact, Color accentColor) {
    return GestureDetector(
      onTap: _handlePlayPause,
      child: AnimatedContainer(
        duration: CardStyles.normal,
        width: isCompact ? 48 : 56,
        height: isCompact ? 48 : 56,
        decoration: BoxDecoration(
          gradient: widget.isPlaying
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor,
                    Color.lerp(accentColor, Colors.black, 0.2)!,
                  ],
                )
              : null,
          color: widget.isPlaying
              ? null
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06)),
          shape: BoxShape.circle,
          boxShadow: widget.isPlaying
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: widget.isPlaying ? Colors.white : accentColor,
          size: isCompact ? 26 : 30,
        ),
      ),
    );
  }

  Widget _buildVolumeControl(bool isDark, bool isCompact, Color accentColor) {
    return Row(
      children: [
        Icon(
          Icons.volume_down_rounded,
          size: isCompact ? 16 : 18,
          color: CardStyles.iconColor(isDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: CardStyles.sliderTheme(context, isDark, accentColor, isCompact: isCompact),
            child: Slider(
              value: widget.volume.toDouble(),
              min: 0,
              max: 100,
              onChanged: (value) {
                widget.onVolumeChanged?.call(value.toInt());
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.volume_up_rounded,
          size: isCompact ? 16 : 18,
          color: accentColor,
        ),
      ],
    );
  }
}

class _SoundWavesPainter extends CustomPainter {
  final Color color;
  final double progress;

  _SoundWavesPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 expanding circles
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * 0.4 + (maxRadius * 0.4 * phase);
      final opacity = (1.0 - phase) * 0.5;
      
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SoundWavesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
