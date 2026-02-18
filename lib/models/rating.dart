class Rating {
  final int id;
  final int userId;
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
    final id = _asInt(json['id']) ?? 0;
    final dynamic recetteRaw = json['recette_id'];
    int recetteId;
    if (recetteRaw is int) {
      recetteId = recetteRaw;
    } else if (recetteRaw is String) {
      recetteId = int.tryParse(recetteRaw) ?? 0;
    } else {
      recetteId = 0;
    }

    final dynamic userIdRaw = json['user_id'];
    int userId;
    if (userIdRaw is int) {
      userId = userIdRaw;
    } else if (userIdRaw is String) {
      userId = int.tryParse(userIdRaw) ?? 0;
    } else {
      userId = 0;
    }

    return Rating(
      id: id,
      userId: userId,
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

  static Rating createNew(int userId, int recetteId, int rating) {
    return Rating(
      id: 0,
      userId: userId,
      recetteId: recetteId,
      rating: rating,
      createdAt: DateTime.now(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
