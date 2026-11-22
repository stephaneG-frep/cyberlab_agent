/// Résultat de l'analyse du Command Guard.
class GuardVerdict {
  final bool blocked;
  final String reason;
  const GuardVerdict.allow() : blocked = false, reason = '';
  const GuardVerdict.block(this.reason) : blocked = true;
}

/// Command Guard : RÈGLE PÉDAGOGIQUE du simulateur.
///
/// Le terminal n'exécute jamais rien sur l'appareil ; ce garde-fou sert à
/// apprendre la prudence en refusant des commandes qui seraient
/// destructrices sur un vrai système. Ce n'est pas une protection système,
/// et la liste des règles n'est pas exhaustive.
///
/// Commandes refusées :
/// - `rm` récursif ET forcé, quelle que soit l'écriture : `-rf`, `-fr`,
///   `-r -f`, `-Rf`, `--recursive --force`, abréviations GNU (`--rec`,
///   `--f`), `--interactive=never`, options placées après les fichiers ;
/// - `dd` avec `of=` ; redirection `>` vers un disque (`/dev/sda`…) ;
/// - formatage (`mkfs`, `mkfs.*`, `mke2fs`, `mkswap`, `wipefs`) et `shred` ;
/// - `find` avec `-delete` sur un chemin système (`/`, `~`, `/etc`…), et
///   `find -exec` dont la commande serait elle-même refusée ;
/// - `chmod`/`chown`/`chgrp` récursifs sur un chemin système ;
/// - la « bombe fork » `:(){ :|:& };:`.
///
/// Analyse :
/// - chaque segment (`;`, `&&`, `||`, `|`, `&`, retour à la ligne) ;
/// - préfixes ignorés avec leurs options : `sudo`, `doas`, `env`, `nohup`,
///   `time`, `command`, `builtin`, `exec`, `nice`, `ionice`, `timeout`,
///   `xargs`, `stdbuf`, `setsid`, `watch`, et les affectations `VAR=valeur` ;
/// - nom de commande normalisé (`\rm`, `/bin/rm`, `"rm"` → `rm`) ;
/// - code imbriqué : `bash -c "…"`, `sh -c`, `su -c`, `eval`, `$(…)`,
///   `` `…` `` (sauf entre apostrophes, où le shell ne l'exécute pas).
/// Seule la commande réellement invoquée compte : `echo "rm -rf /"`,
/// `man rm` ou `grep "rm -rf" notes.txt` ne sont pas bloqués.
class CommandGuard {
  CommandGuard._();

  static const _maxDepth = 4;

  /// Préfixes : options qui prennent une valeur, et nombre d'arguments
  /// positionnels à sauter avant la commande (ex. la durée de `timeout`).
  static const Map<String, (Set<String>, int)> _prefixes = {
    'sudo': ({'-u', '-g', '-C', '-h', '-p', '-U', '-r', '-t', '-D'}, 0),
    'doas': ({'-u', '-C'}, 0),
    'env': ({'-u', '-C'}, 0),
    'nohup': ({}, 0),
    'time': ({}, 0),
    'command': ({}, 0),
    'builtin': ({}, 0),
    'exec': ({'-a'}, 0),
    'nice': ({'-n'}, 0),
    'ionice': ({'-c', '-n', '-p'}, 0),
    'timeout': ({'-s', '-k'}, 1),
    'xargs': ({'-n', '-I', '-L', '-P', '-d', '-E', '-s', '-a'}, 0),
    'stdbuf': ({'-i', '-o', '-e'}, 0),
    'setsid': ({}, 0),
    'watch': ({'-n'}, 0),
  };

  static const _shells = {'sh', 'bash', 'zsh', 'dash', 'ksh', 'fish', 'ash'};

  static const _formatters = {'mkfs', 'mke2fs', 'mkswap', 'wipefs'};

