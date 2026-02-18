import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bennasafi/models/rating.dart';
import 'package:bennasafi/services/api_config.dart';

class RatingDatabase {
  static final http.Client _client = http.Client();
  static const String _kTokenKey = 'auth_token';

  Future<int?> getUserRating(int? userId, int recetteId) async {
    if (userId == null || userId <= 0) return null;
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/$recetteId/ratings',
      ).replace(queryParameters: {'user_id': userId.toString()});

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load rating');
      }

      final data = jsonDecode(response.body);
      final item = _extractItem(data);
      if (item == null) return null;
      return item['rating'] as int?;
    } catch (e) {
      throw Exception('Error fetching user rating: $e');
    }
  }

  Future<Rating> upsertRating(int? userId, int recetteId, int value) async {
    if (userId == null || userId <= 0) {
      throw ArgumentError('userId must be a valid integer');
    }
    if (value < 1 || value > 5) {
      throw ArgumentError('rating must be between 1 and 5');
    }
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/$recetteId/ratings',
      );

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId, 'rating': value}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to save rating: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      final item = _extractItem(data) ?? data;
      return Rating.fromJson(Map<String, dynamic>.from(item));
    } catch (e) {
      throw Exception('Error upserting rating: $e');
    }
  }

  Future<(double avg, int count)> getAverageForRecette(int recetteId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/$recetteId/ratings/average',
      );

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load rating average');
      }

      final data = jsonDecode(response.body);
      final item = _extractItem(data) ?? {};
      final avg = (item['avg'] as num?)?.toDouble() ?? 0.0;
      final count = (item['count'] as num?)?.toInt() ?? 0;
      return (avg, count);
    } catch (e) {
      throw Exception('Error computing average rating: $e');
    }
  }

  static Map<String, dynamic>? _extractItem(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}
