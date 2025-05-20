import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/topup.dart';
import 'dart:math';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fintech_app.db');

    // Supprimer la base de données existante pour forcer la recréation
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT UNIQUE NOT NULL,
        pin TEXT NOT NULL,
        fullName TEXT NOT NULL,
        profileImage TEXT,
        cardNumber TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table des transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table des bénéficiaires
    await db.execute('''
      CREATE TABLE beneficiaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table des recharges
    await db.execute('''
      CREATE TABLE topups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        amount REAL NOT NULL,
        service TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // Méthode pour générer un numéro de carte unique
  String generateCardNumber() {
    final random = Random();
    final numbers = List.generate(16, (_) => random.nextInt(10));
    return numbers.join();
  }

  // Méthodes pour les utilisateurs
  Future<int?> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // Méthodes pour les recharges
  Future<int> createTopUp(TopUp topUp) async {
    final db = await database;
    return await db.insert('topups', topUp.toMap());
  }

  Future<List<TopUp>> getUserTopUps(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'topups',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => TopUp.fromMap(maps[i]));
  }

  Future<double> getUserBalance(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM topups WHERE userId = ?
    ''', [userId]);
    return result.first['total'] as double? ?? 0.0;
  }
}
