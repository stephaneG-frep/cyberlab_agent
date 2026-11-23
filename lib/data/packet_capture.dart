import '../services/display_filter.dart';

/// Capture SIMULÉE « matin_lab.pcap » : une matinée sur le réseau du lab.
/// Postes : 192.168.1.42 (apprenant), 192.168.1.1 (passerelle et DNS),
/// 192.168.56.10 (intranet), 192.168.1.66 (poste suspect). Adresses externes
/// prises dans les plages de documentation (RFC 5737), sauf 8.8.8.8.
///
/// Elle raconte : une navigation HTTPS, une connexion à l'intranet en HTTP
/// (mot de passe en clair), un ping, un tunnel DNS, un scan SYN et une
/// usurpation ARP.
class LabCapture {
  LabCapture._();

  static const fileName = 'matin_lab.pcap';
  static const client = '192.168.1.42';

  static Packet _p(
    int no,
    double time,
    String src,
    String dst,
    String protocol,
    int length,
    String info,
    Set<String> layers,
    Map<String, Object> fields,
  ) => Packet(
    no: no,
    time: time,
    src: src,
    dst: dst,
    protocol: protocol,
    length: length,
    info: info,
    layers: {'eth', ...layers},
    fields: fields,
  );

  static Map<String, Object> _tcp(
    String src,
    int sport,
    String dst,
    int dport, {
    bool syn = false,
    bool ack = false,
    bool rst = false,
    bool fin = false,
  }) => {
    'ip.src': src,
    'ip.dst': dst,
    'tcp.srcport': sport,
    'tcp.dstport': dport,
    'tcp.flags.syn': syn ? 1 : 0,
    'tcp.flags.ack': ack ? 1 : 0,
    'tcp.flags.reset': rst ? 1 : 0,
    'tcp.flags.fin': fin ? 1 : 0,
  };

  static Map<String, Object> _dns(
    String src,
    String dst,
    int sport,
    String name, {
    bool response = false,
    String type = 'A',
    String? answer,
  }) => {
    'ip.src': src,
    'ip.dst': dst,
    'udp.srcport': response ? 53 : sport,
    'udp.dstport': response ? sport : 53,
    'dns.qry.name': name,
    'dns.qry.type': type,
    'dns.flags.response': response ? 1 : 0,
    'dns.a': ?answer,
  };

