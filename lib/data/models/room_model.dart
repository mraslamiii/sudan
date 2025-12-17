import 'package:flutter/material.dart';
import '../../domain/entities/room_entity.dart';

/// Room Model - Data layer implementation of RoomEntity
/// Includes JSON serialization for API/storage communication
class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.deviceIds,
    super.imageUrl,
    super.order,
    super.floorId,
    super.isGeneral,
  });

  /// Create RoomModel from JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: _iconFromString(json['icon'] as String? ?? 'home'),
      deviceIds: (json['deviceIds'] as List?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      order: json['order'] as int? ?? 0,
      floorId: json['floorId'] as String?,
      isGeneral: json['isGeneral'] as bool? ?? false,
    );
  }

  /// Convert RoomModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': _iconToString(icon),
      'deviceIds': deviceIds,
      'imageUrl': imageUrl,
      'order': order,
      'floorId': floorId,
      'isGeneral': isGeneral,
    };
  }

  /// Create mock room for testing
  /// 
  /// Example:
  /// ```dart
  /// final livingRoom = RoomModel.mock(
  ///   id: 'room_living',
  ///   name: 'Living Room',
  ///   icon: Icons.living_rounded,
  /// );
  /// ```
  factory RoomModel.mock({
    required String id,
    required String name,
    required IconData icon,
    List<String>? deviceIds,
    String? imageUrl,
    int order = 0,
    String? floorId,
    bool isGeneral = false,
  }) {
    return RoomModel(
      id: id,
      name: name,
      icon: icon,
      deviceIds: deviceIds ?? [],
      imageUrl: imageUrl,
      order: order,
      floorId: floorId,
      isGeneral: isGeneral,
    );
  }

  // Helper methods for serialization

  static IconData _iconFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'living':
        return Icons.living_rounded;
      case 'bedroom':
        return Icons.bed_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'bathroom':
        return Icons.bathroom_rounded;
      case 'office':
        return Icons.work_rounded;
      case 'garage':
        return Icons.garage_rounded;
      case 'garden':
        return Icons.grass_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.living_rounded) return 'living';
    if (icon == Icons.bed_rounded) return 'bedroom';
    if (icon == Icons.kitchen_rounded) return 'kitchen';
    if (icon == Icons.bathroom_rounded) return 'bathroom';
    if (icon == Icons.work_rounded) return 'office';
    if (icon == Icons.garage_rounded) return 'garage';
    if (icon == Icons.grass_rounded) return 'garden';
    return 'home';
  }

  @override
  RoomModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? deviceIds,
    String? imageUrl,
    int? order,
    String? floorId,
    bool? isGeneral,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      deviceIds: deviceIds ?? this.deviceIds,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      floorId: floorId ?? this.floorId,
      isGeneral: isGeneral ?? this.isGeneral,
    );
  }

  @override
  RoomModel addDevice(String deviceId) {
    if (deviceIds.contains(deviceId)) {
      return this;
    }
    return copyWith(
      deviceIds: [...deviceIds, deviceId],
    );
  }

  @override
  RoomModel removeDevice(String deviceId) {
    return copyWith(
      deviceIds: deviceIds.where((id) => id != deviceId).toList(),
    );
  }
}

