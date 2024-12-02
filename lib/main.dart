import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/services/emergency_services_initializer.dart';

// Gestionnaire de messages en arrière-plan
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

 

  

    // Initialiser les services d'urgence
    final servicesInitializer = EmergencyServicesInitializer();
    try {
      await servicesInitializer.initializeEmergencyServices();
      print('Services d\'urgence initialisés avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des services d\'urgence: $e');
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    runApp(const MyApp());
  } catch (e) {
    print('Erreur d\'initialisation: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecurGuinee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF094FC6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF094FC6)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
