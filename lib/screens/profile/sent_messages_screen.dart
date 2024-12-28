import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/emergency_message.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';

class SentMessagesScreen extends StatelessWidget {
  final _authService = FirebaseAuthService();
  final _firestore = FirebaseFirestore.instance;

  SentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages Envoyés',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF094FC6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('services_messages')
                  .where('userId', isEqualTo: _authService.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int totalMessages = snapshot.data?.docs.length ?? 0;
                int respondedMessages = snapshot.data?.docs
                    .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'responded')
                    .length ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total',
                      totalMessages.toString(),
                      Icons.message,
                    ),
                    _buildStatCard(
                      'Traités',
                      respondedMessages.toString(),
                      Icons.check_circle,
                    ),
                    _buildStatCard(
                      'En attente',
                      (totalMessages - respondedMessages).toString(),
                      Icons.pending,
                    ),
                  ],
                );
              },
            ),
          ),

          // Liste des messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('services_messages')
                  .where('userId', isEqualTo: _authService.currentUser?.uid)
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
                        Icon(
                          Icons.message_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message envoyé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final sortedDocs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aTimestamp = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
                    final bTimestamp = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
                    return bTimestamp.compareTo(aTimestamp);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = sortedDocs[index];
                    final message = EmergencyMessage.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );

                    return _MessageCard(message: message);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final EmergencyMessage message;

  const _MessageCard({required this.message});

  Future<List<EmergencyMessage>> _loadReplies(String messageId) async {
    try {
      debugPrint('Chargement des réponses pour le message: $messageId');

      final QuerySnapshot repliesSnapshot = await FirebaseFirestore.instance
          .collection('services_messages')
          .where('replyTo', isEqualTo: messageId)
          .get();

      debugPrint('Nombre de réponses trouvées: ${repliesSnapshot.docs.length}');

      if (repliesSnapshot.docs.isEmpty) {
        debugPrint('Aucune réponse trouvée');
      } else {
        for (var doc in repliesSnapshot.docs) {
          debugPrint('Réponse trouvée: ${doc.data()}');
        }
      }

      return repliesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('Conversion de la réponse: $data');
        return EmergencyMessage.fromMap(data, doc.id);
      }).toList();
    } catch (error) {
      debugPrint('Erreur lors du chargement des réponses: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.all(16),
          leading: _getServiceIcon(message.serviceName),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(message.timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: _getStatusBadge(message.status),
          children: [
            const Divider(),
            // Message content
            _buildSection(
              title: 'Message',
              content: message.message,
              icon: Icons.message,
            ),
            if (message.location != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Localisation',
                content: message.location?.address ??
                    'Lat: ${message.location?.latitude}, Long: ${message.location?.longitude}',
                icon: Icons.location_on,
                iconColor: Colors.red,
              ),
            ],
            FutureBuilder<List<EmergencyMessage>>(
              future: _loadReplies(message.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Erreur FutureBuilder: ${snapshot.error}');
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Erreur lors du chargement des réponses: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final replies = snapshot.data ?? [];
                debugPrint('Nombre de réponses après conversion: ${replies.length}');

                if (replies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Aucune réponse pour le moment',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Réponses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...replies.map((reply) {
                      debugPrint('Construction de la carte de réponse pour: ${reply.message}');
                      return _ResponseCard(
                        response: ServiceResponse(
                          serviceId: reply.serviceId,
                          serviceName: reply.serviceName,
                          message: reply.message,
                          timestamp: reply.timestamp,
                          status: reply.status,
                          // Vous pouvez ajouter eta si nécessaire
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(content),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _getServiceIcon(String serviceName) {
    IconData iconData;
    Color color;

    if (serviceName.toLowerCase().contains('hôpital') || 
        serviceName.toLowerCase().contains('clinique')) {
      iconData = Icons.local_hospital;
      color = Colors.red;
    } else if (serviceName.toLowerCase().contains('police')) {
      iconData = Icons.local_police;
      color = Colors.blue;
    } else if (serviceName.toLowerCase().contains('pompier')) {
      iconData = Icons.fire_truck;
      color = Colors.orange;
    } else {
      iconData = Icons.emergency;
      color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color),
    );
  }

  Widget _getStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'sent':
        color = Colors.blue;
        text = 'Envoyé';
        break;
      case 'received':
        color = Colors.orange;
        text = 'Reçu';
        break;
      case 'responded':
        color = Colors.green;
        text = 'Traité';
        break;
      default:
        color = Colors.grey;
        text = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final ServiceResponse response;

  const _ResponseCard({required this.response});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(response.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(response.status),
                    color: _getStatusColor(response.status),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(response.status),
                  style: TextStyle(
                    color: _getStatusColor(response.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(response.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(response.message),
            if (response.eta != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatETA(response.eta!),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatETA(EstimatedArrival eta) {
    final minutes = (eta.duration / 60).round();
    return 'Arrivée dans $minutes min (${(eta.distance / 1000).toStringAsFixed(1)} km)';
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'en route':
        return Icons.directions_car;
      case 'arrivé':
        return Icons.location_on;
      case 'terminé':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'en route':
        return 'En route';
      case 'arrivé':
        return 'Sur place';
      case 'terminé':
        return 'Intervention terminée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en route':
        return Colors.orange;
      case 'arrivé':
        return Colors.green;
      case 'terminé':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
} 