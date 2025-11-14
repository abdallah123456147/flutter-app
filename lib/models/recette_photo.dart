class RecettePhoto {
  final int? id;
  final int recetteId;
  final String imageUrl;
  final String? userId;

  RecettePhoto({
    this.id,
    required this.recetteId,
    required this.imageUrl,
    this.userId,
  });

  factory RecettePhoto.fromMap(Map<String, dynamic> map) {
    return RecettePhoto(
      id: map['id'] as int?,
      recetteId: map['recette_id'] as int,
      imageUrl: map['image_url'] as String,
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'recette_id': recetteId, 'image_url': imageUrl, 'user_id': userId};
  }
}
