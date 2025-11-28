import 'dart:convert';

enum CardType {
  light,
  curtain,
  thermostat,
  security,
  music,
  tv,
  fan,
  camera,
  door,
  window,
  airConditioner,
  humidifier,
}

enum CardSize {
  small, // 1x1
  medium, // 2x1
  large, // 2x2
  wide, // 3x1
}

class DashboardCardModel {
  final String id;
  final CardType type;
  final CardSize size;
  final int position;
  final Map<String, dynamic> data;
  final bool isVisible;

  const DashboardCardModel({
    required this.id,
    required this.type,
    required this.size,
    required this.position,
    this.data = const {},
    this.isVisible = true,
  });

  DashboardCardModel copyWith({
    String? id,
    CardType? type,
    CardSize? size,
    int? position,
    Map<String, dynamic>? data,
    bool? isVisible,
  }) {
    return DashboardCardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      position: position ?? this.position,
      data: data ?? this.data,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'size': size.name,
      'position': position,
      'data': data,
      'isVisible': isVisible,
    };
  }

  factory DashboardCardModel.fromJson(Map<String, dynamic> json) {
    return DashboardCardModel(
      id: json['id'] as String,
      type: CardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CardType.light,
      ),
      size: CardSize.values.firstWhere(
        (e) => e.name == json['size'],
        orElse: () => CardSize.medium,
      ),
      position: json['position'] as int,
      data: json['data'] as Map<String, dynamic>? ?? {},
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  static List<DashboardCardModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => DashboardCardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<DashboardCardModel> cards) {
    return cards.map((card) => card.toJson()).toList();
  }

  static String toJsonString(List<DashboardCardModel> cards) {
    return jsonEncode(toJsonList(cards));
  }

  static List<DashboardCardModel> fromJsonString(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return fromJsonList(jsonList);
  }
}

