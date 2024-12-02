import 'package:flutter/material.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/services_firebase/firestore_service.dart';
import 'package:my_app/screens/profile/edit_profile_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PersonalInfoScreen({super.key, required this.userData});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF094FC6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF094FC6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Non renseigné',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: value.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Informations personnelles',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userData: widget.userData),
                ),
              );
              
              if (result == true && mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInfoScreen(userData: widget.userData),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de base',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Nom d\'utilisateur',
              value: widget.userData['username'] ?? '',
              icon: Icons.person_outline,
            ),
            _buildInfoCard(
              title: 'Email',
              value: _authService.currentUser?.email ?? '',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),
            const Text(
              'Coordonnées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Téléphone',
              value: widget.userData['phone'] ?? '',
              icon: Icons.phone_outlined,
            ),
            _buildInfoCard(
              title: 'Adresse',
              value: widget.userData['address'] ?? '',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            const Text(
              'Informations médicales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Groupe sanguin',
              value: widget.userData['bloodType'] ?? '',
              icon: Icons.bloodtype_outlined,
            ),
            _buildInfoCard(
              title: 'Contact d\'urgence',
              value: widget.userData['emergencyContact'] ?? '',
              icon: Icons.emergency_outlined,
            ),
          ],
        ),
      ),
    );
  }
} 