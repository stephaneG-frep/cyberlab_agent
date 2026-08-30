/// Simulated Linux terminal engine. Safe, no real system calls.
class TerminalEngine {
  final Map<String, int> _attempts = {};
  String user = 'learner';
  String host = 'cyberlab';

  String get prompt => '$user@$host:~\$';

  /// Runs a command in the sandbox. Returns the full output (with prompt echo removed).
  CommandResult run(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return CommandResult(output: '', exitCode: 0);
    }
    final parts = _tokenize(raw);
    if (parts.isEmpty) return CommandResult(output: '', exitCode: 0);
    final cmd = parts.first;
    final args = parts.sublist(1);

    switch (cmd) {
      case 'help':
        return ok(_help());
      case 'pwd':
        return ok('/home/$user');
      case 'whoami':
        return ok(user);
      case 'hostname':
        return ok(host);
      case 'echo':
        return ok(args.join(' '));
      case 'ls':
        return ok(_ls(args));
      case 'cd':
        return ok('');
      case 'cat':
        return ok(_cat(args));
      case 'clear':
        return CommandResult(output: '', exitCode: 0, clear: true);
      case 'date':
        return ok(DateTime.now().toString());
      case 'uname':
        return ok(_uname(args));
      case 'ifconfig':
      case 'ip':
        return ok(_network());
      case 'ping':
        return ok(_ping(args));
      case 'nmap':
        return ok(_nmap(args));
      case 'ps':
        return ok(_ps(args));
      case 'grep':
        return ok(
          '(simulation) grep trouvé la correspondance pour : ${args.join(' ')}',
        );
      case 'sudo':
        return ok(
          '(simulation) $host: [sudo] permet de super-utilisateur\n>>>  $user a exécuté la commande en tant que root',
        );
      case 'man':
        return ok(_man(args));
      case 'curl':
      case 'wget':
        return ok(_http(args));
      case 'ssh':
        return ok(
          '(simulation) Connexion SSH simulée vers ${args.isNotEmpty ? args.last : "hôte"}\n>>>  Vous êtes connecté (environnement virtuel). Faites attention: en réel SSH se connecte à une vraie machine.',
        );
      case 'history':
        return ok('(simulation) historique des commandes');
      case 'which':
        return ok(args.isNotEmpty ? '/usr/bin/${args.first}' : '');
      case 'chmod':
        return ok(
          '(simulation) permissions modifiées sur ${args.isNotEmpty ? args.last : "fichier"}',
        );
      case 'chown':
        return ok(
          '(simulation) propriétaire modifié sur ${args.isNotEmpty ? args.last : "fichier"}',
        );
      case 'df':
        return ok(_df());
      case 'free':
        return ok(_free());
      case 'head':
        return ok('(simulation) première(s) ligne(s) affichée(s)');
      case 'tail':
        return ok('(simulation) dernière(s) ligne(s) affichée(s)');
      case 'tree':
        return ok(_tree());
      case 'find':
        return ok('(simulation) fichiers correspondant à : ${args.join(' ')}');
      case 'sort':
        return ok('(simulation) lignes triées');
      case 'wc':
        return ok('(simulation) nombre de lignes / mots / octets');
      case 'awk':
        return ok('(simulation) traitement awk exécuté');
      case 'sed':
        return ok('(simulation) édition de flux sed exécutée');
      case 'exit':
        return ok('(simulation) session terminée. Revoyons plus tôt.');
      case 'docker':
        return ok(_docker(args));
      case 'apt':
        return ok(_apt(args));
      default:
        if (raw.contains('rm -rf')) {
          return CommandResult(
            output:
                'cmd: commande destructrice détectée.\n>>>  GUARD: cette simulation bloque volontairement "rm -rf" pour éviter toute habitude dangereuse.\n>>>  En environnement réel, rm -rf peut détruire des fichiers irrécupérables.',
            exitCode: 1,
          );
        }
        return CommandResult(
          output:
              'bash: $cmd: commande introuvable (simulation)\n'
              'Tapez "help" pour voir les commandes disponibles.',
          exitCode: 127,
        );
    }
  }

  List<String> _tokenize(String input) {
    final parts = <String>[];
    final buf = StringBuffer();
    String? quote;
    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (quote != null) {
        buf.write(c);
        if (c == quote) quote = null;
      } else if (c == "'" || c == '"') {
        quote = c;
        if (buf.isNotEmpty) {
          parts.add(buf.toString());
          buf.clear();
        }
        buf.write(c);
      } else if (c == ' ' || c == '\t') {
        if (buf.isNotEmpty) {
          parts.add(buf.toString());
          buf.clear();
        }
      } else {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty) parts.add(buf.toString());
    return parts;
  }

  CommandResult ok(String out) => CommandResult(output: out, exitCode: 0);

  String _help() => '''
Commandes Linux simulées disponibles:
  pwd, ls, cd, cat, echo, whoami, hostname, date, uname
  ifconfig/ip, ping, nmap, ps, grep, find, sort, wc, head, tail
  awk, sed, chmod, chown, curl/wget, ssh, sudo, man, df, free
  tree, history, which, docker, apt, clear, help, exit

Tapez "man <commande>" pour la documentation. Ex: man nmap''';

  String _ls(List<String> args) {
    if (args.contains('-a')) {
      return '.  ..  .bashrc  .profile  .ssh\n'
          'documents/  scripts/  logs/  notes.txt  rapports/';
    }
    return 'documents/  scripts/  logs/  notes.txt  rapports/';
  }

  String _cat(List<String> args) {
    if (args.isEmpty) return '(simulation) tapez cat <fichier>';
    final f = args.last;
    if (f.contains('log') || f.contains('auth')) {
      return '=== $f ===\n'
          'Aug 28 06:00:01 cyberlab systemd[1]: Started Daily apt.\n'
          'Aug 28 06:02:45 cyberlab sshd[1402]: Failed password for invalid user admin from 203.0.113.7 port 51234\n'
          'Aug 28 06:03:11 cyberlab sshd[1403]: Failed password for root from 203.0.113.7 port 51244\n'
          'Aug 28 06:03:50 cyberlab sshd[1404]: Accepted publickey for learner from 198.51.100.10 port 50123\n'
          'Aug 28 06:05:00 cyberlab sudo[1500]: learner : TTY=pts/0 ; PWD=/home/learner ; USER=root ; COMMAND=/usr/bin/nmap localhost';
    } else if (f == 'notes.txt') {
      return 'notes.txt: rien à noter pour l\'instant.\n'
          'Astuce: utilisez tail/head pour lire les logs en morceaux.';
    }
    return '(simulation) contenu de "$f"';
  }

  String _uname(List<String> args) {
    if (args.contains('-a')) {
      return 'Linux cyberlab 6.1.0-cyber #1 SMP x86_64 GNU/Linux';
    }
    return 'Linux';
  }

  String _network() {
    return '''
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.42  netmask 255.255.255.0  broadcast 192.168.1.255
        ether 08:00:27:9a:3c:11  txqueuelen 1000
        RX packets 12847  bytes 1048291 (1.0 MB)
        TX packets 10122  bytes 912018 (912.0 KB)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0

Routes:
default via 192.168.1.1  dev eth0''';
  }

  String _ping(List<String> args) {
    final target = args.isNotEmpty && !args.first.startsWith('-')
        ? args.first
        : (args.length > 1 ? args.last : 'localhost');
    _attempts[target] = (_attempts[target] ?? 0) + 1;
    final n = _attempts[target]!;
    if (n > 3 && !target.contains('127.0.0.1') && target != 'localhost') {
      return '''
PING $target: 56 data bytes
64 bytes from $target: icmp_seq=1 ttl=64 time=12.3 ms
64 bytes from $target: icmp_seq=2 ttl=64 time=12.9 ms
64 bytes from $target: icmp_seq=3 ttl=64 time=11.7 ms
*** Request timeout for icmp_seq=4
*** Request timeout for icmp_seq=5
$target est peut-être filtré ou hors-ligne (simulation).''';
    }
    return '''
PING $target ($target): 56 data bytes
64 bytes from $target: icmp_seq=0 ttl=64 time=0.056 ms
64 bytes from $target: icmp_seq=1 ttl=64 time=0.045 ms
64 bytes from $target: icmp_seq=2 ttl=64 time=0.044 ms

--- $target ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
(Simulation - ping = test de connectivité, jamais une attaque.)''';
  }

  String _nmap(List<String> args) {
    final target = args.isNotEmpty && !args.first.startsWith('-')
        ? args.first
        : (args.length > 1 ? args.last : 'localhost');
    if (!args.contains('-sS') &&
        !args.contains('-sT') &&
        !args.contains('-sV') &&
        !args.contains('-p')) {
      return '''
Starting Nmap simulation 7.94 ( https://nmap.org )
Nmap scan report for $target
Host is up (0.0010s latency).
PORT     STATE    SERVICE
22/tcp   open     ssh
80/tcp   open     http
443/tcp  closed   https
8080/tcp filtered http-proxy

Nmap done: 1 IP address -- (Simulation: ne scannez jamais une machine sans autorisation.)''';
    }
    if (args.contains('-sV') || args.contains('-sT')) {
      return '''
Starting Nmap simulation 7.94
Scanned $target:
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 9.6 (protocol 2.0)
80/tcp   open  http    nginx 1.24.0
Service detection performed. (Simulation)''';
    }
    return '''
Starting Nmap simulation 7.94
$target: Ports ouverts: 22, 80, 443
(Simulation: nmap sert uniquement sur des cibles autorisées/localhost.)''';
  }

  String _ps(List<String> args) {
    if (args.contains('aux') || args.contains('-e')) {
      return '''USER       PID  %CPU %MEM  COMMAND
root         1   0.0  0.3  /sbin/init
root       235   0.1  0.4  systemd-journald
root       512   0.0  0.2  systemd-logind
learner   1337   2.0  1.1  /usr/bin/nmap -sV localhost
learner   1338   0.0  0.5  bash''';
    }
    return '''PID TTY          TIME CMD
1337 pts/0    00:00:02 nmap
1338 pts/0    00:00:00 bash''';
  }

  String _df() =>
      'Filesystem     1K-blocks    Used Available Use% Mounted on\n'
      '/dev/vda1       20480000 8543210  11936790  42% /';

  String _free() =>
      '              total        used        free      buff/cache\n'
      'Mem:        2097152      890112      500000      707040';

  String _tree() => '''
.
├── documents/
│   └── notes.pdf
├── scripts/
│   ├── analyse_logs.sh
│   └── scan_local.sh
├── logs/
│   └── auth.log
└── notes.txt''';

  String _man(List<String> args) {
    if (args.isEmpty) return '(simulation) man <commande>';
    final cmd = args.first;
    switch (cmd) {
      case 'nmap':
        return '''
NMAP(1)  Manuel de l'administrateur système  NMAP(1)

NOM
       nmap - outil de découverte de réseau et audit de sécurité

SYNOPSIS
       nmap [Type de Scan] [Options] {spécification de cible}

DESCRIPTION
       Nmap (Network Mapper) est un outil libre de découverte de réseau
       et d'audit de sécurité. Il est utilisé pour découvrir des hôtes
       et des services sur un réseau informatique.

OPTIONS COURANTES
       -sT   Scan de connexion TCP
       -sS   Scan SYN (nécessite root)
       -sV   Détection de version des services
       -p    Spécifier les ports à scanner (ex: -p 22,80,443)
       -O    Détection du système d'exploitation

AVERTISSEMENT
       Nmap à usage éthique uniquement sur des hôtes autorisés. Scannez
       uniquement localhost, votre lab, ou des cibles avec autorisation.'''
            .replaceAll(' ', ' ')
            .replaceAll('\n', '\n      ');
      case 'ls':
        return "LS(1)\n\nNOM\n       ls - liste le contenu d'un répertoire\n\nSYNOPSIS\n       ls [OPTION]... [FICHIER]...\n\nOPTIONS\n       -a   inclut les fichiers cachés\n       -l   affichage détaillé\n       -h   tailles lisibles";
      case 'grep':
        return "GREP(1)\n\nNOM\n       grep - recherche des motifs dans les fichiers\n\nSYNOPSIS\n       grep [OPTION]... MOTIF [FICHIER]...\n\nFREQUENT\n       grep 'motif' fichier.log\n       grep -i   ignore la casse\n       grep -v   inverse le résultat";
      default:
        return 'MAN(1)\n\nNOM\n       man - affiche la documentation (simulée)\n\nSYNOPSIS\n       man [COMMANDE]\n\nDESCRIPTION\n       Affiche une fiche pédagogique pour la commande.\n       Commandes documentées : nmap, ls, grep.';
    }
  }

  String _http(List<String> args) {
    if (args.isEmpty) return '(simulation) curl <URL> | wget <URL>';
    String url = args.last;
    if (url.contains('localhost') ||
        url.contains('127.0.0.1') ||
        url.contains('example') ||
        url.contains('juice-shop')) {
      return '''
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: nginx/1.24.0
Content-Length: 1530

<!DOCTYPE html>
<html>
<head><title>Bienvenue sur le site de laboratoire</title></head>
<body><h1>Hello CyberLab</h1></body>
</html>
(Simulation - curl récupère le contenu d'un serveur.)''';
    }
    return '''
(Simulation) Requête vers $url
>>>  En réel, curl/wget récupèrent des données depuis Internet.
>>>  Utilisez-les uniquement vers des ressources autorisées.''';
  }

  String _docker(List<String> args) {
    if (args.isEmpty || args.first == 'ps') {
      return 'CONTAINER ID   IMAGE          STATUS         PORTS\n'
          '   (aucun conteneur - mode simulation)\n'
          '>>>  docker non disponible sur cet appareil sans Docker réel.';
    }
    if (args.first == 'images') {
      return 'REPOSITORY          TAG       IMAGE ID      SIZE\n'
          'cyberlab/webserver   latest    4f2a1c9b     78MB\n'
          '(simulation)';
    }
    if (args.first == 'run') {
      return '(simulation) démarrage d\'un conteneur de laboratoire...\n'
          '>>>  Docker Labs activé uniquement avec un vrai moteur Docker.';
    }
    return '(simulation) docker ${args.join(' ')}';
  }

  String _apt(List<String> args) {
    return '''
(Simulation) apt ${args.join(' ')}
>>>  En réel, apt installe des paquets logiciels sur Debian/Ubuntu.
>>>  Exemple: sudo apt install nmap
>>>  (aucun paquet réel installé - environnement simulé)''';
  }
}

class CommandResult {
  final String output;
  final int exitCode;
  final bool clear;

  CommandResult({
    required this.output,
    required this.exitCode,
    this.clear = false,
  });
}
