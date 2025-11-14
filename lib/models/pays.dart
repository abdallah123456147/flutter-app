class Pays {
  final int id;
  final String name;
  final String image;

  Pays({required this.id, required this.name, required this.image});

  factory Pays.fromMap(Map<String, dynamic> map) {
    return Pays(
      id: map['id'] as int? ?? 0, // Provide default if null
      name: map['name'] as String? ?? '',
      image: map['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image': image};
  }
}