  static final List<Packet> packets = [
    _p(
      1,
      0.000,
      'PcsCompu_9a:3c:11',
      'Broadcast',
      'ARP',
      42,
      'Who has 192.168.1.1? Tell 192.168.1.42',
      {'arp'},
      {
        'arp.opcode': 1,
        'arp.src.proto_ipv4': '192.168.1.42',
        'arp.dst.proto_ipv4': '192.168.1.1',
      },
    ),
    _p(
      2,
      0.001,
      'Routeur_11:22:33',
      'PcsCompu_9a:3c:11',
      'ARP',
      42,
      '192.168.1.1 is at 3c:84:6a:11:22:33',
      {'arp'},
      {
        'arp.opcode': 2,
        'arp.src.proto_ipv4': '192.168.1.1',
        'arp.dst.proto_ipv4': '192.168.1.42',
      },
    ),
    _p(
      3,
      0.050,
      client,
      '192.168.1.1',
      'DNS',
      75,
      'Standard query 0x1a2b A www.example.com',
      {'ip', 'udp', 'dns'},
      _dns(client, '192.168.1.1', 51515, 'www.example.com'),
    ),
    _p(
      4,
      0.071,
      '192.168.1.1',
      client,
      'DNS',
      91,
      'Standard query response 0x1a2b A www.example.com A 198.51.100.20',
      {'ip', 'udp', 'dns'},
      _dns(
        '192.168.1.1',
        client,
        51515,
        'www.example.com',
        response: true,
        answer: '198.51.100.20',
      ),
    ),
    _p(
      5,
      0.080,
      client,
      '198.51.100.20',
      'TCP',
      74,
      '51000 → 443 [SYN] Seq=0 Win=64240 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 51000, '198.51.100.20', 443, syn: true),
    ),
    _p(
      6,
      0.110,
      '198.51.100.20',
      client,
      'TCP',
      74,
      '443 → 51000 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0',
      {'ip', 'tcp'},
      _tcp('198.51.100.20', 443, client, 51000, syn: true, ack: true),
    ),
    _p(
      7,
      0.111,
      client,
      '198.51.100.20',
      'TCP',
      66,
      '51000 → 443 [ACK] Seq=1 Ack=1 Win=64256 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 51000, '198.51.100.20', 443, ack: true),
    ),
    _p(
      8,
      0.112,
      client,
      '198.51.100.20',
      'TLSv1.3',
      583,
      'Client Hello (SNI=www.example.com)',
      {'ip', 'tcp', 'tls'},
      {
        ..._tcp(client, 51000, '198.51.100.20', 443, ack: true),
        'tls.handshake.extensions_server_name': 'www.example.com',
      },
    ),
    _p(
      9,
      0.145,
      '198.51.100.20',
      client,
      'TLSv1.3',
      1514,
      'Server Hello, Change Cipher Spec, Application Data',
      {'ip', 'tcp', 'tls'},
      _tcp('198.51.100.20', 443, client, 51000, ack: true),
    ),
    _p(
      10,
      1.200,
      client,
      '192.168.1.1',
      'DNS',
      71,
      'Standard query 0x3c4d A intranet.lab',
      {'ip', 'udp', 'dns'},
      _dns(client, '192.168.1.1', 52020, 'intranet.lab'),
    ),
    _p(
      11,
      1.215,
      '192.168.1.1',
      client,
      'DNS',
      87,
      'Standard query response 0x3c4d A intranet.lab A 192.168.56.10',
      {'ip', 'udp', 'dns'},
      _dns(
        '192.168.1.1',
        client,
        52020,
        'intranet.lab',
        response: true,
        answer: '192.168.56.10',
      ),
    ),
    _p(
      12,
      1.220,
      client,
      '192.168.56.10',
      'TCP',
      74,
      '51010 → 80 [SYN] Seq=0 Win=64240 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 51010, '192.168.56.10', 80, syn: true),
    ),
    _p(
      13,
      1.221,
      '192.168.56.10',
      client,
      'TCP',
      74,
      '80 → 51010 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0',
      {'ip', 'tcp'},
      _tcp('192.168.56.10', 80, client, 51010, syn: true, ack: true),
    ),
    _p(
      14,
      1.222,
      client,
      '192.168.56.10',
      'TCP',
      66,
      '51010 → 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 51010, '192.168.56.10', 80, ack: true),
    ),
    _p(
      15,
      1.223,
      client,
      '192.168.56.10',
      'HTTP',
      412,
      'GET /login HTTP/1.1',
      {'ip', 'tcp', 'http'},
      {
        ..._tcp(client, 51010, '192.168.56.10', 80, ack: true),
        'http.request.method': 'GET',
        'http.request.uri': '/login',
        'http.host': 'intranet.lab',
      },
    ),
    _p(
      16,
      1.240,
      '192.168.56.10',
      client,
      'HTTP',
      1320,
      'HTTP/1.1 200 OK (text/html)',
      {'ip', 'tcp', 'http'},
      {
        ..._tcp('192.168.56.10', 80, client, 51010, ack: true),
        'http.response.code': 200,
      },
    ),
    _p(
      17,
      5.010,
      client,
      '192.168.56.10',
      'HTTP',
      520,
      'POST /login HTTP/1.1 (application/x-www-form-urlencoded)',
      {'ip', 'tcp', 'http'},
      {
        ..._tcp(client, 51010, '192.168.56.10', 80, ack: true),
        'http.request.method': 'POST',
        'http.request.uri': '/login',
        'http.host': 'intranet.lab',
        'http.file_data': 'user=alice&password=Printemps2026!',
      },
    ),
    _p(
      18,
      5.030,
      '192.168.56.10',
      client,
      'HTTP',
      310,
      'HTTP/1.1 302 Found',
      {'ip', 'tcp', 'http'},
      {
        ..._tcp('192.168.56.10', 80, client, 51010, ack: true),
        'http.response.code': 302,
      },
    ),
    _p(
      19,
      6.000,
      client,
      '8.8.8.8',
      'ICMP',
      98,
      'Echo (ping) request id=0x0001, seq=1/256, ttl=64',
      {'ip', 'icmp'},
      {'ip.src': client, 'ip.dst': '8.8.8.8', 'icmp.type': 8},
    ),
    _p(
      20,
      6.018,
      '8.8.8.8',
      client,
      'ICMP',
      98,
      'Echo (ping) reply id=0x0001, seq=1/256, ttl=117',
      {'ip', 'icmp'},
      {'ip.src': '8.8.8.8', 'ip.dst': client, 'icmp.type': 0},
    ),
    for (final (i, label) in [
      'aGVsbG8gZnJvbQ',
      'bWFjaGluZSA2Ng',
      'cGFzc3dvcmRzLnR4dA',
      'ZW5kIG9mIGRhdGE',
    ].indexed)
      _p(
        21 + i,
        10.0 + 5 * i,
        '192.168.1.66',
        '192.168.1.1',
        'DNS',
        96,
        'Standard query 0x5e0${i + 1} TXT $label.x7f3.exfil.example.net',
        {'ip', 'udp', 'dns'},
        _dns(
          '192.168.1.66',
          '192.168.1.1',
          53000 + i,
          '$label.x7f3.exfil.example.net',
          type: 'TXT',
        ),
      ),
    _p(
      25,
      30.000,
      '203.0.113.7',
      client,
      'TCP',
      58,
      '40001 → 22 [SYN] Seq=0 Win=1024 Len=0',
      {'ip', 'tcp'},
      _tcp('203.0.113.7', 40001, client, 22, syn: true),
    ),
    _p(
      26,
      30.001,
      client,
      '203.0.113.7',
      'TCP',
      58,
      '22 → 40001 [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 22, '203.0.113.7', 40001, syn: true, ack: true),
    ),
    _p(
      27,
      30.002,
      '203.0.113.7',
      client,
      'TCP',
      54,
      '40001 → 22 [RST] Seq=1 Win=0 Len=0',
      {'ip', 'tcp'},
      _tcp('203.0.113.7', 40001, client, 22, rst: true),
    ),
    _p(
      28,
      30.010,
      '203.0.113.7',
      client,
      'TCP',
      58,
      '40001 → 23 [SYN] Seq=0 Win=1024 Len=0',
      {'ip', 'tcp'},
      _tcp('203.0.113.7', 40001, client, 23, syn: true),
    ),
    _p(
      29,
      30.011,
      client,
      '203.0.113.7',
      'TCP',
      54,
      '23 → 40001 [RST, ACK] Seq=1 Ack=1 Win=0 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 23, '203.0.113.7', 40001, rst: true, ack: true),
    ),
    _p(
      30,
      30.020,
      '203.0.113.7',
      client,
      'TCP',
      58,
      '40001 → 3389 [SYN] Seq=0 Win=1024 Len=0',
      {'ip', 'tcp'},
      _tcp('203.0.113.7', 40001, client, 3389, syn: true),
    ),
    _p(
      31,
      30.021,
      client,
      '203.0.113.7',
      'TCP',
      54,
      '3389 → 40001 [RST, ACK] Seq=1 Ack=1 Win=0 Len=0',
      {'ip', 'tcp'},
      _tcp(client, 3389, '203.0.113.7', 40001, rst: true, ack: true),
    ),
    _p(
      32,
      31.500,
      'PcsCompu_66:66:66',
      'PcsCompu_9a:3c:11',
      'ARP',
      42,
      '192.168.1.1 is at 08:00:27:66:66:66 (duplicate use of 192.168.1.1 '
          'detected!)',
      {'arp'},
      {
        'arp.opcode': 2,
        'arp.src.proto_ipv4': '192.168.1.1',
        'arp.dst.proto_ipv4': '192.168.1.42',
      },
    ),
  ];
}

