import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  bool locationEnabled = true;
  String selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Général',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    title: 'Notifications',
                    subtitle: 'Gérer les notifications de l\'application',
                    icon: Icons.notifications_outlined,
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF094FC6),
                    ),
                  ),
                  _buildSettingCard(
                    title: 'Mode sombre',
                    subtitle: 'Changer l\'apparence de l\'application',
                    icon: Icons.dark_mode_outlined,
                    trailing: Switch(
                      value: darkMode,
                      onChanged: (value) {
                        setState(() {
                          darkMode = value;
                        });
                      },
                      activeColor: const Color(0xFF094FC6),
                    ),
                  ),
                  _buildSettingCard(
                    title: 'Localisation',
                    subtitle: 'Autoriser l\'accès à la localisation',
                    icon: Icons.location_on_outlined,
                    trailing: Switch(
                      value: locationEnabled,
                      onChanged: (value) {
                        setState(() {
                          locationEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF094FC6),
                    ),
                  ),
                  _buildSettingCard(
                    title: 'Langue',
                    subtitle: 'Changer la langue de l\'application',
                    icon: Icons.language_outlined,
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      underline: const SizedBox(),
                      items: ['Français', 'English']
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedLanguage = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    title: 'Profil',
                    subtitle: 'Modifier vos informations personnelles',
                    icon: Icons.person_outline,
                    onTap: () {
                      // TODO: Navigation vers le profil
                    },
                  ),
                  _buildSettingCard(
                    title: 'Sécurité',
                    subtitle: 'Gérer la sécurité de votre compte',
                    icon: Icons.security_outlined,
                    onTap: () {
                      // TODO: Navigation vers la sécurité
                    },
                  ),
                  _buildSettingCard(
                    title: 'Confidentialité',
                    subtitle: 'Gérer vos paramètres de confidentialité',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      // TODO: Navigation vers la confidentialité
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aide & Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingCard(
                    title: 'Centre d\'aide',
                    subtitle: 'Consultez notre FAQ et guides',
                    icon: Icons.help_outline,
                    onTap: () {
                      // TODO: Navigation vers l'aide
                    },
                  ),
                  _buildSettingCard(
                    title: 'Nous contacter',
                    subtitle: 'Envoyez-nous vos questions',
                    icon: Icons.mail_outline,
                    onTap: () {
                      // TODO: Navigation vers le contact
                    },
                  ),
                  _buildSettingCard(
                    title: 'À propos',
                    subtitle: 'En savoir plus sur SecurGuinee',
                    icon: Icons.info_outline,
                    onTap: () {
                      // TODO: Navigation vers à propos
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return FadeInUp(
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
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
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
} 