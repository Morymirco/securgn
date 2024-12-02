import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyServicesInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeEmergencyServices() async {
    final Map<String, List<Map<String, dynamic>>> servicesData = {
      'medical': [
        {
          'name': 'Hôpital National Ignace Deen',
          'type': 'Urgences Médicales',
          'phone': ['622 21 35 15', '664 26 25 33'],
          'address': 'Kaloum, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Chirurgie', 'Maternité', 'Pédiatrie'],
          'coordinates': {
            'latitude': 9.5092,
            'longitude': -13.7122
          },
        },
        {
          'name': 'Hôpital National Donka',
          'type': 'Urgences Médicales',
          'phone': ['622 35 35 15', '664 35 25 33'],
          'address': 'Dixinn, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Réanimation', 'Traumatologie'],
          'coordinates': {
            'latitude': 9.5355,
            'longitude': -13.6773
          },
        },
        {
          'name': 'Clinique Ambroise Paré',
          'type': 'Urgences Médicales',
          'phone': ['622 66 77 88', '664 99 00 11'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Cardiologie', 'Pédiatrie'],
          'coordinates': {
            'latitude': 9.5512,
            'longitude': -13.6544
          },
        },
      ],
      'police': [
        {
          'name': 'Direction Centrale de la Police',
          'type': 'Police',
          'phone': ['117', '628 33 44 55'],
          'address': 'Kaloum, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Enquêtes', 'Sécurité routière'],
          'coordinates': {
            'latitude': 9.5147,
            'longitude': -13.7120
          },
        },
        {
          'name': 'Commissariat Central de Matam',
          'type': 'Police',
          'phone': ['622 44 55 66'],
          'address': 'Matam, Conakry',
          'available24h': true,
          'services': ['Interventions', 'Plaintes', 'Patrouilles'],
          'coordinates': {
            'latitude': 9.5512,
            'longitude': -13.6544
          },
        },
        {
          'name': 'Commissariat de Ratoma',
          'type': 'Police',
          'phone': ['622 88 99 00'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Interventions', 'Sécurité de proximité'],
          'coordinates': {
            'latitude': 9.5651,
            'longitude': -13.6203
          },
        },
      ],
      'pompiers': [
        {
          'name': 'Protection Civile Centrale',
          'type': 'Pompiers',
          'phone': ['18', '664 88 99 00'],
          'address': 'Almamya, Conakry',
          'available24h': true,
          'services': ['Incendies', 'Secours', 'Sauvetage'],
          'coordinates': {
            'latitude': 9.5234,
            'longitude': -13.7001
          },
        },
        {
          'name': 'Caserne des Pompiers de Ratoma',
          'type': 'Pompiers',
          'phone': ['664 11 22 33'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Incendies', 'Secours', 'Interventions d\'urgence'],
          'coordinates': {
            'latitude': 9.5651,
            'longitude': -13.6203
          },
        },
      ],
      'assistance_routiere': [
        {
          'name': 'Service d\'Assistance Routière',
          'type': 'Assistance Routière',
          'phone': ['622 77 88 99'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Dépannage', 'Remorquage', 'Assistance technique'],
          'coordinates': {
            'latitude': 9.5651,
            'longitude': -13.6203
          },
        },
        {
          'name': 'SOS Auto Guinée',
          'type': 'Assistance Routière',
          'phone': ['622 00 11 22'],
          'address': 'Matam, Conakry',
          'available24h': true,
          'services': ['Dépannage', 'Remorquage', 'Réparation sur place'],
          'coordinates': {
            'latitude': 9.5512,
            'longitude': -13.6544
          },
        },
      ],
    };

    // Supprimer d'abord toutes les données existantes
    final batch = _firestore.batch();
    final existingServices = await _firestore.collection('emergency_services').get();
    for (var doc in existingServices.docs) {
      batch.delete(doc.reference);
    }

    // Ajouter les nouvelles données
    servicesData.forEach((type, services) {
      services.forEach((service) {
        final docRef = _firestore.collection('emergency_services').doc();
        batch.set(docRef, {
          ...service,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });

    await batch.commit();
    print('Services d\'urgence initialisés avec succès');
  }

  // Méthode pour vérifier les services existants
  Future<void> checkExistingServices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('emergency_services').get();
      print('Nombre de services trouvés: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        print('Service: ${doc.data()}');
      }
    } catch (e) {
      print('Erreur lors de la vérification des services: $e');
    }
  }

  // Méthode pour récupérer les services par type
  Stream<QuerySnapshot> getServicesByType(String type) {
    return _firestore
        .collection('emergency_services')
        .where('type', isEqualTo: type)
        .snapshots();
  }

  // Méthode pour récupérer tous les services
  Stream<QuerySnapshot> getAllServices() {
    return _firestore
        .collection('emergency_services')
        .snapshots();
  }

  // Méthode pour mettre à jour un service
  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _firestore.collection('emergency_services').doc(serviceId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Méthode pour supprimer un service
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('emergency_services').doc(serviceId).delete();
  }
} 