import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/emergency/message_service_screen.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authService = FirebaseAuthService();
  String _searchQuery = '';
  bool _isSearching = false;

  // Liste des suggestions prédéfinies
  final List<String> _suggestions = [
    'Hôpital',
    'Police',
    'Pompiers',
    'Urgences',
    'Clinique',
    'Assistance',
  ];

  Future<void> _saveSearch(String query) async {
    if (query.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_authService.currentUser?.uid)
          .collection('recent_searches')
          .add({
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la sauvegarde de la recherche: $e');
    }
  }

  Widget _buildSuggestionsAndRecent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suggestions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((suggestion) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _searchController.text = suggestion;
                        _searchQuery = suggestion.toLowerCase();
                        _isSearching = true;
                      });
                      _saveSearch(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF094FC6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF094FC6).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: const Color(0xFF094FC6).withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Recherches récentes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recherches récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Supprimer toutes les recherches récentes
                      final recentSearches = await _firestore
                          .collection('users')
                          .doc(_authService.currentUser?.uid)
                          .collection('recent_searches')
                          .get();

                      for (var doc in recentSearches.docs) {
                        await doc.reference.delete();
                      }
                      setState(() {});
                    },
                    child: const Text('Effacer tout'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_authService.currentUser?.uid)
                    .collection('recent_searches')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text(
                      'Aucune recherche récente',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(data['query'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () async {
                            await doc.reference.delete();
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _searchController.text = data['query'] as String;
                            _searchQuery = data['query'].toString().toLowerCase();
                            _isSearching = true;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Rechercher un service...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
              _isSearching = value.isNotEmpty;
            });
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _saveSearch(value);
            }
          },
        ),
      ),
      body: _isSearching
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergency_services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 150,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 100,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Divider(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                var services = snapshot.data?.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'].toString().toLowerCase();
                  final type = data['type'].toString().toLowerCase();
                  final address = data['address'].toString().toLowerCase();
                  
                  return name.contains(_searchQuery) ||
                         type.contains(_searchQuery) ||
                         address.contains(_searchQuery);
                }).toList() ?? [];

                if (services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat trouvé pour\n"$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index].data() as Map<String, dynamic>;
                    final serviceType = service['type'] as String;
                    final serviceColor = _getServiceColor(serviceType);
                    final serviceIcon = _getServiceIcon(serviceType);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: serviceColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    serviceIcon,
                                    color: serviceColor,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.grey[400],
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              service['address'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: serviceColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          serviceType,
                                          style: TextStyle(
                                            color: serviceColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final phones = service['phone'] as List<dynamic>;
                                      if (phones.isNotEmpty) {
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: phones.first.toString(),
                                        );
                                        launchUrl(launchUri);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: serviceColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.phone, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Appeler',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MessageServiceScreen(
                                            service: {
                                              'name': service['name'] as String,
                                              'address': service['address'] as String,
                                            },
                                            serviceColor: serviceColor,
                                            serviceIcon: serviceIcon,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: serviceColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.message, color: serviceColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Message',
                                          style: TextStyle(
                                            color: serviceColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          : _buildSuggestionsAndRecent(),
    );
  }

  Color _getServiceColor(String type) {
    switch (type) {
      case 'Urgences Médicales':
        return Colors.red;
      case 'Police':
        return Colors.blue;
      case 'Pompiers':
        return Colors.orange;
      case 'Assistance Routière':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'Urgences Médicales':
        return Icons.local_hospital;
      case 'Police':
        return Icons.local_police;
      case 'Pompiers':
        return Icons.fire_truck;
      case 'Assistance Routière':
        return Icons.support_agent;
      default:
        return Icons.help_outline;
    }
  }
} 