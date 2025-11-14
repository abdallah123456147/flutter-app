import 'package:uuid/uuid.dart';

class Favoris {
  final String id;
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
      id: json['id'] as String,
      userId: json['user_id'] as String,
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

  // Helper: create a new Favoris with generated UUID
  static Favoris createNew(String userId, int recetteId) {
    return Favoris(
      id: const Uuid().v4(),
      userId: userId,
      recetteId: recetteId,
      createdAt: DateTime.now(),
    );
  }
}
