import 'package:flutter/material.dart';

/// Floor Entity
/// Represents a floor in the smart home system
/// 
/// Example usage:
/// ```dart
/// final firstFloor = FloorEntity(
///   id: 'floor_1',
///   name: 'First Floor',
///   icon: Icons.layers_rounded,
///   roomIds: ['room_living', 'room_kitchen'],
/// );
/// ```
class FloorEntity {
  final String id;
  final String name;
  final IconData icon;
  final List<String> roomIds; // List of room IDs on this floor
  final String? imageUrl; // Optional background image for the floor
  final int order; // Display order

  const FloorEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.roomIds,
    this.imageUrl,
    this.order = 0,
  });

  /// Create a copy with updated fields
  FloorEntity copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? roomIds,
    String? imageUrl,
    int? order,
  }) {
    return FloorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      roomIds: roomIds ?? this.roomIds,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }

  /// Add a room to this floor
  FloorEntity addRoom(String roomId) {
    if (roomIds.contains(roomId)) {
      return this;
    }
    return copyWith(
      roomIds: [...roomIds, roomId],
    );
  }

  /// Remove a room from this floor
  FloorEntity removeRoom(String roomId) {
    return copyWith(
      roomIds: roomIds.where((id) => id != roomId).toList(),
    );
  }

  /// Get number of rooms on this floor
  int get roomCount => roomIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloorEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

