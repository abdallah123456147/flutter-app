import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recette_photo.dart';
import '../services/api_config.dart';

class RecettePhotoService {
  static final http.Client _client = http.Client();
  static const String _kTokenKey = 'auth_token';

  Future<List<RecettePhoto>> fetchPhotos(int recetteId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/$recetteId/photos',
      );
      print('Fetching photos from: $uri');
      final response = await _client.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('Error: Status ${response.statusCode}');
        throw Exception('Failed to load photos: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      print('Decoded data: $data');
      final list = _extractList(data);
      print('Extracted list: $list');
      print('Number of photos: ${list.length}');

      final photos =
          list
              .map(
                (item) => RecettePhoto.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList();

      for (var photo in photos) {
        print(
          'Photo: ID=${photo.id}, RecetteID=${photo.recetteId}, URL=${photo.imageUrl}',
        );
      }

      return photos;
    } catch (e) {
      print('Error fetching photos: $e');
      return [];
    }
  }

  Future<RecettePhoto?> addPhoto({
    required int recetteId,
    required File file,
    int? userId,
    String? token,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/recettes/$recetteId/photos',
    );

    // Get token if not provided
    String? authToken = token;
    if (authToken == null || authToken.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString(_kTokenKey);
    }

    if (authToken == null || authToken.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    if (userId != null && userId > 0) {
      request.fields['user_id'] = userId.toString();
    }
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to upload photo');
    }

    final data = jsonDecode(response.body);
    final item = _extractItem(data) ?? data;
    return RecettePhoto.fromMap(Map<String, dynamic>.from(item));
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  }

  static Map<String, dynamic>? _extractItem(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}
