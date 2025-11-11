import 'package:flutter/material.dart';
import '../../domain/entities/course_summary.dart';

class CourseSummarySheet extends StatelessWidget {
  final CourseSummary summary;

  const CourseSummarySheet({super.key, required this.summary});

  // ====== Palette (ta charte) ======
  static const _cPrimary = Color(0xFF8C52FF);
  static const _cPrimarySoft = Color(0xFF9394FF);
  static const _cPrimaryDeep = Color(0xFF5E17EB);
  static const _cAccent1 = Color(0xFFB589FF);
  static const _cAccent2 = Color(0xFFCEA4FF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== Header dégradé ======
            _Header(
              title: summary.title ?? 'Résumé du cours',
              readingTimeMin: summary.readingTimeMin ?? 2,
              fromCache: summary.cacheHit ?? false,
            ),

            // ====== Contenu scrollable ======
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aperçu
                    if ((summary.overview ?? '').trim().isNotEmpty) ...[
                      _SectionTitle('Aperçu', icon: Icons.info_outline),
                      const SizedBox(height: 8),
                      Text(
                        summary.overview!.trim(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 24),
                    ],

                    // Points clés
                    if ((summary.keyPoints ?? const []).isNotEmpty) ...[
                      _SectionTitle('Points clés', icon: Icons.check_circle_outline),
                      const SizedBox(height: 8),
                      ...summary.keyPoints!.map(
                            (p) => _BulletTile(
                          icon: Icons.check_circle_outline,
                          text: p,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 24),
                    ],

                    // Prochaines étapes
                    if ((summary.nextSteps ?? const []).isNotEmpty) ...[
                      _SectionTitle('Prochaines étapes', icon: Icons.flag_outlined),
                      const SizedBox(height: 8),
                      ...summary.nextSteps!.map(
                            (p) => _BulletTile(
                          icon: Icons.flag_outlined,
                          text: p,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 24),
                    ],

                    // Points forts (chips)
                    if ((summary.highlights ?? const []).isNotEmpty) ...[
                      _SectionTitle('Points forts', icon: Icons.star_rate_outlined),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: summary.highlights!
                            .map((h) => _TagChip(label: h))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 24),
                    ],

                    // Plan du cours / Outline (accordéon simple)
                    if ((summary.outline ?? const []).isNotEmpty) ...[
                      _SectionTitle('Plan du cours', icon: Icons.menu_book_outlined),
                      const SizedBox(height: 8),
                      ...summary.outline!.mapIndexed(
                            (i, item) => ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
                          leading: _IndexBadge(index: i + 1),
                          title: Text(item, style: theme.textTheme.bodyLarge),
                          collapsedShape: const RoundedRectangleBorder(),
                          shape: const RoundedRectangleBorder(),
                          iconColor: _cPrimaryDeep,
                          collapsedIconColor: _cPrimarySoft,
                          children: [
                            Text(
                              'Détails de la section ${i + 1}',
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 24),
                    ],

                    // Termes clés (chips)
                    if ((summary.keyTerms ?? const []).isNotEmpty) ...[
                      _SectionTitle('Termes clés', icon: Icons.sell_outlined),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: summary.keyTerms!
                            .map((t) => _TagChip(
                          label: t,
                          soft: true,
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== Widgets privés ===================

class _Header extends StatelessWidget {
  final String title;
  final int readingTimeMin;
  final bool fromCache;

  const _Header({
    required this.title,
    required this.readingTimeMin,
    required this.fromCache,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CourseSummarySheet._cPrimary, CourseSummarySheet._cPrimaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.5),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _HeaderInfo(
                  icon: Icons.timer_outlined,
                  label: 'Lecture ~ $readingTimeMin min',
                ),
                const SizedBox(width: 12),
                if (fromCache)
                  _HeaderInfo(
                    icon: Icons.cloud_download_outlined,
                    label: 'Depuis le cache',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SectionTitle(this.text, {required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: CourseSummarySheet._cPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: CourseSummarySheet._cPrimaryDeep,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
      ],
    );
  }
}

class _BulletTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: CourseSummarySheet._cPrimarySoft),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool soft; // variation plus douce

  const _TagChip({required this.label, this.soft = false});

  @override
  Widget build(BuildContext context) {
    final bg = soft ? CourseSummarySheet._cAccent2 : CourseSummarySheet._cAccent1;
    final fg = Colors.black.withOpacity(.75);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withOpacity(.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bg.withOpacity(.7)),
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;

  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: CourseSummarySheet._cPrimary.withOpacity(.12),
      child: Text(
        '$index',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: CourseSummarySheet._cPrimaryDeep,
        ),
      ),
    );
  }
}

// Petit utilitaire pour mapIndexed sans package externe
extension on Iterable {
  Iterable<T> mapIndexed<T>(T Function(int i, dynamic e) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}
