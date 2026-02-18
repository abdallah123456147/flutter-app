import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bennasafi/models/recettes.dart';
import 'package:bennasafi/services/api_config.dart';

class RecetteDatabase {
  RecetteDatabase._internal();
  static final RecetteDatabase _instance = RecetteDatabase._internal();
  factory RecetteDatabase() => _instance;

  static final http.Client _client = http.Client();

  Stream<List<Recettes>> get stream async* {
    yield await fetchAll();
  }

  Future<Recettes?> fetchById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/recettes/$id');
      final response = await _client.get(uri);
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      debugPrint('GET $uri -> ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Response body: $bodyPreview');
        throw Exception('Failed to load recipe');
      }
      final data = jsonDecode(response.body);
      final map = _extractItem(data);
      if (map == null) return null;
      return Recettes.fromMap(map);
    } catch (e) {
      debugPrint('Error fetching recipe by id: $e');
      return null;
    }
  }

  Future<List<Recettes>> fetchBySubtype(String subtypeId) async {
    return fetchAll(soustype: subtypeId);
  }

  Future<List<Recettes>> fetchAll({
    String? type,
    String? soustype,
    String? query,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/recettes').replace(
        queryParameters: {
          if (type != null && type.isNotEmpty) 'type': type,
          if (soustype != null && soustype.isNotEmpty) 'soustype': soustype,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      final response = await _client.get(uri);
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      debugPrint('GET $uri -> ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Response body: $bodyPreview');
        throw Exception('Failed to load recipes');
      }
      final data = jsonDecode(response.body);
      final list = _extractList(data);

      return list
          .map((item) => Recettes.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      return [];
    }
  }

  Future<Map<String, List<Recettes>>> fetchSections({
    int limit = 6,
    int allLimit = 30,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/sections',
      ).replace(
        queryParameters: {
          'limit': limit.toString(),
          'all_limit': allLimit.toString(),
        },
      );

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load recipe sections');
      }

      final data = jsonDecode(response.body);
      if (data is! Map || data['data'] is! Map) {
        throw Exception('Invalid sections payload');
      }

      final sections = Map<String, dynamic>.from(data['data'] as Map);
      return {
        'lef_lef': _parseList(sections['lef_lef']),
        'omek_sannefa': _parseList(sections['omek_sannefa']),
        'kool_healthy': _parseList(sections['kool_healthy']),
        'benna_3alamiya': _parseList(sections['benna_3alamiya']),
        'plats': _parseList(sections['plats']),
        'desserts': _parseList(sections['desserts']),
        'all': _parseList(sections['all']),
      };
    } catch (e) {
      debugPrint('Error fetching recipe sections: $e');
      return {
        'lef_lef': [],
        'omek_sannefa': [],
        'kool_healthy': [],
        'benna_3alamiya': [],
        'plats': [],
        'desserts': [],
        'all': [],
      };
    }
  }

  static Future<List<Recettes>> getRecettesBySousType(String soustype) async {
    return _instance.fetchAll(soustype: soustype);
  }

  static Future<List<Recettes>> getRecettesByType(String type) async {
    return _instance.fetchAll(type: type);
  }

  static Future<List<Recettes>> searchRecettes(String query) async {
    if (query.trim().isEmpty) return [];
    return _instance.fetchAll(query: query);
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  }

  static List<Recettes> _parseList(dynamic data) {
    final list = _extractList(data);
    return list
        .map((item) => Recettes.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Map<String, dynamic>? _extractItem(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}
