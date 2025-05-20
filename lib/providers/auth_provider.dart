import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final _storage = const FlutterSecureStorage();
  User? _user;
  bool _isLoading = false;
  String? _error;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> checkAuth() async {
    try {
      final phone = await _storage.read(key: 'phone');
      if (phone != null) {
        final user = await _databaseService.getUserByPhone(phone);
        if (user != null) {
          _user = user;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> register({
    required String fullName,
    required String phone,
    required String pin,
  }) async {
    try {
      // Vérifier si l'utilisateur existe déjà
      final existingUser = await _databaseService.getUserByPhone(phone);
      if (existingUser != null) {
        throw 'Un compte existe déjà avec ce numéro de téléphone';
      }

      final cardNumber = _databaseHelper.generateCardNumber();
      final newUser = User(
        phone: phone,
        pin: pin,
        fullName: fullName,
        cardNumber: cardNumber,
        createdAt: DateTime.now(),
      );

      // Sauvegarder l'utilisateur dans la base de données
      final userId = await _databaseService.createUser(newUser);
      if (userId == null) {
        throw 'Erreur lors de la création du compte';
      }

      // Sauvegarder le numéro de téléphone dans le stockage sécurisé
      await _storage.write(key: 'phone', value: phone);

      // Mettre à jour l'état
      _user = newUser.copyWith(id: userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login({
    required String phone,
    required String pin,
  }) async {
    try {
      // Récupérer l'utilisateur par son numéro de téléphone
      final user = await _databaseService.getUserByPhone(phone);
      if (user == null) {
        throw 'Aucun compte trouvé avec ce numéro de téléphone';
      }

      // Vérifier le PIN
      if (user.pin != pin) {
        throw 'PIN incorrect';
      }

      // Sauvegarder le numéro de téléphone dans le stockage sécurisé
      await _storage.write(key: 'phone', value: phone);

      // Mettre à jour l'état
      _user = user;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'phone');
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
