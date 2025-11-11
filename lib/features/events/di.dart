import 'data/dao/event_dao.dart';
import 'data/dao/participation_dao.dart';

import 'data/repository/event_repository_impl.dart';
import 'data/repository/participation_repository_impl.dart';

import 'domain/repositories/event_repository.dart';
import 'domain/repositories/participation_repository.dart';

import 'domain/usecases/get_events_usecase.dart';
import 'domain/usecases/add_event_usecase.dart';
import 'domain/usecases/update_event_usecase.dart';
import 'domain/usecases/delete_event_usecase.dart';
import 'domain/usecases/get_event_by_id_usecase.dart';

import 'domain/usecases/set_participation_status_usecase.dart';
import 'domain/usecases/get_participation_status_usecase.dart';
import 'domain/usecases/get_event_ids_by_status_usecase.dart';
import 'domain/usecases/remove_participation_usecase.dart';

/// Conteneur d'injection simple pour la feature `events`.
class EventsDI {
  // === Events (Data)
  static final EventDao _dao = EventDao();

  // === Events (Repo)
  static final EventRepository _repository = EventRepositoryImpl(_dao);

  // === Events (Use cases)
  static final GetEventsUseCase getEvents = GetEventsUseCase(_repository);
  static final AddEventUseCase addEvent = AddEventUseCase(_repository);
  static final UpdateEventUseCase updateEvent = UpdateEventUseCase(_repository);
  static final DeleteEventUseCase deleteEvent = DeleteEventUseCase(_repository);
  static final GetEventByIdUseCase getEventById = GetEventByIdUseCase(_repository);

  // === Participation (Data)
  static final ParticipationDao _partDao = ParticipationDao();

  // === Participation (Repo)
  static final ParticipationRepository _partRepo =
  ParticipationRepositoryImpl(_partDao);

  // === Participation (Use cases)
  static final SetParticipationStatusUseCase setParticipationStatus =
  SetParticipationStatusUseCase(_partRepo);
  static final GetParticipationStatusUseCase getParticipationStatus =
  GetParticipationStatusUseCase(_partRepo);
  static final GetEventIdsByStatusUseCase getEventIdsByStatus =
  GetEventIdsByStatusUseCase(_partRepo);
  static final RemoveParticipationUseCase removeParticipation =
  RemoveParticipationUseCase(_partRepo);
}
