import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CCTV Camera Widget - Fully Responsive
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
    
    _recordingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    _recordingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _recordingController, curve: Curves.easeInOut),
    );

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
    return _roomImages[room] ?? _roomImages.values.first;
  }

  void _switchRoom(String room) {
    if (room != _selectedRoom) {
      setState(() => _selectedRoom = room);
      widget.onRoomChanged?.call(room);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.imagePath ?? 
        (_selectedRoom != null ? _getImagePathForRoom(_selectedRoom!) : _roomImages.values.first);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 150;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1C) : const Color(0xFF000000),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Camera Feed with premium overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1C1C1E),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam_off_rounded, color: Colors.white54, size: isCompact ? 32 : 48),
                                SizedBox(height: isCompact ? 6 : 10),
                                Text(
                                  'Camera Offline',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: isCompact ? 11 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Subtle vignette for depth
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Premium overlay gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),

              // Top overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 6 : 10),
                  child: Row(
                    children: [
                      // Room name
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 8 : 10,
                              vertical: isCompact ? 5 : 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_rounded, size: isCompact ? 12 : 14, color: Colors.white),
                                SizedBox(width: isCompact ? 4 : 6),
                                Flexible(
                                  child: Text(
                                    _selectedRoom ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isCompact ? 10 : 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),

                      // Recording indicator
                      if (widget.isRecording)
                        AnimatedBuilder(
                          animation: _recordingAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 7 : 9,
                                vertical: isCompact ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.withOpacity(_recordingAnimation.value * 0.9),
                                    Colors.red.withOpacity(_recordingAnimation.value * 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: isCompact ? 6 : 8,
                                    height: isCompact ? 6 : 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: isCompact ? 4 : 6),
                                  Text(
                                    'REC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isCompact ? 9 : 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      if (widget.isRecording) SizedBox(width: isCompact ? 4 : 6),

                      // Live indicator
                      if (widget.isLive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 5 : 6,
                            vertical: isCompact ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isCompact ? 4 : 5,
                                height: isCompact ? 4 : 5,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                              SizedBox(width: isCompact ? 3 : 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isCompact ? 7 : 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 6 : 10),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 5 : 8,
                              vertical: isCompact ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded, size: isCompact ? 10 : 12, color: Colors.white70),
                                SizedBox(width: isCompact ? 3 : 4),
                                Text(
                                  '$dateStr $timeStr',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompact ? 8 : 10,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Room switcher
                      if (widget.availableRooms.length > 1 && !isCompact) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.availableRooms.map((room) {
                              final isSelected = room == _selectedRoom;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () => _switchRoom(room),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      room,
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white,
                                        fontSize: 9,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

              // Grid overlay
              CustomPaint(painter: _GridPainter()),
            ],
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 3; i++) {
      final x = size.width / 3 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
