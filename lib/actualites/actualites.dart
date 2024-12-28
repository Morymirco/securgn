import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app/actualites/detail_actualite_screen.dart';
import 'package:my_app/widgets/bottom_bar.dart';

class Actualites extends StatefulWidget {
  const Actualites({super.key});

  @override
  State<Actualites> createState() => _ActualitesState();
}

class _ActualitesState extends State<Actualites> {
  String _selectedCategory = 'Tous';
  final List<String> _categories = [
    'Tous',
    'Urgences',
    'Sécurité',
    'Santé',
    'Routes',
  ];

  // Liste des actualités (à remplacer par des données Firestore)
  final List<Map<String, dynamic>> _actualites = [
    {
      'title': 'Nouveau centre médical d\'urgence',
      'description': 'Un nouveau centre médical d\'urgence ouvre ses portes à Conakry...',
      'image': 'assets/images/medical.jpg',
      'date': '2 heures',
      'category': 'Santé',
    },
    {
      'title': 'Alerte météo : Fortes pluies',
      'description': 'Des fortes pluies sont attendues dans la région de Conakry...',
      'image': 'assets/images/meteo2.jpg',
      'date': '5 heures',
      'category': 'Urgences',
    },
    {
      'title': 'Campagne de vaccination',
      'description': 'Une nouvelle campagne de vaccination débute cette semaine...',
      'image': 'assets/images/vaccinatio.jpg',
      'date': '1 jour',
      'category': 'Santé',
    },
    // Ajoutez d'autres actualités ici
  ];

  List<Map<String, dynamic>> get filteredActualites {
    if (_selectedCategory == 'Tous') {
      return _actualites;
    }
    return _actualites.where((actualite) => 
      actualite['category'] == _selectedCategory
    ).toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtrer par catégorie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    this.setState(() {}); // Rafraîchir la liste principale
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: const Color(0xFF094FC6),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category 
                      ? Colors.white 
                      : Colors.black87,
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF094FC6).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF094FC6).withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share,
                      size: 30,
                      color: Color(0xFF094FC6),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Partager via',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Options de partage
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption(
                        icon: Icons.message,
                        label: 'SMS',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Partage par SMS...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareOption(
                        icon: Icons.message,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Partage sur WhatsApp...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareOption(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Partage sur Facebook...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption(
                        icon: Icons.copy,
                        label: 'Copier',
                        color: Colors.grey.shade700,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lien copié dans le presse-papiers'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildShareOption(
                        icon: Icons.more_horiz,
                        label: 'Plus',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          // Implémenter plus d'options de partage
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: const Text(
          'Actualités',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section des catégories
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: _categories.map((category) => 
                    _buildCategoryChip(
                      category, 
                      category == _selectedCategory,
                    ),
                  ).toList(),
                ),
              ),
            ),

            // Liste des actualités filtrées
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: filteredActualites.map((actualite) => 
                  _buildNewsCard(
                    title: actualite['title'],
                    description: actualite['description'],
                    image: actualite['image'],
                    date: actualite['date'],
                    category: actualite['category'],
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 1),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FadeInUp(
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF094FC6),
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (bool value) {
            setState(() {
              _selectedCategory = label;
            });
          },
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF094FC6),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.transparent : const Color(0xFF094FC6),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String description,
    required String image,
    required String date,
    required String category,
  }) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      'Il y a $date',
                      style: const TextStyle(
                        color: Color(0xFF094FC6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF094FC6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF094FC6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showShareDialog(context),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Partager'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF094FC6),
                            side: const BorderSide(color: Color(0xFF094FC6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailActualiteScreen(
                                  actualite: {
                                    'title': title,
                                    'description': description,
                                    'image': image,
                                    'date': date,
                                    'category': category,
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Lire plus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF094FC6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
