import 'package:flutter/material.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course? course;
  final String? title;
  final double? rating;
  final double? progressPercent;
  final bool completed;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkToggle;
  final String? trailingButtonText;

  const CourseCard({
    super.key,
    this.course,
    this.title,
    this.rating,
    this.progressPercent,
    this.completed = false,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkToggle,
    this.trailingButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final c = course;
    final titleText = c?.title ?? title ?? 'Cours';
    final ratingVal = c?.ratingAvg ?? rating ?? 0.0;
    final level = c?.level;
    final lang = c?.language;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
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
                          onPressed: onBookmarkToggle,
                          icon: Icon(isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          Text(ratingVal.toStringAsFixed(1)),
                        ]),
                        if (level != null)
                          Text('Niv $level',
                              style: const TextStyle(fontSize: 12)),
                        if (lang != null)
                          Text('L$lang',
                              style: const TextStyle(fontSize: 12)),
                        if (completed)
                          Row(mainAxisSize: MainAxisSize.min, children: const [
                            Icon(Icons.verified,
                                size: 16, color: Color(0xFF1ABC9C)),
                            SizedBox(width: 2),
                            Text('Terminé',
                                style: TextStyle(
                                    color: Color(0xFF1ABC9C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                      ],
                    ),
                    if (progressPercent != null && !completed) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (progressPercent! / 100).clamp(0, 1),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingButtonText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 6),
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(
                      trailingButtonText!.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
