import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bennasafi/models/ingredients.dart';
import 'package:bennasafi/services/api_config.dart';

class IngredientDatabase {
  static final http.Client _client = http.Client();

  Stream<List<Ingredients>> get stream async* {
    yield await fetchAll();
  }

  Future<List<Ingredients>> fetchAll({String? type}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ingredients').replace(
        queryParameters: {if (type != null && type.isNotEmpty) 'type': type},
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load ingredients');
      }

      final data = jsonDecode(response.body);
      final list = _extractList(data);
      return list
          .map((item) => Ingredients.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching ingredients: $e');
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
}
