import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _todayNotifications = [
    {
      'title': 'Alerte météo',
      'message': 'Fortes pluies attendues dans votre région',
      'time': '2 heures',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
      'isUnread': true,
    },
    {
      'title': 'Nouveau centre médical',
      'message': 'Un nouveau centre médical a ouvert près de chez vous',
      'time': '5 heures',
      'icon': Icons.local_hospital,
      'color': Colors.green,
      'isUnread': false,
    },
  ];

  final List<Map<String, dynamic>> _weekNotifications = [
    {
      'title': 'Mise à jour de sécurité',
      'message': 'Nouvelles mesures de sécurité disponibles',
      'time': '2 jours',
      'icon': Icons.security,
      'color': const Color(0xFF094FC6),
      'isUnread': false,
    },
    {
      'title': 'Conseil santé',
      'message': 'Consultez les nouveaux conseils de santé',
      'time': '3 jours',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'isUnread': false,
    },
  ];

  void _removeNotification(Map<String, dynamic> notification, bool isToday) {
    setState(() {
      if (isToday) {
        _todayNotifications.remove(notification);
      } else {
        _weekNotifications.remove(notification);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              // TODO: Marquer toutes les notifications comme lues
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          if (_todayNotifications.isNotEmpty) ...[
            _buildNotificationGroup(
              'Aujourd\'hui',
              _todayNotifications,
              true,
            ),
          ],
          const SizedBox(height: 20),
          if (_weekNotifications.isNotEmpty) ...[
            _buildNotificationGroup(
              'Cette semaine',
              _weekNotifications,
              false,
            ),
          ],
          if (_todayNotifications.isEmpty && _weekNotifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucune notification',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(String title, List<Map<String, dynamic>> notifications, bool isToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...notifications.map((notification) => _buildNotification(notification, isToday)).toList(),
      ],
    );
  }

  Widget _buildNotification(Map<String, dynamic> notification, bool isToday) {
    return FadeInUp(
      child: Dismissible(
        key: UniqueKey(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _removeNotification(notification, isToday);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification supprimée'),
              action: SnackBarAction(
                label: 'Annuler',
                onPressed: () {
                  setState(() {
                    if (isToday) {
                      _todayNotifications.add(notification);
                    } else {
                      _weekNotifications.add(notification);
                    }
                  });
                },
              ),
            ),
          );
        },
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 24,
                  ),
                ),
                if (notification['isUnread'])
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              notification['title'],
              style: TextStyle(
                fontWeight: notification['isUnread'] ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Il y a ${notification['time']}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
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