class HomeEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;

  const HomeEntity({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });
}


