import 'package:flutter/material.dart';
import '../../routes.dart';

class EventsHomePage extends StatelessWidget {
  const EventsHomePage({super.key});

  static const headerA = Color(0xFF2D6CDF);
  static const headerB = Color(0xFF6CA8FF);
  static const pageBg  = Color(0xFFEFF4FF);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget featureCard({
      required String title,
      required String subtitle,
      required String assetPath,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: .08),
          highlightColor: scheme.primary.withValues(alpha: .04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE0E0E0),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 36),
                  ),
                ),
              ),
              // Texte
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerA,
        foregroundColor: Colors.white,
        title: const Text('Gestion des événements'),
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [headerA, headerB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Bandeau d’accueil
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [headerA, headerB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: headerA.withValues(alpha: .20),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue 👋',
                  style: text.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Page d’accueil de la Gestion Événements.\nChoisissez une section pour commencer.',
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grille de fonctionnalités (2 colonnes)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .88,
            children: [
              featureCard(
                title: 'Liste événements',
                subtitle: 'Parcourir, filtrer, paginer.\n(🎯 page principale)',
                assetPath: 'assets/events/mobile_photo_liste_event.png',
                onTap: () => Navigator.of(context).pushNamed(EventsRoutes.list),
              ),
              featureCard(
                title: 'Statistiques',
                subtitle: 'Vue globale des KPI.',
                assetPath: 'assets/events/mobile_photo_statistique.png',
                onTap: () => Navigator.of(context).pushNamed(EventsRoutes.stats),
              ),
              featureCard(
                title: 'Système de gamification',
                subtitle: 'Badges, points et niveaux.',
                assetPath: 'assets/events/mobile_photo_gamification.png',
                // ✅ on va sur la vraie page via la route nommée
                onTap: () => Navigator.of(context).pushNamed(EventsRoutes.gamification),
              ),
              // dans EventsHomePage, carte "Taux de succès"
              featureCard(
                title: 'Taux de succès',
                subtitle: 'Évalue avant de créer.',
                assetPath: 'assets/events/mobile_photo_taux_succès.png',
                onTap: () => Navigator.of(context).pushNamed(EventsRoutes.success), // <-- AJOUT
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// On garde seulement ce placeholder (pas encore d’écran dédié)
class SuccessRatePlaceholderPage extends StatelessWidget {
  const SuccessRatePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScaffold(
      title: 'Taux de succès',
      message: 'Écran Taux de succès — à implémenter.',
      emoji: '📈',
    );
  }
}

class _PlaceholderScaffold extends StatelessWidget {
  final String title;
  final String message;
  final String emoji;
  const _PlaceholderScaffold({
    required this.title,
    required this.message,
    required this.emoji,
  });

  static const headerA = Color(0xFF2D6CDF);
  static const headerB = Color(0xFF6CA8FF);
  static const pageBg  = Color(0xFFEFF4FF);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerA,
        foregroundColor: Colors.white,
        title: Text(title),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [headerA, headerB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 10),
            Text(
              message,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
