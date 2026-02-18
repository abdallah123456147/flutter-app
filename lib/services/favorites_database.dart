import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bennasafi/models/favorites.dart';
import 'package:bennasafi/services/api_config.dart';

class FavoritesDatabase {
  static final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Favoris>> getUserFavorites() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return [];

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/favoris');
    final response = await _client.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to load favorites');
    }

    final data = jsonDecode(response.body);
    final list = _extractList(data);
    return list
        .map((item) => Favoris.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addToFavorites(int recetteId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/favoris');
    final response = await _client.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({'recette_id': recetteId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add favorite');
    }
  }

  Future<void> removeFromFavoritesByRecipe(int recetteId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/favoris/$recetteId');
    final response = await _client.delete(uri, headers: _authHeaders(token));

    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite');
    }
  }

  Future<bool> isRecipeFavorited(int recetteId) async {
    final favorites = await getUserFavorites();
    return favorites.any((f) => f.recetteId == recetteId);
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  }
}
