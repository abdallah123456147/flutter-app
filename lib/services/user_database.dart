import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserDatabase {
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;
  UserDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        photo TEXT,
        gender Text,
        photo_recette TEXT,
        recette_id INTEGER,
        favoris TEXT
      )
    ''');
  }

  // User registration
  Future<int> insertUser(Users user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // Get user by email
  Future<Users?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Users.fromMap(maps.first);
    }
    return null;
  }

  // Update user favorites
  Future<void> updateUserFavorites(int userId, List<int> favoris) async {
    final db = await database;
    await db.update(
      'users',
      {'favoris': favoris.join(',')},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Update user photo and comment for a recipe
  Future<void> updateUserRecipeData(
    int userId,
    String? photoRecette,
    String? comment,
    int recetteId,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {'photo_recette': photoRecette, 'recette_id': recetteId},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Get user by ID
  Future<Users?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Users.fromMap(maps.first);
    }
    return null;
  }
}
