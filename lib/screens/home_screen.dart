import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  double _balance = 0.0;
  List<Map<String, dynamic>> _recentTransactions = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final balance = await _databaseHelper.getUserBalance(user.phone);
        final transactions =
            await _databaseHelper.getUserTransactions(user.phone);

        if (!mounted) return;
        setState(() {
          _balance = balance;
          _recentTransactions = transactions.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dateFormat = DateFormat('d MMM yyyy à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Fintech App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              tooltip: 'Paramètres',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Êtes-vous sûr de vouloir vous déconnecter ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Déconnecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    actionsPadding: const EdgeInsets.all(16),
                  ),
                );
              },
              tooltip: 'Déconnexion',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // En-tête avec le nom de l'utilisateur
                    Text(
                      'Bonjour, ${user?.fullName ?? ""}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Carte virtuelle
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Carte Virtuelle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              user?.fullName ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.cardNumber
                                      .replaceRange(4, 12, '•••• ••••') ??
                                  '•••• •••• •••• ••••',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '12/25',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${_balance.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions rapides
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          icon: Icons.add,
                          label: 'Recharger',
                          onTap: () async {
                            await Navigator.pushNamed(context, '/topup');
                            _fetchData();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.send,
                          label: 'Transférer',
                          onTap: () async {
                            await Navigator.pushNamed(context, '/transfer');
                            _fetchData();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.history,
                          label: 'Historique',
                          onTap: () {
                            Navigator.pushNamed(context, '/history');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),

              // Section des transactions
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_recentTransactions.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Aucune transaction récente'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = _recentTransactions[index];
                        final amount = transaction['amount'] as double;
                        final type = transaction['transactionType'] as String;
                        final description =
                            transaction['description'] as String;
                        final dateString = transaction['createdAt'] as String;

                        // Parse the date
                        final date = DateTime.parse(dateString);
                        final formattedDate = dateFormat.format(date);

                        // Déterminer l'icône et la couleur
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
                          margin: const EdgeInsets.only(bottom: 8),
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
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _recentTransactions.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
