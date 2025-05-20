import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/topup.dart';

class TopUpForm extends StatefulWidget {
  final Function(TopUp) onSubmit;
  final int userId;

  const TopUpForm({
    super.key,
    required this.onSubmit,
    required this.userId,
  });

  @override
  State<TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<TopUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedService = 'Wave';

  final List<String> _services = ['Wave', 'Orange Money', 'Free Money'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final topUp = TopUp(
        userId: widget.userId,
        amount: double.parse(_amountController.text),
        service: _selectedService,
        createdAt: DateTime.now(),
      );
      widget.onSubmit(topUp);
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Montant (FCFA)',
              prefixIcon: Icon(Icons.attach_money),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un montant valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedService,
            decoration: const InputDecoration(
              labelText: 'Service',
              prefixIcon: Icon(Icons.phone_android),
            ),
            items: _services.map((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedService = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Recharger',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
