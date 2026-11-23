import 'dart:convert';
import 'virtual_fs.dart';

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

/// Terminal Linux SIMULÉ : un petit interpréteur de commandes écrit en Dart
/// qui agit uniquement sur un système de fichiers virtuel en mémoire
/// ([VirtualFs]). Aucune commande n'est exécutée sur l'appareil, aucun
/// fichier réel n'est lu ni écrit, et aucun accès réseau n'a lieu (ping,
/// nmap, curl… restent des simulations pédagogiques).
///
/// Pris en charge : `;`, `&&`, `||`, tubes `|`, redirections `>`, `>>`,
/// `<`, `2>`, `2>&1`, `&>`, variables (`$HOME`, `$?`, `X=1`), `$(…)`,
/// jokers (`*`, `?`, `[…]`), `~`, `sudo`, scripts (`bash f.sh`, `./f.sh`).
class TerminalEngine {
  TerminalEngine() {
    _resetSession();
  }

  final VirtualFs fs = VirtualFs();
  final Map<String, int> _attempts = {};
  final List<String> history = [];
  final Map<String, String> _vars = {};
  String host = 'cyberlab';
  String user = 'learner';
  String cwd = learnerHome;
  int _lastCode = 0;
  bool _sudoNoticeShown = false;

  /// Règle pédagogique activée par défaut (voir [CommandGuard]).
  bool guardEnabled = true;

  static const learnerHome = '/home/learner';
  static const _maxDepth = 5;

  static const guardMessage =
      'COMMAND GUARD (règle pédagogique du simulateur) : commande destructrice '
      'détectée et refusée.\n'
      'Ce terminal est simulé et n\'exécute rien sur votre appareil ; la règle '
      'sert à prendre de bons réflexes. Sur un vrai système, cette commande '
      'pourrait détruire des données de façon irréversible.';

  String get home => user == 'root' ? '/root' : learnerHome;

  String get displayCwd {
    if (cwd == home) return '~';
    if (cwd.startsWith('$home/')) return '~${cwd.substring(home.length)}';
    return cwd;
  }

  /// Invite abrégée pour la zone de saisie : `~/logs\$`.
  String get shortPrompt => '$displayCwd${user == 'root' ? '#' : r'$'}';

  /// Astuce ajoutée quand un chemin RELATIF est introuvable : le dossier
  /// courant est la cause la plus fréquente chez les débutants.
  String _whereHint(String path) {
    if (path.startsWith('/') || path.startsWith('~') || cwd == home) return '';
    return '\n(astuce : vous êtes dans $displayCwd ; « cd ~ » ramène au '
        'dossier personnel, « pwd » affiche le dossier courant)';
  }

  String get prompt => '$user@$host:$displayCwd${user == 'root' ? '#' : r'$'}';

  void _resetSession() {
    user = 'learner';
    cwd = learnerHome;
    _vars
      ..clear()
      ..addAll({
        'SHELL': '/bin/bash',
        'LANG': 'fr_FR.UTF-8',
        'PATH': '/usr/local/bin:/usr/bin:/bin',
        'TERM': 'xterm-256color',
      });
  }

  String _var(String name) => switch (name) {
    'HOME' => home,
    'USER' || 'LOGNAME' => user,
    'PWD' => cwd,
    'HOSTNAME' => host,
    '?' => '$_lastCode',
    _ => _vars[name] ?? '',
  };

  /// Exécute une ligne saisie par l'utilisateur.
  CommandResult run(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return CommandResult(output: '', exitCode: 0);
    history.add(raw);
    final r = _runLine(raw, 0);
    return CommandResult(
      output: r.text,
      exitCode: r.code,
      clear: r.clear,
      blocked: r.blocked,
    );
  }

  // ================================================================ Shell

  _LineResult _runLine(String line, int depth, {StringBuffer? errSink}) {
    if (guardEnabled) {
      final verdict = CommandGuard.check(line);
      if (verdict.blocked) {
        _lastCode = 1;
        final msg = '$guardMessage\nMotif : ${verdict.reason}.';
        if (errSink != null) {
          errSink.writeln(msg);
          return _LineResult('', 1);
        }
        return _LineResult(msg, 1, blocked: true);
      }
    }
    final List<(String, String)> segments;
    try {
      segments = _splitTop(line);
    } on FormatException catch (e) {
      _lastCode = 2;
      return _LineResult('bash: ${e.message}', 2);
    }
    final out = <String>[];
    var code = _lastCode;
    var clear = false;
    var first = true;
    for (final (conn, text) in segments) {
      if (!first) {
        if (conn == '&&' && code != 0) continue;
        if (conn == '||' && code == 0) continue;
      }
      first = false;
      final subErr = StringBuffer();
      _Out r;
      try {
        final cmds = _parsePipeline(_lex(text, depth, subErr));
        r = _runPipeline(cmds, depth);
      } on FormatException catch (e) {
        r = _Out('', 'bash: ${e.message}', 2);
      }
      if (r.clear) {
        clear = true;
        out.clear();
      }
      code = r.code;
      _lastCode = code;
      final err = _strip('$subErr${r.err}');
      if (err.isNotEmpty) {
        if (errSink != null) {
          errSink.writeln(err);
        } else {
          out.add(err);
        }
      }
      final o = _strip(r.out);
      if (o.isNotEmpty) out.add(o);
    }
    return _LineResult(out.join('\n'), code, clear: clear);
  }

