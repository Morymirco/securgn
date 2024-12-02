import 'package:flutter/material.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/services_firebase/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();
  
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyContactController;
  late String _selectedBloodType;
  bool _isLoading = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData['username']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController = TextEditingController(text: widget.userData['address']);
    _emergencyContactController = TextEditingController(text: widget.userData['emergencyContact']);
    _selectedBloodType = widget.userData['bloodType'] ?? 'A+';
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.updateDocument(
          'users',
          _authService.currentUser!.uid,
          {
            'username': _usernameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'emergencyContact': _emergencyContactController.text,
            'bloodType': _selectedBloodType,
          },
        );

        if (mounted) {
          Navigator.pop(context, true); // Retourne true pour indiquer une mise à jour réussie
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour'),
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF094FC6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF094FC6)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _usernameController,
                label: 'Nom d\'utilisateur',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _emergencyContactController,
                label: 'Contact d\'urgence',
                icon: Icons.emergency_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un contact d\'urgence';
                  }
                  return null;
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Groupe sanguin',
                    prefixIcon: const Icon(Icons.bloodtype_outlined, color: Color(0xFF094FC6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF094FC6)),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _bloodTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBloodType = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094FC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }
} 