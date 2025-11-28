import 'package:flutter/material.dart';

import '../../../data/models/dashboard_card_model.dart';
import 'card_widgets/device_card.dart';
import 'cctv_camera_widget.dart';
import 'base_dashboard_card.dart';

/// Factory class to create appropriate card widget based on card type
class DashboardCardFactory {
  static Widget createCard({
    required DashboardCardModel card,
    required bool isEditMode,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDelete,
    Function(CardSize)? onResize,
    Function(Map<String, dynamic>)? onDataUpdate,
  }) {
    // Camera cards use the special CCTV widget
    if (card.type == CardType.camera) {
      final isOn = card.data['isOn'] as bool? ?? true;
      final isRecording = card.data['isRecording'] as bool? ?? false;
      final currentRoom = card.data['location'] as String? ?? 'Living Room';
      final availableRooms = card.data['availableRooms'] as List<dynamic>? ?? 
          ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom'];
      final imagePath = card.data['imagePath'] as String?;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: isOn
            ? CCTVCameraWidget(
                currentRoom: currentRoom,
                availableRooms: availableRooms.cast<String>(),
                isRecording: isRecording,
                isLive: isOn,
                imagePath: imagePath,
                onRoomChanged: (newRoom) {
                  onDataUpdate?.call({
                    'location': newRoom,
                  });
                },
              )
            : Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Camera Offline',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    // All other device cards use the unified DeviceCard
    return DeviceCard(
      card: card,
      isEditMode: isEditMode,
      onTap: onTap,
      onLongPress: onLongPress,
      onDelete: onDelete,
      onResize: onResize,
      onDataUpdate: onDataUpdate,
    );
  }
}

