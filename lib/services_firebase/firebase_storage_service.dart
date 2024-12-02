import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Télécharger un fichier
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors du téléchargement du fichier: $e');
      rethrow;
    }
  }

  // Supprimer un fichier
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Erreur lors de la suppression du fichier: $e');
      rethrow;
    }
  }

  // Obtenir l'URL de téléchargement d'un fichier
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors de l\'obtention de l\'URL: $e');
      rethrow;
    }
  }
} 