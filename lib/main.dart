import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/services/emergency_services_initializer.dart';
import 'package:my_app/services/quick_actions_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser les services d'urgence
  final servicesInitializer = EmergencyServicesInitializer();
  await servicesInitializer.initializeEmergencyServices();
  
  // Vérifier que les services ont été créés
  await servicesInitializer.checkExistingServices();

  // Initialiser les raccourcis
  final quickActionsService = QuickActionsService();
  quickActionsService.initialize();

  runApp(const MyApp());
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
