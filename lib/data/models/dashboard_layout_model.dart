import 'dart:convert';

/// Layout model for advanced dashboard sections and columns.
/// Persists how high-level sections (devices grid, LED control, etc.)
/// are arranged, sized, and distributed across columns.

enum DashboardSectionType { devices, led, thermostat, scenarios, camera, tabletCharger, music, security, curtain, elevator, doorLock }

enum DashboardSectionSize { compact, regular, expanded }

extension DashboardSectionSizeX on DashboardSectionSize {
  String get name => toString().split('.').last;

  static DashboardSectionSize fromName(
    String? value, {
    DashboardSectionSize fallback = DashboardSectionSize.regular,
  }) {
    if (value == null) return fallback;
    return DashboardSectionSize.values.firstWhere(
      (element) => element.name == value,
      orElse: () => fallback,
    );
  }
}

extension DashboardSectionTypeX on DashboardSectionType {
  String get name => toString().split('.').last;

  static DashboardSectionType fromName(
    String? value, {
    DashboardSectionType fallback = DashboardSectionType.devices,
  }) {
    if (value == null) return fallback;
    return DashboardSectionType.values.firstWhere(
      (element) => element.name == value,
      orElse: () => fallback,
    );
  }
}

/// Configuration for a single dashboard section.
class DashboardSectionModel {
  final String id;
  final DashboardSectionType type;
  final DashboardSectionSize size;
  final bool isLocked;

  const DashboardSectionModel({
    required this.id,
    required this.type,
    this.size = DashboardSectionSize.regular,
    this.isLocked = false,
  });

