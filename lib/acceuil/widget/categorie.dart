import 'package:flutter/material.dart';

Widget categorie({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String description,
}) {
  // Détection du mode clair ou sombre
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: const BorderSide(
          color: Color.fromARGB(255, 68, 33, 243), // Bordure bleue en bas
          width: 5.0,
        ),
      ),
    ),
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5.0,
      shadowColor: Colors.grey.withOpacity(0.3),
      color: Theme.of(context).colorScheme.surface, // Utilisation de surface
      child: InkWell(
        onTap: () {
          // Action au clic
        },
        splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône principale
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Flèche de navigation
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
