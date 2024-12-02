import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app/acceuil/acceuil.dart';
import 'package:my_app/actualites/actualites.dart';
import 'package:my_app/contact/contact.dart';
import 'package:my_app/numurgence/numurgence.dart';

import 'detailconseil.dart';

class Conseil extends StatelessWidget {
  Conseil({super.key});
  final List<Map<String, String>> adviceList = [
    {
      "title": "Habitation",
      "description":
          "Tranquillité vacances, cambriolages, squats... Protéger son logement",
      "details":
          "Les conseils pour protéger votre habitation comprennent l'installation d'alarmes, la sécurisation des fenêtres, et des astuces pour éloigner les cambrioleurs pendant vos absences."
    },
    {
      "title": "Famille",
      "description": "Protection et sécurité de la famille",
      "details":
          "Assurez la sécurité de vos proches grâce à des gestes simples : sensibilisation des enfants, contacts d'urgence, et vigilance sur les réseaux sociaux."
    },
    {
      "title": "Mobilités et transports",
      "description":
          "Règles de conduite des véhicules, sécurité dans les transports (en commun, publics...)",
      "details":
          "Suivez les meilleures pratiques pour la sécurité routière et dans les transports : port de la ceinture, vigilance aux arrêts et respect du code de la route."
    },
    {
      "title": "Numérique",
      "description":
          "Les réseaux sociaux, chantage à la webcam, hameçonnage ou cyber-malveillance",
      "details":
          "Protégez-vous en ligne : utilisez des mots de passe sécurisés, méfiez-vous des e-mails frauduleux, et surveillez votre présence sur les réseaux sociaux."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Conseils",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête avec image
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF094FC6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF094FC6).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/security.png',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 20,
                    child: const Text(
                      'Conseils de sécurité',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: adviceList.length,
              itemBuilder: (context, index) {
                final advice = adviceList[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: index * 100),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detailconseil(
                            title: advice["title"]!,
                            details: advice["details"]!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF094FC6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF094FC6),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    advice["title"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    advice["description"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF094FC6),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          onTap: (int index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const Accueil())
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const Actualites())
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const Numurgence())
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF094FC6),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: "Actualités",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: "Conseils",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: "N° Urgence",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Contact()),
          );
        },
        backgroundColor: const Color(0xFF094FC6),
        child: const Icon(Icons.forum, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