  static const _sensitivePaths = {
    '/',
    '~',
    r'$HOME',
    r'${HOME}',
    '/home',
    '/root',
    '/etc',
    '/usr',
    '/var',
    '/boot',
    '/bin',
    '/sbin',
    '/lib',
    '/lib64',
    '/opt',
    '/dev',
    '/sys',
    '/proc',
    '/srv',
    '/mnt',
    '/media',
  };

  static final _forkBomb = RegExp(r'(\S+)\s*\(\)\s*\{[^}]*\1\s*\|\s*\1');

  static final _rawDisk = RegExp(
    r'^/dev/(sd[a-z]|hd[a-z]|vd[a-z]|xvd[a-z]|nvme\d|mmcblk\d)',
  );

  static final _assignment = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*=');

  static GuardVerdict check(String input) => _check(input, 0);

  static GuardVerdict _check(String input, int depth) {
    if (depth > _maxDepth) return const GuardVerdict.allow();
    if (_forkBomb.hasMatch(input)) {
      return const GuardVerdict.block('bombe fork (saturation du système)');
    }
    for (final inner in substitutions(input)) {
      final v = _check(inner, depth + 1);
      if (v.blocked) return v;
    }
    for (final segment in splitSegments(input)) {
      final v = _checkWords(segment.map(_unquote).toList(), depth);
      if (v.blocked) return v;
    }
    return const GuardVerdict.allow();
  }

  static GuardVerdict _checkWords(List<String> words, int depth) {
    final redirect = _rawDiskRedirect(words);
    if (redirect != null) return redirect;

    final i = _skipPrefixes(words);
    if (i >= words.length) return const GuardVerdict.allow();
    // Mot de commande issu d'une chaîne entre guillemets (`watch "rm -rf /"`).
    if (words[i].trim().contains(RegExp(r'\s'))) {
      return _check(words[i], depth + 1);
    }
    final cmd = commandName(words[i]);
    final args = words.sublist(i + 1);

    if (cmd == 'rm' && _isRecursiveForce(args)) {
      return const GuardVerdict.block(
        'suppression récursive forcée (rm -r + -f)',
      );
    }
    if (cmd == 'dd' && args.any((a) => a.startsWith('of='))) {
      return const GuardVerdict.block('écriture brute dd (of=)');
    }
    if (_formatters.contains(cmd) || cmd.startsWith('mkfs.')) {
      return const GuardVerdict.block('formatage ou effacement d\'un disque');
    }
    if (cmd == 'shred') {
      return const GuardVerdict.block('effacement irréversible (shred)');
    }
    if ((cmd == 'chmod' || cmd == 'chown' || cmd == 'chgrp') &&
        _hasRecursiveFlag(args) &&
        args.any(_isSensitivePath)) {
      return GuardVerdict.block(
        'modification récursive des droits d\'un répertoire système ($cmd -R)',
      );
    }
    if (cmd == 'find') return _checkFind(args, depth);

    // Code imbriqué exécuté par un autre programme.
    if (_shells.contains(cmd) || cmd == 'su') {
      final script = _dashCArgument(args);
      if (script != null) return _check(script, depth + 1);
    }
    if (cmd == 'eval' && args.isNotEmpty) {
      return _check(args.join(' '), depth + 1);
    }
    return const GuardVerdict.allow();
  }

  /// Index du mot de commande réel, après préfixes et affectations.
  static int _skipPrefixes(List<String> words) {
    var i = 0;
    while (i < words.length) {
      final w = words[i];
      if (_assignment.hasMatch(w)) {
        i++; // VAR=valeur commande
        continue;
      }
      final prefix = _prefixes[commandName(w)];
      if (prefix == null) break;
      final (valued, positional) = prefix;
      i++;
      while (i < words.length) {
        final a = words[i];
        if (a == '--') {
          i++;
          break;
        }
        if (a.startsWith('-') && a.length > 1) {
          i += valued.contains(a) ? 2 : 1;
          continue;
        }
        if (_assignment.hasMatch(a)) {
          i++; // env VAR=valeur, sudo VAR=valeur
          continue;
        }
        break;
      }
      i += positional;
    }
    return i;
  }

