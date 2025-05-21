import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../models/transfer.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  double _balance = 0.0;
  Map<String, dynamic>? _recipientInfo;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final balance = await _databaseHelper.getUserBalance(user.phone);
      setState(() {
        _balance = balance;
      });
    }
  }

  Future<void> _checkRecipient() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Vérifier le format du numéro
    final phoneRegex = RegExp(r'^\+221\s?[0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format de numéro invalide. Exemple: +221 7XXXXXXXX'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Supprimer les espaces du numéro pour la recherche
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
      final recipient = await _databaseHelper.getUserByPhone(cleanPhone);
      if (mounted) {
        setState(() {
          _recipientInfo = recipient;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erreur lors de la vérification du destinataire: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) throw 'Utilisateur non connecté';

      final recipientPhone =
          _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
      final amount = double.parse(_amountController.text);

      // Vérifier si le destinataire existe
      final recipient = await _databaseHelper.getUserByPhone(recipientPhone);
      if (recipient == null) {
        throw 'Aucun utilisateur trouvé avec ce numéro de téléphone';
      }

      if (amount > _balance) {
        throw 'Solde insuffisant';
      }

      final transfer = Transfer(
        fromPhone: user.phone,
        toPhone: recipientPhone,
        amount: amount,
        createdAt: DateTime.now(),
      );

      await _databaseHelper.createTransfer(transfer);

      if (mounted) {
        // Notification de succès
        await NotificationService().showNotification(
          title: 'Transfert réussi',
          body:
              'Vous avez envoyé ${amount.toStringAsFixed(0)} FCFA à ${recipient['fullName']}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfert effectué avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Notification d'erreur
        await NotificationService().showNotification(
          title: 'Erreur de transfert',
          body: e.toString(),
          playSound: true,
          vibrate: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solde disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_balance.toStringAsFixed(2)} FCFA',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro du destinataire',
                  hintText: '+221 7XXXXXXXX',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _isLoading ? null : _checkRecipient,
                  ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() => _recipientInfo = null),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  // Vérifier le format du numéro (+221 suivi de 9 chiffres)
                  final phoneRegex = RegExp(r'^\+221\s?[0-9]{9}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Format invalide. Exemple: +221 7XXXXXXXX';
                  }
                  return null;
                },
              ),
              if (_recipientInfo != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _recipientInfo!['profileImage'] != null
                          ? NetworkImage(_recipientInfo!['profileImage'])
                          : null,
                      child: _recipientInfo!['profileImage'] == null
                          ? Text(_recipientInfo!['fullName'][0])
                          : null,
                    ),
                    title: Text(_recipientInfo!['fullName']),
                    subtitle: Text(_recipientInfo!['phone']),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                  if (amount > _balance) {
                    return 'Solde insuffisant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading || _recipientInfo == null
                    ? null
                    : _handleTransfer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Effectuer le transfert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
