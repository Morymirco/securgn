import 'package:flutter/material.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/screens/profile/emergency_contacts_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _authService = FirebaseAuthService();
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  Widget _buildSecurityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF094FC6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Sécurité',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paramètres de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 20),
            _buildSecurityOption(
              title: 'Authentification biométrique',
              subtitle: 'Utiliser l\'empreinte digitale pour se connecter',
              icon: Icons.fingerprint,
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
            _buildSecurityOption(
              title: 'Notifications d\'urgence',
              subtitle: 'Recevoir des alertes en cas d\'urgence',
              icon: Icons.notifications_active,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSecurityOption(
              title: 'Localisation',
              subtitle: 'Partager votre position en cas d\'urgence',
              icon: Icons.location_on,
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Actions de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              title: 'Changer le mot de passe',
              subtitle: 'Modifier votre mot de passe actuel',
              icon: Icons.lock_outline,
              onTap: () {
                // Implémenter le changement de mot de passe
              },
            ),
            _buildActionButton(
              title: 'Historique des connexions',
              subtitle: 'Voir les appareils connectés',
              icon: Icons.devices,
              onTap: () {
                // Afficher l'historique des connexions
              },
            ),
            _buildActionButton(
              title: 'Contacts d\'urgence',
              subtitle: 'Gérer vos contacts en cas d\'urgence',
              icon: Icons.contact_phone,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 