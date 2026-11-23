import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/packet_capture.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import '../services/display_filter.dart';
import '../widgets/common.dart';

/// Module Wireshark : cours, mémo des filtres, capture SIMULÉE avec de vrais
/// filtres d'affichage, et scénarios d'analyse. Aucune capture réseau n'est
/// effectuée sur l'appareil.
class WiresharkScreen extends StatefulWidget {
  const WiresharkScreen({super.key});

  @override
  State<WiresharkScreen> createState() => _WiresharkScreenState();
}

class _WiresharkScreenState extends State<WiresharkScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            segments: const [
              ButtonSegment(value: 0, label: Text('Cours')),
              ButtonSegment(value: 1, label: Text('Filtres')),
              ButtonSegment(value: 2, label: Text('Capture')),
              ButtonSegment(value: 3, label: Text('Analyse')),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
        ),
        Expanded(
          child: switch (_tab) {
            0 => const _Course(),
            1 => const _Filters(),
            2 => const CaptureLab(),
            _ => const _Analyse(),
          },
        ),
      ],
    );
  }
}

// ================================================================ Cours

class _Course extends StatelessWidget {
  const _Course();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Wireshark : analyser le trafic réseau',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Wireshark est un analyseur de paquets : il capture le trafic '
          'réseau et permet de l\'inspecter en détail (protocoles, requêtes, '
          'contenu). Il est indispensable pour comprendre ce qui circule sur '
          'un réseau et détecter des anomalies.',
          style: TextStyle(height: 1.5),
        ),
        SizedBox(height: 12),
        _Point(
          'Capture',
          'On lance une capture sur une interface ; chaque paquet s\'affiche '
              'en temps réel. Les captures s\'enregistrent en .pcap ou .pcapng.',
        ),
        _Point(
          'La liste de paquets',
          'Chaque ligne est un paquet : numéro, heure, source, destination, '
              'protocole, résumé. Un clic ouvre le détail de ses champs.',
        ),
        _Point(
          'Filtres d\'affichage',
          'Ils masquent tout ce qui ne correspond pas (dns, ip.addr == …). '
              'Ils ne suppriment rien de la capture : on peut toujours revenir '
              'en arrière. Entraînez-vous dans l\'onglet Capture.',
        ),
        _Point(
          'Suivre un flux',
          '« Follow TCP Stream » reconstitue l\'échange complet entre deux '
              'machines, très utile pour lire un contenu HTTP.',
        ),
        _Point(
          'Pour la sécurité',
          'On y repère les scans, l\'exfiltration, les mots de passe en '
              'clair, les requêtes vers des domaines suspects, l\'usurpation ARP.',
        ),
        SizedBox(height: 8),
        _Callout(
          'Capturer et analyser du trafic ne se fait que sur vos propres '
          'réseaux ou des environnements autorisés. Intercepter le trafic '
          'd\'autrui sans autorisation est illégal.',
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

// ======================================================= Mémo des filtres

class _Filters extends StatelessWidget {
  const _Filters();

  static const _items = [
    (
      'Un protocole',
      'dns',
      'Seulement les paquets DNS. Marche aussi avec '
          'arp, tcp, udp, http, tls, icmp.',
    ),
    (
      'Une adresse (les deux sens)',
      'ip.addr == 192.168.1.42',
      'Source OU destination.',
    ),
    (
      'Source ou destination seule',
      'ip.src == 203.0.113.7',
      'ip.dst pour la destination.',
    ),
    (
      'Un port',
      'tcp.port == 443',
      'Port source ou destination ; tcp.dstport pour la destination seule.',
    ),
    ('Requêtes web', 'http.request', 'Les requêtes, sans les réponses.'),
    (
      'Méthode HTTP',
      'http.request.method == "POST"',
      'Les chaînes s\'écrivent entre guillemets.',
    ),
    (
      'Chercher un texte',
      'dns.qry.name contains "exfil"',
      'contains cherche un texte dans un champ (sensible à la casse).',
    ),
    (
      'Drapeaux TCP',
      'tcp.flags.syn == 1 && tcp.flags.ack == 0',
      'Les ouvertures de connexion (SYN seul).',
    ),
    (
      'ET / OU',
      'dns || arp',
      '&& (and) : les deux conditions ; || (or) : '
          'l\'une ou l\'autre.',
    ),
    (
      'Exclure',
      '!(arp || dns)',
      '! (not) inverse ; les parenthèses '
          'regroupent.',
    ),
    (
      'Différent de',
      'ip.addr != 192.168.1.1',
      'Exclut l\'adresse en source ET en destination.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (t, f, d) in _items)
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
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d, style: const TextStyle(height: 1.4, fontSize: 13)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ========================================================= Capture simulée

/// Capture simulée filtrable, avec exercices validés sur le RÉSULTAT du
/// filtre (toute écriture équivalente est acceptée).
class CaptureLab extends StatefulWidget {
  const CaptureLab({super.key});

  @override
  State<CaptureLab> createState() => _CaptureLabState();
}

class _CaptureLabState extends State<CaptureLab> {
  final _filter = TextEditingController();
  int _index = 0;
  bool _hint = false;
  String? _error;
  List<Packet> _shown = LabCapture.packets;
  String? _verdict;
  bool _success = false;

  FilterExercise get _ex => FilterExercises.all[_index];

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  void _apply(String text) {
    setState(() {
      _verdict = null;
      _success = false;
      try {
        _shown = DisplayFilter.parse(text).apply(LabCapture.packets);
        _error = null;
      } on FilterError catch (e) {
        _error = e.message;
      }
    });
  }

  void _go(int delta) {
    setState(() {
      _index = (_index + delta) % FilterExercises.all.length;
      _hint = false;
      _verdict = null;
      _success = false;
    });
  }

  Future<void> _check() async {
    if (_error != null) return;
    final got = _shown.map((p) => p.no).toSet();
    final want = _ex.expected(LabCapture.packets);
    if (got.length == want.length && got.containsAll(want)) {
      final gained = await context.read<AppState>().solveFilterExercise(
        _ex.id,
        _ex.xp,
      );
      if (!mounted) return;
      setState(() {
        _success = true;
        _verdict = gained > 0
            ? 'Bravo ! Filtre correct (+$gained XP).'
            : 'Filtre correct (exercice déjà réussi).';
      });
      return;
    }
    final missing = want.difference(got).length;
    final extra = got.difference(want).length;
    setState(() {
      _success = false;
      _verdict =
          'Pas encore : votre filtre affiche ${got.length} paquet(s), il en '
          'faut ${want.length}.'
          '${missing > 0 ? ' Il en manque $missing.' : ''}'
          '${extra > 0 ? ' $extra paquet(s) en trop.' : ''}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final done = FilterExercises.all
        .where((e) => app.isRewarded(RewardKeys.wireshark(e.id)))
        .length;
    final solved = app.isRewarded(RewardKeys.wireshark(_ex.id));
    final total = LabCapture.packets.length;
    final empty = _filter.text.trim().isEmpty;
    final barColor = empty
        ? null
        : (_error == null ? Colors.green : Colors.red).withValues(alpha: 0.18);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Exercice ${_index + 1}/${FilterExercises.all.length} · '
                        '${_ex.title}',
                        key: const ValueKey('ws-title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (solved)
                      const Icon(Icons.check_circle, color: Colors.green),
                    IconButton(
                      tooltip: 'Exercice précédent',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _go(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      key: const ValueKey('ws-next'),
                      tooltip: 'Exercice suivant',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _go(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                Text(_ex.task),
                const SizedBox(height: 4),
                Text(
                  'Réussis : $done/${FilterExercises.all.length} · '
                  '${_ex.xp} XP par exercice',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_hint)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Indice : ${_ex.hint}',
                      style: const TextStyle(color: Colors.amber),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => setState(() => _hint = true),
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('Indice'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('ws-filter'),
                controller: _filter,
                onChanged: _apply,
                onSubmitted: (_) => _check(),
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                smartQuotesType: SmartQuotesType.disabled,
                smartDashesType: SmartDashesType.disabled,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  filled: barColor != null,
                  fillColor: barColor,
                  prefixIcon: const Icon(Icons.filter_alt, size: 20),
                  hintText: 'Filtre d\'affichage… (ex. dns)',
                  border: const OutlineInputBorder(),
                  errorText: _error,
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const ValueKey('ws-check'),
              onPressed: _error == null ? _check : null,
              child: const Text('Vérifier'),
            ),
          ],
        ),
        if (_verdict != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              key: const ValueKey('ws-verdict'),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_success ? Colors.green : Colors.orange).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _verdict!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_success) ...[
                    const SizedBox(height: 4),
                    Text(_ex.explanation),
                    const SizedBox(height: 4),
                    Text(
                      'Écriture de référence : ${_ex.solution}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '${LabCapture.fileName} · ${_shown.length} / $total paquets affichés'
          ' · touchez un paquet pour le détail',
          key: const ValueKey('ws-count'),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        for (final p in _shown) PacketRow(packet: p),
      ],
    );
  }
}

Color _protocolColor(String protocol) => switch (protocol) {
  'DNS' => const Color(0xFF5B8DEF),
  'HTTP' => const Color(0xFF6CC24A),
  'ARP' => const Color(0xFFE2B93D),
  'ICMP' => const Color(0xFFE07BC0),
  'TCP' => const Color(0xFF8B90F0),
  _ => const Color(0xFF4FC3B0),
};

class PacketRow extends StatelessWidget {
  final Packet packet;
  const PacketRow({super.key, required this.packet});

  @override
  Widget build(BuildContext context) {
    final color = _protocolColor(packet.protocol);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: color.withValues(alpha: 0.10),
      child: InkWell(
        key: ValueKey('packet-${packet.no}'),
        onTap: () => _showDetails(context, packet),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${packet.no}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${packet.src} → ${packet.dst}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    packet.protocol,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(packet.info, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDetails(BuildContext context, Packet p) {
  final fields = p.fields.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              'Paquet ${p.no} · ${p.protocol}',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Temps ${p.time.toStringAsFixed(3)} s · ${p.length} octets · '
              'couches : ${p.layers.join(' / ')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(p.info),
            const Divider(),
            for (final e in fields)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${e.key} : ',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: '${e.value}',
                        style: TextStyle(
                          fontWeight: e.key == 'http.file_data'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: e.key == 'http.file_data'
                              ? Colors.redAccent
                              : null,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// ================================================================ Analyse

class _Analyse extends StatelessWidget {
  const _Analyse();

  static const _scenarios = [
    (
      'Le poste qui parle trop au DNS',
      'Paquets 21 à 24 : 192.168.1.66 envoie une requête DNS TXT toutes les 5 '
          'secondes vers des sous-domaines illisibles de exfil.example.net. '
          'Qu\'est-ce que cela évoque ?',
      'Un tunnel DNS : les données sont encodées dans les noms demandés '
          '(ici du Base64, décodable dans le terminal du Lab). Le DNS sortant '
          'est souvent peu filtré, d\'où son usage pour l\'exfiltration. '
          'Défense : n\'autoriser que les résolveurs internes, surveiller les '
          'noms longs et les volumes, bloquer les domaines récents.',
    ),
    (
      'Trois SYN en 20 millisecondes',
      'Paquets 25 à 31 : 203.0.113.7 envoie des SYN vers les ports 22, 23 et '
          '3389. Le port 22 répond SYN, ACK et l\'attaquant renvoie aussitôt '
          'un RST ; les autres ports répondent RST, ACK. Que se passe-t-il ?',
      'Un scan SYN (« semi-ouvert », nmap -sS) : l\'attaquant ne termine '
          'jamais la poignée de main. SYN, ACK = port ouvert (22) ; RST = port '
          'fermé (23, 3389). Le service SSH est désormais une cible : à durcir '
          'et à surveiller.',
    ),
    (
      'Deux adresses MAC pour la passerelle',
      'Paquet 32 : une réponse ARP non sollicitée annonce « 192.168.1.1 is at '
          '08:00:27:66:66:66 », alors que le paquet 2 donnait 3c:84:6a:11:22:33. '
          'Quel est le risque ?',
      'Une usurpation ARP (ARP spoofing) : le poste 08:00:27:66:66:66 se fait '
          'passer pour la passerelle afin d\'intercepter le trafic (homme du '
          'milieu). Combinée au HTTP en clair, elle permettrait de voler le '
          'mot de passe d\'alice. Défense : inspection ARP dynamique sur les '
          'commutateurs, HTTPS partout.',
    ),
    (
      'Un formulaire lisible par tous',
      'Paquet 17 : POST /login vers intranet.lab, en HTTP. Que voit-on dans le '
          'détail du paquet et pourquoi est-ce grave ?',
      'Le corps contient user=alice&password=Printemps2026! en clair. Sans '
          'TLS, n\'importe qui capable de capturer le trafic (Wi-Fi partagé, '
          'usurpation ARP) lit les identifiants. Il faut du HTTPS sur tous les '
          'services, même internes, et changer le mot de passe d\'alice.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Scénarios d\'analyse',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chaque scénario s\'appuie sur la capture de l\'onglet Capture. '
          'Réfléchissez, vérifiez dans la capture, puis dépliez l\'explication.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        for (final (title, question, answer) in _scenarios)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Callout(title, Icons.report, Colors.amber),
                  Text(question, style: const TextStyle(height: 1.5)),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Voir l\'explication'),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      Text(answer, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ],
              ),
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
