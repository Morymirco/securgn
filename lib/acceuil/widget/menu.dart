import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  // Ajout de la méthode _buildDrawerItem
  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 68, 33, 243)),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                  255, 68, 33, 243), // Couleur principale du header
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 40, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "SoulCherif",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.light_mode, color: Colors.white),
                    onPressed: () {
                      // Ajouter une action pour changer le thème
                      print("Changer le thème");
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des éléments du Drawer
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.account_circle,
                  text: "Mon Profile",
                  onTap: () {
                    print("Mon Profile");
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.contact_page,
                  text: "Contact",
                  onTap: () {
                    print("Contact");
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.search,
                  text: "Recherche",
                  onTap: () {
                    print("Recherche");
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.article,
                  text: "Actualités",
                  onTap: () {
                    print("Actualités");
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: "Paramètre",
                  onTap: () {
                    print("Paramètre");
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  text: "Fonctionnement SecurGuinée",
                  onTap: () {
                    print("Fonctionnement SecurGuinée");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
