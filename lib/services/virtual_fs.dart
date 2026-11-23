/// Système de fichiers VIRTUEL du terminal simulé : une arborescence en
/// mémoire, sans aucun accès aux fichiers de l'appareil. Il est recréé à
/// l'identique par [VirtualFs.reset] (commande `labreset`).
///
/// Modèle de droits simplifié : propriétaire + bits rwx (propriétaire et
/// « autres ») ; root a tous les droits. Les groupes ne sont pas simulés.
class VNode {
  final bool isDir;
  String content;
  final Map<String, VNode> children;
  int mode;
  String owner;
  DateTime mtime;

  VNode.file(this.content, {this.mode = 420, this.owner = 'learner'})
    : isDir = false,
      children = {},
      mtime = VirtualFs.epoch;

  VNode.dir({this.mode = 493, this.owner = 'learner'})
    : isDir = true,
      content = '',
      children = {},
      mtime = VirtualFs.epoch;

  int get size => isDir ? 4096 : content.length;

  VNode deepCopy() {
    final n = isDir
        ? VNode.dir(mode: mode, owner: owner)
        : VNode.file(content, mode: mode, owner: owner);
    n.mtime = mtime;
    for (final e in children.entries) {
      n.children[e.key] = e.value.deepCopy();
    }
    return n;
  }
}

/// Erreur d'opération sur le système de fichiers (message à la bash).
class FsError implements Exception {
  final String message;
  const FsError(this.message);
  @override
  String toString() => message;
}

class VirtualFs {
  VirtualFs() {
    reset();
  }

  /// Date fixe des fichiers d'origine (affichage stable de `ls -l`).
  static final epoch = DateTime(2026, 8, 28, 6, 0);

  static const noSuchFile = 'Aucun fichier ou dossier de ce type';
  static const denied = 'Permission non accordée';
  static const notADir = 'N\'est pas un dossier';
  static const isADir = 'Est un dossier';

  late VNode root;

  // ------------------------------------------------------------ Chemins