  /// Découpe au premier niveau sur `;`, `&&`, `||` et `&` (hors guillemets
  /// et hors `$(…)`). Retourne (connecteur précédent, texte).
  List<(String, String)> _splitTop(String line) {
    final result = <(String, String)>[];
    final buf = StringBuffer();
    var conn = '';
    String? quote;
    var paren = 0;
    void push(String next) {
      final t = buf.toString().trim();
      buf.clear();
      if (t.isEmpty) {
        if (next == ';' && conn.isEmpty && result.isEmpty) return;
        throw FormatException(
          'erreur de syntaxe près du symbole inattendu « $next »',
        );
      }
      result.add((conn, t));
      conn = next;
    }

    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      final next = i + 1 < line.length ? line[i + 1] : '';
      if (quote != null) {
        buf.write(c);
        if (c == '\\' && quote == '"' && next.isNotEmpty) {
          buf.write(next);
          i++;
        } else if (c == quote) {
          quote = null;
        }
        continue;
      }
      if (c == '\\' && next.isNotEmpty) {
        buf
          ..write(c)
          ..write(next);
        i++;
        continue;
      }
      if (c == "'" || c == '"' || c == '`') {
        quote = c;
        buf.write(c);
        continue;
      }
      if (c == r'$' && next == '(') paren++;
      if (c == ')' && paren > 0) paren--;
      if (paren > 0) {
        buf.write(c);
        continue;
      }
      if (c == ';') {
        push(';');
      } else if (c == '&' && next == '&') {
        push('&&');
        i++;
      } else if (c == '|' && next == '|') {
        push('||');
        i++;
      } else if (c == '&' &&
          next != '>' &&
          !(i > 0 && (line[i - 1] == '>' || line[i - 1] == '<'))) {
        push(';'); // arrière-plan : exécuté normalement ici
      } else {
        buf.write(c);
      }
    }
    if (quote != null) {
      throw const FormatException('erreur de syntaxe : guillemet non fermé');
    }
    final t = buf.toString().trim();
    if (t.isNotEmpty) {
      result.add((conn, t));
    } else if (conn == '&&' || conn == '||') {
      throw const FormatException('erreur de syntaxe : commande attendue');
    }
    return result;
  }

  /// Analyse lexicale d'un segment, avec expansion des variables, de `~`
  /// et des substitutions de commande.
  List<_Tok> _lex(String s, int depth, StringBuffer subErr) {
    final toks = <_Tok>[];
    final buf = StringBuffer();
    var has = false, glob = false, quoted = false;
    void flush() {
      if (has) toks.add(_Tok(buf.toString(), glob: glob));
      buf.clear();
      has = false;
      glob = false;
      quoted = false;
    }

    int dollar(int i) {
      // s[i] == '$' ; retourne l'index suivant l'expression.
      final next = i + 1 < s.length ? s[i + 1] : '';
      if (next == '(') {
        var d = 1, j = i + 2;
        for (; j < s.length && d > 0; j++) {
          if (s[j] == '(') d++;
          if (s[j] == ')') d--;
        }
        if (d != 0) {
          throw const FormatException('erreur de syntaxe : « ) » manquante');
        }
        buf.write(_substitute(s.substring(i + 2, j - 1), depth, subErr));
        return j;
      }
      if (next == '{') {
        final end = s.indexOf('}', i + 2);
        if (end < 0) {
          throw const FormatException('erreur de syntaxe : « } » manquante');
        }
        buf.write(_var(s.substring(i + 2, end)));
        return end + 1;
      }
      if (next == '?') {
        buf.write(_var('?'));
        return i + 2;
      }
      final m = RegExp(
        r'^[A-Za-z_][A-Za-z0-9_]*',
      ).firstMatch(s.substring(i + 1));
      if (m == null) {
        buf.write(r'$');
        return i + 1;
      }
      buf.write(_var(m.group(0)!));
      return i + 1 + m.group(0)!.length;
    }

    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      final next = i + 1 < s.length ? s[i + 1] : '';
      if (c == "'") {
        final j = s.indexOf("'", i + 1);
        if (j < 0) {
          throw const FormatException(
            'erreur de syntaxe : apostrophe non fermée',
          );
        }
        buf.write(s.substring(i + 1, j));
        has = quoted = true;
        i = j;
        continue;
      }
      if (c == '"') {
        var j = i + 1;
        while (j < s.length && s[j] != '"') {
          if (s[j] == '\\' && j + 1 < s.length && r'"\$`'.contains(s[j + 1])) {
            buf.write(s[j + 1]);
            j += 2;
          } else if (s[j] == r'$') {
            j = dollar(j);
          } else {
            buf.write(s[j]);
            j++;
          }
        }
        if (j >= s.length) {
          throw const FormatException(
            'erreur de syntaxe : guillemet non fermé',
          );
        }
        has = quoted = true;
        i = j;
        continue;
      }
      if (c == '`') {
        final j = s.indexOf('`', i + 1);
        if (j < 0) {
          throw const FormatException('erreur de syntaxe : « ` » non fermé');
        }
        buf.write(_substitute(s.substring(i + 1, j), depth, subErr));
        has = true;
        i = j;
        continue;
      }
      if (c == '\\') {
        if (next.isNotEmpty) {
          buf.write(next);
          i++;
        }
        has = quoted = true;
        continue;
      }
      if (c == r'$') {
        i = dollar(i) - 1;
        has = true;
        continue;
      }
      if (c == ' ' || c == '\t') {
        flush();
        continue;
      }
      if (c == '>' || c == '<' || c == '|' || (c == '&' && next == '>')) {
        if (c == '>' && has && !quoted && buf.toString() == '2') {
          buf.clear();
          has = false;
          if (s.startsWith('>&1', i)) {
            toks.add(const _Tok('2>&1', op: true));
            i += 2;
          } else if (next == '>') {
            toks.add(const _Tok('2>>', op: true));
            i++;
          } else {
            toks.add(const _Tok('2>', op: true));
          }
          continue;
        }
        flush();
        if (c == '&') {
          toks.add(const _Tok('&>', op: true));
          i++;
        } else if (c == '>' && next == '>') {
          toks.add(const _Tok('>>', op: true));
          i++;
        } else {
          toks.add(_Tok(c, op: true));
        }
        continue;
      }
      if (c == '~' && !has && (next.isEmpty || next == '/' || next == ' ')) {
        buf.write(home);
        has = true;
        continue;
      }
      if (c == '*' || c == '?' || c == '[') glob = true;
      buf.write(c);
      has = true;
    }
    flush();
    return toks;
  }

  String _substitute(String inner, int depth, StringBuffer subErr) {
    if (depth >= _maxDepth) {
      subErr.writeln('bash: substitution trop imbriquée');
      return '';
    }
    final r = _runLine(inner, depth + 1, errSink: subErr);
    return r.text.replaceAll('\n', ' ').trim();
  }

  List<_Cmd> _parsePipeline(List<_Tok> toks) {
    final cmds = <_Cmd>[];
    var words = <_Tok>[];
    var redirs = <(String, String)>[];
    void end(String symbol) {
      if (words.isEmpty && redirs.isEmpty) {
        throw FormatException(
          'erreur de syntaxe près du symbole inattendu « $symbol »',
        );
      }
      cmds.add(_Cmd(words, redirs));
      words = [];
      redirs = [];
    }

    for (var i = 0; i < toks.length; i++) {
      final t = toks[i];
      if (!t.op) {
        words.add(t);
      } else if (t.text == '|') {
        end('|');
      } else if (t.text == '2>&1') {
        redirs.add(('2>&1', ''));
      } else {
        if (i + 1 >= toks.length || toks[i + 1].op) {
          throw const FormatException(
            'erreur de syntaxe près du symbole inattendu « newline »',
          );
        }
        redirs.add((t.text, toks[++i].text));
      }
    }
    if (words.isNotEmpty || redirs.isNotEmpty) {
      cmds.add(_Cmd(words, redirs));
    } else if (cmds.isNotEmpty) {
      throw const FormatException(
        'erreur de syntaxe près du symbole inattendu « | »',
      );
    }
    return cmds;
  }

  _Out _runPipeline(List<_Cmd> cmds, int depth) {
    String? stdin;
    final err = StringBuffer();
    var last = const _Out('', '', 0);
    for (var k = 0; k < cmds.length; k++) {
      final c = cmds[k];
      String? input = k == 0 ? null : stdin;
      var failed = false;
      for (final (op, target) in c.redirs) {
        if (op != '<') continue;
        try {
          input = fs.readFile(_abs(target), user);
        } on FsError catch (e) {
          err.writeln('bash: $target: ${e.message}');
          failed = true;
        }
      }
      if (failed) {
        last = const _Out('', '', 1);
        stdin = '';
        continue;
      }
      // Affectations seules : X=1
      final assign = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)=(.*)$', dotAll: true);
      if (c.words.isNotEmpty && c.words.every((w) => assign.hasMatch(w.text))) {
        for (final w in c.words) {
          final m = assign.firstMatch(w.text)!;
          _vars[m.group(1)!] = m.group(2)!;
        }
        last = const _Out('', '', 0);
        stdin = '';
        continue;
      }
      var words = c.words;
      while (words.isNotEmpty && assign.hasMatch(words.first.text)) {
        words = words.sublist(1); // VAR=1 commande : affectation ignorée
      }
      final args = _expandGlobs(words);
      final r = args.isEmpty
          ? const _Out('', '', 0)
          : _exec(args, input, depth);
      if (r.clear) return r;
      var outText = r.out, errText = r.err;
      for (final (op, target) in c.redirs) {
        switch (op) {
          case '2>&1':
            outText = _joinText(outText, errText);
            errText = '';
          case '2>' || '2>>':
            if (target != '/dev/null' && errText.isNotEmpty) {
              final e = _writeRedirect(target, errText, append: op == '2>>');
              if (e != null) err.writeln(e);
            }
            errText = '';
          case '&>':
            final e = _writeRedirect(target, _joinText(outText, errText));
            if (e != null) err.writeln(e);
            outText = errText = '';
          case '>' || '>>':
            final e = _writeRedirect(target, outText, append: op == '>>');
            if (e != null) {
              err.writeln(e);
              last = _Out('', '', 1);
            }
            outText = '';
        }
      }
      if (errText.isNotEmpty) err.writeln(_strip(errText));
      stdin = outText;
      last = _Out(outText, '', r.code);
    }
    return _Out(last.out, err.toString(), last.code);
  }

  String? _writeRedirect(String target, String text, {bool append = false}) {
    if (target == '/dev/null') return null;
    final t = _strip(text);
    try {
      fs.writeFile(_abs(target), t.isEmpty ? '' : '$t\n', user, append: append);
      return null;
    } on FsError catch (e) {
      return 'bash: $target: ${e.message}';
    }
  }

  // ============================================================ Jokers

  List<String> _expandGlobs(List<_Tok> words) {
    final out = <String>[];
    for (final w in words) {
      out.addAll(w.glob ? _glob(w.text) : [w.text]);
    }
    return out;
  }

  static RegExp globToRegExp(String pattern, {bool caseInsensitive = false}) {
    final b = StringBuffer('^');
    for (var i = 0; i < pattern.length; i++) {
      final c = pattern[i];
      if (c == '*') {
        b.write('[^/]*');
      } else if (c == '?') {
        b.write('[^/]');
      } else if (c == '[') {
        final end = pattern.indexOf(']', i + 1);
        if (end < 0) {
          b.write(r'\[');
        } else {
          var cls = pattern.substring(i + 1, end);
          if (cls.startsWith('!')) cls = '^${cls.substring(1)}';
          b.write('[${cls.replaceAll(r'\', r'\\')}]');
          i = end;
        }
      } else {
        b.write(RegExp.escape(c));
      }
    }
    b.write(r'$');
    return RegExp(b.toString(), caseSensitive: !caseInsensitive);
  }

  /// Jokers dans le dernier élément du chemin (`*.log`, `logs/*`, `/etc/*`).
  List<String> _glob(String word) {
    final slash = word.lastIndexOf('/');
    final dirPart = slash < 0 ? '' : word.substring(0, slash + 1);
    final pattern = slash < 0 ? word : word.substring(slash + 1);
    if (RegExp(r'[*?\[]').hasMatch(dirPart) || pattern.isEmpty) return [word];
    final dirAbs = _abs(dirPart.isEmpty ? '.' : dirPart);
    final dir = fs.lookup(dirAbs);
    if (dir == null ||
        !dir.isDir ||
        !VirtualFs.canRead(dir, user) ||
        !VirtualFs.canExec(dir, user)) {
      return [word];
    }
    final re = globToRegExp(pattern);
    final names =
        dir.children.keys
            .where((n) => !n.startsWith('.') || pattern.startsWith('.'))
            .where(re.hasMatch)
            .toList()
          ..sort();
    return names.isEmpty ? [word] : [for (final n in names) '$dirPart$n'];
  }

  // ======================================================== Utilitaires

  String _abs(String p) => VirtualFs.resolve(p, cwd, home);

  static String _strip(String s) {
    var e = s.length;
    while (e > 0 && (s[e - 1] == '\n' || s[e - 1] == '\r')) {
      e--;
    }
    return s.substring(0, e);
  }

  static String _joinText(String a, String b) {
    final x = _strip(a), y = _strip(b);
    if (x.isEmpty) return y;
    if (y.isEmpty) return x;
    return '$x\n$y';
  }

  /// Lignes d'un contenu (sans la ligne vide finale).
  static List<String> _lines(String content) {
    if (content.isEmpty) return [];
    final t = content.endsWith('\n')
        ? content.substring(0, content.length - 1)
        : content;
    return t.split('\n');
  }

  /// Contenu « fichier » d'une entrée standard (terminé par un saut de ligne).
  static String _asContent(String stdin) =>
      stdin.isEmpty ? '' : '${_strip(stdin)}\n';

  static _Out _ok(String out) => _Out(out, '', 0);
  static _Out _fail(String err, [int code = 1]) => _Out('', err, code);

  /// Sépare options courtes (`-abc`, `-n 5`) et arguments.
  static ({Set<String> flags, Map<String, String> values, List<String> rest})
  _opts(List<String> args, {Set<String> withValue = const {}}) {
    final flags = <String>{};
    final values = <String, String>{};
    final rest = <String>[];
    var onlyArgs = false;
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      if (onlyArgs || a == '-' || !a.startsWith('-')) {
        rest.add(a);
        continue;
      }
      if (a == '--') {
        onlyArgs = true;
        continue;
      }
      if (a.startsWith('--')) {
        flags.add(a);
        continue;
      }
      for (var j = 1; j < a.length; j++) {
        final f = a[j];
        if (withValue.contains(f)) {
          final v = j + 1 < a.length
              ? a.substring(j + 1)
              : (i + 1 < args.length ? args[++i] : '');
          values[f] = v;
          break;
        }
        flags.add(f);
      }
    }
    return (flags: flags, values: values, rest: rest);
  }

  /// Entrées d'un filtre : fichiers nommés, ou l'entrée standard.
  ({List<(String, String)> inputs, String err}) _inputs(
    String cmd,
    List<String> files,
    String? stdin,
  ) {
    if (files.isEmpty || (files.length == 1 && files.first == '-')) {
      return (inputs: [('', _asContent(stdin ?? ''))], err: '');
    }
    final inputs = <(String, String)>[];
    final err = StringBuffer();
    String? hint;
    for (final f in files) {
      try {
        inputs.add((f, fs.readFile(_abs(f), user)));
      } on FsError catch (e) {
        err.writeln('$cmd: $f: ${e.message}');
        if (e.message == VirtualFs.noSuchFile && hint == null) {
          final h = _whereHint(f);
          if (h.isNotEmpty) hint = h.substring(1);
        }
      }
    }
    if (hint != null) err.writeln(hint);
    return (inputs: inputs, err: err.toString());
  }

  static const _months = [
    'janv.', 'févr.', 'mars', 'avril', 'mai', 'juin', //
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static String _modeString(VNode n) {
    final b = StringBuffer(n.isDir ? 'd' : '-');
    for (final shift in [6, 3, 0]) {
      final v = (n.mode >> shift) & 7;
      b
        ..write(v & 4 != 0 ? 'r' : '-')
        ..write(v & 2 != 0 ? 'w' : '-')
        ..write(v & 1 != 0 ? 'x' : '-');
    }
    return b.toString();
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _longLine(VNode n, String name) {
    final t = n.mtime;
    final date =
        '${_months[t.month - 1].padRight(5)} ${t.day.toString().padLeft(2)} '
        '${_two(t.hour)}:${_two(t.minute)}';
    return '${_modeString(n)} ${n.isDir ? 2 : 1} ${n.owner.padRight(8)} '
        '${n.owner.padRight(8)} ${n.size.toString().padLeft(5)} $date $name';
  }

  // ========================================================== Commandes

  static const _builtins = {
    'help',
    'pwd',
    'cd',
    'ls',
    'cat',
    'less',
    'more',
    'head',
    'tail',
    'grep',
    'wc',
    'sort',
    'uniq',
    'cut',
    'awk',
    'sed',
    'echo',
    'printf',
    'touch',
    'mkdir',
    'rmdir',
    'rm',
    'cp',
    'mv',
    'find',
    'tree',
    'chmod',
    'chown',
    'file',
    'stat',
    'whoami',
    'id',
    'groups',
    'history',
    'which',
    'man',
    'clear',
    'date',
    'uname',
    'hostname',
    'ifconfig',
    'ip',
    'ping',
    'nmap',
    'ps',
    'df',
    'free',
    'curl',
    'wget',
    'ssh',
    'docker',
    'apt',
    'sudo',
    'su',
    'exit',
    'env',
    'printenv',
    'export',
    'base64',
    'true',
    'false',
    'labreset',
    'bash',
    'sh',
    'nano',
    'vi',
    'vim',
  };

  _Out _exec(List<String> args, String? stdin, int depth) {
    var name = args.first;
    var rest = args.sublist(1);
    switch (name) {
      case 'll':
        name = 'ls';
        rest = ['-la', ...rest];
      case 'la':
        name = 'ls';
        rest = ['-a', ...rest];
    }
    if (name.contains('/')) {
      return _runScript(name, depth, direct: true);
    }
    switch (name) {
      case 'help':
        return _ok(_help);
      case 'pwd':
        return _ok(cwd);
      case 'cd':
        return _cd(rest);
      case 'ls':
        return _ls(rest);
      case 'cat' || 'less' || 'more':
        return _cat(name, rest, stdin);
      case 'head' || 'tail':
        return _headTail(name, rest, stdin);
      case 'grep':
        return _grep(rest, stdin);
      case 'wc':
        return _wc(rest, stdin);
      case 'sort':
        return _sort(rest, stdin);
      case 'uniq':
        return _uniq(rest, stdin);
      case 'cut':
        return _cut(rest, stdin);
      case 'awk':
        return _awk(rest, stdin);
      case 'sed':
        return _sed(rest, stdin);
      case 'echo':
        return _echo(rest);
      case 'printf':
        return _ok(
          rest.isEmpty
              ? ''
              : rest.first.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t'),
        );
      case 'touch':
        return _touch(rest);
      case 'mkdir':
        return _mkdir(rest);
      case 'rmdir':
        return _rmdir(rest);
      case 'rm':
        return _rm(rest);
      case 'cp' || 'mv':
        return _cpMv(name, rest);
      case 'find':
        return _find(rest, depth);
      case 'tree':
        return _tree(rest);
      case 'chmod':
        return _chmod(rest);
      case 'chown':
        return _chown(rest);
      case 'file':
        return _file(rest);
      case 'stat':
        return _stat(rest);
      case 'whoami':
        return _ok(user);
      case 'id':
        return _ok(
          user == 'root'
              ? 'uid=0(root) gid=0(root) groupes=0(root)'
              : 'uid=1000(learner) gid=1000(learner) groupes=1000(learner),27(sudo)',
        );
      case 'groups':
        return _ok(user == 'root' ? 'root' : 'learner sudo');
      case 'history':
        return _ok(
          [
            for (var i = 0; i < history.length; i++)
              '${(i + 1).toString().padLeft(5)}  ${history[i]}',
          ].join('\n'),
        );
      case 'which':
        final found = rest.where(_builtins.contains).toList();
        return _Out(
          found.map((c) => '/usr/bin/$c').join('\n'),
          '',
          found.length == rest.length && rest.isNotEmpty ? 0 : 1,
        );
      case 'man':
        return _ok(_man(rest));
      case 'clear':
        return const _Out('', '', 0, clear: true);
      case 'date':
        return _ok(_date());
      case 'uname':
        return _ok(
          rest.contains('-a')
              ? 'Linux $host 6.1.0-cyber #1 SMP x86_64 GNU/Linux'
              : 'Linux',
        );
      case 'hostname':
        return _ok(host);
      case 'ifconfig' || 'ip':
        return _ok(_network);
      case 'ping':
        return _ok(_ping(rest));
      case 'nmap':
        return _ok(_nmap(rest));
      case 'ps':
        return _ok(_ps(rest));
      case 'df':
        return _ok(
          'Sys. de fichiers blocs de 1K   Utilisé Disponible Uti% Monté sur\n'
          '/dev/vda1          20480000   8543210   11936790  42% /',
        );
      case 'free':
        return _ok(
          '              total       utilisé      libre     tampon/cache\n'
          'Mem:        2097152        890112     500000          707040',
        );
      case 'curl' || 'wget':
        return _ok(_http(rest));
      case 'ssh':
        return _ok(
          '(simulation) Connexion SSH simulée vers '
          '${rest.isNotEmpty ? rest.last : "hôte"}\n'
          '>>>  En réel, SSH se connecte à une vraie machine : uniquement '
          'avec autorisation.',
        );
      case 'docker':
        return _ok(_docker(rest));
      case 'apt' || 'apt-get':
        return _ok(
          '(simulation) apt ${rest.join(' ')}\n'
          '>>>  En réel, apt installe des paquets sur Debian/Ubuntu '
          '(ex. sudo apt install nmap).\n'
          '>>>  Aucun paquet n\'est installé dans ce terminal simulé.',
        );
      case 'sudo':
        return _sudo(rest, stdin, depth);
      case 'su':
        return _fail(
          'su : Échec de l\'authentification (simulation : utilisez '
          '« sudo -i » pour devenir root)',
        );
      case 'exit' || 'logout':
        if (user == 'root') {
          user = 'learner';
          if (cwd == '/root' || cwd.startsWith('/root/')) cwd = learnerHome;
          return _ok('déconnexion (retour à learner)');
        }
        return _ok(
          '(simulation) La session reste ouverte : quittez l\'écran pour '
          'fermer le terminal.',
        );
      case 'env' || 'printenv':
        if (rest.isNotEmpty && name == 'printenv') {
          return _ok(rest.map(_var).join('\n'));
        }
        final all = {
          ..._vars,
          'HOME': home,
          'USER': user,
          'PWD': cwd,
          'HOSTNAME': host,
        };
        final keys = all.keys.toList()..sort();
        return _ok(keys.map((k) => '$k=${all[k]}').join('\n'));
      case 'export':
        for (final a in rest) {
          final eq = a.indexOf('=');
          if (eq > 0) _vars[a.substring(0, eq)] = a.substring(eq + 1);
        }
        return _ok('');
      case 'base64':
        return _base64(rest, stdin);
      case 'true':
        return _ok('');
      case 'false':
        return const _Out('', '', 1);
      case 'labreset':
        fs.reset();
        _resetSession();
        _attempts.clear();
        return _ok(
          'Lab réinitialisé : fichiers d\'origine restaurés, retour dans '
          '$learnerHome en tant que learner.',
        );
      case 'bash' || 'sh':
        if (rest.isEmpty) {
          return _ok('(simulation) Vous êtes déjà dans un shell bash.');
        }
        if (rest.first == '-c') {
          if (rest.length < 2) {
            return _fail('bash: -c : option requiert un argument', 2);
          }
          final r = _runLine(rest[1], depth + 1);
          return _Out(r.text, '', r.code);
        }
        return _runScript(rest.first, depth, direct: false);
      case 'nano' || 'vi' || 'vim':
        return _ok(
          '(simulation) Éditeur indisponible dans ce terminal.\n'
          'Pour écrire : echo "texte" > fichier   (remplace)\n'
          '              echo "texte" >> fichier  (ajoute à la fin)',
        );
      default:
        return _fail(
          'bash: $name : commande introuvable\n'
          'Tapez « help » pour voir les commandes disponibles.',
          127,
        );
    }
  }

  static const _help = '''
Terminal Linux simulé : les commandes agissent sur un système de fichiers
VIRTUEL (rien n'est exécuté sur votre appareil).

Fichiers   : pwd  cd  ls [-la]  cat  head  tail  touch  mkdir [-p]  rmdir
             rm [-r]  cp [-r]  mv  find  tree  file  stat  chmod  chown
Texte      : grep [-ivncloEr]  wc [-lwc]  sort [-rnu]  uniq [-c]  cut -d -f
             awk '{print \$1}'  sed 's/a/b/g'  echo  base64 [-d]
Système    : whoami  id  ps  df  free  uname  date  env  history  sudo
Réseau     : ifconfig  ping  nmap  curl  ssh  (simulés)
Shell      : |  >  >>  <  2>/dev/null  ;  &&  ||  \$VAR  \$(cmd)  *.log
Scripts    : bash script.sh  ou  ./script.sh (après chmod +x)
Lab        : labreset (restaure les fichiers d'origine)  clear  help
             man <commande>

À explorer : ~/notes.txt, ~/logs/auth.log, ~/logs/access.log, /etc/passwd,
/var/log (avec sudo), ~/scripts. Exemple :
  grep "Failed password" ~/logs/auth.log | wc -l''';

  // --------------------------------------------------------- Fichiers

  _Out _cd(List<String> rest) {
    final target = rest.isEmpty ? home : rest.first;
    if (target == '-') {
      final prev = _vars['OLDPWD'] ?? cwd;
      _vars['OLDPWD'] = cwd;
      cwd = prev;
      return _ok(cwd);
    }
    final abs = _abs(target);
    try {
      final n = fs.existing(abs, user);
      if (!n.isDir) return _fail('bash: cd: $target: ${VirtualFs.notADir}');
      if (!VirtualFs.canExec(n, user)) {
        return _fail('bash: cd: $target: ${VirtualFs.denied}');
      }
    } on FsError catch (e) {
      return _fail(
        'bash: cd: $target: ${e.message}'
        '${e.message == VirtualFs.noSuchFile ? _whereHint(target) : ''}',
      );
    }
    _vars['OLDPWD'] = cwd;
    cwd = abs;
    return _ok('');
  }

  _Out _ls(List<String> args) {
    final o = _opts(args);
    final all = o.flags.contains('a') || o.flags.contains('A');
    final long = o.flags.contains('l');
    final targets = o.rest.isEmpty ? ['.'] : o.rest;
    final out = <String>[];
    final err = StringBuffer();
    final files = <String>[];
    final dirs = <String>[];
    for (final t in targets) {
      try {
        final n = fs.existing(_abs(t), user);
        (n.isDir ? dirs : files).add(t);
      } on FsError catch (e) {
        err.writeln('ls: impossible d\'accéder à \'$t\': ${e.message}');
      }
    }
    if (long) {
      for (final f in files) {
        out.add(_longLine(fs.lookup(_abs(f))!, f));
      }
    } else if (files.isNotEmpty) {
      out.add(files.join('  '));
    }
    for (final d in dirs) {
      final n = fs.lookup(_abs(d))!;
      if (!VirtualFs.canRead(n, user)) {
        err.writeln(
          'ls: impossible d\'ouvrir le répertoire \'$d\': ${VirtualFs.denied}',
        );
        continue;
      }
      if (targets.length > 1) out.add('${out.isEmpty ? '' : '\n'}$d:');
      final names =
          n.children.keys.where((k) => all || !k.startsWith('.')).toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (long) {
        out.add('total ${names.length * 4}');
        if (all) {
          out.add(_longLine(n, '.'));
          out.add(_longLine(fs.lookup(VirtualFs.parentOf(_abs(d)))!, '..'));
        }
        for (final k in names) {
          out.add(_longLine(n.children[k]!, k));
        }
      } else {
        final shown = [
          if (all) ...['./', '../'],
          for (final k in names) n.children[k]!.isDir ? '$k/' : k,
        ];
        if (shown.isNotEmpty) out.add(shown.join('  '));
      }
    }
    return _Out(out.join('\n'), err.toString(), err.isEmpty ? 0 : 2);
  }

  _Out _cat(String cmd, List<String> args, String? stdin) {
    final o = _opts(args);
    final res = _inputs(cmd, o.rest, stdin);
    final buf = StringBuffer();
    var n = 0;
    for (final (_, content) in res.inputs) {
      for (final line in _lines(content)) {
        if (o.flags.contains('n')) {
          buf.writeln('${(++n).toString().padLeft(6)}\t$line');
        } else {
          buf.writeln(line);
        }
      }
    }
    return _Out(_strip(buf.toString()), res.err, res.err.isEmpty ? 0 : 1);
  }

  _Out _headTail(String cmd, List<String> args, String? stdin) {
    // -5 équivaut à -n 5
    final norm = [
      for (final a in args)
        RegExp(r'^-\d+$').hasMatch(a) ? '-n${a.substring(1)}' : a,
    ];
    final o = _opts(norm, withValue: {'n'});
    final spec = o.values['n'] ?? '10';
    final fromStart = cmd == 'tail' && spec.startsWith('+');
    final count = int.tryParse(spec.replaceFirst('+', ''));
    if (count == null) {
      return _fail('$cmd: nombre de lignes incorrect: « $spec »');
    }
    final res = _inputs(cmd, o.rest, stdin);
    final out = <String>[];
    for (final (name, content) in res.inputs) {
      final lines = _lines(content);
      if (res.inputs.length > 1) {
        out.add('${out.isEmpty ? '' : '\n'}==> $name <==');
      }
      if (cmd == 'head') {
        out.addAll(lines.take(count));
      } else if (fromStart) {
        out.addAll(lines.skip(count > 0 ? count - 1 : 0));
      } else {
        out.addAll(lines.skip(lines.length > count ? lines.length - count : 0));
      }
    }
    if (cmd == 'tail' && o.flags.contains('f')) {
      out.add(
        '(simulation) tail -f suivrait le fichier en continu (Ctrl+C pour arrêter).',
      );
    }
    return _Out(out.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  _Out _grep(List<String> args, String? stdin) {
    final o = _opts(args, withValue: {'e'});
    final rest = List.of(o.rest);
    final pattern = o.values['e'] ?? (rest.isEmpty ? null : rest.removeAt(0));
    if (pattern == null) {
      return _fail('Utilisation : grep [OPTION]... MOTIF [FICHIER]...', 2);
    }
    final f = o.flags;
    var source = f.contains('E') ? pattern : _bre(pattern);
    if (f.contains('w')) source = r'\b(?:' + source + r')\b';
    final RegExp re;
    try {
      re = RegExp(source, caseSensitive: !f.contains('i'));
    } on FormatException {
      return _fail('grep: expression régulière incorrecte', 2);
    }
    final recursive = f.contains('r') || f.contains('R');
    final err = StringBuffer();
    final inputs = <(String, String)>[];
    if (rest.isEmpty && !recursive) {
      inputs.add(('', _asContent(stdin ?? '')));
    } else {
      for (final t in rest.isEmpty ? ['.'] : rest) {
        final abs = _abs(t);
        try {
          final n = fs.existing(abs, user);
          if (n.isDir) {
            if (!recursive) {
              err.writeln('grep: $t: ${VirtualFs.isADir}');
              continue;
            }
            for (final (p, node) in fs.walk(abs, user)) {
              if (node.isDir || !VirtualFs.canRead(node, user)) continue;
              final rel = p == abs
                  ? t
                  : '${t == '/' ? '' : t}${p.substring(abs == '/' ? 0 : abs.length)}';
              inputs.add((rel, node.content));
            }
          } else {
            inputs.add((t, fs.readFile(abs, user)));
          }
        } on FsError catch (e) {
          err.writeln('grep: $t: ${e.message}');
        }
      }
    }
    final prefix = inputs.length > 1 || recursive;
    final out = <String>[];
    var any = false;
    for (final (name, content) in inputs) {
      var count = 0;
      final lines = _lines(content);
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final hit = re.hasMatch(line) != f.contains('v');
        if (!hit) continue;
        count++;
        any = true;
        if (f.contains('c') || f.contains('l') || f.contains('q')) continue;
        final head =
            '${prefix ? '$name:' : ''}${f.contains('n') ? '${i + 1}:' : ''}';
        if (f.contains('o') && !f.contains('v')) {
          for (final m in re.allMatches(line)) {
            out.add('$head${m.group(0)}');
          }
        } else {
          out.add('$head$line');
        }
      }
      if (f.contains('c')) out.add('${prefix ? '$name:' : ''}$count');
      if (f.contains('l') && count > 0) {
        out.add(name.isEmpty ? '(entrée standard)' : name);
      }
    }
    if (f.contains('q')) out.clear();
    final code = err.isNotEmpty && !any ? 2 : (any ? 0 : 1);
    return _Out(out.join('\n'), err.toString(), code);
  }

  /// Expression régulière « basique » (BRE) vers RegExp : `+ ? | ( ) { }`
  /// sont littéraux, sauf précédés d'un antislash (extension GNU).
  static String _bre(String p) {
    const special = '+?|(){}';
    final b = StringBuffer();
    for (var i = 0; i < p.length; i++) {
      final c = p[i];
      if (c == '\\' && i + 1 < p.length && special.contains(p[i + 1])) {
        b.write(p[i + 1]);
        i++;
      } else if (special.contains(c)) {
        b.write('\\$c');
      } else {
        b.write(c);
        if (c == '\\' && i + 1 < p.length) {
          b.write(p[i + 1]);
          i++;
        }
      }
    }
    return b.toString();
  }

  _Out _wc(List<String> args, String? stdin) {
    final o = _opts(args);
    var flags = ['l', 'w', 'c'].where(o.flags.contains).toList();
    if (flags.isEmpty) flags = ['l', 'w', 'c'];
    final res = _inputs('wc', o.rest, stdin);
    final rows = <(List<int>, String)>[];
    final total = [0, 0, 0];
    for (final (name, content) in res.inputs) {
      final counts = [
        '\n'.allMatches(content).length,
        content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
        utf8.encode(content).length,
      ];
      for (var i = 0; i < 3; i++) {
        total[i] += counts[i];
      }
      rows.add((counts, name));
    }
    if (rows.length > 1) rows.add((total, 'total'));
    final idx = flags.map((f) => 'lwc'.indexOf(f)).toList();
    final width = flags.length == 1 && rows.length == 1
        ? 0
        : rows
              .expand((r) => idx.map((i) => '${r.$1[i]}'.length))
              .fold(1, (a, b) => a > b ? a : b);
    final out = [
      for (final (counts, name) in rows)
        [
          for (final i in idx) '${counts[i]}'.padLeft(width),
          if (name.isNotEmpty) name,
        ].join(' '),
    ];
    return _Out(out.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  _Out _sort(List<String> args, String? stdin) {
    final o = _opts(args, withValue: {'k', 't'});
    final res = _inputs('sort', o.rest, stdin);
    final lines = [for (final (_, c) in res.inputs) ..._lines(c)];
    final key = int.tryParse((o.values['k'] ?? '').split(',').first);
    final sep = o.values['t'];
    String keyOf(String l) {
      if (key == null) return l;
      final fields = sep == null
          ? l.trim().split(RegExp(r'\s+'))
          : l.split(sep);
      return key - 1 < fields.length ? fields.sublist(key - 1).join(' ') : '';
    }

    num numOf(String l) =>
        num.tryParse(
          RegExp(r'^\s*-?\d+(\.\d+)?').stringMatch(keyOf(l))?.trim() ?? '',
        ) ??
        0;
    if (o.flags.contains('n')) {
      lines.sort((a, b) => numOf(a).compareTo(numOf(b)));
    } else {
      lines.sort((a, b) => keyOf(a).compareTo(keyOf(b)));
    }
    var result = o.flags.contains('r') ? lines.reversed.toList() : lines;
    if (o.flags.contains('u')) {
      final seen = <String>{};
      result = result.where(seen.add).toList();
    }
    return _Out(result.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  _Out _uniq(List<String> args, String? stdin) {
    final o = _opts(args);
    final res = _inputs('uniq', o.rest.take(1).toList(), stdin);
    final lines = [for (final (_, c) in res.inputs) ..._lines(c)];
    final groups = <(String, int)>[];
    for (final l in lines) {
      if (groups.isNotEmpty && groups.last.$1 == l) {
        groups[groups.length - 1] = (l, groups.last.$2 + 1);
      } else {
        groups.add((l, 1));
      }
    }
    final out = [
      for (final (l, n) in groups)
        if (!o.flags.contains('d') || n > 1)
          if (!o.flags.contains('u') || n == 1)
            o.flags.contains('c') ? '${n.toString().padLeft(7)} $l' : l,
    ];
    return _Out(out.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  /// Liste de positions `1,3`, `2-4`, `3-`, `-2` (base 1).
  static bool Function(int) _ranges(String spec) {
    final parts = spec.split(',').map((p) {
      final m = RegExp(r'^(\d*)(-?)(\d*)$').firstMatch(p.trim());
      if (m == null) throw const FormatException('liste incorrecte');
      final a = int.tryParse(m.group(1)!), b = int.tryParse(m.group(3)!);
      if (m.group(2)!.isEmpty) {
        if (a == null) throw const FormatException('liste incorrecte');
        return (a, a);
      }
      return (a ?? 1, b ?? 1 << 30);
    }).toList();
    return (i) => parts.any((r) => i >= r.$1 && i <= r.$2);
  }

  _Out _cut(List<String> args, String? stdin) {
    final o = _opts(args, withValue: {'d', 'f', 'c'});
    final delim = o.values['d'] ?? '\t';
    if (delim.length != 1) {
      return _fail('cut: le délimiteur doit être un seul caractère');
    }
    final spec = o.values['f'] ?? o.values['c'];
    if (spec == null) {
      return _fail(
        'cut: vous devez spécifier une liste de champs (-f) ou de caractères (-c)',
      );
    }
    final bool Function(int) keep;
    try {
      keep = _ranges(spec);
    } on FormatException {
      return _fail('cut: liste de positions incorrecte: « $spec »');
    }
    final res = _inputs('cut', o.rest, stdin);
    final out = <String>[];
    for (final (_, content) in res.inputs) {
      for (final line in _lines(content)) {
        if (o.values.containsKey('c')) {
          final chars = line.split('');
          out.add(
            [
              for (var i = 0; i < chars.length; i++)
                if (keep(i + 1)) chars[i],
            ].join(),
          );
        } else if (!line.contains(delim)) {
          out.add(line);
        } else {
          final fields = line.split(delim);
          out.add(
            [
              for (var i = 0; i < fields.length; i++)
                if (keep(i + 1)) fields[i],
            ].join(delim),
          );
        }
      }
    }
    return _Out(out.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  /// awk simplifié : `[-F sep] '[/motif/] {print $1, $NF, "texte"}'`.
  _Out _awk(List<String> args, String? stdin) {
    final o = _opts(args, withValue: {'F'});
    if (o.rest.isEmpty) {
      return _fail('Utilisation : awk [-F sep] \'{print \$1}\' [fichier]', 2);
    }
    final prog = o.rest.first;
    final m = RegExp(
      r'^\s*(?:/(.*)/)?\s*(?:\{\s*print\s*(.*?)\s*\})?\s*$',
    ).firstMatch(prog);
    if (m == null || (m.group(1) == null && m.group(2) == null)) {
      return _fail(
        '(simulation) awk : seules les formes \'{print \$1}\', '
        '\'/motif/\' et \'/motif/ {print \$2, \$NF}\' sont prises en charge ici.',
        2,
      );
    }
    final RegExp? filter;
    try {
      filter = m.group(1) == null ? null : RegExp(m.group(1)!);
    } on FormatException {
      return _fail('awk: expression régulière incorrecte', 2);
    }
    final items = (m.group(2) ?? r'$0')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final sep = o.values['F'];
    final res = _inputs('awk', o.rest.sublist(1), stdin);
    final out = <String>[];
    for (final (_, content) in res.inputs) {
      for (final line in _lines(content)) {
        if (filter != null && !filter.hasMatch(line)) continue;
        final fields = sep == null
            ? line
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((s) => s.isNotEmpty)
                  .toList()
            : line.split(sep);
        String value(String item) {
          if (item.startsWith('"') && item.endsWith('"') && item.length >= 2) {
            return item.substring(1, item.length - 1);
          }
          if (item == r'$0') return line;
          if (item == r'$NF') return fields.isEmpty ? '' : fields.last;
          if (item == 'NF') return '${fields.length}';
          final n = int.tryParse(item.replaceFirst(r'$', ''));
          if (item.startsWith(r'$') && n != null) {
            return n >= 1 && n <= fields.length ? fields[n - 1] : '';
          }
          return item;
        }

        out.add(items.map(value).join(' '));
      }
    }
    return _Out(out.join('\n'), res.err, res.err.isEmpty ? 0 : 1);
  }

  /// sed simplifié : substitution `s/motif/remplacement/[g]` (séparateur
  /// libre) et suppression de lignes `/motif/d`.
  _Out _sed(List<String> args, String? stdin) {
    final o = _opts(args, withValue: {'e'});
    final rest = List.of(o.rest);
    final script = o.values['e'] ?? (rest.isEmpty ? null : rest.removeAt(0));
    if (script == null) {
      return _fail('Utilisation : sed \'s/ancien/nouveau/g\' [fichier]', 1);
    }
    final res = _inputs('sed', rest, stdin);
    final lines = [for (final (_, c) in res.inputs) ..._lines(c)];
    final del = RegExp(r'^/(.*)/d$').firstMatch(script);
    if (del != null) {
      final RegExp re;
      try {
        re = RegExp(_bre(del.group(1)!));
      } on FormatException {
        return _fail('sed: expression régulière incorrecte');
      }
      return _Out(lines.where((l) => !re.hasMatch(l)).join('\n'), res.err, 0);
    }
    if (script.length < 4 || script[0] != 's') {
      return _fail(
        '(simulation) sed : seules les commandes \'s/ancien/nouveau/[g]\' et '
        '\'/motif/d\' sont prises en charge ici.',
      );
    }
    final sepChar = script[1];
    final parts = script.substring(2).split(sepChar);
    if (parts.length < 3) return _fail('sed: commande « s » inachevée');
    final RegExp re;
    try {
      re = RegExp(
        o.flags.contains('E') || o.flags.contains('r')
            ? parts[0]
            : _bre(parts[0]),
        caseSensitive: !parts[2].contains('I'),
      );
    } on FormatException {
      return _fail('sed: expression régulière incorrecte');
    }
    final global = parts[2].contains('g');
    String repl(Match m) => parts[1].replaceAllMapped(
      RegExp(r'\\(\d)|&'),
      (x) => x.group(0) == '&'
          ? m.group(0)!
          : (m.group(int.parse(x.group(1)!)) ?? ''),
    );
    final out = lines
        .map(
          (l) => global
              ? l.replaceAllMapped(re, repl)
              : l.replaceFirstMapped(re, repl),
        )
        .join('\n');
    if (o.flags.contains('i') && rest.isNotEmpty) {
      try {
        fs.writeFile(_abs(rest.first), out.isEmpty ? '' : '$out\n', user);
        return _ok('');
      } on FsError catch (e) {
        return _fail('sed: ${rest.first}: ${e.message}');
      }
    }
    return _Out(out, res.err, res.err.isEmpty ? 0 : 1);
  }

  _Out _echo(List<String> args) {
    var rest = args;
    var newline = true, escapes = false;
    while (rest.isNotEmpty && RegExp(r'^-[neE]+$').hasMatch(rest.first)) {
      if (rest.first.contains('n')) newline = false;
      if (rest.first.contains('e')) escapes = true;
      rest = rest.sublist(1);
    }
    var text = rest.join(' ');
    if (escapes) text = text.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t');
    return _ok(newline ? text : text);
  }

  _Out _touch(List<String> args) {
    final err = StringBuffer();
    for (final f in _opts(args).rest) {
      final abs = _abs(f);
      try {
        final n = fs.lookup(abs);
        if (n != null) {
          if (!VirtualFs.canWrite(n, user)) {
            throw const FsError(VirtualFs.denied);
          }
          n.mtime = DateTime.now();
        } else {
          fs.writeFile(abs, '', user);
        }
      } on FsError catch (e) {
        err.writeln('touch: impossible de faire un touch \'$f\': ${e.message}');
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _mkdir(List<String> args) {
    final o = _opts(args);
    if (o.rest.isEmpty) return _fail('mkdir: opérande manquant');
    final err = StringBuffer();
    for (final d in o.rest) {
      try {
        fs.makeDir(_abs(d), user, parents: o.flags.contains('p'));
      } on FsError catch (e) {
        err.writeln(
          'mkdir: impossible de créer le répertoire « $d »: ${e.message}',
        );
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _rmdir(List<String> args) {
    final err = StringBuffer();
    for (final d in _opts(args).rest) {
      try {
        final n = fs.existing(_abs(d), user);
        if (!n.isDir) throw const FsError(VirtualFs.notADir);
        if (n.children.isNotEmpty) {
          throw const FsError('Le dossier n\'est pas vide');
        }
        fs.remove(_abs(d), user);
      } on FsError catch (e) {
        err.writeln('rmdir: impossible de supprimer \'$d\': ${e.message}');
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _rm(List<String> args) {
    final o = _opts(args);
    final f = o.flags;
    final recursive =
        f.contains('r') || f.contains('R') || f.contains('--recursive');
    final force = f.contains('f') || f.contains('--force');
    if (o.rest.isEmpty) return force ? _ok('') : _fail('rm: opérande manquant');
    final err = StringBuffer();
    for (final p in o.rest) {
      final abs = _abs(p);
      if (abs == '/' && recursive) {
        if (!f.contains('--no-preserve-root')) {
          err.writeln(
            'rm: il est dangereux d\'opérer récursivement sur \'/\'\n'
            'rm: utilisez --no-preserve-root pour inhiber cette mesure de sécurité',
          );
          continue;
        }
        if (user != 'root') {
          err.writeln('rm: impossible de supprimer \'/\': ${VirtualFs.denied}');
          continue;
        }
        fs.root.children.clear();
        err.writeln(
          '(simulation) Le système de fichiers VIRTUEL a été entièrement '
          'effacé. Sur une vraie machine, ce serait irréversible. Tapez '
          '« labreset » pour tout restaurer.',
        );
        continue;
      }
      try {
        final n = fs.existing(abs, user);
        if (n.isDir && !recursive) {
          err.writeln(
            'rm: impossible de supprimer \'$p\': ${VirtualFs.isADir}',
          );
          continue;
        }
        if (n.isDir &&
            cwd.startsWith(abs) &&
            (cwd == abs || cwd.startsWith('$abs/'))) {
          cwd = VirtualFs.parentOf(abs);
        }
        fs.remove(abs, user);
      } on FsError catch (e) {
        if (force && e.message == VirtualFs.noSuchFile) continue;
        err.writeln('rm: impossible de supprimer \'$p\': ${e.message}');
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _cpMv(String cmd, List<String> args) {
    final o = _opts(args);
    if (o.rest.length < 2) {
      return _fail('$cmd: opérande de fichier cible manquant');
    }
    final sources = o.rest.sublist(0, o.rest.length - 1);
    final dest = o.rest.last;
    final destAbs = _abs(dest);
    final destNode = fs.lookup(destAbs);
    final intoDir = destNode != null && destNode.isDir;
    if (sources.length > 1 && !intoDir) {
      return _fail('$cmd: la cible \'$dest\' n\'est pas un répertoire');
    }
    final err = StringBuffer();
    for (final s in sources) {
      final srcAbs = _abs(s);
      try {
        final n = fs.existing(srcAbs, user);
        if (n.isDir &&
            cmd == 'cp' &&
            !(o.flags.contains('r') || o.flags.contains('R'))) {
          err.writeln('cp: -r non spécifié ; omission du répertoire \'$s\'');
          continue;
        }
        if (!VirtualFs.canRead(n, user)) throw const FsError(VirtualFs.denied);
        final target = intoDir
            ? VirtualFs.join(destAbs, VirtualFs.baseName(srcAbs))
            : destAbs;
        if (target == srcAbs || target.startsWith('$srcAbs/')) {
          err.writeln('$cmd: impossible de copier un répertoire dans lui-même');
          continue;
        }
        final existingTarget = fs.lookup(target);
        if (existingTarget != null && existingTarget.isDir) {
          throw const FsError(VirtualFs.isADir);
        }
        final copy = n.deepCopy();
        if (cmd == 'cp') {
          copy.owner = user;
          copy.mtime = DateTime.now();
        } else {
          fs.remove(srcAbs, user);
        }
        fs.put(target, copy, user);
      } on FsError catch (e) {
        err.writeln('$cmd: \'$s\': ${e.message}');
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _find(List<String> args, int depth) {
    final starts = <String>[];
    var i = 0;
    while (i < args.length &&
        !args[i].startsWith('-') &&
        args[i] != '!' &&
        args[i] != '(') {
      starts.add(args[i++]);
    }
    if (starts.isEmpty) starts.add('.');
    RegExp? name;
    String? type, owner;
    int? maxDepth;
    var delete = false;
    List<String>? exec;
    String next(String opt) {
      if (i >= args.length) {
        throw FormatException('find: argument manquant pour « $opt »');
      }
      return args[i++];
    }

    try {
      while (i < args.length) {
        final a = args[i++];
        switch (a) {
          case '-name':
            name = globToRegExp(next(a));
          case '-iname':
            name = globToRegExp(next(a), caseInsensitive: true);
          case '-type':
            type = next(a);
          case '-user':
            owner = next(a);
          case '-maxdepth':
            maxDepth = int.tryParse(next(a));
          case '-delete':
            delete = true;
          case '-print':
            break;
          case '-exec':
            exec = [];
            while (i < args.length && args[i] != ';' && args[i] != '+') {
              exec.add(args[i++]);
            }
            if (i >= args.length) {
              throw const FormatException(
                'find: argument manquant pour « -exec »',
              );
            }
            i++;
          default:
            return _fail('find: prédicat inconnu « $a »');
        }
      }
    } on FormatException catch (e) {
      return _fail(e.message);
    }
    final out = <String>[];
    final err = StringBuffer();
    final matches = <(String, String)>[];
    void visit(String abs, String shown, int level) {
      final n = fs.lookup(abs);
      if (n == null) return;
      final ok =
          (name == null || name.hasMatch(VirtualFs.baseName(abs))) &&
          (type == null || (type == 'd' ? n.isDir : !n.isDir)) &&
          (owner == null || n.owner == owner);
      if (ok) matches.add((abs, shown));
      if (!n.isDir || (maxDepth != null && level >= maxDepth)) return;
      if (!VirtualFs.canRead(n, user) || !VirtualFs.canExec(n, user)) {
        err.writeln('find: \'$shown\': ${VirtualFs.denied}');
        return;
      }
      final names = n.children.keys.toList()..sort();
      for (final c in names) {
        visit(
          VirtualFs.join(abs, c),
          shown.endsWith('/') ? '$shown$c' : '$shown/$c',
          level + 1,
        );
      }
    }

    for (final s in starts) {
      final abs = _abs(s);
      try {
        fs.existing(abs, user);
      } on FsError catch (e) {
        err.writeln('find: \'$s\': ${e.message}');
        continue;
      }
      visit(abs, s, 0);
    }
    if (delete) {
      for (final (abs, shown) in matches.reversed) {
        try {
          final n = fs.lookup(abs);
          if (n != null && n.isDir && n.children.isNotEmpty) {
            throw const FsError('Le dossier n\'est pas vide');
          }
          fs.remove(abs, user);
        } on FsError catch (e) {
          err.writeln('find: impossible de supprimer \'$shown\': ${e.message}');
        }
      }
    } else if (exec != null) {
      for (final (_, shown) in matches) {
        final cmd = [for (final w in exec) w == '{}' ? shown : w];
        if (cmd.isEmpty) break;
        final r = _exec(cmd, null, depth + 1);
        if (r.out.isNotEmpty) out.add(_strip(r.out));
        if (r.err.isNotEmpty) err.writeln(_strip(r.err));
      }
    } else {
      out.addAll(matches.map((m) => m.$2));
    }
    return _Out(out.join('\n'), err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _tree(List<String> args) {
    final target = _opts(args).rest.isEmpty ? '.' : _opts(args).rest.first;
    final abs = _abs(target);
    try {
      final n = fs.existing(abs, user);
      if (!n.isDir) return _ok(target);
    } on FsError catch (e) {
      return _fail('$target [${e.message}]');
    }
    final out = <String>[target];
    var dirs = 0, files = 0;
    void draw(VNode n, String prefix) {
      final names = n.children.keys.where((k) => !k.startsWith('.')).toList()
        ..sort();
      for (var i = 0; i < names.length; i++) {
        final last = i == names.length - 1;
        final c = n.children[names[i]]!;
        out.add(
          '$prefix${last ? '└── ' : '├── '}${names[i]}${c.isDir ? '/' : ''}',
        );
        if (c.isDir) {
          dirs++;
          if (VirtualFs.canRead(c, user) && VirtualFs.canExec(c, user)) {
            draw(c, '$prefix${last ? '    ' : '│   '}');
          }
        } else {
          files++;
        }
      }
    }

    draw(fs.lookup(abs)!, '');
    out.add('\n$dirs répertoire(s), $files fichier(s)');
    return _ok(out.join('\n'));
  }

  /// Mode octal (`755`) ou symbolique (`u+x`, `go-w`, `a=r`, `+x`).
  static int? applyMode(int mode, String spec) {
    if (RegExp(r'^[0-7]{3,4}$').hasMatch(spec)) {
      return int.parse(spec, radix: 8) & 511;
    }
    var m = mode;
    for (final clause in spec.split(',')) {
      final p = RegExp(r'^([ugoa]*)([+\-=])([rwx]*)$').firstMatch(clause);
      if (p == null) return null;
      final who = p.group(1)!.isEmpty ? 'a' : p.group(1)!;
      var bits = 0;
      for (final r in p.group(3)!.split('')) {
        bits |= switch (r) {
          'r' => 4,
          'w' => 2,
          _ => 1,
        };
      }
      var mask = 0, clear = 0;
      for (final w in who.split('')) {
        final shifts = switch (w) {
          'u' => [6],
          'g' => [3],
          'o' => [0],
          _ => [6, 3, 0],
        };
        for (final s in shifts) {
          mask |= bits << s;
          clear |= 7 << s;
        }
      }
      m = switch (p.group(2)!) {
        '+' => m | mask,
        '-' => m & ~mask,
        _ => (m & ~clear) | mask,
      };
    }
    return m & 511;
  }

  _Out _chmod(List<String> args) {
    final o = _opts(
      args.where((a) => !RegExp(r'^-[rwx]+$').hasMatch(a)).toList(),
    );
    // « chmod -x f » : le -x est un mode, pas une option.
    final modeArgs = args
        .where((a) => RegExp(r'^-[rwx]+$').hasMatch(a))
        .toList();
    final rest = [...modeArgs, ...o.rest];
    if (rest.length < 2) return _fail('chmod: opérande manquant');
    final spec = rest.first;
    final err = StringBuffer();
    for (final f in rest.sublist(1)) {
      final abs = _abs(f);
      try {
        fs.existing(abs, user);
      } on FsError catch (e) {
        err.writeln('chmod: impossible d\'accéder à \'$f\': ${e.message}');
        continue;
      }
      final targets = o.flags.contains('R')
          ? fs.walk(abs, user).toList()
          : [(abs, fs.lookup(abs)!)];
      for (final (_, n) in targets) {
        if (user != 'root' && n.owner != user) {
          err.writeln(
            'chmod: modification des droits de \'$f\': Opération non permise',
          );
          break;
        }
        final next = applyMode(n.mode, spec);
        if (next == null) return _fail('chmod: mode incorrect: « $spec »');
        n.mode = next;
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  static const _knownUsers = {
    'root',
    'learner',
    'www-data',
    'backup',
    'daemon',
    'sshd',
  };

  _Out _chown(List<String> args) {
    final o = _opts(args);
    if (o.rest.length < 2) return _fail('chown: opérande manquant');
    final owner = o.rest.first.split(':').first;
    if (!_knownUsers.contains(owner)) {
      return _fail('chown: utilisateur incorrect: « $owner »');
    }
    final err = StringBuffer();
    for (final f in o.rest.sublist(1)) {
      final abs = _abs(f);
      try {
        fs.existing(abs, user);
      } on FsError catch (e) {
        err.writeln('chown: impossible d\'accéder à \'$f\': ${e.message}');
        continue;
      }
      if (user != 'root') {
        err.writeln(
          'chown: modification du propriétaire de \'$f\': Opération non permise',
        );
        continue;
      }
      final targets = o.flags.contains('R')
          ? fs.walk(abs, user).toList()
          : [(abs, fs.lookup(abs)!)];
      for (final (_, n) in targets) {
        n.owner = owner;
      }
    }
    return _Out('', err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _file(List<String> args) {
    final out = <String>[];
    for (final f in _opts(args).rest) {
      final n = fs.lookup(_abs(f));
      final kind = n == null
          ? 'cannot open (Aucun fichier ou dossier de ce type)'
          : n.isDir
          ? 'directory'
          : n.content.isEmpty
          ? 'empty'
          : n.content.startsWith('%PDF')
          ? 'PDF document'
          : n.content.startsWith('#!/bin/bash')
          ? 'Bourne-Again shell script, ASCII text executable'
          : n.content.startsWith('<!DOCTYPE html')
          ? 'HTML document, ASCII text'
          : 'ASCII text';
      out.add('$f: $kind');
    }
    return _ok(out.join('\n'));
  }

  _Out _stat(List<String> args) {
    final out = <String>[];
    final err = StringBuffer();
    for (final f in _opts(args).rest) {
      try {
        final n = fs.existing(_abs(f), user);
        out.add(
          '  Fichier : $f\n'
          '   Taille : ${n.size}\t${n.isDir ? 'répertoire' : 'fichier'}\n'
          '   Accès : (0${(n.mode & 511).toRadixString(8)}/${_modeString(n)})  '
          'UID : (${n.owner})',
        );
      } on FsError catch (e) {
        err.writeln('stat: impossible d\'évaluer \'$f\': ${e.message}');
      }
    }
    return _Out(out.join('\n'), err.toString(), err.isEmpty ? 0 : 1);
  }

  _Out _base64(List<String> args, String? stdin) {
    final o = _opts(args);
    final res = _inputs('base64', o.rest, stdin);
    final text = res.inputs.map((e) => e.$2).join();
    if (o.flags.contains('d') || o.flags.contains('--decode')) {
      try {
        final cleaned = text.replaceAll(RegExp(r'\s'), '');
        return _Out(
          utf8.decode(base64.decode(cleaned), allowMalformed: true),
          res.err,
          0,
        );
      } on FormatException {
        return _fail('base64: entrée incorrecte');
      }
    }
    return _Out(
      base64.encode(utf8.encode(text)),
      res.err,
      res.err.isEmpty ? 0 : 1,
    );
  }

  _Out _sudo(List<String> rest, String? stdin, int depth) {
    if (rest.isEmpty) return _fail('utilisation : sudo commande');
    if (rest.first == '-l') {
      return _ok(
        'L\'utilisateur learner peut utiliser les commandes suivantes sur $host :\n'
        '    (ALL : ALL) ALL',
      );
    }
    var i = 0;
    var shell = false;
    while (i < rest.length && rest[i].startsWith('-')) {
      if (rest[i] == '-i' || rest[i] == '-s') shell = true;
      if (rest[i] == '-u' || rest[i] == '-g') i++;
      i++;
    }
    final cmd = rest.sublist(i < rest.length ? i : rest.length);
    final notice = user == 'root' || _sudoNoticeShown
        ? ''
        : '[sudo] Mot de passe de learner : ******** (simulation)\n';
    _sudoNoticeShown = true;
    if (shell ||
        (cmd.length == 1 && const {'su', 'bash', 'sh'}.contains(cmd.first)) ||
        (cmd.length == 2 && cmd.first == 'su' && cmd[1] == '-')) {
      user = 'root';
      cwd = '/root';
      return _Out(
        'Vous êtes root : tous les droits, donc prudence ! '
        'Tapez « exit » pour revenir à learner.',
        notice,
        0,
      );
    }
    if (cmd.isEmpty) return _fail('utilisation : sudo commande');
    final previous = user;
    user = 'root';
    try {
      final r = _exec(cmd, stdin, depth);
      return _Out(r.out, '$notice${r.err}', r.code, clear: r.clear);
    } finally {
      // « sudo -i » géré plus haut : ici root ne dure que la commande.
      user = previous;
    }
  }

  _Out _runScript(String path, int depth, {required bool direct}) {
    final abs = _abs(path);
    final VNode n;
    try {
      n = fs.existing(abs, user);
    } on FsError catch (e) {
      return _fail(
        'bash: $path: ${e.message}'
        '${e.message == VirtualFs.noSuchFile ? _whereHint(path) : ''}',
        127,
      );
    }
    if (n.isDir) return _fail('bash: $path: ${VirtualFs.isADir}', 126);
    if (direct && !VirtualFs.canExec(n, user)) {
      return _fail(
        'bash: $path: ${VirtualFs.denied}\n'
        '(astuce : rendez le script exécutable avec « chmod +x $path »)',
        126,
      );
    }
    if (!VirtualFs.canRead(n, user)) {
      return _fail('bash: $path: ${VirtualFs.denied}', 126);
    }
    if (depth >= _maxDepth) {
      return _fail('bash: $path : imbrication trop profonde');
    }
    final out = <String>[];
    var code = 0;
    for (final line in _lines(n.content)) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('#')) continue;
      final r = _runLine(t, depth + 1);
      if (r.text.isNotEmpty) out.add(r.text);
      code = r.code;
      if (r.blocked) break;
    }
    return _Out(out.join('\n'), '', code);
  }

  // ================================================ Simulations réseau

  String _date() {
    const days = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
    final d = DateTime.now();
    return '${days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year} '
        '${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';
  }

  static const _network = '''
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.42  netmask 255.255.255.0  broadcast 192.168.1.255
        ether 08:00:27:9a:3c:11  txqueuelen 1000
        RX packets 12847  bytes 1048291 (1.0 MB)
        TX packets 10122  bytes 912018 (912.0 KB)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0

Routes:
default via 192.168.1.1  dev eth0''';

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
$target est peut-être filtré ou hors ligne (simulation).''';
    }
    return '''
PING $target ($target): 56 data bytes
64 bytes from $target: icmp_seq=0 ttl=64 time=0.056 ms
64 bytes from $target: icmp_seq=1 ttl=64 time=0.045 ms
64 bytes from $target: icmp_seq=2 ttl=64 time=0.044 ms

--- $target ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
(Simulation : ping teste la connectivité, ce n'est jamais une attaque.)''';
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

Nmap done: 1 IP address (simulation : ne scannez jamais une machine sans autorisation)''';
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
$target: ports ouverts : 22, 80, 443
(Simulation : nmap seulement sur des cibles autorisées ou localhost.)''';
  }

  String _ps(List<String> args) {
    if (args.contains('aux') || args.contains('-e') || args.contains('-ef')) {
      return '''USER       PID  %CPU %MEM  COMMAND
root         1   0.0  0.3  /sbin/init
root       235   0.1  0.4  /lib/systemd/systemd-journald
root       512   0.0  0.2  /usr/sbin/sshd -D
www-data   640   0.0  0.9  nginx: worker process
backup     777   0.0  0.1  /bin/bash /home/backup/sauvegarde.sh
learner   1337   2.0  1.1  /usr/bin/nmap -sV localhost
learner   1338   0.0  0.5  bash''';
    }
    return '''    PID TTY          TIME CMD
   1338 pts/0    00:00:00 bash
   1400 pts/0    00:00:00 ps''';
  }

  String _man(List<String> args) {
    if (args.isEmpty) {
      return 'Quelle page de manuel voulez-vous ? (ex. man grep)';
    }
    switch (args.first) {
      case 'nmap':
        return 'NMAP(1)\n\nNOM\n       nmap - découverte de réseau et audit de sécurité\n\n'
            'OPTIONS COURANTES\n       -sT  scan TCP connect\n       -sS  scan SYN (root)\n'
            '       -sV  détection de version\n       -p   ports (ex. -p 22,80,443)\n\n'
            'AVERTISSEMENT\n       Uniquement sur des hôtes autorisés (localhost, votre lab).';
      case 'ls':
        return 'LS(1)\n\nNOM\n       ls - liste le contenu d\'un répertoire\n\n'
            'OPTIONS\n       -a  inclut les fichiers cachés (.bashrc…)\n'
            '       -l  affichage détaillé (droits, propriétaire, taille)';
      case 'grep':
        return 'GREP(1)\n\nNOM\n       grep - recherche des motifs dans des fichiers\n\n'
            'OPTIONS\n       -i  ignore la casse      -v  inverse la sélection\n'
            '       -n  numéros de ligne    -c  compte les lignes\n'
            '       -o  seulement la partie trouvée\n'
            '       -E  expression régulière étendue\n'
            '       -r  recherche récursive dans un dossier\n\n'
            'EXEMPLE\n       grep -c "Failed password" ~/logs/auth.log';
      case 'chmod':
        return 'CHMOD(1)\n\nNOM\n       chmod - modifie les droits d\'accès\n\n'
            'EXEMPLES\n       chmod +x script.sh   rend exécutable\n'
            '       chmod 640 fichier    rw- r-- --- (propriétaire, groupe, autres)\n'
            '       chmod go-w fichier   retire l\'écriture au groupe et aux autres';
      case 'find':
        return 'FIND(1)\n\nNOM\n       find - recherche des fichiers\n\n'
            'EXEMPLES\n       find ~ -name "*.log"\n       find / -type f -user root\n'
            '       find . -type d';
      case 'cut' || 'sort' || 'uniq':
        return 'Combo classique d\'analyse de logs :\n'
            '  grep "Failed" auth.log | cut -d " " -f 11 | sort | uniq -c | sort -nr\n'
            '  cut -d SEP -f N : garde le champ N\n'
            '  sort -n : tri numérique ; -r : inverse\n'
            '  uniq -c : compte les lignes identiques consécutives';
      default:
        return 'Pas de page détaillée pour « ${args.first} » dans ce terminal '
            'simulé. Pages disponibles : nmap, ls, grep, chmod, find, cut, '
            'sort, uniq. Tapez « help » pour la liste des commandes.';
    }
  }

  String _http(List<String> args) {
    if (args.isEmpty) return 'curl: essayez « curl http://localhost »';
    final url = args.last;
    if (url.contains('localhost') ||
        url.contains('127.0.0.1') ||
        url.contains('example') ||
        url.contains('juice-shop')) {
      return '''
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: nginx/1.24.0

${fs.lookup('/var/www/html/index.html')?.content.trimRight() ?? '<h1>Hello CyberLab</h1>'}
(Simulation : curl récupère le contenu d'un serveur web.)''';
    }
    return '''
(Simulation) Requête vers $url
>>>  En réel, curl et wget récupèrent des données sur Internet.
>>>  Uniquement vers des ressources autorisées.''';
  }

  String _docker(List<String> args) {
    if (args.isEmpty || args.first == 'ps') {
      return 'CONTAINER ID   IMAGE          STATUS         PORTS\n'
          '   (aucun conteneur, mode simulation)';
    }
    if (args.first == 'images') {
      return 'REPOSITORY          TAG       IMAGE ID      SIZE\n'
          'cyberlab/webserver   latest    4f2a1c9b     78MB\n(simulation)';
    }
    return '(simulation) docker ${args.join(' ')} : nécessite un vrai moteur Docker.';
  }
}

class _Tok {
  final String text;
  final bool op;
  final bool glob;
  const _Tok(this.text, {this.op = false, this.glob = false});
}

class _Cmd {
  final List<_Tok> words;
  final List<(String, String)> redirs;
  const _Cmd(this.words, this.redirs);
}

class _Out {
  final String out;
  final String err;
  final int code;
  final bool clear;
  const _Out(this.out, this.err, this.code, {this.clear = false});
}

class _LineResult {
  final String text;
  final int code;
  final bool clear;
  final bool blocked;
  const _LineResult(
    this.text,
    this.code, {
    this.clear = false,
    this.blocked = false,
  });
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
