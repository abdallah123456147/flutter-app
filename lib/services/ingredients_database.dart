import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/ingredients.dart';

class IngredientDatabase {
  final database = Supabase.instance.client.from('ingredients');

  final stream = Supabase.instance.client
      .from('ingredients')
      .stream(primaryKey: ['id'])
      .map(
        (data) =>
            data
                .map((ingredientMap) => Ingredients.fromMap(ingredientMap))
                .toList(),
      );
}
