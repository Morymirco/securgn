import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'message_service_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String serviceType;
  final Color serviceColor;
  final IconData serviceIcon;

  const ServiceListScreen({
    super.key,
    required this.serviceType,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  XFile? selectedImage;
  String? currentAddress;
  Position? currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Les services de localisation sont désactivés. Veuillez les activer.'),
      ));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Les permissions de localisation sont refusées.'),
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Les permissions de localisation sont définitivement refusées.'),
      ));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

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
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    // Afficher un bottom sheet pour choisir la source
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

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  List<Map<String, String>> _getServicesList() {
    switch (widget.serviceType) {
      case 'Police':
        return [
          {
            'name': 'Commissariat Central de Kaloum',
            'address': 'Kaloum, Conakry',
            'phone': '117',
          },
          {
            'name': 'Commissariat de Matam',
            'address': 'Matam, Conakry',
            'phone': '117',
          },
          {
            'name': 'Commissariat de Ratoma',
            'address': 'Ratoma, Conakry',
            'phone': '117',
          },
        ];
      case 'Pompiers':
        return [
          {
            'name': 'Centre de Secours Principal',
            'address': 'Almamya, Conakry',
            'phone': '118',
          },
          {
            'name': 'Centre de Secours de Matoto',
            'address': 'Matoto, Conakry',
            'phone': '118',
          },
          {
            'name': 'Centre de Secours de Kipé',
            'address': 'Kipé, Conakry',
            'phone': '118',
          },
        ];
      case 'SAMU':
        return [
          {
            'name': 'SAMU - CHU Donka',
            'address': 'Donka, Conakry',
            'phone': '115',
          },
          {
            'name': 'SAMU - Clinique Ambroise Paré',
            'address': 'Coronthie, Conakry',
            'phone': '115',
          },
          {
            'name': 'SAMU - Hôpital Ignace Deen',
            'address': 'Kaloum, Conakry',
            'phone': '115',
          },
        ];
      case 'Urgence Médicale':
        return [
          {
            'name': 'Hôpital National Donka',
            'address': 'Donka, Conakry',
            'phone': '629000000',
          },
          {
            'name': 'Clinique Pasteur',
            'address': 'Kaloum, Conakry',
            'phone': '628000000',
          },
          {
            'name': 'Clinique Ambroise Paré',
            'address': 'Ratoma, Conakry',
            'phone': '627000000',
          },
          {
            'name': 'Centre Médical Communal de Matam',
            'address': 'Matam, Conakry',
            'phone': '626000000',
          },
        ];
      case 'Assistance Routière':
        return [
          {
            'name': 'Dépannage Auto 24/7',
            'address': 'Autoroute Fidel Castro, Conakry',
            'phone': '666000000',
          },
          {
            'name': 'SOS Remorquage',
            'address': 'Route Le Prince, Conakry',
            'phone': '664000000',
          },
          {
            'name': 'Garage Central',
            'address': 'Kaloum, Conakry',
            'phone': '662000000',
          },
          {
            'name': 'Service Dépannage Express',
            'address': 'Matoto, Conakry',
            'phone': '661000000',
          },
        ];
      default:
        return [];
    }
  }

  void _showMessageDialog(BuildContext context, Map<String, String> service) {
    final messageController = TextEditingController();
    bool isAttachmentMenuVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(widget.serviceIcon, color: widget.serviceColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Message pour ${service['name']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Décrivez votre situation',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre message ici...',
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      if (selectedImage != null)
                        Stack(
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(selectedImage!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.8),
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
                      if (currentAddress != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentAddress!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isAttachmentMenuVisible)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () => _pickImage(context),
                                tooltip: 'Prendre une photo',
                              ),
                              IconButton(
                                icon: const Icon(Icons.photo_library),
                                onPressed: () => _pickImage(context),
                                tooltip: 'Choisir une photo',
                              ),
                              IconButton(
                                icon: const Icon(Icons.location_on),
                                onPressed: _getCurrentPosition,
                                tooltip: 'Partager la position',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: widget.serviceColor,
              ),
              onPressed: () {
                setState(() {
                  isAttachmentMenuVisible = !isAttachmentMenuVisible;
                });
              },
            ),
            TextButton(
              onPressed: () {
                messageController.dispose();
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final message = messageController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Message envoyé'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.done_all,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Envoyé',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
                messageController.dispose();
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.send),
              label: const Text('Envoyer'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _getServicesList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: widget.serviceColor,
        elevation: 0,
        title: Text(
          'Services ${widget.serviceType}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // En-tête avec icône du service
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.serviceColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.serviceIcon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Liste des services ${widget.serviceType}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Liste des services
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: index * 100),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icône du service avec badge
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: widget.serviceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.serviceIcon,
                              color: widget.serviceColor,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Informations du service
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Ouvert 24/7',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        service['address']!,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          service['phone']!,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _makePhoneCall(service['phone']!),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: widget.serviceColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: 16,
                                                  color: widget.serviceColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Appeler',
                                                  style: TextStyle(
                                                    color: widget.serviceColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MessageServiceScreen(
                                                service: service,
                                                serviceColor: widget.serviceColor,
                                                serviceIcon: widget.serviceIcon,
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: widget.serviceColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Tooltip(
                                              message: 'Envoyer un message',
                                              child: Icon(
                                                Icons.message_outlined,
                                                size: 16,
                                                color: widget.serviceColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 