import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SocAlert {
  final String id;
  final String title;
  final String details;
  final String source;
  final String
  correctSeverity; // Critique | Élevé | Moyen | Faible | Informations
  final String correctCategory; // Détection | Analyse | Triage | Réponse
  final String explanation;

  SocAlert({
    required this.id,
    required this.title,
    required this.details,
    required this.source,
    required this.correctSeverity,
    required this.correctCategory,
    required this.explanation,
  });
}

class _SocData {
  static final alerts = [
    SocAlert(
      id: 's1',
      title: 'Tentatives de connexion répétées',
      details:
          '35 échecs de connexion SSH (Failed password) depuis 203.0.113.7 en 2 minutes, vers le compte root.',
      source: 'auth.log / SIEM',
      correctSeverity: 'Élevé',
      correctCategory: 'Détection',
      explanation:
          'Un brute-force en cours sur SSH : forte probabilité d\'attaque. Sévérité élevée car une compromission de root est possible. Action : verrouiller/limiter, bannir l\'IP, garantir des mots de passe forts.',
    ),
    SocAlert(
      id: 's2',
      title: 'Connexion depuis une nouvelle IP',
      details:
          'Connexion SSH réussie (Accepted) pour l\'utilisateur alice depuis 198.51.100.77, jamais vue pour ce compte.',
      source: 'auth.log',
      correctSeverity: 'Moyen',
      correctCategory: 'Analyse',
      explanation:
          'Une connexion depuis une IP inconnue peut être légitime (télétravail) ou compromettre un compte. Sévérité moyenne. Action : vérifier avec alice si le déplacement est légitime (le 2FA aide).',
    ),
    SocAlert(
      id: 's3',
      title: 'Processus inhabituel',
      details:
          'Processus "minerd" consommant 350% CPU, absent de la liste des processus attendus, lancé depuis /tmp.',
      source: 'EDR / ps aux',
      correctSeverity: 'Critique',
      correctCategory: 'Détection',
      explanation:
          'Un processus de minage de cryptomonnaie dans /tmp signe presque certainement une compromission (un attaquant a exécuté un mineur). Sévérité critique. Action : isoler la machine, analyser, éradiquer.',
    ),
    SocAlert(
      id: 's4',
      title: 'Fichier système modifié',
      details:
          'Le fichier /etc/passwd a été modifié à 02:30, pendant la nuit, hors des fenêtres de maintenance.',
      source: 'FIM / auditd',
      correctSeverity: 'Élevé',
      correctCategory: 'Réponse',
      explanation:
          'Une modification du fichier des comptes (passwd) à une heure inhabituelle est très suspecte : création de compte backdoor possible. Sévérité élevée. Action : comparer avec la sauvegarde, vérifier les nouveaux comptes, enquêter.',
    ),
    SocAlert(
      id: 's5',
      title: 'Trafic réseau anormal',
      details:
          'Volume de données sortant de 2,5 Go en 10 minutes vers une IP externe inconnue, depuis un serveur de production.',
      source: 'IDS / netflow',
      correctSeverity: 'Critique',
      correctCategory: 'Détection',
      explanation:
          'Une exfiltration de données massive et sortante vers une IP inconnue est une compromission probable. Sévérité critique. Action : bloquer la connexion, prélever des preuves, investiguer (IOC).',
    ),
    SocAlert(
      id: 's6',
      title: 'Élévation détectée',
      details:
          'Commande sudo exécutée par "bob" alors qu\'il n\'est pas dans le groupe sudo, puis accès à des fichiers sensibles.',
      source: 'auth.log / logs sudo',
      correctSeverity: 'Critique',
      correctCategory: 'Réponse',
      explanation:
          'Une élévation de privilèges non autorisée est critique : elle permet de prendre le contrôle. Action : isoler le compte, analyser, corriger la faille d\'élévation.',
    ),
  ];

  static SocAlert random() => alerts[Random().nextInt(alerts.length)];
}

class SocSimulator extends StatefulWidget {
  const SocSimulator({super.key});

  @override
  State<SocSimulator> createState() => _SocSimulatorState();
}

class _SocSimulatorState extends State<SocSimulator> {
  late SocAlert _alert;
  String? _severity;
  String? _category;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _alert = _SocData.random();
  }

  void _new() {
    setState(() {
      _alert = _SocData.random();
      _severity = null;
      _category = null;
      _submitted = false;
    });
  }

  void _submit() {
    final app = context.read<AppState>();
    final sevOk = _severity == _alert.correctSeverity;
    final catOk = _category == _alert.correctCategory;
    if (sevOk && catOk) {
      app.addXp(25, skill: 'Blueteam');
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.radar, size: 48, color: Colors.amber),
        const SizedBox(height: 8),
        const Text(
          'SOC Simulator',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Analysez l\'alerte fictive : classez sa gravité, catégorisez, puis proposez une action. L\'IA vous corrige.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
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
                        _alert.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_alert.details),
                const SizedBox(height: 8),
                Text(
                  'Source : ${_alert.source}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '1. Niveau de gravité',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in [
              'Critique',
              'Élevé',
              'Moyen',
              'Faible',
              'Informations',
            ])
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
          '2. Catégorie d\'action',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final c in ['Détection', 'Analyse', 'Triage', 'Réponse'])
              ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: _submitted
                    ? null
                    : (_) => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_submitted)
          _correction()
        else
          FilledButton.icon(
            onPressed: (_severity != null && _category != null)
                ? _submit
                : null,
            icon: const Icon(Icons.fact_check),
            label: const Text('Analyser (l\'IA corrige)'),
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: _new,
            icon: const Icon(Icons.refresh),
            label: const Text('Nouvelle alerte'),
          ),
        ),
      ],
    );
  }

  Widget _correction() {
    final sevOk = _severity == _alert.correctSeverity;
    final catOk = _category == _alert.correctCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: (sevOk && catOk)
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          child: ListTile(
            leading: Icon(
              sevOk && catOk ? Icons.check_circle : Icons.info,
              color: sevOk && catOk ? Colors.greenAccent : Colors.orange,
            ),
            title: Text(
              sevOk && catOk
                  ? 'Excellente analyse ! (+25 XP)'
                  : 'Les points à revoir',
            ),
            subtitle: Text(
              'Gravité attendue : ${_alert.correctSeverity} (vous : ${_severity ?? "-"})  ·  '
              'Catégorie : ${_alert.correctCategory} (vous : ${_category ?? "-"})',
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
                  'Analyse du CyberCoach',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_alert.explanation),
                const SizedBox(height: 8),
                const Text(
                  'Action recommandée :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _extractAction(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _extractAction(BuildContext context) {
    final exp = _alert.explanation;
    final idx = exp.indexOf('Action :');
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        idx >= 0 ? exp.substring(idx + 'Action :'.length).trim() : '—',
      ),
    );
  }
}