  /// Nom de commande normalisé : sans antislash (`\rm`), ni chemin
  /// (`/bin/rm`).
  static String commandName(String word) =>
      word.replaceAll(r'\', '').split('/').last;

  static GuardVerdict? _rawDiskRedirect(List<String> words) {
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      final m = RegExp(r'^\d*>>?(.*)$').firstMatch(w);
      if (m == null) continue;
      final target = m.group(1)!.isNotEmpty
          ? m.group(1)!
          : (i + 1 < words.length ? words[i + 1] : '');
      if (_rawDisk.hasMatch(target)) {
        return const GuardVerdict.block('écriture brute vers un disque (>)');
      }
    }
    return null;
  }

  static GuardVerdict _checkFind(List<String> args, int depth) {
    final starts = args
        .takeWhile((a) => !a.startsWith('-') && a != '(' && a != '!')
        .toList();
    if (args.contains('-delete') && starts.any(_isSensitivePath)) {
      return const GuardVerdict.block(
        'suppression massive avec find -delete sur un répertoire système',
      );
    }
    for (var i = 0; i < args.length; i++) {
      if (!const {'-exec', '-execdir', '-ok', '-okdir'}.contains(args[i])) {
        continue;
      }
      final sub = <String>[];
      for (var j = i + 1; j < args.length; j++) {
        final a = args[j];
        if (a == ';' || a == r'\;' || a == r'\' || a == '+') break;
        sub.add(a);
      }
      final v = _checkWords(sub, depth + 1);
      if (v.blocked) return v;
    }
    return const GuardVerdict.allow();
  }

  /// Argument de `-c` (`bash -c "…"`, `bash -lc "…"`, `su -c "…"`).
  static String? _dashCArgument(List<String> args) {
    for (var i = 0; i < args.length - 1; i++) {
      final a = args[i];
      if (a == '--command') return args[i + 1];
      if (a.startsWith('-') && !a.startsWith('--') && a.contains('c')) {
        return args[i + 1];
      }
    }
    for (final a in args) {
      if (a.startsWith('--command=')) return a.substring(10);
    }
    return null;
  }

  static bool _hasRecursiveFlag(List<String> args) => args.any(
    (a) =>
        a == '--recursive' ||
        (a.startsWith('-') && !a.startsWith('--') && a.contains('R')),
  );

  static bool _isSensitivePath(String path) {
    var p = path.trim();
    if (p.endsWith('/*')) p = p.substring(0, p.length - 2);
    while (p.length > 1 && p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    if (p.isEmpty) p = '/';
    return _sensitivePaths.contains(p);
  }

  static bool _isRecursiveForce(List<String> args) {
    var recursive = false, force = false;
    for (final a in args) {
      if (a == '--') break; // la suite n'est que des noms de fichiers
      if (a.startsWith('--')) {
        final eq = a.indexOf('=');
        final name = eq < 0 ? a.substring(2) : a.substring(2, eq);
        final value = eq < 0 ? null : a.substring(eq + 1);
        if (name.isEmpty) continue;
        // GNU accepte toute abréviation non ambiguë d'une option longue.
        if ('recursive'.startsWith(name)) {
          recursive = true;
        } else if ('force'.startsWith(name)) {
          force = true;
        } else if ('interactive'.startsWith(name) && value == 'never') {
          force = true;
        }
      } else if (a.startsWith('-') && a.length > 1) {
        final flags = a.substring(1);
        if (flags.contains('r') || flags.contains('R')) recursive = true;
        if (flags.contains('f')) force = true;
      }
    }
    return recursive && force;
  }

  static String _unquote(String w) {
    final b = StringBuffer();
    String? quote;
    for (final ch in w.split('')) {
      if (quote == null && (ch == '"' || ch == "'")) {
        quote = ch;
      } else if (ch == quote) {
        quote = null;
      } else {
        b.write(ch);
      }
    }
    return b.toString();
  }

  /// Contenu des substitutions de commande `$(…)`, `<(…)`, `>(…)` et
  /// `` `…` ``. Entre apostrophes, le shell n'exécute rien : ignoré.
  static List<String> substitutions(String input) {
    final found = <String>[];
    var inSingle = false;
    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == r'\' && !inSingle) {
        i++;
        continue;
      }
      if (c == "'") {
        inSingle = !inSingle;
        continue;
      }
      if (inSingle) continue;
      final next = i + 1 < input.length ? input[i + 1] : '';
      if ((c == r'$' || c == '<' || c == '>') && next == '(') {
        if (c == r'$' && i + 2 < input.length && input[i + 2] == '(') {
          continue; // $(( … )) : arithmétique
        }
        var depth = 1, j = i + 2;
        for (; j < input.length && depth > 0; j++) {
          if (input[j] == '(') depth++;
          if (input[j] == ')') depth--;
        }
        found.add(input.substring(i + 2, depth == 0 ? j - 1 : j));
        i = j - 1;
      } else if (c == '`') {
        var j = i + 1;
        while (j < input.length && input[j] != '`') {
          if (input[j] == r'\') j++;
          j++;
        }
        found.add(input.substring(i + 1, j.clamp(i + 1, input.length)));
        i = j;
      }
    }
    return found;
  }

  /// Découpe en segments (`;`, `&&`, `||`, `|`, `&`) hors guillemets, puis en
  /// mots (les guillemets sont conservés dans les mots).
  static List<List<String>> splitSegments(String input) {
    final segments = <List<String>>[];
    var words = <String>[];
    final buf = StringBuffer();
    String? quote;
    void endWord() {
      if (buf.isNotEmpty) {
        words.add(buf.toString());
        buf.clear();
      }
    }

    void endSegment() {
      endWord();
      if (words.isNotEmpty) segments.add(words);
      words = <String>[];
    }

    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (quote != null) {
        buf.write(c);
        if (c == quote) quote = null;
      } else if (c == '"' || c == "'") {
        quote = c;
        buf.write(c);
      } else if (c == ';' || c == '|' || c == '&' || c == '\n') {
        endSegment();
      } else if (c == ' ' || c == '\t') {
        endWord();
      } else {
        buf.write(c);
      }
    }
    endSegment();
    return segments;
  }
}

