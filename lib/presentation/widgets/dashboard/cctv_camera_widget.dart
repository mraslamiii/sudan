import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CCTV Camera Widget with full features
/// Simulates a security camera feed with room switching, recording indicators, etc.
class CCTVCameraWidget extends StatefulWidget {
  final String? currentRoom;
  final List<String> availableRooms;
  final Function(String)? onRoomChanged;
  final bool isRecording;
  final bool isLive;
  final String? imagePath;

  const CCTVCameraWidget({
    super.key,
    this.currentRoom,
    this.availableRooms = const [],
    this.onRoomChanged,
    this.isRecording = false,
    this.isLive = true,
    this.imagePath,
  });

  @override
  State<CCTVCameraWidget> createState() => _CCTVCameraWidgetState();
}

class _CCTVCameraWidgetState extends State<CCTVCameraWidget>
    with TickerProviderStateMixin {
  late AnimationController _recordingController;
  late AnimationController _timeController;
  late Animation<double> _recordingAnimation;
  String? _selectedRoom;

  // Map rooms to image paths
  final Map<String, String> _roomImages = {
    'Living Room': 'assets/images/point3d-commercial-imaging-ltd-kx-gbP7lMak-unsplash.jpg',
    'Bed Room': 'assets/images/photo-1600585154340-be6161a56a0c.jpeg',
    'Kitchen': 'assets/images/point3d-commercial-imaging-ltd-kx-gbP7lMak-unsplash.jpg',
    'Bathroom': 'assets/images/photo-1600585154340-be6161a56a0c.jpeg',
  };

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.currentRoom ?? 
        (widget.availableRooms.isNotEmpty ? widget.availableRooms.first : 'Living Room');
    
    // Recording indicator animation
    _recordingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    _recordingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _recordingController,
        curve: Curves.easeInOut,
      ),
    );

    // Time update controller
    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _recordingController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _getImagePathForRoom(String room) {
    if (_roomImages.containsKey(room)) {
      return _roomImages[room]!;
    }
    return _roomImages.values.isNotEmpty
        ? _roomImages.values.first
        : 'assets/images/point3d-commercial-imaging-ltd-kx-gbP7lMak-unsplash.jpg';
  }

  void _switchRoom(String room) {
    if (room != _selectedRoom) {
      setState(() {
        _selectedRoom = room;
      });
      widget.onRoomChanged?.call(room);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.imagePath ?? 
        (_selectedRoom != null ? _getImagePathForRoom(_selectedRoom!) : 
         'assets/images/point3d-commercial-imaging-ltd-kx-gbP7lMak-unsplash.jpg');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1C) : const Color(0xFF000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed Background
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1C1C1E),
                  child: const Center(
                    child: Icon(
                      Icons.videocam_off_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay gradient for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Top overlay with room name, time, and recording indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Room name
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedRoom ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recording indicator
                  if (widget.isRecording)
                    AnimatedBuilder(
                      animation: _recordingAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(_recordingAnimation.value * 0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'REC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(width: 8),

                  // Live indicator
                  if (widget.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom overlay with timestamp and controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp
                  AnimatedBuilder(
                    animation: _timeController,
                    builder: (context, child) {
                      final now = DateTime.now();
                      final timeStr = DateFormat('HH:mm:ss').format(now);
                      final dateStr = DateFormat('yyyy-MM-dd').format(now);
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$dateStr $timeStr',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Room switcher buttons
                  if (widget.availableRooms.length > 1) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.availableRooms.map((room) {
                          final isSelected = room == _selectedRoom;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _switchRoom(room),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  room,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Grid overlay (optional, for security camera feel)
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for grid overlay on camera feed
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width / 3 * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