  DashboardSectionModel copyWith({DashboardSectionSize? size, bool? isLocked}) {
    return DashboardSectionModel(
      id: id,
      type: type,
      size: size ?? this.size,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  /// Value used to distribute vertical space inside a column.
  double get heightWeight {
    final base = switch (type) {
      DashboardSectionType.devices => 4.2,
      DashboardSectionType.led => 1.9,
      DashboardSectionType.thermostat => 2.1,
      DashboardSectionType.scenarios => 3.0,
      DashboardSectionType.camera => 2.4,
      DashboardSectionType.tabletCharger => 2.0,
      DashboardSectionType.music => 2.0,
      DashboardSectionType.security => 2.2,
      DashboardSectionType.curtain => 2.0,
      DashboardSectionType.elevator => 2.1,
      DashboardSectionType.doorLock => 1.8,
    };

    final multiplier = switch (size) {
      DashboardSectionSize.compact => 0.82,
      DashboardSectionSize.regular => 1.0,
      DashboardSectionSize.expanded => 1.35,
    };

    return base * multiplier;
  }

  DashboardSectionSize nextSize() {
    final options = _sizeOptionsFor(type);
    final currentIndex = options.indexOf(size);
    final nextIndex = (currentIndex + 1) % options.length;
    return options[nextIndex];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'size': size.name,
      'isLocked': isLocked,
    };
  }

  factory DashboardSectionModel.fromJson(Map<String, dynamic> json) {
    final type = DashboardSectionTypeX.fromName(
      json['type'] as String?,
      fallback: DashboardSectionType.devices,
    );
    return DashboardSectionModel(
      id: json['id'] as String? ?? type.name,
      type: type,
      size: DashboardSectionSizeX.fromName(
        json['size'] as String?,
        fallback: _defaultSizeFor(type),
      ),
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  static DashboardSectionModel defaultFor(DashboardSectionType type) {
    return DashboardSectionModel(
      id: type.name,
      type: type,
      size: _defaultSizeFor(type),
      isLocked: type == DashboardSectionType.devices,
    );
  }
}

/// Configuration for a horizontal column inside the dashboard layout.
class DashboardColumnModel {
  final String id;
  final double flex;
  final List<DashboardSectionModel> sections;

  const DashboardColumnModel({
    required this.id,
    required this.flex,
    required this.sections,
  });

  DashboardColumnModel copyWith({
    double? flex,
    List<DashboardSectionModel>? sections,
  }) {
    return DashboardColumnModel(
      id: id,
      flex: flex ?? this.flex,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flex': flex,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  factory DashboardColumnModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    return DashboardColumnModel(
      id: json['id'] as String? ?? _randomColumnId(),
      flex: (json['flex'] as num?)?.toDouble() ?? 30.0,
      sections: sectionsJson
          .map((e) => DashboardSectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Root layout object containing all columns.
class DashboardLayoutModel {
  final List<DashboardColumnModel> columns;

  const DashboardLayoutModel({required this.columns});

  double get totalFlex =>
      columns.fold<double>(0, (previous, column) => previous + column.flex);

  DashboardLayoutModel copyWith({List<DashboardColumnModel>? columns}) {
    return DashboardLayoutModel(columns: columns ?? this.columns);
  }

  Map<String, dynamic> toJson() {
    return {'columns': columns.map((c) => c.toJson()).toList()};
  }

  String toJsonString() => jsonEncode(toJson());

  factory DashboardLayoutModel.fromJson(Map<String, dynamic> json) {
    final columnsJson = json['columns'] as List<dynamic>? ?? [];
    final columns = columnsJson
        .map((e) => DashboardColumnModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (columns.isEmpty) {
      return DashboardLayoutModel.defaultLayout();
    }

    return DashboardLayoutModel(columns: columns);
  }

  factory DashboardLayoutModel.fromJsonString(String jsonString) {
    return DashboardLayoutModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  static DashboardLayoutModel defaultLayout() {
    // Start with devices and scenarios sections - other sections will be added dynamically
    return DashboardLayoutModel(
      columns: [
        DashboardColumnModel(
          id: 'column_devices',
          flex: 60,
          sections: [
            DashboardSectionModel.defaultFor(DashboardSectionType.devices),
          ],
        ),
        DashboardColumnModel(
          id: 'column_controls',
          flex: 40,
          sections: [
            DashboardSectionModel.defaultFor(DashboardSectionType.scenarios),
          ],
        ),
      ],
    );
  }
}

DashboardSectionSize _defaultSizeFor(DashboardSectionType type) {
  return switch (type) {
    DashboardSectionType.devices => DashboardSectionSize.expanded,
    DashboardSectionType.led => DashboardSectionSize.regular,
    DashboardSectionType.thermostat => DashboardSectionSize.regular,
    DashboardSectionType.scenarios => DashboardSectionSize.regular,
    DashboardSectionType.camera => DashboardSectionSize.regular,
    DashboardSectionType.tabletCharger => DashboardSectionSize.regular,
    DashboardSectionType.music => DashboardSectionSize.regular,
    DashboardSectionType.security => DashboardSectionSize.regular,
    DashboardSectionType.curtain => DashboardSectionSize.regular,
    DashboardSectionType.elevator => DashboardSectionSize.regular,
    DashboardSectionType.doorLock => DashboardSectionSize.regular,
  };
}

List<DashboardSectionSize> _sizeOptionsFor(DashboardSectionType type) {
  switch (type) {
    case DashboardSectionType.devices:
      return const [
        DashboardSectionSize.regular,
        DashboardSectionSize.expanded,
      ];
    case DashboardSectionType.led:
    case DashboardSectionType.thermostat:
    case DashboardSectionType.scenarios:
    case DashboardSectionType.camera:
    case DashboardSectionType.tabletCharger:
    case DashboardSectionType.music:
    case DashboardSectionType.security:
    case DashboardSectionType.curtain:
    case DashboardSectionType.elevator:
    case DashboardSectionType.doorLock:
      return const [
        DashboardSectionSize.compact,
        DashboardSectionSize.regular,
        DashboardSectionSize.expanded,
      ];
  }
}

String _randomColumnId() {
  return 'column_${DateTime.now().microsecondsSinceEpoch}';
}
