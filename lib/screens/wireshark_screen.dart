import 'package:flutter/material.dart';
import '../widgets/common.dart';

class WiresharkScreen extends StatefulWidget {
  const WiresharkScreen({super.key});

  @override
  State<WiresharkScreen> createState() => _WiresharkScreenState();
}

class _WiresharkScreenState extends State<WiresharkScreen> {
  int _tab = 0;

  static const _filters = [
    (
      'Filtre IP',
      'ip.addr == 192.168.1.10',
      'Affiche le trafic vers/à partir d\'une adresse IP donnée.',
    ),
    (
      'Filtre DNS',
      'dns',
      'N\'affiche que les paquets DNS (résolutions de noms).',
    ),
    (
      'Filtre TCP',
      'tcp.port == 443',
      'Affiche le trafic TCP sur le port 443 (HTTPS).',
    ),
    (
      'Requêtes HTTP',
      'http.request',
      'Affiche uniquement les requêtes HTTP envoyées.',
    ),
    (
      'Protocole ARP',
      'arp',
      'Affiche le trafic ARP (traduction IP → MAC localement).',
    ),
    ('Filtre DHCP', 'dhcp', 'Affiche le trafic DHCP (attribution d\'IP).'),
  ];

  static const _challenges = [
    (
      'Trouver une IP',
      'Utilisez le filtre pour voir tout le trafic d\'une machine. Quel filtre affiche tout le trafic où 192.168.1.10 apparaît comme source OU destination ?',
      'ip.addr == 192.168.1.10',
    ),
    (
      'Identifier un protocole',
      'Quel filtre affiche uniquement le trafic lié à la résolution de noms de domaines ?',
      'dns',
    ),
    (
      'Requête DNS',
      'Quel filtre retrouve les requêtes DNS envoyées par un client ?',
      'dns.flags.response == 0',
    ),
    (
      'Échange TCP',
      'Quel filtre montre les paquets du numéro de port source/destination 443 ?',
      'tcp.port == 443',
    ),
  ];

  static const _anomaly = (
    "Une analyse montre une machine qui envoie des milliers de requêtes DNS vers un domaine inconnu 'exfil.example.net' toutes les 5 secondes. Qu'est-ce que cela évoque ?",
    "Cela ressemble à un DNS tunnelling : l'attaquant exfiltre des données en les encodant dans des requêtes DNS, car le DNS sortant est souvent peu filtré. La défense : filtrer/autoriser uniquement les DNS légitimes et surveiller ce trafic.",
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            segments: const [
              ButtonSegment(value: 0, label: Text('Cours')),
              ButtonSegment(value: 1, label: Text('Filtres')),
              ButtonSegment(value: 2, label: Text('Challenges')),
              ButtonSegment(value: 3, label: Text('Analyse')),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
        ),
        Expanded(
          child: switch (_tab) {
            0 => const _Course(),
            1 => _Filters(),
            2 => const _Challenges(),
            _ => const _Analyse(),
          },
        ),
      ],
    );
  }
}

class _Course extends StatelessWidget {
  const _Course();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Wireshark : analyser le trafic réseau',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Wireshark est un analyseur de paquets : il capture le trafic réseau et permet de l\'inspecter en détail (protocoles, requêtes, contenu). '
          'Il est indispensable pour comprendre ce qui circule sur un réseau et détecter des anomalies.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 12),
        const _Point(
          'Capture',
          'On lance une capture sur une interface, Wireshark affiche chaque paquet en temps réel. Les fichiers de capture sont en .pcap/.pcapng.',
        ),
        const _Point(
          'La liste de paquets',
          'Chaque ligne = un paquet : numéro, heure, source, destination, protocole, info.',
        ),
        const _Point(
          'Filtres d\'affichage',
          'Les filtres limitent l\'affichage (ex: dns, ip.addr==...). C\'est l\'outil clé pour trouver rapidement ce qu\'on cherche.',
        ),
        const _Point(
          'Suivre un flux',
          '"Follow TCP Stream" reconstitue l\'échange complet entre deux machines, très utile pour lire un contenu HTTP.',
        ),
        const _Point(
          'Pour la sécurité',
          'On détecte : scans, exfiltration, trafic anormal, requêtes vers des domaines suspects, brute-force.',
        ),
        const SizedBox(height: 8),
        const _Callout(
          'Attention : capturer et analyser le trafic ne doit se faire que sur vos propres réseaux ou des environnements autorisés. Intercepter le trafic d\'autrui sans autorisation est illégal.',
          Icons.warning_amber,
          Colors.orange,
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  final String title;
  final String text;
  const _Point(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: CyberLabSeed.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (t, f, d) in _WiresharkScreenState._filters)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_alt, color: CyberLabSeed.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(d, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      f,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Challenges extends StatelessWidget {
  const _Challenges();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Challenges Wireshark',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Répondez avec le bon filtre, puis vérifiez.'),
        const SizedBox(height: 12),
        for (final (t, q, ans) in _WiresharkScreenState._challenges)
          _WsChallenge(title: t, question: q, answer: ans),
      ],
    );
  }
}

class _WsChallenge extends StatefulWidget {
  final String title;
  final String question;
  final String answer;
  const _WsChallenge({
    required this.title,
    required this.question,
    required this.answer,
  });

  @override
  State<_WsChallenge> createState() => _WsChallengeState();
}

class _WsChallengeState extends State<_WsChallenge> {
  final _controller = TextEditingController();
  String? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(widget.question),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Votre filtre',
                      hintStyle: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() {
                    final a = _controller.text.trim();
                    _result = a.isNotEmpty && _same(a, widget.answer)
                        ? 'correct'
                        : 'incorrect';
                  }),
                  child: const Text('Vérifier'),
                ),
              ],
            ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _result == 'correct'
                    ? const Text(
                        '✔ Correction parfaite !',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✘ Pas encore. Indice : le filtre attendu est :',
                            style: TextStyle(color: Colors.orange),
                          ),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SelectableText(
                              widget.answer,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  bool _same(String a, String b) =>
      a.replaceAll(' ', '') == b.replaceAll(' ', '');
}

class _Analyse extends StatelessWidget {
  const _Analyse();

  @override
  Widget build(BuildContext context) {
    final (puzzle, exp) = _WiresharkScreenState._anomaly;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Challenge d\'analyse',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _Callout('ANOMALIE', Icons.report, Colors.amber),
        const SizedBox(height: 8),
        Text(puzzle, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 16),
        const Text(
          'Voir l\'explication',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          color: CyberLabSeed.blue.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(exp, style: const TextStyle(height: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _Callout extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _Callout(this.text, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
