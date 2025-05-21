import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/topup.dart';
import '../models/transfer.dart';
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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // Table des contacts
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerPhone TEXT NOT NULL,
        contactPhone TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        UNIQUE(ownerPhone, contactPhone)
      )
    ''');

    // Table des transferts
    await db.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromPhone TEXT NOT NULL,
        toPhone TEXT NOT NULL,
        amount REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gérer les migrations futures ici
    if (oldVersion < 2) {
      // Exemple de migration pour la version 2
      // await db.execute('ALTER TABLE users ADD COLUMN newColumn TEXT');
    }
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
    final userId = await db.insert('users', user);

    // Synchroniser les contacts avec les autres utilisateurs
    final List<Map<String, dynamic>> existingUsers = await db.query('users');
    for (var existingUser in existingUsers) {
      if (existingUser['phone'] != user['phone']) {
        // Ajouter le nouvel utilisateur comme contact pour les utilisateurs existants
        await addContact(existingUser['phone'], user['phone']);
        // Ajouter les utilisateurs existants comme contacts pour le nouvel utilisateur
        await addContact(user['phone'], existingUser['phone']);
      }
    }

    return userId;
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

  Future<double> getUserBalance(String phone) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE 
          WHEN type = 'topup' THEN amount 
          WHEN type = 'transfer_sent' THEN -amount
          WHEN type = 'transfer_received' THEN amount
          ELSE 0 
        END), 0) as balance
      FROM (
        SELECT amount, 'topup' as type FROM topups WHERE userId = (SELECT id FROM users WHERE phone = ?)
        UNION ALL
        SELECT amount, 'transfer_sent' as type FROM transfers WHERE fromPhone = ?
        UNION ALL
        SELECT amount, 'transfer_received' as type FROM transfers WHERE toPhone = ?
      )
    ''', [phone, phone, phone]);
    return result.first['balance'] as double? ?? 0.0;
  }

  // Méthodes pour les contacts
  Future<int> addContact(String ownerPhone, String contactPhone) async {
    final db = await database;
    try {
      return await db.insert('contacts', {
        'ownerPhone': ownerPhone,
        'contactPhone': contactPhone,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignorer les erreurs de contrainte d'unicité
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getContacts(String ownerPhone) async {
    final db = await database;
    // Récupérer tous les utilisateurs sauf l'utilisateur actuel
    final List<Map<String, dynamic>> contacts = await db.rawQuery('''
      SELECT 
        phone as contactPhone,
        fullName as contactName,
        profileImage as contactImage
      FROM users
      WHERE phone != ?
      ORDER BY fullName ASC
    ''', [ownerPhone]);
    return contacts;
  }

  Future<bool> isContact(String ownerPhone, String contactPhone) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'contacts',
      where: 'ownerPhone = ? AND contactPhone = ?',
      whereArgs: [ownerPhone, contactPhone],
    );
    return result.isNotEmpty;
  }

  // Méthode pour synchroniser les contacts entre utilisateurs
  Future<void> syncContacts() async {
    final db = await database;

    // Récupérer tous les utilisateurs
    final List<Map<String, dynamic>> users = await db.query('users');

    // Pour chaque utilisateur, créer des contacts avec tous les autres utilisateurs
    for (var user in users) {
      final String userPhone = user['phone'] as String;

      for (var otherUser in users) {
        final String otherUserPhone = otherUser['phone'] as String;

        // Ne pas créer de contact avec soi-même
        if (userPhone != otherUserPhone) {
          // Vérifier si le contact existe déjà
          final isContact = await this.isContact(userPhone, otherUserPhone);

          // Si le contact n'existe pas, le créer
          if (!isContact) {
            await addContact(userPhone, otherUserPhone);
          }
        }
      }
    }
  }

  // Méthodes pour les transferts
  Future<int> createTransfer(Transfer transfer) async {
    final db = await database;
    final map = transfer.toMap();
    map['createdAt'] =
        DateTime.parse(map['createdAt'] as String).toIso8601String();
    return await db.insert('transfers', map);
  }

  Future<List<Transfer>> getUserTransfers(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        id,
        fromPhone,
        toPhone,
        amount,
        datetime(createdAt) as createdAt
      FROM transfers
      WHERE fromPhone = ? OR toPhone = ?
      ORDER BY createdAt DESC
    ''', [phone, phone]);
    return List.generate(maps.length, (i) => Transfer.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String phone) async {
    final db = await database;

    // Récupérer les recharges
    final List<Map<String, dynamic>> topups = await db.rawQuery('''
      SELECT 
        t.*,
        'topup' as transactionType,
        t.service as description,
        datetime(t.createdAt) as createdAt
      FROM topups t
      JOIN users u ON t.userId = u.id
      WHERE u.phone = ?
    ''', [phone]);

    // Récupérer les transferts envoyés
    final List<Map<String, dynamic>> sentTransfers = await db.rawQuery('''
      SELECT 
        tr.*,
        'transfer_sent' as transactionType,
        u.fullName as recipientName,
        'Transfert à ' || u.fullName as description,
        datetime(tr.createdAt) as createdAt
      FROM transfers tr
      JOIN users u ON tr.toPhone = u.phone
      WHERE tr.fromPhone = ?
    ''', [phone]);

    // Récupérer les transferts reçus
    final List<Map<String, dynamic>> receivedTransfers = await db.rawQuery('''
      SELECT 
        tr.*,
        'transfer_received' as transactionType,
        u.fullName as senderName,
        'Transfert de ' || u.fullName as description,
        datetime(tr.createdAt) as createdAt
      FROM transfers tr
      JOIN users u ON tr.fromPhone = u.phone
      WHERE tr.toPhone = ?
    ''', [phone]);

    // Combiner toutes les transactions
    final List<Map<String, dynamic>> allTransactions = [
      ...topups,
      ...sentTransfers,
      ...receivedTransfers,
    ];

    // Trier par date de création (du plus récent au plus ancien)
    allTransactions.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt'] as String);
      final dateB = DateTime.parse(b['createdAt'] as String);
      return dateB.compareTo(dateA);
    });

    return allTransactions;
  }
}
