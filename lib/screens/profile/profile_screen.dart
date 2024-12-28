import 'dart:math' as math;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/profile/emergency_contacts_screen.dart';
import 'package:my_app/screens/profile/emergency_qr_screen.dart';
import 'package:my_app/screens/profile/personal_info_screen.dart';
import 'package:my_app/screens/profile/security_screen.dart';
import 'package:my_app/screens/profile/sent_messages_screen.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/services_firebase/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();
  String userName = '';
  String userEmail = '';
  Map<String, dynamic>? _userData;

  // Liste des couleurs de l'application
  final List<Color> _brandColors = [
    const Color(0xFF094FC6),  // Couleur principale
    const Color(0xFF1E88E5),
    const Color(0xFF2196F3),
    const Color(0xFF42A5F5),
    const Color(0xFF64B5F6),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (_authService.currentUser != null) {
        final doc = await _firestoreService.getDocument(
          'users',
          _authService.currentUser!.uid,
        );
        
        if (mounted) {
          final data = doc.data() as Map<String, dynamic>?;
          
          if (data != null) {
            setState(() {
              _userData = data;
              userName = data['username'] ?? 'Utilisateur';
              userEmail = _authService.currentUser?.email ?? '';
              
              // Vérification et log des données pour le débogage
              print('Données utilisateur chargées:');
              print('Username: ${data['username']}');
              print('Phone: ${data['phone']}');
              print('Address: ${data['address']}');
              print('Emergency Contact: ${data['emergencyContact']}');
              print('Blood Type: ${data['bloodType']}');
            });
          } else {
            print('Aucune donnée trouvée pour l\'utilisateur');
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des informations'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour obtenir les initiales
  String _getInitials(String username) {
    if (username.isEmpty) return '';
    
    final names = username.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return username.substring(0, math.min(2, username.length)).toUpperCase();
  }

  // Fonction pour obtenir une couleur aléatoire
  Color _getRandomColor() {
    return _brandColors[math.Random().nextInt(_brandColors.length)];
  }

  // Widget pour l'avatar avec initiales
  Widget _buildInitialsAvatar() {
    final initials = _getInitials(userName);
    final backgroundColor = _getRandomColor();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: backgroundColor,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showPersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoScreen(userData: _userData ?? {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF094FC6),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF094FC6),
                      const Color(0xFF094FC6).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        _buildInitialsAvatar(), // Utilisation du nouveau widget
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Color(0xFF094FC6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu du profil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Statistiques
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.notifications_active,
                            title: 'Alertes',
                            value: '12',
                          ),
                          _buildStatItem(
                            icon: Icons.contact_phone,
                            title: 'Contacts',
                            value: '5',
                          ),
                          _buildStatItem(
                            icon: Icons.security,
                            title: 'Niveau',
                            value: 'Pro',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Options du profil
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: _buildProfileOption(
                      icon: Icons.person_outline,
                      title: 'Informations personnelles',
                      subtitle: 'Modifier vos informations',
                      onTap: _showPersonalInfo,
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: _buildProfileOption(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Gérer vos notifications',
                      onTap: () {},
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 300),
                    child: _buildProfileOption(
                      icon: Icons.security,
                      title: 'Sécurité',
                      subtitle: 'Paramètres de sécurité',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecurityScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 400),
                    child: _buildProfileOption(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contacts d\'urgence',
                      subtitle: 'Gérer vos contacts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyContactsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 450),
                    child: _buildProfileOption(
                      icon: Icons.qr_code,
                      title: 'QR Code d\'urgence',
                      subtitle: 'Vos informations médicales d\'urgence',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyQRScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 450),
                    child: _buildProfileOption(
                      icon: Icons.message_outlined,
                      title: 'Messages envoyés',
                      subtitle: 'Historique de vos messages',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  SentMessagesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Bouton de déconnexion
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF094FC6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF094FC6),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF094FC6),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF094FC6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF094FC6),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: title == 'Informations personnelles' ? _showPersonalInfo : onTap,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 