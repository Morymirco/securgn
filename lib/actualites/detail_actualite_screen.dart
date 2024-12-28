import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DetailActualiteScreen extends StatefulWidget {
  final Map<String, dynamic> actualite;

  const DetailActualiteScreen({super.key, required this.actualite});

  @override
  State<DetailActualiteScreen> createState() => _DetailActualiteScreenState();
}

class _DetailActualiteScreenState extends State<DetailActualiteScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('fr_FR', null);
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
      } else if (dateValue is DateTime) {
        return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(dateValue);
      } else if (dateValue is Timestamp) {
        return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(dateValue.toDate());
      }
      return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(DateTime.now());
    } catch (e) {
      print('Erreur de formatage de date: $e');
      return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final formattedDate = _formatDate(widget.actualite['date']);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec image
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF094FC6),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'actualite_${widget.actualite['id']}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.actualite['image'] ?? 'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  Share.share(
                    '${widget.actualite['title']}\n\n${widget.actualite['description']}\n\nLu sur SecurGuinee',
                  );
                },
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et date
                  Row(
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
                          widget.actualite['category'] ?? 'Actualité',
                          style: const TextStyle(
                            color: Color(0xFF094FC6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Titre
                  Text(
                    widget.actualite['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Source
                  if (widget.actualite['source'] != null)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.source_outlined,
                            color: Color(0xFF094FC6),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Source: ${widget.actualite['source']}',
                            style: const TextStyle(
                              color: Color(0xFF094FC6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    widget.actualite['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  if (widget.actualite['tags'] != null) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.actualite['tags'] as List<dynamic>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // Bouton flottant pour partager
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Share.share(
            '${widget.actualite['title']}\n\n${widget.actualite['description']}\n\nLu sur SecurGuinee',
          );
        },
        backgroundColor: const Color(0xFF094FC6),
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
} 