import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecetteRepository {
  final SupabaseClient supabase;

  RecetteRepository(this.supabase);

  // Add ingredients to a recipe (using bulk insert)
  Future<void> addIngredientsToRecette({
    required String recetteId,
    required List<int> ingredientIds,
    List<String>? quantities,
    List<String>? unite,
  }) async {
    // Prepare all insert operations as a list of maps
    final inserts = List<Map<String, dynamic>>.generate(ingredientIds.length, (
      i,
    ) {
      return {
        'recette_id': recetteId,
        'ingredient_id': ingredientIds[i],
        'quantity':
            quantities != null && i < quantities.length ? quantities[i] : null,
        'unit': unite != null && i < unite.length ? unite[i] : null,
      };
    });

    // Execute as a single bulk insert
    await supabase.from('recette_ingredients').insert(inserts);
  }

  // Get all ingredients for a recipe (corrected query)
  Future<List<Ingredients>> getIngredientsForRecette(String recetteId) async {
    final response = await supabase
        .from('recette_ingredients')
        .select('''
          ingredient:ingredient_id (
            id,
            nameIngredient,
            quantity,
            unite,
            imageIngredient,
            created_at
          )
        ''')
        .eq('recette_id', recetteId);

    final data = response as List<dynamic>;
    return data.map((item) => Ingredients.fromMap(item['ingredient'])).toList();
  }

  // Get all recipes that use a specific ingredient (corrected query)
  Future<List<Recettes>> getRecettesForIngredient(int ingredientId) async {
    final response = await supabase
        .from('recette_ingredients')
        .select('''
          recette:recette_id (
            id,
            name,
            description,
            type,
            soustype,
            preparation,
            cuisson,
            nbre,
            image
          )
        ''')
        .eq('ingredient_id', ingredientId);

    final data = response as List<dynamic>;
    return data.map((item) => Recettes.fromMap(item['recette'])).toList();
  }

  // Additional useful methods
  Future<void> removeIngredientFromRecette({
    required String recetteId,
    required int ingredientId,
  }) async {
    await supabase.from('recette_ingredients').delete().match({
      'recette_id': recetteId,
      'ingredient_id': ingredientId,
    });
  }

  Future<void> updateIngredientQuantity({
    required String recetteId,
    required int ingredientId,
    required String newQuantity,
  }) async {
    await supabase
        .from('recette_ingredients')
        .update({'quantity': newQuantity})
        .match({'recette_id': recetteId, 'ingredient_id': ingredientId});
  }
}
