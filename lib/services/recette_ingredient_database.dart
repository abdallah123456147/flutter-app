import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/models/recettes.dart';
import 'package:http/http.dart' as http;
import 'package:bennasafi/services/api_config.dart';

class RecetteRepository {
  RecetteRepository();

  static final http.Client _client = http.Client();

  Future<List<Ingredients>> getIngredientsForRecette(int recetteId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/recettes/$recetteId');
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load recipe');
      }

      final data = jsonDecode(response.body);
      final map = _extractItem(data);
      if (map == null) return [];

      final recette = Recettes.fromMap(map);
      return recette.ingredients ?? [];
    } catch (e) {
      debugPrint('Error fetching ingredients for recette: $e');
      return [];
    }
  }

  // Get all recipes that use a specific ingredient (corrected query)
  Future<List<Recettes>> getRecettesForIngredient(int ingredientId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/ingredients/$ingredientId/recettes',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load recipes by ingredient');
      }

      final data = jsonDecode(response.body);
      final list = _extractList(data);
      return list
          .map((item) => Recettes.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recipes for ingredient: $e');
      return [];
    }
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
