import 'package:flutter/material.dart';
import '../widgets/virtual_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  double _balance = 25000.0; // Donnée statique

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true;
    });

    // Simuler un délai de chargement
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBalance,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Carte virtuelle
                    VirtualCard(
                      fullName: 'John Doe',
                      cardNumber: '4532 •••• •••• 7895',
                      expiryDate: '12/25',
                      balance: _balance,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Actions rapides
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          icon: Icons.add,
                          label: 'Recharger',
                          onTap: () {
                            // TODO: Implémenter la recharge
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.send,
                          label: 'Transférer',
                          onTap: () {
                            // TODO: Implémenter le transfert
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.history,
                          label: 'Historique',
                          onTap: () {
                            // TODO: Implémenter l'historique
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section des transactions récentes
                    const Text(
                      'Transactions récentes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              index % 2 == 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          child: Icon(
                            index % 2 == 0
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: index % 2 == 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          index % 2 == 0 ? 'Reçu de John' : 'Envoyé à Marie',
                        ),
                        subtitle: Text(
                          '${index + 1} Mars 2024',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          '${index % 2 == 0 ? '+' : '-'}${(index + 1) * 1000} FCFA',
                          style: TextStyle(
                            color: index % 2 == 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }, childCount: 5),
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
