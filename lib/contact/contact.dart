import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  Position? currentPosition;
  String? currentAddress;
  bool _isLoadingLocation = false;
  Stream<QuerySnapshot>? _messagesStream;
  String? _replyingToId;

  @override
  void initState() {
    super.initState();
    _initializeMessagesStream();
  }

  void _initializeMessagesStream() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _messagesStream = _firestore
          .collection('chat_urgence')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      
      setState(() {
        currentPosition = position;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}';
        }
      });
    } catch (e) {
      print('Erreur de localisation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la récupération de la position'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
      await _sendMessage(imageFile: File(photo.path));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      await _sendMessage(imageFile: File(image.path));
    }
  }

  void _replyToMessage(String messageId) {
    setState(() {
      _replyingToId = messageId;
    });
    _controller.text = 'Réponse au message...';
  }

  Future<void> _sendMessage({File? imageFile}) async {
    if (_controller.text.isEmpty && imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUser;
      
      final message = {
        'userId': currentUser?.uid ?? 'anonymous',
        'userName': currentUser?.email ?? 'Anonyme',
        'message': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': imageFile != null ? 'image' : 'text',
        'status': 'sent',
        'isAnonymous': currentUser == null,
        if (_replyingToId != null) 'replyTo': _replyingToId,
      };

      if (currentPosition != null) {
        message['location'] = {
          'latitude': currentPosition!.latitude,
          'longitude': currentPosition!.longitude,
          'address': currentAddress,
        };
      }

      await _firestore.collection('chat_urgence').add(message);

      if (mounted) {
        _controller.clear();
        setState(() {
          _image = null;
          _replyingToId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentPosition != null 
                        ? 'Message envoyé avec la localisation' 
                        : 'Message envoyé',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF094FC6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image,
                  color: Color(0xFF094FC6),
                ),
              ),
              title: const Text('Galerie photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF094FC6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF094FC6),
                ),
              ),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      // Supprimer d'abord toutes les réponses à ce message
      final replies = await _firestore
          .collection('chat_urgence')
          .where('replyTo', isEqualTo: messageId)
          .get();
      
      for (var doc in replies.docs) {
        await doc.reference.delete();
      }

      // Supprimer le message principal
      await _firestore.collection('chat_urgence').doc(messageId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF094FC6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/security.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Service disponible 24/7',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (currentUser == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                backgroundColor: Colors.red.withOpacity(0.2),
                label: const Text(
                  'Mode Anonyme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                avatar: const Icon(
                  Icons.person_off,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          IconButton(
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.location_on, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Organiser les messages et leurs réponses
                  final messages = <String, Map<String, dynamic>>{};
                  final replies = <String, List<Map<String, dynamic>>>{};

                  for (var doc in snapshot.data!.docs) {
                    final message = doc.data() as Map<String, dynamic>;
                    message['id'] = doc.id;

                    if (message['replyTo'] != null) {
                      // C'est une réponse
                      final parentId = message['replyTo'] as String;
                      replies[parentId] = replies[parentId] ?? [];
                      replies[parentId]!.add(message);
                    } else {
                      // C'est un message principal
                      messages[doc.id] = message;
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageId = messages.keys.elementAt(index);
                      final message = messages[messageId];
                      final messageReplies = replies[messageId] ?? [];
                      final hasLocation = message?['location'] != null;
                      final isCurrentUser = message?['userId'] == _authService.currentUser?.uid;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message principal
                          FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? const Color(0xFF094FC6) : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: isCurrentUser 
                                                ? Colors.white.withOpacity(0.2)
                                                : const Color(0xFF094FC6).withOpacity(0.1),
                                            child: Icon(
                                              Icons.person,
                                              size: 18,
                                              color: isCurrentUser 
                                                  ? Colors.white
                                                  : const Color(0xFF094FC6),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            message?['userName'] ?? 'Anonyme',
                                            style: TextStyle(
                                              color: isCurrentUser ? Colors.white70 : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (isCurrentUser)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: isCurrentUser ? Colors.white70 : Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Supprimer le message'),
                                                    content: const Text('Voulez-vous vraiment supprimer ce message ?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Annuler'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          _deleteMessage(message?['id'] ?? '');
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                        ),
                                                        child: const Text('Supprimer'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          if (!isCurrentUser)
                                            IconButton(
                                              icon: Icon(
                                                Icons.reply,
                                                color: isCurrentUser ? Colors.white70 : Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _replyToMessage(message?['id'] ?? '');
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    message?['message'] ?? '',
                                    style: TextStyle(
                                      color: isCurrentUser ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (hasLocation) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser 
                                            ? Colors.white.withOpacity(0.1)
                                            : const Color(0xFF094FC6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: isCurrentUser ? Colors.white : const Color(0xFF094FC6),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              message?['location']['address'] ?? 'Position partagée',
                                              style: TextStyle(
                                                color: isCurrentUser ? Colors.white : const Color(0xFF094FC6),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Réponses au message
                          if (messageReplies.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Column(
                                children: messageReplies.map((reply) {
                                  final isReplyFromCurrentUser = reply['userId'] == _authService.currentUser?.uid;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isReplyFromCurrentUser 
                                          ? const Color(0xFF094FC6).withOpacity(0.9)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.reply,
                                              size: 16,
                                              color: isReplyFromCurrentUser ? Colors.white70 : Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              reply['userName'] ?? 'Anonyme',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isReplyFromCurrentUser ? Colors.white70 : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          reply['message'],
                                          style: TextStyle(
                                            color: isReplyFromCurrentUser ? Colors.white : Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Colors.grey[600],
                      onPressed: _showAttachmentOptions,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Message d\'urgence...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF094FC6),
                            Color(0xFF0A3A8B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF094FC6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _isLoading ? null : () => _sendMessage(),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
