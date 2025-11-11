import 'package:flutter/material.dart';
import '../../di.dart';
import '../../routes.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart'; // ParticipationStatus

/// Données combinées pour le FutureBuilder
class _DetailData {
  final EventEntity event;
  final String? myStatus; // peut être null si aucun statut
  const _DetailData(this.event, this.myStatus);
}

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int? _id;
  Future<_DetailData?>? _future;

  // ✅ Indique si quelque chose a changé (edit ou changement de statut)
  bool _changed = false;

  // ⚠️ Branche sur l’utilisateur courant (à relier au module users)
  static const int _currentUserId = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final idEvenement = (args is int) ? args : null;
    if (_id != idEvenement) {
      _id = idEvenement;
      _future = (_id == null) ? Future.value(null) : _load();
    }
  }

  Future<_DetailData?> _load() async {
    if (_id == null) return null;
    final e = await EventsDI.getEventById.call(_id!);
    if (e == null) return null;
    final part = await EventsDI.getParticipationStatus(
      evenementId: _id!,
      userId: _currentUserId,
    );
    return _DetailData(e, part?.status);
  }

  Future<void> _edit() async {
    if (_id == null) return;

    final result = await Navigator.of(context)
        .pushNamed(EventsRoutes.edit, arguments: _id);

    if (!mounted) return;

    if (result == 'updated') {
      _changed = true;

      // ✅ Préparer le Future avant setState (sinon "setState callback returned a Future")
      final next = _load();
      setState(() {
        _future = next;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement mis à jour')),
      );
    }
  }

  Future<void> _delete() async {
    if (_id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Confirmer la suppression de cet événement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await EventsDI.deleteEvent.call(_id!);
    if (!mounted) return;

    Navigator.of(context).pop('deleted');
  }

  // ✅ Utilisé par le bouton back de l’AppBar
  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(_changed ? 'updated' : null);
    return false;
  }

  Future<void> _setStatus(String value) async {
    if (_id == null) return;

    await EventsDI.setParticipationStatus(
      evenementId: _id!,
      userId: _currentUserId,
      status: value,
    );
    if (!mounted) return;

    _changed = true;

    // ✅ Ne pas renvoyer de Future depuis le callback setState
    final next = _load();
    setState(() {
      _future = next;
    });

    final label = switch (value) {
      ParticipationStatus.participe => 'Participe',
      ParticipationStatus.favori => 'Ajouté aux favoris',
      ParticipationStatus.neParticipePas => 'Ne participe pas',
      _ => value,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
  }

  @override
  Widget build(BuildContext context) {
    // Palette locale pour un look plus affirmé
    const pageBg = Color(0xFFF3F5FF); // bleu très pâle
    const appBarBlue = Color(0xFF2D6CDF);
    const headerA = Color(0xFF4D8BFF);
    const headerB = Color(0xFF5FA2FF);
    const pillRed = Color(0xFFE74D4D);

    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_changed ? 'updated' : null);
      },
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: appBarBlue,
          foregroundColor: Colors.white,
          title: const Text('Détail événement'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onWillPop(),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
          ],
        ),
        body: FutureBuilder<_DetailData?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text('Événement introuvable'));
            }
            final event = data.event;
            final myStatus = data.myStatus; // peut être null

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ======= HEADER COLORÉ =======
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [headerA, headerB],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appBarBlue.withValues(alpha: .25),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre + badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                event.titre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: pillRed,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: pillRed.withValues(alpha: .28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text('Événement',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Lieu + date
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ChipIcon(
                              icon: Icons.place,
                              label: event.localisation,
                              bg: Colors.white.withValues(alpha: .9),
                              fg: scheme.onSurface,
                            ),
                            _ChipIcon(
                              icon: Icons.event,
                              label: event.date,
                              bg: Colors.white.withValues(alpha: .9),
                              fg: scheme.onSurface,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Sélecteur de statut
                        _StatusSelector(
                          value: myStatus,
                          onChanged: _setStatus,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ======= DESCRIPTION =======
                if ((event.description ?? '').trim().isNotEmpty)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // ======= INFOS =======
                Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest
                      .withValues(alpha: .85), // lisible & doux
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Durée (jours)', value: '${event.dureeJours}'),
                        _InfoRow(label: 'Nombre de places', value: '${event.nombrePlaces}'),
                        _InfoRow(label: 'Importance', value: event.niveauImportance),
                        _InfoRow(label: 'Exigeance', value: event.niveauExigeance),
                        _InfoRow(label: 'Formateur', value: event.formateur),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  const _ChipIcon({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      backgroundColor: bg,
      side: BorderSide(color: fg.withValues(alpha: .15)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: s.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value, style: s.bodyMedium)),
        ],
      ),
    );
  }
}

/// Sélecteur de statut avec **3 ChoiceChips colorés**
class _StatusSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _StatusSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    ChoiceChip buildChip({
      required String label,
      required IconData icon,
      required String val,
      required Color selectedBg,
      required Color selectedFg,
      required Color unselectedBg,
      required Color unselectedFg,
      required Color borderColor,
    }) {
      final selected = value == val;
      return ChoiceChip(
        selected: selected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? selectedFg : unselectedFg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: unselectedBg,
        selectedColor: selectedBg, // OK avec M3 ici
        side: BorderSide(color: selected ? borderColor : borderColor.withValues(alpha: .4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onSelected: (_) => onChanged(val),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Participe → primaire
            buildChip(
              label: 'Participe',
              icon: Icons.check_circle,
              val: ParticipationStatus.participe,
              selectedBg: scheme.primary,
              selectedFg: scheme.onPrimary,
              unselectedBg: Colors.white.withValues(alpha: .9),
              unselectedFg: scheme.onSurface,
              borderColor: scheme.primary,
            ),
            // Ne participe pas → erreur
            buildChip(
              label: 'Ne participe pas',
              icon: Icons.block,
              val: ParticipationStatus.neParticipePas,
              selectedBg: scheme.error,
              selectedFg: scheme.onError,
              unselectedBg: Colors.white.withValues(alpha: .9),
              unselectedFg: scheme.onSurface,
              borderColor: scheme.error,
            ),
            // Favori → secondaire
            buildChip(
              label: 'Favori',
              icon: Icons.favorite,
              val: ParticipationStatus.favori,
              selectedBg: scheme.secondary,
              selectedFg: scheme.onSecondary,
              unselectedBg: Colors.white.withValues(alpha: .9),
              unselectedFg: scheme.onSurface,
              borderColor: scheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}
