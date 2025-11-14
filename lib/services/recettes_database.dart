import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/recettes.dart';

class RecetteDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Recettes>> get stream {
    return _client
        .from('recettes')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((map) => Recettes.fromMap(map)).toList());
  }

  // Fetch a single recipe with its relations (ingredients via recette_ingredients, niveau, pays)
  Future<Recettes?> fetchById(int id) async {
    final List<dynamic> data = await _client
        .from('recettes')
        .select('''
          id,
          name,
          description,
          type,
          soustype,
          preparation,
          cuisson,
          nbre,
          image,
          recette_ingredients(
            id,
            quantity,
            unit,
            ingredients(
              id,
              name,
              type,
              image
            )
          ),
          niveau(
            id,
            name,
            image
          ),
          pays(
            id,
            name,
            image
          )
        ''')
        .eq('id', id)
        .limit(1);

    if (data.isEmpty) return null;
    return Recettes.fromMap(data.first as Map<String, dynamic>);
  }

  Future<List<Recettes>> fetchBySubtype(String subtypeId) async {
    try {
      final List<dynamic> data = await _client
          .from('recettes')
          .select('''
          id,
          name,
          description,
          type,
          soustype,
          preparation,
          cuisson,
          nbre,
          image,
          recette_ingredients(
            id,
            quantity,
            unit,
            ingredients(
              id,
              name,
              type,
              image
            )
          ),
          niveau(
            id,
            name,
            image
          ),
          pays(
            id,
            name,
            image
          )
        ''')
          .eq('soustype', subtypeId);

      return data
          .map((map) => Recettes.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recipes by subtype: $e');
      return [];
    }
  }

  static Future<List<Recettes>> getRecettesBySousType(String soustype) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final List<dynamic> data = await client
          .from('recettes')
          .select('''
          id,
          name,
          description,
          type,
          soustype,
          preparation,
          cuisson,
          nbre,
          image,
          recette_ingredients(
            id,
            quantity,
            unit,
            ingredients(
              id,
              name,
              type,
              image
            )
          ),
          niveau(
            id,
            name,
            image
          ),
          pays(
            id,
            name,
            image
          )
        ''')
          .eq('soustype', soustype);

      return data
          .map((map) => Recettes.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recipes by sous-type "$soustype": $e');
      return [];
    }
  }

  // Search recipes by name or description
  static Future<List<Recettes>> searchRecettes(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final SupabaseClient client = Supabase.instance.client;
      final List<dynamic> data = await client
          .from('recettes')
          .select('''
          id,
          name,
          description,
          type,
          soustype,
          preparation,
          cuisson,
          nbre,
          image,
          recette_ingredients(
            id,
            quantity,
            unit,
            ingredients(
              id,
              name,
              type,
              image
            )
          ),
          niveau(
            id,
            name,
            image
          ),
          pays(
            id,
            name,
            image
          )
        ''')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .limit(50);

      return data
          .map((map) => Recettes.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching recipes with query "$query": $e');
      return [];
    }
  }
}
