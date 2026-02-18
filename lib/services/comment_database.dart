import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comments.dart';
import '../services/api_config.dart';

class CommentDatabase {
  static final http.Client _client = http.Client();
  static const String _kTokenKey = 'auth_token';

  Future<void> insertComment(Comments comment) async {
    if (comment.recetteId == null) {
      throw Exception('recetteId is required');
    }

    // Get auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/recettes/${comment.recetteId}/comments',
    );

    final payload = <String, dynamic>{
      'comment': comment.comment,
      'user_id': comment.userId,
    };

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ?? 'Failed to add comment: ${response.statusCode}',
      );
    }
  }

  Future<List<Comments>> fetchCommentsByRecette(int recetteId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/$recetteId/comments',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load comments');
      }

      final data = jsonDecode(response.body);
      final list = _extractList(data);

      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['user'] is Map<String, dynamic>) {
          return Comments.fromMapWithUser(map);
        }
        return Comments.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('Error in fetchCommentsByRecette: $e');
      return await getCommentsByRecetteId(recetteId);
    }
  }

  Future<List<Comments>> getCommentsByRecetteId(int recetteId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/comments',
      ).replace(queryParameters: {'recette_id': recetteId.toString()});

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load comments');
      }

      final data = jsonDecode(response.body);
      final list = _extractList(data);

      return list
          .map((item) => Comments.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error in getCommentsByRecetteId: $e');
      return [];
    }
  }

  Future<List<Comments>> getCommentsByUserId(String userId) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/comments',
      ).replace(queryParameters: {'user_id': userId});

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load comments');
      }

      final data = jsonDecode(response.body);
      final list = _extractList(data);

      return list
          .map((item) => Comments.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error in getCommentsByUserId: $e');
      return [];
    }
  }

  Future<void> updateComment(int id, String newComment) async {
    // Get auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/comments/$id');
    final response = await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': newComment}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ??
            'Failed to update comment: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteComment(int id) async {
    // Get auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/comments/$id');
    final response = await _client.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ??
            'Failed to delete comment: ${response.statusCode}',
      );
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
