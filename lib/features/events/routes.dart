import 'package:flutter/widgets.dart';

// Import des pages
import 'presentation/pages/events_home_page.dart';
import 'presentation/pages/events_list_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'presentation/pages/event_form_page.dart';
import 'presentation/pages/events_stats_page.dart';
import 'presentation/pages/events_gamification_page.dart'; // ⬅️ nouvelle import
import 'presentation/pages/events_success_page.dart';

class EventsRoutes {
  static const home          = '/events/home';
  static const list          = '/events';
  static const detail        = '/events/detail';
  static const add           = '/events/add';
  static const edit          = '/events/edit';
  static const stats         = '/events/stats';
  static const gamification  = '/events/gamification'; // ⬅️ nouvelle route
  static const success = '/events/success';

  static Map<String, WidgetBuilder> get map => {
    home:          (_) => const EventsHomePage(),
    list:          (_) => const EventsListPage(),
    detail:        (_) => const EventDetailPage(),
    add:           (_) => const EventFormPage(),
    edit:          (_) => const EventFormPage(),
    stats:         (_) => const EventsStatsPage(),
    gamification:  (_) => const EventsGamificationPage(), // ⬅️ nouvelle page
    success: (_) => const EventsSuccessPage(),
  };
}
