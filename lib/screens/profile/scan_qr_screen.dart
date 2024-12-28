import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scanner QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Accès à la caméra requis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pour scanner les QR codes, veuillez autoriser l\'accès à la caméra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF094FC6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ouvrir les paramètres'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue == null) continue;
                      _handleQRData(barcode.rawValue!);
                    }
                  },
                ),
                // Overlay de scan
                CustomPaint(
                  painter: ScanOverlayPainter(),
                  child: Container(),
                ),
              ],
            ),
    );
  }

  void _handleQRData(String data) {
    try {
      final decodedData = json.decode(data);
      Navigator.pop(context);
      _showEmergencyInfo(decodedData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code invalide'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEmergencyInfo(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations d\'urgence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Nom', data['name']),
            _buildInfoRow('Groupe sanguin', data['bloodType']),
            _buildInfoRow('Contact d\'urgence', data['emergencyContact']),
            if (data['medicalConditions'] != null) ...[
              const SizedBox(height: 10),
              const Text(
                'Conditions médicales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._buildList(data['medicalConditions']),
            ],
            if (data['allergies'] != null) ...[
              const SizedBox(height: 10),
              const Text(
                'Allergies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._buildList(data['allergies']),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF094FC6),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Non renseigné',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList(List<dynamic> items) {
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(left: 20, top: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(item.toString()),
        ],
      ),
    )).toList();
  }
}

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            scanArea,
            const Radius.circular(20),
          )),
      ),
      paint,
    );

    // Coins du cadre de scan
    final borderPaint = Paint()
      ..color = const Color(0xFF094FC6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerSize = 30.0;
    
    // Coin supérieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.top + cornerSize)
        ..lineTo(scanArea.left, scanArea.top)
        ..lineTo(scanArea.left + cornerSize, scanArea.top),
      borderPaint,
    );

    // Coin supérieur droit
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerSize, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top + cornerSize),
      borderPaint,
    );

    // Coin inférieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.bottom - cornerSize)
        ..lineTo(scanArea.left, scanArea.bottom)
        ..lineTo(scanArea.left + cornerSize, scanArea.bottom),
      borderPaint,
    );

    // Coin inférieur droit
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerSize, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom - cornerSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 