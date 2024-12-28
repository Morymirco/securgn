import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyServicesInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeEmergencyServices() async {
    final Map<String, List<Map<String, dynamic>>> servicesData = {
      'medical': [
        {
          'serviceId': 'ignacedeen_urgences_001',
          'name': 'Hôpital National Ignace Deen',
          'type': 'Urgences Médicales',
          'phone': ['622 21 35 15', '664 26 25 33'],
          'address': 'Kaloum, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Chirurgie', 'Maternité', 'Pédiatrie'],
          'coordinates': const GeoPoint(9.5092, -13.7122),
          'email': 'urgences.ignacedeen@gmail.com',
          'username': 'ignacedeen_urgences',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'donka_urgences_001',
          'name': 'Hôpital National Donka',
          'type': 'Urgences Médicales',
          'phone': ['622 35 35 15', '664 35 25 33'],
          'address': 'Dixinn, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Réanimation', 'Traumatologie'],
          'coordinates': const GeoPoint(9.5355, -13.6773),
          'email': 'urgences.nationaldonka@gmail.com',
          'username': 'nationaldonka_urgences',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'ambroisepare_urgences_001',
          'name': 'Clinique Ambroise Paré',
          'type': 'Urgences Médicales',
          'phone': ['622 66 77 88', '664 99 00 11'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Cardiologie', 'Pédiatrie'],
          'coordinates': const GeoPoint(9.5512, -13.6544),
          'email': 'urgences.ambroisepare@gmail.com',
          'username': 'ambroisepare_urgences',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
      ],
      'police': [
        {
          'serviceId': 'police_centrale_001',
          'name': 'Direction Centrale de la Police',
          'type': 'Police',
          'phone': ['117', '628 33 44 55'],
          'address': 'Kaloum, Conakry',
          'available24h': true,
          'services': ['Urgences', 'Enquêtes', 'Sécurité routière'],
          'coordinates': const GeoPoint(9.5147, -13.7120),
          'email': 'police.centrale@gmail.com',
          'username': 'police_centrale',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'matam_police_001',
          'name': 'Commissariat Central de Matam',
          'type': 'Police',
          'phone': ['622 44 55 66'],
          'address': 'Matam, Conakry',
          'available24h': true,
          'services': ['Interventions', 'Plaintes', 'Patrouilles'],
          'coordinates': const GeoPoint(9.5512, -13.6544),
          'email': 'police.commissariat.matam@gmail.com',
          'username': 'matam_police',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'ratoma_police_001',
          'name': 'Commissariat de Ratoma',
          'type': 'Police',
          'phone': ['622 88 99 00'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Interventions', 'Sécurité de proximité'],
          'coordinates': const GeoPoint(9.5651, -13.6203),
          'email': 'police.commissariat.ratoma@gmail.com',
          'username': 'ratoma_police',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
      ],
      'pompiers': [
        {
          'serviceId': 'protectioncivile_centrale_001',
          'name': 'Protection Civile Centrale',
          'type': 'Pompiers',
          'phone': ['18', '664 88 99 00'],
          'address': 'Almamya, Conakry',
          'available24h': true,
          'services': ['Incendies', 'Secours', 'Sauvetage'],
          'coordinates': const GeoPoint(9.5234, -13.7001),
          'email': 'pompiers.protectioncivile.centrale@gmail.com',
          'username': 'protectioncivile_centrale',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'caserne_ratoma_001',
          'name': 'Caserne des Pompiers de Ratoma',
          'type': 'Pompiers',
          'phone': ['664 11 22 33'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Incendies', 'Secours', 'Interventions d\'urgence'],
          'coordinates': const GeoPoint(9.5651, -13.6203),
          'email': 'pompiers.caserne.ratoma@gmail.com',
          'username': 'caserne_ratoma',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
      ],
      'assistance_routiere': [
        {
          'serviceId': 'assistance_routiere_001',
          'name': 'Service d\'Assistance Routière',
          'type': 'Assistance Routière',
          'phone': ['622 77 88 99'],
          'address': 'Ratoma, Conakry',
          'available24h': true,
          'services': ['Dépannage', 'Remorquage', 'Assistance technique'],
          'coordinates': const GeoPoint(9.5651, -13.6203),
          'email': 'assistance.routiere@gmail.com',
          'username': 'assistance_routiere',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
        {
          'serviceId': 'sos_auto_guinee_001',
          'name': 'SOS Auto Guinée',
          'type': 'Assistance Routière',
          'phone': ['622 00 11 22'],
          'address': 'Matam, Conakry',
          'available24h': true,
          'services': ['Dépannage', 'Remorquage', 'Réparation sur place'],
          'coordinates': const GeoPoint(9.5512, -13.6544),
          'email': 'sos.auto.guinee@gmail.com',
          'username': 'sos_auto_guinee',
          'password': 'defaultPassword123',
          'isActive': true,
          'role': 'SERVICE',
        },
      ],
    };

    final batch = _firestore.batch();
    
    // Supprimer les services existants
    final existingServices = await _firestore.collection('emergency_services').get();
    for (var doc in existingServices.docs) {
      batch.delete(doc.reference);
    }

    // Ajouter les nouveaux services avec leur serviceId comme ID du document
    servicesData.forEach((type, services) {
      services.forEach((service) {
        // Utiliser le serviceId comme ID du document
        final docRef = _firestore
            .collection('emergency_services')
            .doc(service['serviceId'] as String);
            
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