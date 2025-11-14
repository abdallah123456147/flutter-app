import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/user.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User registration
  Future<Users?> registerUser(Users user) async {
    try {
      final Map<String, dynamic> data =
          await _supabase.from('users').insert(user.toMap()).select().single();
      return Users.fromMap(data);
    } catch (e) {
      // Bubble up for higher-level handling
      rethrow;
    }
  }

  // Get user by email
  Future<Users?> getUserByEmail(String email) async {
    try {
      final data =
          await _supabase
              .from('users')
              .select()
              .eq('email', email)
              .limit(1)
              .maybeSingle();
      if (data == null) return null;
      return Users.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Update user favorites
  Future<void> updateUserFavorites(String userId, List<int> favoris) async {
    try {
      await _supabase
          .from('users')
          .update({
            'favoris': favoris.join(','),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Error updating favorites: $e');
      throw e;
    }
  }

  // Update user recipe data (photo and comment)
  Future<void> updateUserRecipeData(
    String userId,
    String? photoRecette,
    String? comment,
    int recetteId,
  ) async {
    try {
      await _supabase
          .from('users')
          .update({
            'photo_recette': photoRecette,
            'comment': comment,
            'recette_id': recetteId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Error updating user recipe data: $e');
      throw e;
    }
  }

  // Update user profile (name, email, photo)
  Future<void> updateUserProfile(
    String userId,
    String? name,
    String? email,
    String? photo,
  ) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null && name.isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (email != null && email.isNotEmpty) {
        // Normalize email like in registration
        updateData['email'] = email.trim().toLowerCase();
      }
      if (photo != null && photo.isNotEmpty) {
        updateData['photo'] = photo;
      }

      // Only update if there's something to update (besides updated_at)
      if (updateData.length > 1) {
        await _supabase
            .from('users')
            .update(updateData)
            .eq('id', userId);
        
        print('Profile update successful for user: $userId');
      } else {
        print('No fields to update');
        throw Exception('Aucun champ à mettre à jour');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<Users?> getUserById(String id) async {
    try {
      final Map<String, dynamic> data =
          await _supabase.from('users').select().eq('id', id).single();
      return Users.fromMap(data);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  // Check if email already exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final data =
          await _supabase
              .from('users')
              .select('id')
              .eq('email', email)
              .maybeSingle();
      return data != null;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
