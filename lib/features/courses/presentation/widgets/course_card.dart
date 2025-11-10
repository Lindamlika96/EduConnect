import 'package:flutter/material.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course? course;
  final double? progressPercent;
  final bool completed;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkToggle;
  final String? trailingButtonText; // ex: "Découvrir le cours" (affiché seulement si non commencé)

  const CourseCard({
    super.key,
    this.course,
    this.progressPercent,
    this.completed = false,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkToggle,
    this.trailingButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final c = course!;
    final title = c.title;
    final rating = c.ratingAvg?.toStringAsFixed(1) ?? '–';
    final level = c.level;
    final lang = c.language;

    final double prog = (progressPercent ?? 0).clamp(0, 100);
    final bool showProgress = !completed && prog > 0.0;
    final bool showCTA = !completed && (prog == 0.0) && trailingButtonText != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          // padding homogène (évite que la carte “découvrir” paraisse plus haute)
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne 1 : pictogramme + titre + bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_outlined, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border),
                              onPressed: onBookmarkToggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Ligne 2 : méta-infos à gauche + CTA (si présent) à droite
                        Row(
                          children: [
                            // bloc gauche (wrap pour rester compact)
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Row(mainAxisSize: MainAxisSize.min, children: [
                                    const Icon(Icons.star,
                                        size: 14, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(rating),
                                  ]),
                                  Text('Niv $level',
                                      style: const TextStyle(fontSize: 12)),
                                  Text('L$lang',
                                      style: const TextStyle(fontSize: 12)),
                                  if (completed)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.verified,
                                            size: 14, color: Color(0xFF1ABC9C)),
                                        SizedBox(width: 2),
                                        Text(
                                          'Terminé',
                                          style: TextStyle(
                                            color: Color(0xFF1ABC9C),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // CTA aligné à droite, même ligne → pas de hauteur supplémentaire
                            if (showCTA)
                              _HoverCta(
                                text: trailingButtonText!,
                                onTap: onTap,
                                icon: Icons.explore,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Ligne 3 : barre de progression (seulement quand en cours)
              if (showProgress) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prog / 100,
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Petit widget interne pour gérer l’effet hover (web/desktop) du CTA.
/// - Légère montée (-1px) + soulignement + curseur “click”
class _HoverCta extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;

  const _HoverCta({
    required this.text,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  State<_HoverCta> createState() => _HoverCtaState();
}

class _HoverCtaState extends State<_HoverCta> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: widget.color,
      fontWeight: FontWeight.w600,
      fontSize: 13,
      decoration: _hover ? TextDecoration.underline : TextDecoration.none,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(0, _hover ? -1.0 : 0.0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 4),
              Text(widget.text, style: baseStyle),
            ],
          ),
        ),
      ),
    );
  }
}
