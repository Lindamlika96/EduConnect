import 'package:flutter/material.dart';
import '../../di.dart';
import '../../domain/entities/event_entity.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titre = TextEditingController();
  final _description = TextEditingController();
  final _date = TextEditingController(); // format ISO yyyy-mm-dd
  final _dureeJours = TextEditingController(text: '1');
  final _nombrePlaces = TextEditingController(text: '0');

  // Valeurs contraintes par la DB (CHECK)
  static const _localisations = [
    'Tunis','Sfax','Sousse','Kairouan','Bizerte','Gabès','Ariana'
  ];
  static const _importances = [
    'Très peu','Peu','Moyen','Important','Très important','Événement extraordinaire'
  ];
  static const _exigeances = [
    'Très peu','Peu','Moyen','Important','Très important','Extraordinaire'
  ];
  static const _formateurs = [
    'Élève Université','Étudiant bénévole','Professeur Université','Expert','PDG'
  ];

  String _localisation = _localisations.first;
  String _importance = _importances.first;
  String _exigeance = _exigeances.first;
  String _formateur = _formateurs.first;

  bool _submitting = false;

  // --- Mode édition
  int? _editingId; // id_evenement si édition
  Future<EventEntity?>? _loadFuture;
  bool _hydrated = false; // hydrate les champs une seule fois

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_editingId == null && args is int) {
      _editingId = args;
      _loadFuture = EventsDI.getEventById.call(_editingId!);
    }
    _loadFuture ??= Future.value(null); // création
  }

  // ⚠️ NE PAS appeler setState ici (sinon setState during build)
  void _hydrateFrom(EventEntity e) {
    if (_hydrated) return;
    _hydrated = true;
    _titre.text = e.titre;
    _description.text = e.description ?? '';
    _date.text = e.date;
    _dureeJours.text = e.dureeJours.toString();
    _nombrePlaces.text = e.nombrePlaces.toString();
    _localisation = e.localisation;
    _importance = e.niveauImportance;
    _exigeance = e.niveauExigeance;
    _formateur = e.formateur;
    // pas de setState: les Dropdowns utilisent initialValue/isExpanded
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _date.dispose();
    _dureeJours.dispose();
    _nombrePlaces.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = () {
      try {
        if (_date.text.trim().isEmpty) return now;
        return DateTime.parse(_date.text.trim());
      } catch (_) {
        return now;
      }
    }();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Choisir une date',
    );
    if (picked != null) {
      _date.text = picked.toIso8601String().split('T').first;
      if (mounted) setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final duree = int.parse(_dureeJours.text);
    final places = int.parse(_nombrePlaces.text);

    final entity = EventEntity(
      idEvenement: _editingId, // null si création
      titre: _titre.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      localisation: _localisation,
      date: _date.text.trim(),
      dureeJours: duree,
      nombrePlaces: places,
      niveauImportance: _importance,
      niveauExigeance: _exigeance,
      formateur: _formateur,
    );

    setState(() => _submitting = true);
    try {
      final nav = Navigator.of(context);
      if (_editingId == null) {
        final id = await EventsDI.addEvent(entity);
        if (!mounted) return;
        nav.pop(id); // renvoie l'id inséré
      } else {
        await EventsDI.updateEvent(entity);
        if (!mounted) return;
        nav.pop('updated'); // flag pour recharger
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  String? _validIntMin1(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ requis';
    final n = int.tryParse(v);
    if (n == null || n < 1) return 'Doit être un entier ≥ 1';
    return null;
  }

  String? _validIntMin0(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ requis';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Doit être un entier ≥ 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Palette simple
    const pageBg = Color(0xFFEFF4FF); // bleu très pâle
    const headerA = Color(0xFF2D6CDF);
    const headerB = Color(0xFF6CA8FF);

    InputDecoration buildDec(String label, {Widget? suffixIcon}) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: .6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
    }

    // builder pour item sélectionné (évite overflow) — renommé pour enlever le lint
    List<Widget> selectedBuilder(List<String> values) =>
        values
            .map((v) => Align(
          alignment: Alignment.centerLeft,
          child: Text(v, overflow: TextOverflow.ellipsis),
        ))
            .toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerA,
        foregroundColor: Colors.white,
        title: Text(_editingId == null ? 'Nouvel événement' : 'Modifier l’événement'),
      ),
      body: FutureBuilder<EventEntity?>(
        future: _loadFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final existing = snap.data;
          if (_editingId != null && existing == null) {
            return const Center(child: Text('Événement introuvable'));
          }
          if (existing != null) _hydrateFrom(existing); // pas de setState ici

          return AbsorbPointer(
            absorbing: _submitting,
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Header dégradé
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [headerA, headerB],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingId == null ? 'Créer un événement' : 'Modifier l’événement',
                            style: text.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Renseignez les informations ci-dessous.",
                            style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .9)),
                          ),
                        ],
                      ),
                    ),

                    // Corps
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _SectionCard(
                              title: 'Informations',
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _titre,
                                    decoration: buildDec('Titre *'),
                                    validator: _required,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _description,
                                    decoration: buildDec('Description'),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 12),

                                  // Localisation
                                  DropdownButtonFormField<String>(
                                    isExpanded: true, // ✅ évite l’overflow
                                    initialValue: _localisation,
                                    items: _localisations
                                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                        .toList(),
                                    selectedItemBuilder: (_) => selectedBuilder(_localisations),
                                    onChanged: (v) => setState(() => _localisation = v!),
                                    decoration: buildDec('Localisation *'),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _date,
                                          decoration: buildDec(
                                            'Date (yyyy-mm-dd) *',
                                            suffixIcon: IconButton(
                                              tooltip: 'Choisir une date',
                                              icon: const Icon(Icons.event),
                                              onPressed: _pickDate,
                                            ),
                                          ),
                                          validator: _required,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _dureeJours,
                                          decoration: buildDec('Durée (jours) *'),
                                          keyboardType: TextInputType.number,
                                          validator: _validIntMin1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nombrePlaces,
                                          decoration: buildDec('Nombre de places *'),
                                          keyboardType: TextInputType.number,
                                          validator: _validIntMin0,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true, // ✅
                                          initialValue: _formateur,
                                          items: _formateurs
                                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                              .toList(),
                                          selectedItemBuilder: (_) => selectedBuilder(_formateurs),
                                          onChanged: (v) => setState(() => _formateur = v!),
                                          decoration: buildDec('Formateur *'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            _SectionCard(
                              title: 'Niveaux',
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    isExpanded: true, // ✅
                                    initialValue: _importance,
                                    items: _importances
                                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                        .toList(),
                                    selectedItemBuilder: (_) => selectedBuilder(_importances),
                                    onChanged: (v) => setState(() => _importance = v!),
                                    decoration: buildDec('Niveau d’importance *'),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true, // ✅
                                    initialValue: _exigeance,
                                    items: _exigeances
                                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                        .toList(),
                                    selectedItemBuilder: (_) => selectedBuilder(_exigeances),
                                    onChanged: (v) => setState(() => _exigeance = v!),
                                    decoration: buildDec('Niveau d’exigeance *'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // CTA fixe
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
                  child: SizedBox(
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _editingId == null
                              ? const [headerA, headerB]
                              : [scheme.secondary, scheme.secondaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_editingId == null ? headerA : scheme.secondary)
                                .withValues(alpha: .35),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _submitting ? null : _submit,
                          child: Center(
                            child: Text(
                              _submitting
                                  ? (_editingId == null ? 'Enregistrement…' : 'Mise à jour…')
                                  : (_editingId == null ? 'Enregistrer' : 'Mettre à jour'),
                              style: text.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------- UI HELPERS ----------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
