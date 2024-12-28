import 'package:quick_actions/quick_actions.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickActionsService {
  final QuickActions quickActions = const QuickActions();

  void initialize() {
    quickActions.initialize((shortcutType) async {
      // Gérer les actions selon le type de raccourci
      switch (shortcutType) {
        case 'action_emergency_call':
          await _makeEmergencyCall();
          break;
      }
    });

    // Définir les raccourcis disponibles
    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'action_emergency_call',
        localizedTitle: 'Appel Urgence',
        icon: 'ic_emergency_call',
      ),
    ]);
  }

  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '117', // Numéro d'urgence de la police en Guinée
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('Erreur lors de l\'appel: $e');
    }
  }
} 