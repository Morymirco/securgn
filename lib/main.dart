import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/services/emergency_services_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecurGuinee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
