import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour suivre l'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription avec email et mot de passe
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur de réinitialisation du mot de passe: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur de déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier si l'email existe déjà
  Future<bool> emailExists(String email) async {
    try {
      final result = await _auth.fetchSignInMethodsForEmail(email);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
} 