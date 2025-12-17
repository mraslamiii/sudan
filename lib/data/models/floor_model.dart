import 'package:flutter/material.dart';
import '../../domain/entities/floor_entity.dart';

/// Floor Model - Data layer implementation of FloorEntity
/// Includes JSON serialization for API/storage communication
class FloorModel extends FloorEntity {
  const FloorModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.roomIds,
    super.imageUrl,
    super.order,
  });

  /// Create FloorModel from JSON
  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: _iconFromString(json['icon'] as String? ?? 'layers'),
      roomIds: (json['roomIds'] as List?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Convert FloorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': _iconToString(icon),
      'roomIds': roomIds,
      'imageUrl': imageUrl,
      'order': order,
    };
  }

  /// Create mock floor for testing
  /// 
  /// Example:
  /// ```dart
  /// final firstFloor = FloorModel.mock(
  ///   id: 'floor_1',
  ///   name: 'First Floor',
  ///   icon: Icons.layers_rounded,
  /// );
  /// ```
  factory FloorModel.mock({
    required String id,
    required String name,
    required IconData icon,
    List<String>? roomIds,
    String? imageUrl,
    int order = 0,
  }) {
    return FloorModel(
      id: id,
      name: name,
      icon: icon,
      roomIds: roomIds ?? [],
      imageUrl: imageUrl,
      order: order,
    );
  }

  // Helper methods for serialization

  static IconData _iconFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'layers':
        return Icons.layers_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'villa':
        return Icons.villa_rounded;
      case 'stairs':
        return Icons.stairs_rounded;
      default:
        return Icons.layers_rounded;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.layers_rounded) return 'layers';
    if (icon == Icons.home_rounded) return 'home';
    if (icon == Icons.apartment_rounded) return 'apartment';
    if (icon == Icons.business_rounded) return 'business';
    if (icon == Icons.villa_rounded) return 'villa';
    if (icon == Icons.stairs_rounded) return 'stairs';
    return 'layers';
  }

  @override
  FloorModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? roomIds,
    String? imageUrl,
    int? order,
  }) {
    return FloorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      roomIds: roomIds ?? this.roomIds,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }

  @override
  FloorModel addRoom(String roomId) {
    if (roomIds.contains(roomId)) {
      return this;
    }
    return copyWith(
      roomIds: [...roomIds, roomId],
    );
  }

  @override
  FloorModel removeRoom(String roomId) {
    return copyWith(
      roomIds: roomIds.where((id) => id != roomId).toList(),
    );
  }
}

