import 'package:uuid/uuid.dart';

class Rating {
  final String id;
  final String userId;
  final int recetteId;
  final int rating; // value between 1 and 5
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.userId,
    required this.recetteId,
    required this.rating,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    final dynamic recetteRaw = json['recette_id'];
    int recetteId;
    if (recetteRaw is int) {
      recetteId = recetteRaw;
    } else if (recetteRaw is String) {
      recetteId = int.tryParse(recetteRaw) ?? 0;
    } else {
      recetteId = 0;
    }
    return Rating(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recetteId: recetteId,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recette_id': recetteId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Rating createNew(String userId, int recetteId, int rating) {
    return Rating(
      id: const Uuid().v4(),
      userId: userId,
      recetteId: recetteId,
      rating: rating,
      createdAt: DateTime.now(),
    );
  }
}
