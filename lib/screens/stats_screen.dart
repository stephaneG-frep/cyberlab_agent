import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

enum StatMeasure { xp, minutes }

/// Une colonne du graphique : un jour, ou une semaine sur 90 jours.
class StatBucket {
  final DateTime from;
  final DateTime to;
  final int xp;
  final int minutes;
  const StatBucket(this.from, this.to, this.xp, this.minutes);

  int value(StatMeasure m) => m == StatMeasure.xp ? xp : minutes;
}

const _months = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', //
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

String shortDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// Regroupe les jours par paquets de [size] (le dernier finit aujourd'hui).
List<StatBucket> bucketize(
  List<({DateTime day, DayStats stats})> days,
  int size,
) {
  final out = <StatBucket>[];
  for (var end = days.length; end > 0; end -= size) {
    final start = end - size < 0 ? 0 : end - size;
    final part = days.sublist(start, end);
    out.insert(
      0,
      StatBucket(
        part.first.day,
        part.last.day,
        part.fold(0, (a, d) => a + d.stats.xp),
        // Les secondes sont additionnées avant l'arrondi à la minute.
        part.fold(0, (a, d) => a + d.stats.seconds) ~/ 60,
      ),
    );
  }
  return out;
}

/// Haut d'axe « rond », pair (la graduation du milieu est entière).
int niceMax(int v) {
  if (v <= 2) return 2;
  for (var p = 1; ; p *= 10) {
    for (final m in const [2, 4, 6, 8, 10]) {
      if (m * p >= v) return m * p;
    }
  }
}

/// Statistiques dans le temps : XP et temps, jour par jour.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _days = 30;
  StatMeasure _measure = StatMeasure.xp;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final days = app.activity(_days);
    final buckets = bucketize(days, _days == 90 ? 7 : 1);
    final active = days
        .where((d) => d.stats.xp > 0 || d.stats.actions > 0)
        .toList();
    final totalXp = days.fold(0, (a, d) => a + d.stats.xp);
    final totalMin = days.fold(0, (a, d) => a + d.stats.seconds) ~/ 60;
    final empty = active.isEmpty && totalMin == 0;
    final unit = _measure == StatMeasure.xp ? 'XP' : 'minutes';

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final n in const [7, 30, 90])
                ChoiceChip(
                  key: ValueKey('stats-$n'),
                  label: Text('$n jours'),
                  selected: _days == n,
                  onSelected: (_) => setState(() {
                    _days = n;
                    _selected = null;
                  }),
                ),
              for (final m in StatMeasure.values)
                ChoiceChip(
                  key: ValueKey('stats-${m.name}'),
                  label: Text(m == StatMeasure.xp ? 'XP' : 'Temps'),
                  selected: _measure == m,
                  onSelected: (_) => setState(() => _measure = m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.bolt,
                  value: '$totalXp',
                  label: 'XP gagnés',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  value: '$totalMin',
                  label: 'Minutes',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.event_available,
                  value: '${active.length}',
                  label: 'Jours actifs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (empty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucune activité enregistrée sur cette période. Ouvrez un '
                  'cours ou répondez à un quiz : la journée apparaîtra ici.',
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _measure == StatMeasure.xp
                          ? 'XP gagnés par ${_days == 90 ? 'semaine' : 'jour'}'
                          : 'Minutes par ${_days == 90 ? 'semaine' : 'jour'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _readout(buckets, unit),
                      key: const ValueKey('stats-readout'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    StatsChart(
                      buckets: buckets,
                      measure: _measure,
                      selected: _selected,
                      onSelected: (i) => setState(() => _selected = i),
                      semanticLabel: _summary(buckets, unit),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: ExpansionTile(
                key: const ValueKey('stats-table'),
                title: const Text('Voir en tableau'),
                children: [
                  for (final d in days.reversed)
                    if (d.stats.xp > 0 ||
                        d.stats.actions > 0 ||
                        d.stats.seconds >= 60)
                      ListTile(
                        dense: true,
                        title: Text(shortDay(d.day)),
                        subtitle: Text(
                          '${d.stats.xp} XP · ${d.stats.minutes} min · '
                          '${d.stats.actions} '
                          'action${d.stats.actions > 1 ? 's' : ''}',
                        ),
                      ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'L\'activité est datée depuis la version 1.6.0 : ce qui précède '
            'compte dans vos totaux mais n\'a pas été enregistré jour par jour.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _label(StatBucket b) => b.from == b.to
      ? shortDay(b.from)
      : 'du ${shortDay(b.from)} au ${shortDay(b.to)}';

  String _readout(List<StatBucket> buckets, String unit) {
    final i = _selected;
    if (i == null || i >= buckets.length) {
      return 'Touchez une colonne pour lire sa valeur.';
    }
    return '${buckets[i].value(_measure)} $unit · ${_label(buckets[i])}';
  }

  String _summary(List<StatBucket> buckets, String unit) {
    var best = buckets.first;
    for (final b in buckets) {
      if (b.value(_measure) > best.value(_measure)) best = b;
    }
    return 'Graphique en colonnes, ${buckets.length} '
        '${_days == 90 ? 'semaines' : 'jours'}. Maximum : '
        '${best.value(_measure)} $unit, ${_label(best)}. Détail dans le '
        'tableau ci-dessous.';
  }
}

/// Colonnes d'une seule série, sur un seul axe.
class StatsChart extends StatelessWidget {
  const StatsChart({
    super.key,
    required this.buckets,
    required this.measure,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
  });

  final List<StatBucket> buckets;
  final StatMeasure measure;
  final int? selected;
  final ValueChanged<int> onSelected;
  final String semanticLabel;

  static const _height = 160.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    // Teinte unique validée (contraste ≥ 3:1) sur les cartes des deux thèmes.
    final color = dark ? const Color(0xFF3987E5) : const Color(0xFF2A78D6);
    final grid = theme.colorScheme.outlineVariant;
    final small = theme.textTheme.labelSmall;
    final top = niceMax(
      buckets.fold(0, (m, b) => b.value(measure) > m ? b.value(measure) : m),
    );
    final n = buckets.length;

    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: _height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$top', style: small),
                    Text('${top ~/ 2}', style: small),
                    Text('0', style: small),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    void pick(Offset p) {
                      final i = (p.dx / box.maxWidth * n).floor();
                      onSelected(i < 0 ? 0 : (i >= n ? n - 1 : i));
                    }

                    final slot = box.maxWidth / n;
                    // 2 px d'écart entre colonnes, 24 px au maximum.
                    final width = (slot - 2).clamp(2.0, 24.0);
                    return GestureDetector(
                      key: const ValueKey('stats-plot'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => pick(d.localPosition),
                      onHorizontalDragUpdate: (d) => pick(d.localPosition),
                      child: SizedBox(
                        height: _height,
                        child: Stack(
                          children: [
                            for (final y in const [0.0, 0.5, 1.0])
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: y * (_height - 1),
                                child: Container(height: 1, color: grid),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < n; i++)
                                  SizedBox(
                                    width: slot,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: width,
                                        height:
                                            buckets[i].value(measure) /
                                            top *
                                            _height,
                                        decoration: BoxDecoration(
                                          color:
                                              selected == null || selected == i
                                              ? color
                                              : color.withValues(alpha: 0.45),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(shortDay(buckets.first.from), style: small)),
              Flexible(
                child: Text(
                  'aujourd\'hui',
                  style: small,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
