import 'package:flutter/material.dart';
import '../../domain/entities/event_entity.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // ✅ Dégradé doux + légère élévation
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.surface.withValues(alpha: .96),
          scheme.primaryContainer.withValues(alpha: .20),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.primary.withValues(alpha: .07),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: scheme.outlineVariant.withValues(alpha: .5)),
    );

    // ✅ Widget helper pour afficher une capsule (places / durée)
    Widget metricPill(String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: DefaultTextStyle(
          style: text.labelMedium!.copyWith(color: scheme.onSecondaryContainer),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 6),
              Text(
                value,
                style: text.labelMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: .08),
          highlightColor: scheme.primary.withValues(alpha: .04),
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Barre d’accent colorée à gauche
                Container(
                  width: 5,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),

                // ✅ Zone principale : titre + infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Titre ----
                      Text(
                        event.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: .2,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ---- Lieu + date ----
                      Row(
                        children: [
                          Icon(Icons.place, size: 16, color: scheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              event.localisation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.event, size: 16, color: scheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              event.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ✅ Métriques à droite (capsules)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    metricPill('Places', '${event.nombrePlaces}'),
                    const SizedBox(height: 6),
                    metricPill('Durée', '${event.dureeJours} j'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
