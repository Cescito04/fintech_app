import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/database_helper.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final databaseHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: user != null
            ? databaseHelper.getUserTransactions(user.phone)
            : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune transaction',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final dateFormat = DateFormat('d MMMM yyyy à HH:mm', 'fr_FR');
              final amount = transaction['amount'] as double;
              final type = transaction['transactionType'] as String;
              final description = transaction['description'] as String;

              // Déterminer l'icône et la couleur en fonction du type de transaction
              IconData icon;
              Color color;
              String prefix = '';

              switch (type) {
                case 'topup':
                  icon = Icons.add_circle;
                  color = Colors.green;
                  prefix = '+';
                  break;
                case 'transfer_sent':
                  icon = Icons.send;
                  color = Colors.red;
                  prefix = '-';
                  break;
                case 'transfer_received':
                  icon = Icons.call_received;
                  color = Colors.green;
                  prefix = '+';
                  break;
                default:
                  icon = Icons.payment;
                  color = Colors.blue;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    '$prefix${amount.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  subtitle: Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Text(
                    dateFormat.format(DateTime.parse(transaction['createdAt'])),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
