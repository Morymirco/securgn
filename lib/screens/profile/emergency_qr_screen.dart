import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_app/screens/profile/scan_qr_screen.dart';

class EmergencyQRScreen extends StatefulWidget {
  const EmergencyQRScreen({super.key});

  @override
  State<EmergencyQRScreen> createState() => _EmergencyQRScreenState();
}

class _EmergencyQRScreenState extends State<EmergencyQRScreen> {
  final _authService = FirebaseAuthService();
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .get();

      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des données: $e');
    }
  }

  String _generateEmergencyData() {
    if (_userData == null) return '';

    final emergencyData = {
      'name': _userData!['username'] ?? '',
      'bloodType': _userData!['bloodType'] ?? '',
      'emergencyContact': _userData!['emergencyContact'] ?? '',
      'medicalConditions': _userData!['medicalConditions'] ?? [],
      'allergies': _userData!['allergies'] ?? [],
      'medications': _userData!['medications'] ?? [],
    };

    return json.encode(emergencyData);
  }

  Future<void> _shareQRCode() async {
    try {
      final qrData = _generateEmergencyData();
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/emergency_qr.png');

      final qrImage = await qrPainter.toImageData(200);
      await file.writeAsBytes(qrImage!.buffer.asUint8List());

      await Share.share(
        'Mon QR Code d\'urgence SecurGuinee',
        subject: 'QR Code d\'urgence',
      );
    } catch (e) {
      print('Erreur lors du partage du QR code: $e');
    }
  }

  Future<void> _downloadPDF() async {
    final pdf = pw.Document();
    
    try {
      // Générer le QR code
      final qrData = _generateEmergencyData();
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
      );
      final qrImage = await qrPainter.toImageData(200);
      final qrBytes = qrImage!.buffer.asUint8List();

      // Créer le PDF
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // En-tête
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'QR Code d\'urgence SecurGuinee',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // QR Code
                pw.Image(
                  pw.MemoryImage(qrBytes),
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 20),

                // Informations d'urgence
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfInfoRow('Nom', _userData?['username'] ?? ''),
                      _buildPdfInfoRow('Groupe sanguin', _userData?['bloodType'] ?? ''),
                      _buildPdfInfoRow('Contact d\'urgence', _userData?['emergencyContact'] ?? ''),
                      
                      if (_userData?['medicalConditions'] != null) ...[
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Conditions médicales:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        ..._buildPdfList(_userData!['medicalConditions']),
                      ],

                      if (_userData?['allergies'] != null) ...[
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Allergies:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        ..._buildPdfList(_userData!['allergies']),
                      ],
                    ],
                  ),
                ),

                // Note de bas de page
                pw.Spacer(),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Text(
                    'En cas d\'urgence, scannez ce QR code pour accéder aux informations médicales.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Sauvegarder le PDF dans les documents
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/qr_code_urgence.pdf');
      await file.writeAsBytes(await pdf.save());

      // Partager le PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mon QR Code d\'urgence SecurGuinee',
        subject: 'QR Code d\'urgence',
      );

    } catch (e) {
      print('Erreur lors de la création du PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création du PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? 'Non renseigné' : value,
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfList(List<dynamic> items) {
    return items.map((item) => pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, top: 5),
      child: pw.Text('• $item'),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code d\'urgence',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQRCode,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPDF,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Section QR Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: _generateEmergencyData(),
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Scannez ce QR code pour accéder à mes informations d\'urgence',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Informations affichées
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations d\'urgence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF094FC6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow('Nom', _userData?['username'] ?? ''),
                        _buildInfoRow('Groupe sanguin', _userData?['bloodType'] ?? ''),
                        _buildInfoRow('Contact d\'urgence', _userData?['emergencyContact'] ?? ''),
                        if (_userData?['medicalConditions'] != null) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Conditions médicales',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          ..._buildList(_userData!['medicalConditions']),
                        ],
                        if (_userData?['allergies'] != null) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Allergies',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          ..._buildList(_userData!['allergies']),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Note de confidentialité
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ces informations ne sont accessibles qu\'en cas d\'urgence via le scan du QR code.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanQRScreen()),
          );
        },
        backgroundColor: const Color(0xFF094FC6),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Non renseigné' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black87,
              ),
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