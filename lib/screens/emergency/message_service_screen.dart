import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';

class MessageServiceScreen extends StatefulWidget {
  final Map<String, String> service;
  final Color serviceColor;
  final IconData serviceIcon;

  const MessageServiceScreen({
    super.key,
    required this.service,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  State<MessageServiceScreen> createState() => _MessageServiceScreenState();
}

class _MessageServiceScreenState extends State<MessageServiceScreen> {
  final _messageController = TextEditingController();
  final _authService = FirebaseAuthService();
  final _firestore = FirebaseFirestore.instance;
  XFile? selectedImage;
  String? currentAddress;
  Position? currentPosition;
  bool _isLoading = false;

  // Ajout de la liste des messages prédéfinis
  final List<String> predefinedMessages = [
    "J'ai besoin d'une assistance immédiate",
    "Situation d'urgence en cours",
    "Besoin d'aide médicale",
    "Accident de la route",
    "Situation dangereuse",
    "Besoin d'intervention rapide",
    "Urgence médicale",
    "Demande de secours",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      selectedImage = photo;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentPosition() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentPosition = position;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}';
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un message')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer le message
      final message = {
        'userId': _authService.currentUser?.uid,
        'userName': _authService.currentUser?.email,
        'serviceId': widget.service['id'],
        'serviceName': widget.service['name'],
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      };

      // Ajouter la localisation si disponible
      if (currentPosition != null) {
        message['location'] = {
          'latitude': currentPosition!.latitude,
          'longitude': currentPosition!.longitude,
          'address': currentAddress,
        };
      }

      // Envoyer le message
      await _firestore
          .collection('services_messages')
          .add(message);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(child: Text('Message envoyé')),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.done_all, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Envoyé',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
          ),
        );
        Navigator.pop(context);
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

  Color get _softServiceColor => widget.serviceColor.withOpacity(0.8);
  Color get _ultraSoftServiceColor => widget.serviceColor.withOpacity(0.1);
  Color get _mediumSoftServiceColor => widget.serviceColor.withOpacity(0.15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _softServiceColor,
        elevation: 0,
        title: Text(
          'Message à ${widget.service['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // En-tête avec info du service
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _softServiceColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.serviceIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.9),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.service['address']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Service disponible 24/7',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corps du message
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Messages rapides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: predefinedMessages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              _messageController.text = predefinedMessages[index];
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _ultraSoftServiceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _mediumSoftServiceColor,
                                ),
                              ),
                              child: Text(
                                predefinedMessages[index],
                                style: TextStyle(
                                  color: _softServiceColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Votre message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Champ de message
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre situation...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15),
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),

                  // Image sélectionnée
                  if (selectedImage != null)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: FileImage(File(selectedImage!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Localisation
                  if (currentAddress != null)
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Boutons d'action avec nouvelles icônes et design
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'Photo',
                          onPressed: _pickImage,
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.location_on,
                          label: _isLoading ? 'Chargement...' : 'Position',
                          onPressed: _getCurrentPosition,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton d'envoi avec animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor.withOpacity(_isLoading ? 0.7 : 1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Envoyer le message',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _softServiceColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }
} 