/// Simulated Linux terminal engine. Safe, no real system calls.
class TerminalEngine {
  final Map<String, int> _attempts = {};
  String user = 'learner';
  String host = 'cyberlab';

  /// Règle pédagogique activée par défaut (voir [CommandGuard]).
  bool guardEnabled = true;

  String get prompt => '$user@$host:~\$';

  static const guardMessage =
      'COMMAND GUARD (règle pédagogique du simulateur) : commande destructrice '
      'détectée et refusée.\n'
      'Ce terminal est simulé et n\'exécute rien sur votre appareil ; la règle '
      'sert à prendre de bons réflexes. Sur un vrai système, cette commande '
      'pourrait détruire des données de façon irréversible.';

  /// Runs a command in the sandbox. Returns the full output (with prompt echo removed).
  CommandResult run(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return CommandResult(output: '', exitCode: 0);
    }
    if (guardEnabled) {
      final verdict = CommandGuard.check(raw);
      if (verdict.blocked) {
        return CommandResult(
          output: '$guardMessage\nMotif : ${verdict.reason}.',
          exitCode: 1,
          blocked: true,
        );
      }
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
      case 'rm':
        return ok(
          args.isEmpty
              ? 'rm: opérande manquant (simulation)'
              : '(simulation) suppression simulée : ${args.where((a) => !a.startsWith('-')).join(' ')}\n'
                    '>>>  Aucun fichier réel n\'a été touché. Sur un vrai système, rm est définitif (pas de corbeille).',
        );
      default:
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
  rm, tree, history, which, docker, apt, clear, help, exit

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

  /// Vrai si la commande a été refusée par le Command Guard.
  final bool blocked;

  CommandResult({
    required this.output,
    required this.exitCode,
    this.clear = false,
    this.blocked = false,
  });
}
