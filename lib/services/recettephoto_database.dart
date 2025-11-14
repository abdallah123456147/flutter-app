import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recette_photo.dart';

class RecettePhotoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RecettePhoto>> fetchPhotos(int recetteId) async {
    final response = await _supabase
        .from('recette_photos')
        .select()
        .eq('recette_id', recetteId);

    if (response != null && response is List) {
      return response.map((e) => RecettePhoto.fromMap(e)).toList();
    }
    return [];
  }

  Future<void> addPhoto(RecettePhoto photo, File file) async {
    final path =
        'recette_photos/recette_${photo.recetteId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload to Supabase Storage
    await _supabase.storage.from('images').upload(path, file);

    final publicUrl = _supabase.storage.from('images').getPublicUrl(path);

    // Insert record into table
    await _supabase.from('recette_photos').insert({
      'recette_id': photo.recetteId,
      'user_id': photo.userId,
      'image_url': publicUrl,
    });
  }
}
