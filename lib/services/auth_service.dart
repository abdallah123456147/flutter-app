import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import 'favorites_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  Users? _currentUser;
  bool _isLoggedIn = false;
  final SupabaseService _supabaseService = SupabaseService();
  late final FavoritesDatabase _favoritesDb = FavoritesDatabase(
    supabase: Supabase.instance.client,
  );
  String? _lastError;
  static const String _kUserIdKey = 'current_user_id';

  Users? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get lastError => _lastError;

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      final Users? user = await _supabaseService.getUserByEmail(email);
      if (user != null && user.password == password) {
        _currentUser = user;
        _isLoggedIn = true;
        // persist user id
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kUserIdKey, user.id!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Register method
  Future<bool> register(Users user) async {
    try {
      _lastError = null;
      final normalizedEmail = user.email.trim().toLowerCase();
      final newUser = await _supabaseService.registerUser(
        Users(
          id: user.id ?? const Uuid().v4(),
          name: user.name.trim(),
          email: normalizedEmail,
          password: user.password,
          photo: user.photo,
          photoRecette: user.photoRecette,
          recetteId: user.recetteId,
          gender: user.gender,
          // favoris: user.favoris,
          createdAt: user.createdAt ?? DateTime.now(),
          updatedAt: user.updatedAt ?? DateTime.now(),
        ),
      );
      if (newUser != null) {
        _currentUser = newUser;
        _isLoggedIn = true;
        // persist user id
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kUserIdKey, newUser.id!);
        notifyListeners();
        return true;
      }
      _lastError = 'Unknown error creating user';
      return false;
    } catch (e) {
      // If unique constraint violation occurs, treat as email exists
      final message = e.toString().toLowerCase();
      if (message.contains('duplicate key') ||
          message.contains('unique constraint') ||
          message.contains('already exists')) {
        _lastError = 'Cette adresse email est déjà utilisée';
        return false;
      }
      _lastError = e.toString();
      print('Registration error: $e');
      return false;
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_kUserIdKey));
    notifyListeners();
  }

  // Initialize from persisted storage
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(_kUserIdKey);
      if (savedUserId == null || savedUserId.isEmpty) return;
      final user = await _supabaseService.getUserById(savedUserId);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
      } else {
        // cleanup if user not found
        await prefs.remove(_kUserIdKey);
      }
    } catch (e) {
      // ignore init errors
    }
  }

  // Add to favorites (favoris table)
  Future<void> addToFavorites(int recetteId) async {
    if (_currentUser == null) return;
    final userId = _currentUser!.id!;
    final already = await _favoritesDb.isRecipeFavorited(userId, recetteId);
    if (already) return;
    await _favoritesDb.addToFavorites(userId, recetteId);
    notifyListeners();
  }

  // Remove from favorites (favoris table)
  Future<void> removeFromFavorites(int recetteId) async {
    if (_currentUser == null) return;
    await _favoritesDb.removeFromFavoritesByUserAndRecipe(
      _currentUser!.id!,
      recetteId,
    );
    notifyListeners();
  }

  // Check if recipe is in favorites
  Future<bool> isFavorite(int recetteId) async {
    if (_currentUser == null) return false;
    return _favoritesDb.isRecipeFavorited(_currentUser!.id!, recetteId);
  }

  // Update user recipe data
  Future<void> updateUserRecipeData(
    String? photoRecette,
    String? comment,
    int recetteId,
  ) async {
    if (_currentUser != null) {
      await _supabaseService.updateUserRecipeData(
        _currentUser!.id!,
        photoRecette,
        comment,
        recetteId,
      );
      // Update local user data
      _currentUser = _currentUser!.copyWith(
        photoRecette: photoRecette,
        comment: comment,
        recetteId: recetteId,
      );
      notifyListeners();
    }
  }

  // Update user profile (name, email, photo)
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? photo,
  }) async {
    if (_currentUser == null) return false;
    try {
      // Check if email is being changed and if it already exists
      if (email != null && 
          email.trim().isNotEmpty && 
          email.trim().toLowerCase() != _currentUser!.email.toLowerCase()) {
        final emailExists = await _supabaseService.checkEmailExists(
          email.trim().toLowerCase(),
        );
        if (emailExists) {
          _lastError = 'Cette adresse email est déjà utilisée';
          return false;
        }
      }

      // Update in Supabase
      await _supabaseService.updateUserProfile(
        _currentUser!.id!,
        name,
        email,
        photo,
      );
      
      // Refresh user data from database to ensure we have the latest data
      final updatedUser = await _supabaseService.getUserById(_currentUser!.id!);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } else {
        // If refresh fails, update local data as fallback
        _currentUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          email: email ?? _currentUser!.email,
          photo: photo ?? _currentUser!.photo,
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating profile: $e');
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('duplicate key') ||
          errorMsg.contains('unique constraint') ||
          errorMsg.contains('already exists')) {
        _lastError = 'Cette adresse email est déjà utilisée';
      } else {
        _lastError = e.toString();
      }
      return false;
    }
  }
}

// Add copyWith method to Users class
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
      // favoris: favoris ?? this.favoris,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
