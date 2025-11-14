import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comments.dart';

class CommentDatabase {
  final supabase = Supabase.instance.client;

  // 🟢 Add a comment
  Future<void> addComment(Comments comment) async {
    await supabase.from('comments').insert(comment.toMap());
  }

  Future<void> insertComment(Comments comment) async {
    final payload = comment.toMap();
    payload.remove('id');
    payload.remove('created_at');
    payload.remove('updated_at');

    await supabase.from('comments').insert(payload);
  }

  // ✅ FIXED: Proper join syntax
  Future<List<Comments>> fetchCommentsByRecette(int recetteId) async {
    try {
      final data = await supabase
          .from('comments')
          .select('''
            *,
            users!inner(*)
          ''')
          .eq('recette_id', recetteId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Comments.fromMapWithUser(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in fetchCommentsByRecette: $e');
      // Fallback to simple query without join
      return await getCommentsByRecetteId(recetteId);
    }
  }

  // Alternative method with different join syntax
  Future<List<Comments>> fetchCommentsByRecetteAlternative(
    int recetteId,
  ) async {
    try {
      final data = await supabase
          .from('comments')
          .select('*, users(id, name, email, photo)')
          .eq('recette_id', recetteId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Comments.fromMapWithUser(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in fetchCommentsByRecetteAlternative: $e');
      return await getCommentsByRecetteId(recetteId);
    }
  }

  // 🟡 Get all comments for a recipe (without user join)
  Future<List<Comments>> getCommentsByRecetteId(int recetteId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('recette_id', recetteId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => Comments.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  // 🔵 Get all comments by a user
  Future<List<Comments>> getCommentsByUserId(String userId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => Comments.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  // 🟣 Update a comment
  Future<void> updateComment(String id, String newComment) async {
    await supabase
        .from('comments')
        .update({
          'comment': newComment,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  // 🔴 Delete a comment
  Future<void> deleteComment(String id) async {
    await supabase.from('comments').delete().eq('id', id);
  }
}
