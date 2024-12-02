import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer un document
  Future<void> createDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      print('Erreur lors de la création du document: $e');
      rethrow;
    }
  }

  // Lire un document
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      print('Erreur lors de la lecture du document: $e');
      rethrow;
    }
  }

  // Mettre à jour un document
  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      print('Erreur lors de la mise à jour du document: $e');
      rethrow;
    }
  }

  // Supprimer un document
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du document: $e');
      rethrow;
    }
  }

  // Obtenir un stream de documents
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }
} 