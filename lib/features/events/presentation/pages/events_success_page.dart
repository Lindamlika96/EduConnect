// lib/features/events/presentation/pages/events_success_page.dart
import 'package:flutter/material.dart';
import '../../di.dart';
import '../../domain/entities/event_entity.dart';
import '../controllers/event_success_controller.dart';

class EventsSuccessPage extends StatefulWidget {
  const EventsSuccessPage({super.key});

  @override
  State<EventsSuccessPage> createState() => _EventsSuccessPageState();
}

class _EventsSuccessPageState extends State<EventsSuccessPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titre = TextEditingController();
  final _description = TextEditingController();
  final _date = TextEditingController(); // yyyy-mm-dd
  final _dureeJours = TextEditingController(text: '1');
  final _nombrePlaces = TextEditingController(text: '0');

  // Valeurs (mêmes listes que ton formulaire)
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
  late final EventSuccessController _success;

  @override
  void initState() {
    super.initState();
    _success = EventSuccessController();
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _date.dispose();
    _dureeJours.dispose();
    _nombrePlaces.dispose();
    _success.dispose();
    super.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initial;
    try {
      initial = _date.text.trim().isEmpty ? now : DateTime.parse(_date.text.trim());
    } catch (_) {
      initial = now;
    }
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

  // ==== EVALUATION ====
  Future<void> _evaluate() async {
    if (!_formKey.currentState!.validate()) return;

    final duree = int.parse(_dureeJours.text);
    final places = int.parse(_nombrePlaces.text);

    await _success.evaluate(
      localisation: _localisation,
      dureeJours: duree,
      nombrePlaces: places,
      niveauImportance: _importance,
      niveauExigeance: _exigeance,
      formateur: _formateur,
    );

    if (!mounted) return;

    if (_success.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur évaluation: ${_success.error}')),
      );
      return;
    }

    final score = (_success.lastScore ?? 0.0);
    final advice = _success.lastAdvice ?? 'Indéterminé';

    _showDecisionSheet(score: score, advice: advice);
  }

  void _showDecisionSheet({required double score, required String advice}) {
    final scheme = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Résultat de l’évaluation', style: txt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: score.clamp(0.0, 1.0),
                        minHeight: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(score*100).toStringAsFixed(0)}%',
                    style: txt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(advice, style: txt.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Ajouter l’événement'),
                      onPressed: () async {
                        Navigator.of(context).pop(); // ferme le bottom sheet
                        await _createEvent();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createEvent() async {
    setState(() => _submitting = true);
    try {
      final nav = Navigator.of(context);
      final entity = EventEntity(
        idEvenement: null,
        titre: _titre.text.trim(),
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
        localisation: _localisation,
        date: _date.text.trim(),
        dureeJours: int.parse(_dureeJours.text),
        nombrePlaces: int.parse(_nombrePlaces.text),
        niveauImportance: _importance,
        niveauExigeance: _exigeance,
        formateur: _formateur,
      );
      final id = await EventsDI.addEvent(entity);
      if (!mounted) return;
      nav.pop(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFEFF4FF);
    const headerA = Color(0xFF2D6CDF);
    const headerB = Color(0xFF6CA8FF);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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

    List<Widget> selectedBuilder(List<String> values) =>
        values.map((v) => Align(
          alignment: Alignment.centerLeft,
          child: Text(v, overflow: TextOverflow.ellipsis),
        )).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerA,
        foregroundColor: Colors.white,
        title: const Text('Évaluer le succès'),
        actions: [
          AnimatedBuilder(
            animation: _success,
            builder: (context, _) {
              if (_success.loading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [headerA, headerB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Bandeau
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
                Text('Estime le potentiel avant création',
                    style: text.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 6),
                Text(
                  'Renseigne les champs ci-dessous puis appuie sur “Évaluer le succès”.',
                  style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .9)),
                ),
              ],
            ),
          ),

          // Form
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

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _localisation,
                          items: _localisations.map((v) =>
                              DropdownMenuItem(value: v, child: Text(v))).toList(),
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
                                isExpanded: true,
                                initialValue: _formateur,
                                items: _formateurs.map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v))).toList(),
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
                          isExpanded: true,
                          initialValue: _importance,
                          items: _importances.map((v) =>
                              DropdownMenuItem(value: v, child: Text(v))).toList(),
                          selectedItemBuilder: (_) => selectedBuilder(_importances),
                          onChanged: (v) => setState(() => _importance = v!),
                          decoration: buildDec('Niveau d’importance *'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _exigeance,
                          items: _exigeances.map((v) =>
                              DropdownMenuItem(value: v, child: Text(v))).toList(),
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

      // CTA fixe : Évaluer
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 8, 16, 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [headerA, headerB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: headerA.withValues(alpha: .35),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _success,
              builder: (context, _) {
                final busy = _submitting || _success.loading;
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: busy ? null : _evaluate,
                    child: Center(
                      child: Text(
                        busy ? 'Évaluation…' : 'Évaluer le succès',
                        style: text.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ----- Helper UI -----
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
          Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
