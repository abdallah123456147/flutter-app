class RecetteIngredient {
  final int id;
  final int recetteId; // FK to recettes.id
  final int ingredientId; // FK to ingredients.id
  final String quantity;
  final String unit;

  RecetteIngredient({
    required this.id,
    required this.recetteId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });

  factory RecetteIngredient.fromMap(Map<String, dynamic> map) {
    return RecetteIngredient(
      id: map['id'] as int? ?? 0,
      recetteId: map['recette_id'] as int,
      ingredientId: map['ingredient_id'] as int,
      quantity: map['quantity'] as String,
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recette_id': recetteId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
