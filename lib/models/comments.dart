import 'user.dart';

class Comments {
  final int? id;
  final String? comment;
  final int? userId;
  final int? recetteId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Users? user; // populated when joining users

  Comments({
    this.id,
    required this.comment,
    required this.userId,
    required this.recetteId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'comment': comment,
      'user_id': userId,
      'recette_id': recetteId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Comments.fromMap(Map<String, dynamic> map) {
    return Comments(
      id: _asInt(map['id']),
      comment: map['comment'],
      userId: _asInt(map['user_id']),
      recetteId: _asInt(map['recette_id']),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  factory Comments.fromMapWithUser(Map<String, dynamic> map) {
    final base = Comments.fromMap(map);
    Users? joinedUser;
    final dynamic userMap = map['user'];
    if (userMap is Map<String, dynamic>) {
      joinedUser = Users.fromMap(userMap);
    }
    return Comments(
      id: base.id,
      comment: base.comment,
      userId: base.userId,
      recetteId: base.recetteId,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      user: joinedUser,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
