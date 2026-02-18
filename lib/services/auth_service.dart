import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_config.dart';
import 'favorites_database.dart';

class AuthService with ChangeNotifier {
  Users? _currentUser;
  bool _isLoggedIn = false;
  String? _lastError;
  String? _authToken;

  static final http.Client _client = http.Client();
  static const String _kUserIdKey = 'current_user_id';
  static const String _kTokenKey = 'auth_token';

  final FavoritesDatabase _favoritesDb = FavoritesDatabase();

  Users? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get lastError => _lastError;

  Future<bool> login(String email, String password) async {
    try {
      _lastError = null;
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      final data = jsonDecode(response.body);
      final payload = _extractItem(data);
      if (payload == null) return false;

      final userMap = Map<String, dynamic>.from(payload['user']);
      final token = payload['token'] as String?;
      if (token == null || token.isEmpty) return false;

      _currentUser = Users.fromMap(userMap);
      _isLoggedIn = true;
      _authToken = token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserIdKey, _currentUser!.id ?? '');
      await prefs.setString(_kTokenKey, token);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  Future<bool> register(Users user) async {
    try {
      _lastError = null;
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/register');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': user.name.trim(),
          'email': user.email.trim().toLowerCase(),
          'password': user.password,
          'password_confirmation': user.password,
          'gender': user.gender,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _lastError = 'Inscription echouee';
        return false;
      }

      final data = jsonDecode(response.body);
      final payload = _extractItem(data);
      if (payload == null) return false;

      final userMap = Map<String, dynamic>.from(payload['user']);
      final token = payload['token'] as String?;
      if (token == null || token.isEmpty) return false;

      _currentUser = Users.fromMap(userMap);
      _isLoggedIn = true;
      _authToken = token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserIdKey, _currentUser!.id ?? '');
      await prefs.setString(_kTokenKey, token);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _authToken = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_kUserIdKey);
      prefs.remove(_kTokenKey);
    });
    notifyListeners();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      if (token == null || token.isEmpty) return;

      _authToken = token;
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/me');
      final response = await _client.get(
        uri,
        headers: _authHeaders(token),
      );

      if (response.statusCode != 200) {
        await prefs.remove(_kUserIdKey);
        await prefs.remove(_kTokenKey);
        return;
      }

      final data = jsonDecode(response.body);
      final userMap = _extractItem(data);
      if (userMap == null) return;

      _currentUser = Users.fromMap(Map<String, dynamic>.from(userMap));
      _isLoggedIn = true;
      notifyListeners();
    } catch (_) {
      // ignore init errors
    }
  }

  Future<void> logoutFromServer() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/logout');
    await _client.post(uri, headers: _authHeaders(token));
  }

  Future<void> addToFavorites(int recetteId) async {
    await _favoritesDb.addToFavorites(recetteId);
    notifyListeners();
  }

  Future<void> removeFromFavorites(int recetteId) async {
    await _favoritesDb.removeFromFavoritesByRecipe(recetteId);
    notifyListeners();
  }

  Future<bool> isFavorite(int recetteId) async {
    return _favoritesDb.isRecipeFavorited(recetteId);
  }

  Future<bool> updateProfile({String? name, String? email, String? photo}) async {
    if (_currentUser == null) return false;
    try {
      _lastError = null;
      final token = await _getToken();
      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile');
      final body = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim().toLowerCase();
      }
      if (photo != null && photo.trim().isNotEmpty) body['photo'] = photo.trim();

      final response = await _client.patch(
        uri,
        headers: _authHeaders(token),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        _lastError = 'Erreur lors de la mise a jour du profil';
        return false;
      }

      final data = jsonDecode(response.body);
      final userMap = _extractItem(data);
      if (userMap == null) return false;

      _currentUser = Users.fromMap(Map<String, dynamic>.from(userMap));
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    try {
      _lastError = null;
      final token = await _getToken();
      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile/photo');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        })
        ..files.add(await http.MultipartFile.fromPath('photo', filePath));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        _lastError = 'Erreur lors du telechargement de la photo';
        return false;
      }

      final data = jsonDecode(response.body);
      final userMap = _extractItem(data);
      if (userMap == null) return false;

      _currentUser = Users.fromMap(Map<String, dynamic>.from(userMap));
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  Future<String?> _getToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_kTokenKey);
    return _authToken;
  }

  Map<String, String> _authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Map<String, dynamic>? _extractItem(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map<String, dynamic>) return data;
    return null;
  }
}

extension UserCopyWith on Users {
  Users copyWith({
    String? name,
    String? email,
    String? password,
    String? photo,
    String? photoRecette,
    String? comment,
    int? recetteId,
    String? gender,
    List<int>? favoris,
  }) {
    return Users(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photo: photo ?? this.photo,
      photoRecette: photoRecette ?? this.photoRecette,
      comment: comment ?? this.comment,
      recetteId: recetteId ?? this.recetteId,
      gender: gender ?? this.gender,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
