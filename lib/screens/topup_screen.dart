import 'package:flutter/material.dart';
import '../models/topup.dart';
import '../services/database_helper.dart';
import '../widgets/topup_form.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _databaseHelper = DatabaseHelper();

  Future<void> _handleTopUp(TopUp topUp) async {
    try {
      await _databaseHelper.createTopUp(topUp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recharge effectuée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Rafraîchir l'écran
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharger'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affichage du solde
            FutureBuilder<double>(
              future: user != null
                  ? _databaseHelper.getUserBalance(user.phone)
                  : Future.value(0.0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final balance = snapshot.data ?? 0.0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Solde actuel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${balance.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Formulaire de recharge
            const Text(
              'Nouvelle recharge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TopUpForm(
              onSubmit: _handleTopUp,
              userId: user?.id ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
