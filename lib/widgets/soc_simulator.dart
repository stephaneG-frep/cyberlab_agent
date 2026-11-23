import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/soc_alerts.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';

/// Simulateur SOC : l'apprenant qualifie une alerte fictive (gravité et
/// décision), puis lit une correction rédigée à l'avance.
class SocSimulator extends StatefulWidget {
  const SocSimulator({super.key, this.random});

  /// Générateur injectable (tests).
  final Random? random;

  @override
  State<SocSimulator> createState() => _SocSimulatorState();
}

class _SocSimulatorState extends State<SocSimulator> {
  static const xpPerAlert = 25;

  late final Random _random = widget.random ?? Random();
  SocAlert? _alert;
  String? _severity;
  String? _decision;
  bool _submitted = false;
  int _xpGained = 0;

  /// Prochaine alerte : en priorité une alerte pas encore réussie, jamais
  /// la même deux fois de suite.
  SocAlert _pick(AppState app) {
    final all = SocCatalog.alerts;
    final pending = all
        .where((a) => !app.isRewarded(RewardKeys.soc(a.id)))
        .where((a) => a.id != _alert?.id)
        .toList();
    final pool = pending.isNotEmpty
        ? pending
        : all.where((a) => a.id != _alert?.id).toList();
    return pool[_random.nextInt(pool.length)];
  }

  void _new() {
    setState(() {
      _alert = _pick(context.read<AppState>());
      _severity = null;
      _decision = null;
      _submitted = false;
      _xpGained = 0;
    });
  }

  Future<void> _submit() async {
    final alert = _alert!;
    final app = context.read<AppState>();
    final ok = _severity == alert.severity && _decision == alert.decision;
    final gained = await app.resolveSocAlert(alert.id, ok, xpPerAlert);
    if (!mounted) return;
    setState(() {
      _xpGained = gained;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final alert = _alert ??= _pick(app);
    final solved = SocCatalog.alerts
        .where((a) => app.isRewarded(RewardKeys.soc(a.id)))
        .length;
    final total = SocCatalog.alerts.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.radar, size: 48, color: Colors.amber),
        const SizedBox(height: 8),
        const Text(
          'Simulateur SOC',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Qualifiez l\'alerte fictive : sa gravité, puis la décision de '
          'l\'analyste. Une correction rédigée à l\'avance s\'affiche ensuite '
          '(25 XP une fois par alerte réussie).',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Text(
          'Alertes réussies : $solved / $total',
          key: const ValueKey('soc-progress'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          semanticsLabel: 'Alertes réussies : $solved sur $total',
          value: solved / total,
          minHeight: 6,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notification_important,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.title,
                        key: const ValueKey('soc-title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (app.isRewarded(RewardKeys.soc(alert.id)))
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                Text(alert.details),
                const SizedBox(height: 8),
                Text(
                  'Source : ${alert.source}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('1. Gravité', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final s in SocCatalog.severities)
              ChoiceChip(
                label: Text(s),
                selected: _severity == s,
                onSelected: _submitted
                    ? null
                    : (_) => setState(() => _severity = s),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '2. Décision',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _decision == null
              ? 'Quelle est la prochaine étape ?'
              : '$_decision : ${SocCatalog.decisionHelp[_decision]}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final d in SocCatalog.decisions)
              ChoiceChip(
                label: Text(d),
                tooltip: SocCatalog.decisionHelp[d],
                selected: _decision == d,
                onSelected: _submitted
                    ? null
                    : (_) => setState(() => _decision = d),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_submitted)
          _correction(alert)
        else
          FilledButton.icon(
            key: const ValueKey('soc-submit'),
            onPressed: (_severity != null && _decision != null)
                ? _submit
                : null,
            icon: const Icon(Icons.fact_check),
            label: const Text('Valider mon analyse'),
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            key: const ValueKey('soc-next'),
            onPressed: _new,
            icon: const Icon(Icons.refresh),
            label: const Text('Nouvelle alerte'),
          ),
        ),
      ],
    );
  }

  Widget _correction(SocAlert alert) {
    final sevOk = _severity == alert.severity;
    final decOk = _decision == alert.decision;
    final ok = sevOk && decOk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: ok
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          child: ListTile(
            leading: Icon(
              ok ? Icons.check_circle : Icons.info,
              color: ok ? Colors.greenAccent : Colors.orange,
            ),
            title: Text(
              ok
                  ? (_xpGained > 0
                        ? 'Excellente analyse ! (+$_xpGained XP)'
                        : 'Excellente analyse ! (alerte déjà réussie, pas de nouveaux XP)')
                  : 'Les points à revoir',
              key: const ValueKey('soc-verdict'),
            ),
            subtitle: Text(
              'Gravité : ${alert.severity}${sevOk ? ' ✔' : ' (vous : $_severity)'}\n'
              'Décision : ${alert.decision}${decOk ? ' ✔' : ' (vous : $_decision)'}',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correction (fiche pédagogique)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(alert.explanation),
                const SizedBox(height: 8),
                const Text(
                  'Action recommandée',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(alert.action),
                if (alert.mitre != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'MITRE ATT&CK : ${alert.mitre}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
