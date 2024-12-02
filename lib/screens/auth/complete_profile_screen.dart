import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app/acceuil/acceuil.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/services_firebase/firestore_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String userId;

  const CompleteProfileScreen({super.key, required this.userId});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  String _selectedBloodType = 'A+';
  bool _isLoading = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.updateDocument(
          'users',
          widget.userId,
          {
            'phone': _phoneController.text,
            'address': _addressController.text,
            'emergencyContact': _emergencyContactController.text,
            'bloodType': _selectedBloodType,
            'profileCompleted': true,
          },
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Accueil()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF094FC6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Compléter votre profil'),
        backgroundColor: const Color(0xFF094FC6),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.15,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF094FC6).withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: const Icon(
                      Icons.person_add,
                      size: 50,
                      color: Color(0xFF094FC6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Informations complémentaires',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ces informations nous aideront à mieux vous assister en cas d\'urgence',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              _buildInputField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _emergencyContactController,
                label: 'Contact d\'urgence',
                icon: Icons.emergency,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un contact d\'urgence';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBloodType,
                    decoration: InputDecoration(
                      labelText: 'Groupe sanguin',
                      prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF094FC6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
              ),
              const SizedBox(height: 40),

              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 600),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094FC6),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Terminer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }
} 