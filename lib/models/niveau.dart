class Niveau {
  final String id;
  final String name;
  final String image;

  Niveau({required this.id, required this.name, required this.image});

  factory Niveau.fromMap(Map<String, dynamic> map) {
    final dynamic rawId = map['id'];
    return Niveau(
      id: rawId != null ? rawId.toString() : '',
      name: (map['name'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image': image};
  }
}
