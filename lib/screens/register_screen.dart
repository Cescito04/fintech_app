import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:country_picker/country_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isLoading = false;
  Country _selectedCountry = Country(
    phoneCode: '221',
    countryCode: 'SN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Senegal',
    example: '771234567',
    displayName: 'Senegal (SN) [+221]',
    displayNameNoCountryCode: 'Senegal (SN)',
    e164Key: '221-SN-0',
  );

  // Dio instance for API calls
  final _dio = Dio();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  /// Validates the PIN format (4 digits)
  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est requis';
    }
    if (value.length != 4) {
      return 'Le code PIN doit contenir 4 chiffres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le code PIN doit contenir uniquement des chiffres';
    }
    return null;
  }

  /// Validates the phone number format
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le numéro de téléphone doit contenir uniquement des chiffres';
    }
    if (value.length < 8) {
      return 'Le numéro de téléphone doit contenir au moins 8 chiffres';
    }
    return null;
  }

  /// Registers the user by sending data to the API
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler un délai de chargement de 2 secondes
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une réponse réussie
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );

        // Afficher les données saisies dans la console
        print('Données d\'inscription :');
        print('Prénom: ${_firstNameController.text}');
        print('Nom: ${_lastNameController.text}');
        print(
          'Téléphone: +${_selectedCountry.phoneCode}${_phoneController.text}',
        );
        print('PIN: ${_pinController.text}');

        // Naviguer vers l'écran précédent
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur inattendue est survenue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field with Country Picker
              Row(
                children: [
                  // Country Picker Button
                  InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                        countryListTheme: CountryListThemeData(
                          borderRadius: BorderRadius.circular(12),
                          inputDecoration: InputDecoration(
                            labelText: 'Rechercher',
                            hintText: 'Entrez le nom du pays',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Phone Number Field
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // PIN Field
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'Code PIN (4 chiffres)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: _validatePin,
              ),
              const SizedBox(height: 24),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'S\'inscrire',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