  /// Chemin absolu normalisé de [path] depuis [cwd] (`~` → [home]).
  static String resolve(String path, String cwd, String home) {
    var p = path;
    if (p == '~') {
      p = home;
    } else if (p.startsWith('~/')) {
      p = '$home${p.substring(1)}';
    }
    final base = p.startsWith('/') ? <String>[] : split(cwd);
    for (final part in p.split('/')) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        if (base.isNotEmpty) base.removeLast();
      } else {
        base.add(part);
      }
    }
    return '/${base.join('/')}';
  }

  static List<String> split(String abs) =>
      abs.split('/').where((e) => e.isNotEmpty).toList();

  static String parentOf(String abs) {
    final parts = split(abs);
    if (parts.isEmpty) return '/';
    parts.removeLast();
    return '/${parts.join('/')}';
  }

  static String baseName(String abs) {
    final parts = split(abs);
    return parts.isEmpty ? '/' : parts.last;
  }

  static String join(String dir, String name) =>
      dir == '/' ? '/$name' : '$dir/$name';

  // ------------------------------------------------------------- Accès

  VNode? lookup(String abs) {
    var node = root;
    for (final part in split(abs)) {
      if (!node.isDir) return null;
      final next = node.children[part];
      if (next == null) return null;
      node = next;
    }
    return node;
  }

  static bool canRead(VNode n, String user) =>
      user == 'root' || (n.owner == user ? n.mode & 256 != 0 : n.mode & 4 != 0);

  static bool canWrite(VNode n, String user) =>
      user == 'root' || (n.owner == user ? n.mode & 128 != 0 : n.mode & 2 != 0);

  static bool canExec(VNode n, String user) =>
      user == 'root' || (n.owner == user ? n.mode & 64 != 0 : n.mode & 1 != 0);

  /// Vérifie qu'on peut traverser tous les dossiers parents de [abs].
  void checkTraverse(String abs, String user) {
    var node = root;
    final parts = split(abs);
    for (var i = 0; i < parts.length - 1; i++) {
      final next = node.children[parts[i]];
      if (next == null || !next.isDir) return;
      if (!canExec(next, user)) throw const FsError(denied);
      node = next;
    }
  }

  /// Nœud existant ou erreur « Aucun fichier… » / « Permission… ».
  VNode existing(String abs, String user) {
    checkTraverse(abs, user);
    final n = lookup(abs);
    if (n == null) throw const FsError(noSuchFile);
    return n;
  }

  String readFile(String abs, String user) {
    final n = existing(abs, user);
    if (n.isDir) throw const FsError(isADir);
    if (!canRead(n, user)) throw const FsError(denied);
    return n.content;
  }

  /// Écrit (ou ajoute à) un fichier ; le crée si besoin.
  void writeFile(
    String abs,
    String content,
    String user, {
    bool append = false,
  }) {
    checkTraverse(abs, user);
    final existingNode = lookup(abs);
    if (existingNode != null) {
      if (existingNode.isDir) throw const FsError(isADir);
      if (!canWrite(existingNode, user)) throw const FsError(denied);
      existingNode.content = append ? existingNode.content + content : content;
      existingNode.mtime = DateTime.now();
      return;
    }
    final parent = lookup(parentOf(abs));
    if (parent == null) throw const FsError(noSuchFile);
    if (!parent.isDir) throw const FsError(notADir);
    if (!canWrite(parent, user)) throw const FsError(denied);
    parent.children[baseName(abs)] = VNode.file(content, owner: user)
      ..mtime = DateTime.now();
  }

  void makeDir(String abs, String user, {bool parents = false}) {
    if (lookup(abs) != null) {
      if (parents && lookup(abs)!.isDir) return;
      throw const FsError('Le fichier existe');
    }
    final parentPath = parentOf(abs);
    var parent = lookup(parentPath);
    if (parent == null) {
      if (!parents) throw const FsError(noSuchFile);
      makeDir(parentPath, user, parents: true);
      parent = lookup(parentPath)!;
    }
    if (!parent.isDir) throw const FsError(notADir);
    if (!canWrite(parent, user)) throw const FsError(denied);
    parent.children[baseName(abs)] = VNode.dir(owner: user)
      ..mtime = DateTime.now();
  }

  /// Supprime [abs] (dossier : récursivement). Le droit d'écriture sur le
  /// dossier parent est exigé, comme sous Linux.
  void remove(String abs, String user) {
    if (abs == '/') throw const FsError(denied);
    checkTraverse(abs, user);
    final parent = lookup(parentOf(abs));
    final name = baseName(abs);
    if (parent == null || !parent.children.containsKey(name)) {
      throw const FsError(noSuchFile);
    }
    if (!canWrite(parent, user)) throw const FsError(denied);
    parent.children.remove(name);
  }

  /// Insère [node] sous [abs] (le parent doit exister et être modifiable).
  void put(String abs, VNode node, String user) {
    checkTraverse(abs, user);
    final parent = lookup(parentOf(abs));
    if (parent == null) throw const FsError(noSuchFile);
    if (!parent.isDir) throw const FsError(notADir);
    if (!canWrite(parent, user)) throw const FsError(denied);
    parent.children[baseName(abs)] = node;
  }

  /// Parcours en profondeur : (chemin absolu, nœud), [abs] compris.
  Iterable<(String, VNode)> walk(String abs, String user) sync* {
    final n = lookup(abs);
    if (n == null) return;
    yield (abs, n);
    if (!n.isDir || !canRead(n, user) || !canExec(n, user)) return;
    final names = n.children.keys.toList()..sort();
    for (final name in names) {
      yield* walk(join(abs, name), user);
    }
  }

  // ------------------------------------------------------ Contenu initial

  void reset() {
    VNode d([int mode = 493, String owner = 'root']) =>
        VNode.dir(mode: mode, owner: owner);
    VNode f(String c, [int mode = 420, String owner = 'root']) =>
        VNode.file(c, mode: mode, owner: owner);
    VNode lf(String c, [int mode = 420]) => f(c, mode, 'learner');
    VNode ld([int mode = 493]) => d(mode, 'learner');

    root = d()
      ..children.addAll({
        'bin': d(),
        'usr': d()..children['bin'] = d(),
        'boot': d(),
        'dev': d()..children['null'] = f('', 438),
        'proc': d(),
        'tmp': d(511),
        'opt': d(),
        'root': d(448)
          ..children['flag.txt'] = f(
            'FLAG{root_lit_tout_mais_ne_touche_a_rien}\n',
            384,
          ),
        'etc': d()
          ..children.addAll({
            'hostname': f('cyberlab\n'),
            'hosts': f(
              '127.0.0.1\tlocalhost\n'
              '127.0.1.1\tcyberlab\n'
              '192.168.56.10\tjuice-shop.lab\n',
            ),
            'os-release': f(
              'PRETTY_NAME="CyberLab Linux (simulation)"\n'
              'NAME="CyberLab Linux"\nVERSION_ID="1.2"\nID=cyberlab\n',
            ),
            'passwd': f(
              'root:x:0:0:root:/root:/bin/bash\n'
              'daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin\n'
              'www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin\n'
              'sshd:x:110:65534::/run/sshd:/usr/sbin/nologin\n'
              'learner:x:1000:1000:Apprenant CyberLab:/home/learner:/bin/bash\n'
              'backup:x:1001:1001::/home/backup:/bin/bash\n',
            ),
            'shadow': f(
              'root:\$6\$simulation\$hash_fictif_non_exploitable:19800:0:99999:7:::\n'
              'learner:\$6\$simulation\$autre_hash_fictif:19800:0:99999:7:::\n',
              416,
            ),
            'group': f(
              'root:x:0:\nsudo:x:27:learner\nwww-data:x:33:\n'
              'learner:x:1000:\n',
            ),
            'crontab': f(
              '# m h dom mon dow user command\n'
              '17 *  * * *  root  cd / && run-parts --report /etc/cron.hourly\n'
              '*/5 * * * *  backup  /home/backup/sauvegarde.sh\n',
            ),
            'ssh': d()
              ..children['sshd_config'] = f(
                'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes\n'
                '# À durcir : PermitRootLogin no, PasswordAuthentication no\n',
              ),
          }),
        'var': d()
          ..children.addAll({
            'log': d()
              ..children.addAll({
                'syslog': f(_syslog, 416),
                'auth.log': f(_authLog, 416),
              }),
            'www': d()
              ..children['html'] = (d()
                ..children['index.html'] = f(
                  '<!DOCTYPE html>\n<html><head><title>Site du lab</title>'
                  '</head>\n<body><h1>Hello CyberLab</h1>\n'
                  '<!-- TODO retirer : identifiants de test admin/admin123 -->\n'
                  '</body></html>\n',
                )),
          }),
        'home': d()
          ..children['learner'] = (ld()
            ..children.addAll({
              '.bashrc': lf(
                '# ~/.bashrc (simulation)\nalias ll=\'ls -la\'\n'
                'export PS1="\\u@\\h:\\w\\\$ "\n',
              ),
              '.profile': lf('# ~/.profile\n. ~/.bashrc\n'),
              '.bash_history': lf(
                'ls -la\ncat notes.txt\nsudo nmap -sV localhost\n'
                'grep "Failed password" logs/auth.log | wc -l\n',
                384,
              ),
              '.ssh': ld(448)
                ..children.addAll({
                  'authorized_keys': lf(
                    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFICTIF learner@laptop\n',
                    384,
                  ),
                  'known_hosts': lf(
                    'juice-shop.lab ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXEMPLE\n',
                  ),
                }),
              'notes.txt': lf(
                'Notes du lab\n'
                '- Analyser logs/auth.log : tentatives SSH suspectes ?\n'
                '- Vérifier le serveur web (logs/access.log)\n'
                '- Ne scanner que les machines du lab\n'
                'Astuce : grep, cut, sort et uniq -c font un excellent combo.\n',
              ),
              'documents': ld()
                ..children.addAll({
                  'rapport_incident.md': lf(
                    '# Rapport d\'incident (brouillon)\n\n'
                    '## Résumé\nNombreuses tentatives SSH depuis 203.0.113.7.\n\n'
                    '## Actions\n- [ ] Bloquer l\'IP\n'
                    '- [ ] Désactiver PermitRootLogin\n'
                    '- [ ] Activer fail2ban\n',
                  ),
                  'notes.pdf': lf('%PDF-1.7 (contenu binaire simulé)\n'),
                }),
              'logs': ld()
                ..children.addAll({
                  'auth.log': lf(_authLog),
                  'access.log': lf(_accessLog),
                }),
              'scripts': ld()
                ..children.addAll({
                  'analyse_logs.sh': lf(
                    '#!/bin/bash\n'
                    '# Résume les tentatives SSH échouées\n'
                    'echo "Tentatives échouées :"\n'
                    'grep -c "Failed password" ~/logs/auth.log\n'
                    'echo "Adresses sources :"\n'
                    'grep "Failed password" ~/logs/auth.log | '
                    'grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" | sort | uniq -c\n',
                    493,
                  ),
                  'scan_local.sh': lf(
                    '#!/bin/bash\n'
                    '# Scan du lab local uniquement\n'
                    'echo "Scan de localhost (autorisé)"\n'
                    'nmap localhost\n',
                  ),
                }),
              'rapports': ld(),
            })),
      });
  }

  static const _authLog =
      'Aug 28 06:01:12 cyberlab sshd[1398]: Accepted publickey for learner from 198.51.100.10 port 50110 ssh2\n'
      'Aug 28 06:02:45 cyberlab sshd[1402]: Failed password for invalid user admin from 203.0.113.7 port 51234 ssh2\n'
      'Aug 28 06:02:47 cyberlab sshd[1402]: Failed password for invalid user admin from 203.0.113.7 port 51236 ssh2\n'
      'Aug 28 06:03:11 cyberlab sshd[1403]: Failed password for root from 203.0.113.7 port 51244 ssh2\n'
      'Aug 28 06:03:15 cyberlab sshd[1403]: Failed password for root from 203.0.113.7 port 51250 ssh2\n'
      'Aug 28 06:03:20 cyberlab sshd[1404]: Failed password for root from 203.0.113.7 port 51262 ssh2\n'
      'Aug 28 06:04:02 cyberlab sshd[1405]: Failed password for invalid user test from 192.0.2.44 port 40022 ssh2\n'
      'Aug 28 06:04:09 cyberlab sshd[1405]: Failed password for invalid user oracle from 192.0.2.44 port 40031 ssh2\n'
      'Aug 28 06:05:00 cyberlab sudo[1500]: learner : TTY=pts/0 ; PWD=/home/learner ; USER=root ; COMMAND=/usr/bin/nmap localhost\n'
      'Aug 28 06:07:33 cyberlab sshd[1510]: Accepted password for backup from 203.0.113.7 port 51400 ssh2\n'
      'Aug 28 06:07:34 cyberlab sshd[1510]: pam_unix(sshd:session): session opened for user backup by (uid=0)\n';

  static const _accessLog =
      '198.51.100.10 - - [28/Aug/2026:06:10:01 +0000] "GET / HTTP/1.1" 200 1530 "-" "Mozilla/5.0"\n'
      '198.51.100.10 - - [28/Aug/2026:06:10:02 +0000] "GET /favicon.ico HTTP/1.1" 404 162 "-" "Mozilla/5.0"\n'
      '203.0.113.7 - - [28/Aug/2026:06:12:40 +0000] "GET /admin HTTP/1.1" 403 199 "-" "sqlmap/1.8"\n'
      '203.0.113.7 - - [28/Aug/2026:06:12:41 +0000] "GET /login.php?user=admin\'%20OR%201=1-- HTTP/1.1" 500 0 "-" "sqlmap/1.8"\n'
      '203.0.113.7 - - [28/Aug/2026:06:12:43 +0000] "GET /../../etc/passwd HTTP/1.1" 400 0 "-" "sqlmap/1.8"\n'
      '192.0.2.44 - - [28/Aug/2026:06:15:10 +0000] "GET /wp-login.php HTTP/1.1" 404 162 "-" "curl/8.5"\n'
      '198.51.100.10 - - [28/Aug/2026:06:20:00 +0000] "POST /contact HTTP/1.1" 200 88 "-" "Mozilla/5.0"\n';

  static const _syslog =
      'Aug 28 06:00:01 cyberlab systemd[1]: Started Daily apt download activities.\n'
      'Aug 28 06:00:05 cyberlab CRON[1201]: (backup) CMD (/home/backup/sauvegarde.sh)\n'
      'Aug 28 06:09:59 cyberlab kernel: [UFW BLOCK] IN=eth0 SRC=203.0.113.7 DST=192.168.1.42 PROTO=TCP DPT=3306\n';
}
