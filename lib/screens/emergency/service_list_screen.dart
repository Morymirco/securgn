import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/emergency_service.dart';
import 'package:my_app/screens/emergency/message_service_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceListScreen extends StatelessWidget {
  final String serviceType;
  final Color serviceColor;
  final IconData serviceIcon;

  const ServiceListScreen({
    Key? key,
    required this.serviceType,
    required this.serviceColor,
    required this.serviceIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          serviceType,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: serviceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_services')
            .where('type', isEqualTo: serviceType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(serviceIcon, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun service disponible',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final service = EmergencyService.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: serviceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              serviceIcon,
                              color: serviceColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        service.address,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
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
                    if (service.services.isNotEmpty) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: service.services.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: serviceColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: serviceColor,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (service.phone.isNotEmpty) {
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: service.phone.first,
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
                                      service: service,
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
      ),
    );
  }
} 