/// Exercice de filtrage : réussi quand le filtre de l'apprenant affiche
/// EXACTEMENT les mêmes paquets que [solution]. Plusieurs écritures sont
/// donc acceptées (ex. `!(arp || dns)` ou `not arp and not dns`).
class FilterExercise {
  final String id;
  final String title;
  final String task;
  final String hint;
  final String solution;
  final String explanation;
  final int xp;
  const FilterExercise({
    required this.id,
    required this.title,
    required this.task,
    required this.hint,
    required this.solution,
    required this.explanation,
    this.xp = 20,
  });

  Set<int> expected(List<Packet> packets) =>
      DisplayFilter.parse(solution).apply(packets).map((p) => p.no).toSet();
}

class FilterExercises {
  FilterExercises._();

  static const all = <FilterExercise>[
    FilterExercise(
      id: 'ws1',
      title: 'Une machine précise',
      task:
          'Affichez tout le trafic échangé avec le serveur intranet '
          '192.168.56.10, qu\'il soit source ou destination.',
      hint: 'Le champ ip.addr correspond à la source OU à la destination.',
      solution: 'ip.addr == 192.168.56.10',
      explanation:
          'ip.addr couvre les deux sens : on voit la poignée de main TCP, la '
          'page de connexion et l\'envoi du formulaire.',
    ),
    FilterExercise(
      id: 'ws2',
      title: 'Résolutions de noms',
      task: 'N\'affichez que le trafic DNS.',
      hint: 'Le nom d\'un protocole seul est déjà un filtre.',
      solution: 'dns',
      explanation:
          'Le DNS révèle les sites consultés, même quand le trafic web est '
          'chiffré. Remarquez les requêtes étranges de 192.168.1.66.',
    ),
    FilterExercise(
      id: 'ws3',
      title: 'Requêtes web',
      task:
          'Affichez seulement les requêtes HTTP envoyées par le navigateur '
          '(pas les réponses du serveur).',
      hint: 'Wireshark distingue http.request et http.response.',
      solution: 'http.request',
      explanation:
          'Deux requêtes : GET /login pour afficher le formulaire, puis POST '
          '/login pour l\'envoyer.',
    ),
    FilterExercise(
      id: 'ws4',
      title: 'Identifiants en clair',
      task:
          'Isolez la requête qui envoie le formulaire de connexion. Touchez '
          'ensuite le paquet pour lire son contenu.',
      hint:
          'Un formulaire est envoyé avec la méthode POST : comparez le champ '
          'http.request.method à "POST".',
      solution: 'http.request.method == "POST"',
      explanation:
          'Le paquet 17 contient « user=alice&password=Printemps2026! » en '
          'clair : l\'intranet utilise HTTP sans TLS. Toute personne sur le '
          'réseau peut lire le mot de passe. Solution : HTTPS partout.',
    ),
    FilterExercise(
      id: 'ws5',
      title: 'Les paquets de l\'attaquant',
      task: 'Affichez tous les paquets ÉMIS par l\'adresse 203.0.113.7.',
      hint: 'ip.src est l\'adresse source uniquement.',
      solution: 'ip.src == 203.0.113.7',
      explanation:
          'Des SYN vers plusieurs ports puis un RST : c\'est la signature d\'un '
          'scan SYN (nmap -sS). L\'attaquant ne termine jamais les connexions.',
    ),
    FilterExercise(
      id: 'ws6',
      title: 'Ouvertures de connexion',
      task:
          'Affichez uniquement les tentatives d\'ouverture de connexion TCP : '
          'drapeau SYN présent, drapeau ACK absent.',
      hint:
          'Combinez tcp.flags.syn == 1 et tcp.flags.ack == 0 avec && (ou and).',
      solution: 'tcp.flags.syn == 1 && tcp.flags.ack == 0',
      explanation:
          'Chaque SYN seul est un « bonjour » TCP. Trois SYN depuis la même '
          'adresse vers des ports différents en quelques millisecondes : un '
          'scan.',
    ),
    FilterExercise(
      id: 'ws7',
      title: 'Le tunnel DNS',
      task:
          'Affichez les requêtes DNS dont le nom demandé contient le mot '
          '« exfil ».',
      hint:
          'L\'opérateur contains cherche un texte dans un champ : '
          'dns.qry.name contains "…"',
      solution: 'dns.qry.name contains "exfil"',
      explanation:
          'Les sous-domaines sont du Base64 sans « = » final. Décodez-les dans '
          'le terminal (echo cGFzc3dvcmRzLnR4dA | base64 -d) : le poste '
          '192.168.1.66 exfiltre « passwords.txt » par le DNS.',
    ),
    FilterExercise(
      id: 'ws8',
      title: 'Sans le bruit',
      task: 'Masquez l\'ARP et le DNS pour ne garder que le reste du trafic.',
      hint: '! (ou not) inverse un filtre ; des parenthèses regroupent.',
      solution: '!(arp || dns)',
      explanation:
          'Exclure le bruit de fond est le premier geste d\'une analyse : on '
          'part du tout, puis on retire ce qui est connu et normal.',
    ),
    FilterExercise(
      id: 'ws9',
      title: 'Ports fermés',
      task:
          'Affichez les réinitialisations (drapeau RST) envoyées par le poste '
          '192.168.1.42 : elles révèlent des ports fermés.',
      hint: 'tcp.flags.reset == 1, combiné à l\'adresse source.',
      solution: 'tcp.flags.reset == 1 && ip.src == 192.168.1.42',
      explanation:
          'Les ports 23 (telnet) et 3389 (RDP) répondent RST : fermés. Le '
          'port 22 a répondu SYN, ACK (paquet 26) : il est ouvert, et '
          'l\'attaquant le sait.',
    ),
  ];
}
