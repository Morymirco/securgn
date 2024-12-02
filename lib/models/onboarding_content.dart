class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingContent> contents = [
  OnboardingContent(
    title: 'Bienvenue sur SecurGuinee',
    description: 'Votre application pour les situations d\'urgence',
    image: 'assets/images/img_numurgence.jpeg',
  ),
  OnboardingContent(
    title: 'Accès Rapide',
    description: 'Trouvez rapidement les numéros d\'urgence dont vous avez besoin',
    image: 'assets/images/img_numurgence.jpeg',
  ),
  OnboardingContent(
    title: 'Toujours Prêt',
    description: 'Gardez les contacts d\'urgence à portée de main',
    image: 'assets/images/img_numurgence.jpeg',
  ),
]; 