import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/rating.dart';

class RatingDatabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int?> getUserRating(String userId, int recetteId) async {
    try {
      final data =
          await _supabase
              .from('ratings')
              .select('rating')
              .eq('user_id', userId)
              .eq('recette_id', recetteId)
              .maybeSingle();
      if (data == null) return null;
      return data['rating'] as int?;
    } on PostgrestException catch (e) {
      throw Exception('Error fetching user rating: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Rating> upsertRating(String userId, int recetteId, int value) async {
    if (value < 1 || value > 5) {
      throw ArgumentError('rating must be between 1 and 5');
    }
    try {
      final existing =
          await _supabase
              .from('ratings')
              .select('*')
              .eq('user_id', userId)
              .eq('recette_id', recetteId)
              .maybeSingle();

      if (existing == null) {
        // Insert minimal payload to satisfy RLS (let DB handle id/timestamps)
        final payload = {
          'user_id': userId,
          'recette_id': recetteId,
          'rating': value,
        };
        final inserted =
            await _supabase.from('ratings').insert(payload).select().single();
        return Rating.fromJson(Map<String, dynamic>.from(inserted));
      } else {
        final updated =
            await _supabase
                .from('ratings')
                .update({'rating': value})
                .eq('id', existing['id'] as String)
                .select()
                .single();
        return Rating.fromJson(Map<String, dynamic>.from(updated));
      }
    } on PostgrestException catch (e) {
      throw Exception('Error upserting rating: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<(double avg, int count)> getAverageForRecette(int recetteId) async {
    try {
      final List rows = await _supabase
          .from('ratings')
          .select('rating')
          .eq('recette_id', recetteId);
      if (rows.isEmpty) return (0.0, 0);
      double sum = 0;
      int count = 0;
      for (final row in rows) {
        final r = (row['rating'] as int?) ?? 0;
        if (r > 0) {
          sum += r.toDouble();
          count += 1;
        }
      }
      if (count == 0) return (0.0, 0);
      return (sum / count, count);
    } on PostgrestException catch (e) {
      throw Exception('Error computing average rating: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
