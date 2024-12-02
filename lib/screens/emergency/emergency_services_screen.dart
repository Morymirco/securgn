import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/emergency/service_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyServicesScreen extends StatelessWidget {
  const EmergencyServicesScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: const Text(
          'Services d\'urgence',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF094FC6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Numéros d\'urgence',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Services disponibles 24h/24 et 7j/7',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Police
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildEmergencyCard(
                      title: 'Police',
                      phoneNumber: '117',
                      description: 'Pour toute urgence nécessitant l\'intervention de la police',
                      icon: Icons.local_police,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Police',
                              serviceColor: Colors.blue,
                              serviceIcon: Icons.local_police,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Pompiers
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: _buildEmergencyCard(
                      title: 'Pompiers',
                      phoneNumber: '118',
                      description: 'Pour les incendies et les secours',
                      icon: Icons.fire_truck,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Pompiers',
                              serviceColor: Colors.red,
                              serviceIcon: Icons.fire_truck,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // SAMU
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: _buildEmergencyCard(
                      title: 'SAMU',
                      phoneNumber: '115',
                      description: 'Service d\'aide médicale urgente',
                      icon: Icons.medical_services,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'SAMU',
                              serviceColor: Colors.green,
                              serviceIcon: Icons.medical_services,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Gendarmerie
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 300),
                    child: _buildEmergencyCard(
                      title: 'Gendarmerie',
                      phoneNumber: '122',
                      description: 'Pour les zones rurales et périurbaines',
                      icon: Icons.security,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Gendarmerie',
                              serviceColor: Colors.indigo,
                              serviceIcon: Icons.security,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Protection Civile
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 400),
                    child: _buildEmergencyCard(
                      title: 'Protection Civile',
                      phoneNumber: '119',
                      description: 'Pour les catastrophes et situations d\'urgence',
                      icon: Icons.health_and_safety,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Protection Civile',
                              serviceColor: Colors.orange,
                              serviceIcon: Icons.health_and_safety,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Urgence Médicale
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 500),
                    child: _buildEmergencyCard(
                      title: 'Urgence Médicale',
                      phoneNumber: '629000000',
                      description: 'Services médicaux d\'urgence et cliniques',
                      icon: Icons.local_hospital,
                      color: const Color(0xFFE57373),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Urgence Médicale',
                              serviceColor: const Color(0xFFE57373),
                              serviceIcon: Icons.local_hospital,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Assistance Routière
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 600),
                    child: _buildEmergencyCard(
                      title: 'Assistance Routière',
                      phoneNumber: '666000000',
                      description: 'Dépannage et remorquage 24/7',
                      icon: Icons.car_repair,
                      color: Colors.brown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceListScreen(
                              serviceType: 'Assistance Routière',
                              serviceColor: Colors.brown,
                              serviceIcon: Icons.car_repair,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String phoneNumber,
    required String description,
    required IconData icon,
    required Color color,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    phoneNumber,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 