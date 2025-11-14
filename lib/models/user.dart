class Users {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String? photo;
  final String? photoRecette;
  final String? comment;
  final int? recetteId;
  final String gender;
  // final List<int> favoris;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Users({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photo,
    this.photoRecette,
    this.comment,
    this.recetteId,
    required this.gender,
    List<int>? favoris,
    this.createdAt,
    this.updatedAt,
  });
  // : favoris = favoris ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photo': photo,
      'photo_recette': photoRecette,
      'comment': comment,
      'recette_id': recetteId,
      'gender': gender,
      // 'favoris': favoris.join(','),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      photo: map['photo'],
      photoRecette: map['photo_recette'],
      comment: map['comment'],
      recetteId: map['recette_id'],
      gender: map['gender'],
      // favoris:
      //     (map['favoris'] as String?)
      //         ?.split(',')
      //         .map((e) => int.tryParse(e) ?? 0)
      //         .where((id) => id > 0)
      //         .toList() ??
      //     [],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
