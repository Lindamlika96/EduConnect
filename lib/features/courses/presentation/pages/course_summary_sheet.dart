// lib/features/courses/presentation/pages/course_summary_sheet.dart
import 'package:flutter/material.dart';
import '../../domain/entities/course_summary.dart';

class CourseSummarySheet extends StatelessWidget {
  final CourseSummary summary;
  const CourseSummarySheet({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scroll) {
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: ListView(
              controller: scroll,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(summary.title.isEmpty ? 'Résumé du cours' : summary.title,
                    style: theme.textTheme.titleLarge),

                const SizedBox(height: 6),
                Text(
                  'Lecture ~ ${summary.readingTimeMin} min • ${summary.cacheHit ? "Depuis le cache" : "Généré"}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),

                const SizedBox(height: 16),
                if (summary.overview.isNotEmpty) ...[
                  Text("Aperçu", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(summary.overview),
                  const SizedBox(height: 16),
                ],

                if (summary.keyPoints.isNotEmpty) ...[
                  Text("Points clés", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...summary.keyPoints.map(
                        (p) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(p),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (summary.nextSteps.isNotEmpty) ...[
                  Text("Prochaines étapes", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...summary.nextSteps.map(
                        (p) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.flag_outlined),
                      title: Text(p),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (summary.highlights.isNotEmpty) ...[
                  Text("Points forts", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: summary.highlights
                        .map((h) => Chip(label: Text(h)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                if (summary.outline.isNotEmpty) ...[
                  Text("Plan du cours", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...summary.outline.map(
                        (p) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.chevron_right),
                      title: Text(p),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (summary.keyTerms.isNotEmpty) ...[
                  Text("Mots-clés", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                    summary.keyTerms.map((t) => Chip(label: Text(t))).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
