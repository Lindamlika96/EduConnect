import 'package:flutter/foundation.dart';
import '../../di.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart'; // ParticipationStatus

enum EventsTab { tous, favori, participe, neParticipePas }

class EventController extends ChangeNotifier {
  final List<EventEntity> _items = [];
  bool _loading = false;
  String? _error;

  // ⚠️ À brancher plus tard à l'user réel (module users)
  int currentUserId = 1;

  EventsTab _currentTab = EventsTab.tous;

  // Statut par eventId pour l’utilisateur courant
  final Map<int, String> _statusByEventId = {};

  // Compteurs d’onglets (pour l’utilisateur courant)
  int _favorisCount = 0;
  int _participeCount = 0;
  int _neParticipePasCount = 0;

  List<EventEntity> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  EventsTab get currentTab => _currentTab;

  int get favorisCount => _favorisCount;
  int get participeCount => _participeCount;
  int get neParticipePasCount => _neParticipePasCount;

  /// Récupère le statut de l’utilisateur courant pour un event (ou null).
  String? getStatusFor(int eventId) => _statusByEventId[eventId];

  Future<void> load({String? search}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1) Récupère tous les events (option search)
      final data = await EventsDI.getEvents(search: search);

      // 2) Récupère les trois listes d’IDs pour l’utilisateur courant
      final favorisIds = await EventsDI.getEventIdsByStatus(
        userId: currentUserId,
        status: ParticipationStatus.favori,
      );
      final participeIds = await EventsDI.getEventIdsByStatus(
        userId: currentUserId,
        status: ParticipationStatus.participe,
      );
      final neParticipePasIds = await EventsDI.getEventIdsByStatus(
        userId: currentUserId,
        status: ParticipationStatus.neParticipePas,
      );

      // 3) Met à jour les compteurs
      _favorisCount = favorisIds.length;
      _participeCount = participeIds.length;
      _neParticipePasCount = neParticipePasIds.length;

      // 4) Reconstruit la map statut par event
      _statusByEventId
        ..clear()
        ..addEntries(favorisIds.map((id) => MapEntry(id, ParticipationStatus.favori)))
        ..addEntries(participeIds.map((id) => MapEntry(id, ParticipationStatus.participe)))
        ..addEntries(neParticipePasIds.map((id) => MapEntry(id, ParticipationStatus.neParticipePas)));

      // 5) Filtre les items selon l’onglet
      List<EventEntity> result = data;
      if (_currentTab != EventsTab.tous) {
        final filterSet = switch (_currentTab) {
          EventsTab.favori => favorisIds.toSet(),
          EventsTab.participe => participeIds.toSet(),
          EventsTab.neParticipePas => neParticipePasIds.toSet(),
          EventsTab.tous => <int>{}, // non utilisé ici
        };
        result = data.where((e) => e.idEvenement != null && filterSet.contains(e.idEvenement!)).toList();
      }

      _items
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setTab(EventsTab tab, {String? search}) async {
    _currentTab = tab;
    await load(search: search);
  }

  /// Action: définir le statut de participation pour un event (upsert).
  Future<void> setStatus({
    required int evenementId,
    required String status,
    String? search,
  }) async {
    await EventsDI.setParticipationStatus(
      evenementId: evenementId,
      userId: currentUserId,
      status: status,
    );
    // Recharge la vue courante pour refléter filtres + compteurs + badges
    await load(search: search);
  }
}
