import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aide',
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
            // Section FAQ
            const Text(
              'Questions fréquentes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              question: 'Comment contacter les services d\'urgence ?',
              answer: 'Vous pouvez contacter les services d\'urgence en utilisant le bouton d\'appel direct ou en envoyant un message via l\'application. En cas d\'urgence, privilégiez l\'appel direct.',
            ),
            _buildFAQItem(
              question: 'Comment partager ma localisation ?',
              answer: 'Lors de l\'envoi d\'un message d\'urgence, vous pouvez activer le partage de localisation en cliquant sur le bouton "Position". Assurez-vous d\'avoir activé la localisation sur votre appareil.',
            ),
            _buildFAQItem(
              question: 'Les services sont-ils disponibles 24h/24 ?',
              answer: 'Oui, tous les services d\'urgence sont disponibles 24h/24 et 7j/7. Les temps de réponse peuvent varier selon le service et la situation.',
            ),

            const SizedBox(height: 30),

            // Section Guides
            const Text(
              'Guides d\'utilisation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(height: 20),
            _buildGuideItem(
              title: 'Premiers secours',
              description: 'Guide des gestes de premiers secours essentiels',
              icon: Icons.medical_services,
              onTap: () {
                // Navigation vers le guide de premiers secours
              },
            ),
            _buildGuideItem(
              title: 'Sécurité routière',
              description: 'Conseils et procédures en cas d\'accident',
              icon: Icons.car_crash,
              onTap: () {
                // Navigation vers le guide de sécurité routière
              },
            ),
            _buildGuideItem(
              title: 'Situations d\'urgence',
              description: 'Comment réagir face à différentes urgences',
              icon: Icons.warning,
              onTap: () {
                // Navigation vers le guide des situations d'urgence
              },
            ),

            const SizedBox(height: 30),

            // Section Contact Support
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF094FC6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Besoin d\'aide supplémentaire ?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF094FC6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Notre équipe de support est disponible pour vous aider',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Action pour contacter le support
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF094FC6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.support_agent, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Contacter le support',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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

  Widget _buildFAQItem({
    required String question,
    required String answer,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required String title,
    required String description,
    required IconData icon,
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
            offset: const Offset(0, 2),
          ),
        ],
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
          description,
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
} 