import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white),
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
            // Section Notifications
            _buildSection(
              title: 'Notifications',
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _buildSwitchTile(
                    title: 'Notifications d\'urgence',
                    subtitle: 'Recevoir les alertes d\'urgence',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                    icon: Icons.notifications_active_outlined,
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: _buildSwitchTile(
                    title: 'Son',
                    subtitle: 'Activer le son des notifications',
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() => _soundEnabled = value);
                    },
                    icon: Icons.volume_up_outlined,
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: _buildSwitchTile(
                    title: 'Vibration',
                    subtitle: 'Activer la vibration',
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() => _vibrationEnabled = value);
                    },
                    icon: Icons.vibration,
                  ),
                ),
              ],
            ),

            // Section Localisation
            _buildSection(
              title: 'Localisation',
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildSwitchTile(
                    title: 'Service de localisation',
                    subtitle: 'Permettre l\'accès à votre position',
                    value: _locationEnabled,
                    onChanged: (value) {
                      setState(() => _locationEnabled = value);
                    },
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),

            // Section Langue
            _buildSection(
              title: 'Langue',
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: _buildLanguageSelector(),
                ),
              ],
            ),

            // Section Confidentialité
            _buildSection(
              title: 'Confidentialité et sécurité',
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 500),
                  child: _buildNavigationTile(
                    title: 'Politique de confidentialité',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      // TODO: Navigation vers la politique de confidentialité
                    },
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 600),
                  child: _buildNavigationTile(
                    title: 'Conditions d\'utilisation',
                    icon: Icons.description_outlined,
                    onTap: () {
                      // TODO: Navigation vers les conditions d'utilisation
                    },
                  ),
                ),
              ],
            ),

            // Section À propos
            _buildSection(
              title: 'À propos',
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 700),
                  child: ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF094FC6),
                    ),
                    title: const Text('Version de l\'application'),
                    subtitle: const Text('1.0.0'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF094FC6),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFF094FC6)),
        activeColor: const Color(0xFF094FC6),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
        leading: Icon(icon, color: const Color(0xFF094FC6)),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
        leading: const Icon(
          Icons.language,
          color: Color(0xFF094FC6),
        ),
        title: const Text('Langue de l\'application'),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Implémenter le sélecteur de langue
        },
      ),
    );
  }
} 