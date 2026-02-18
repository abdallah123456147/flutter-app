class Favoris {
  final int id;
  final String userId;
  final int recetteId;
  final DateTime createdAt;

  Favoris({
    required this.id,
    required this.userId,
    required this.recetteId,
    required this.createdAt,
  });

  // Factory constructor to create object from Supabase record
  factory Favoris.fromJson(Map<String, dynamic> json) {
    return Favoris(
      id: _asInt(json['id']) ?? 0,
      userId: json['user_id']?.toString() ?? '',
      recetteId:
          (json['recette_id'] is int)
              ? json['recette_id'] as int
              : int.parse(json['recette_id'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert object to JSON (for insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recette_id': recetteId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
