import 'package:supabase/supabase.dart';
import 'package:bennasafi/models/favorites.dart';

class FavoritesDatabase {
  final SupabaseClient supabase;

  FavoritesDatabase({required this.supabase});

  // Add a recipe to favorites
  Future<Favoris> addToFavorites(String userId, int recetteId) async {
    try {
      final favoris = Favoris.createNew(userId, recetteId);

      final response =
          await supabase
              .from('favoris')
              .insert(favoris.toJson())
              .select()
              .single();

      return Favoris.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error adding to favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Remove a recipe from favorites
  Future<void> removeFromFavorites(String favorisId) async {
    try {
      await supabase.from('favoris').delete().eq('id', favorisId);
    } on PostgrestException catch (e) {
      throw Exception('Error removing from favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Remove from favorites by user and recipe ID
  Future<void> removeFromFavoritesByUserAndRecipe(
    String userId,
    int recetteId,
  ) async {
    try {
      await supabase
          .from('favoris')
          .delete()
          .eq('user_id', userId)
          .eq('recette_id', recetteId);
    } on PostgrestException catch (e) {
      throw Exception('Error removing from favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all favorites for a user
  Future<List<Favoris>> getUserFavorites(String userId) async {
    try {
      final response = await supabase
          .from('favoris')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Favoris.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error fetching favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Check if a recipe is favorited by user
  Future<bool> isRecipeFavorited(String userId, int recetteId) async {
    try {
      final response =
          await supabase
              .from('favoris')
              .select('id')
              .eq('user_id', userId)
              .eq('recette_id', recetteId)
              .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw Exception('Error checking favorite status: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get favorite ID for a user and recipe
  Future<String?> getFavoriteId(String userId, int recetteId) async {
    try {
      final response =
          await supabase
              .from('favoris')
              .select('id')
              .eq('user_id', userId)
              .eq('recette_id', recetteId)
              .maybeSingle();

      return response?['id'] as String?;
    } on PostgrestException catch (e) {
      throw Exception('Error getting favorite ID: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get favorite count for a recipe
  // Future<int> getRecipeFavoriteCount(String recetteId) async {
  //   try {
  //     final response = await supabase
  //         .from('favoris')
  //         .select('id', count: CountOption.exact)
  //         .eq('recette_id', recetteId);

  //     return response.count ?? 0;
  //   } on PostgrestException catch (e) {
  //     throw Exception('Error getting favorite count: ${e.message}');
  //   } catch (e) {
  //     throw Exception('Unexpected error: $e');
  //   }
  // }

  // Remove all favorites for a user (useful for account deletion)
  Future<void> clearUserFavorites(String userId) async {
    try {
      await supabase.from('favoris').delete().eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error clearing favorites: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
