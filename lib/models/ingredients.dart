class Ingredients {
  final int id;
  final String name;
  final String type;
  final String image;

  Ingredients({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
  });

  factory Ingredients.fromMap(Map<String, dynamic> map) {
    return Ingredients(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      image: map['image'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'image': image};
  }
}
