import '../services/terminal_engine.dart';
import '../services/virtual_fs.dart';

/// Nature d'un critère vérifié automatiquement dans le terminal simulé.
enum CheckKind {
  /// Le chemin est un dossier.
  isDir,

  /// Le chemin est un fichier.
  isFile,

  /// Le fichier contient toutes les valeurs.
  contains,

  /// Le fichier ne contient aucune des valeurs.
  notContains,

  /// Droits : « 600 », ou « u+x » (exécutable par le propriétaire).
  mode,

  /// Propriétaire du chemin.
  owner,

  /// La sortie d'une commande contient toutes les valeurs (une fois suffit).
  output,

  /// Une ligne de la sortie vaut exactement la valeur (une fois suffit).
  outputIs,

  /// La sortie d'une commande correspond à l'expression régulière.
  outputRegex,

  /// Une commande tapée correspond à l'expression régulière.
  command,
}

class TerminalCheck {
  final CheckKind kind;
  final String label;
  final String? path;
  final List<String> values;
  const TerminalCheck(
    this.kind,
    this.label, {
    this.path,
    this.values = const [],
  });

  /// Vrai pour les critères liés à une commande (acquis une fois atteints) ;
  /// faux pour l'état des fichiers (réévalué à chaque commande).
  bool get latched =>
      kind == CheckKind.output ||
      kind == CheckKind.outputIs ||
      kind == CheckKind.outputRegex ||
      kind == CheckKind.command;

  /// Évalue le critère après la commande [command] qui a produit [output].
  bool test(TerminalEngine e, String command, String output) {
    VNode? node() {
      if (path == null) return null;
      return e.fs.lookup(
        VirtualFs.resolve(
          path!,
          TerminalEngine.learnerHome,
          TerminalEngine.learnerHome,
        ),
      );
    }

    switch (kind) {
      case CheckKind.isDir:
        return node()?.isDir == true;
      case CheckKind.isFile:
        return node()?.isDir == false;
      case CheckKind.contains:
        final n = node();
        return n != null && !n.isDir && values.every(n.content.contains);
      case CheckKind.notContains:
        final n = node();
        return n != null && !n.isDir && !values.any(n.content.contains);
      case CheckKind.mode:
        final n = node();
        if (n == null) return false;
        final v = values.first;
        if (v == 'u+x') return n.mode & 64 != 0;
        return (n.mode & 511).toRadixString(8) == v;
      case CheckKind.owner:
        return node()?.owner == values.first;
      case CheckKind.output:
        return values.every(output.contains);
      case CheckKind.outputIs:
        // Une ligne vaut exactement la valeur (la ligne « [sudo] … » ou un
        // message d'erreur ne doit pas empêcher la validation).
        return output.split('\n').any((l) => l.trim() == values.first);
      case CheckKind.outputRegex:
        return RegExp(values.first, multiLine: true).hasMatch(output);
      case CheckKind.command:
        return RegExp(values.first).hasMatch(command.trim());
    }
  }
}

/// Exercice pratique d'un cours, vérifié par le terminal simulé (les
/// commandes partent du dossier personnel, sur des fichiers d'origine).
class TerminalExercise {
  final String courseId;
  final String title;
  final String instruction;
  final List<TerminalCheck> checks;
  final String hint;

  /// Solution de référence (une commande par ligne), montrée après la
  /// réussite ; les tests vérifient qu'elle valide tous les critères.
  final String solution;
  final int xp;

  const TerminalExercise({
    required this.courseId,
    required this.title,
    required this.instruction,
    required this.checks,
    required this.hint,
    required this.solution,
    this.xp = 15,
  });
}

TerminalCheck _cmd(String label, String regex) =>
    TerminalCheck(CheckKind.command, label, values: [regex]);
TerminalCheck _out(String label, List<String> v) =>
    TerminalCheck(CheckKind.output, label, values: v);

const _ip = r'grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"';

final Map<String, TerminalExercise> terminalExercises = {
  for (final e in <TerminalExercise>[
    // ---------------------------------------------------------- Linux
    TerminalExercise(
      courseId: 'lin-terminal',
      title: 'Premiers pas',
      instruction:
          'Affichez le dossier courant, puis listez tous les fichiers de votre '
          'dossier personnel, y compris les fichiers cachés.',
      checks: [
        _cmd('Afficher le dossier courant', r'^pwd$'),
        _out('Lister les fichiers cachés (.bashrc)', ['.bashrc', '.profile']),
      ],
      hint: 'ls a une option d\'une lettre pour « all ».',
      solution: 'pwd\nls -a',
    ),
    TerminalExercise(
      courseId: 'lin-filesystem',
      title: 'Le nom de la machine',
      instruction:
          'Le nom de la machine est enregistré dans un fichier de /etc. '
          'Affichez son contenu.',
      checks: [
        _cmd('Lire un fichier de /etc', r'/etc/hostname'),
        _out('Le nom « cyberlab » s\'affiche', ['cyberlab']),
      ],
      hint: 'ls /etc, puis cat sur le fichier dont le nom évoque l\'hôte.',
      solution: 'cat /etc/hostname',
    ),
    TerminalExercise(
      courseId: 'lin-navigation',
      title: 'Ranger un rapport',
      instruction:
          'Créez le dossier rapports/2026 dans votre dossier personnel, puis '
          'copiez-y notes.txt.',
      checks: [
        TerminalCheck(
          CheckKind.isDir,
          'Dossier ~/rapports/2026 créé',
          path: '~/rapports/2026',
        ),
        TerminalCheck(
          CheckKind.isFile,
          'notes.txt copié dedans',
          path: '~/rapports/2026/notes.txt',
        ),
      ],
      hint: 'mkdir crée un dossier ; cp copie un fichier vers un dossier.',
      solution: 'mkdir -p rapports/2026\ncp notes.txt rapports/2026/',
    ),
    TerminalExercise(
      courseId: 'lin-users',
      title: 'Votre compte',
      instruction:
          'Affichez la ligne de votre compte (learner) dans /etc/passwd.',
      checks: [
        _out('La ligne de learner s\'affiche', ['learner:x:1000:1000']),
      ],
      hint: 'grep affiche les lignes qui contiennent un mot.',
      solution: 'grep learner /etc/passwd',
    ),
    TerminalExercise(
      courseId: 'lin-groups',
      title: 'Vos groupes',
      instruction: 'Affichez les groupes auxquels appartient votre compte.',
      checks: [
        _cmd('Commande des groupes', r'^(groups|id)\b'),
        _out('Le groupe sudo apparaît', ['sudo']),
      ],
      hint: 'La commande porte le nom de ce que vous cherchez.',
      solution: 'groups',
    ),
    TerminalExercise(
      courseId: 'lin-permissions',
      title: 'Lire des droits',
      instruction:
          'Affichez les droits détaillés des fichiers du dossier scripts.',
      checks: [
        _out('Les droits rwx s\'affichent', ['-rwxr-xr-x', 'analyse_logs.sh']),
      ],
      hint: 'ls a une option d\'affichage « long ».',
      solution: 'ls -l scripts',
    ),
    TerminalExercise(
      courseId: 'lin-chmod',
      title: 'Protéger un fichier',
      instruction:
          'Faites en sorte que vous seul puissiez lire et modifier notes.txt '
          '(droits 600).',
      checks: [
        TerminalCheck(
          CheckKind.mode,
          'notes.txt en 600',
          path: '~/notes.txt',
          values: ['600'],
        ),
      ],
      hint: 'En octal : 6 = lecture + écriture, 0 = aucun droit.',
      solution: 'chmod 600 notes.txt',
    ),
    TerminalExercise(
      courseId: 'lin-chown',
      title: 'Changer de propriétaire',
      instruction: 'Donnez la propriété du dossier rapports au compte root.',
      checks: [
        TerminalCheck(
          CheckKind.owner,
          'rapports appartient à root',
          path: '~/rapports',
          values: ['root'],
        ),
      ],
      hint: 'Seul root peut changer le propriétaire d\'un fichier.',
      solution: 'sudo chown root rapports',
    ),
    TerminalExercise(
      courseId: 'lin-sudo',
      title: 'Un fichier réservé',
      instruction:
          'Affichez le fichier des empreintes de mots de passe, réservé à root.',
      checks: [
        _out('Les empreintes s\'affichent', ['hash_fictif']),
      ],
      hint:
          'Le fichier est /etc/shadow ; il faut emprunter les droits de root.',
      solution: 'sudo cat /etc/shadow',
    ),
    TerminalExercise(
      courseId: 'lin-processes',
      title: 'Trouver un processus',
      instruction: 'Affichez tous les processus et repérez celui de nmap.',
      checks: [
        _cmd('Lister les processus', r'^ps\b'),
        _out('Le processus nmap apparaît', ['nmap']),
      ],
      hint: 'ps aux affiche les processus de tous les utilisateurs.',
      solution: 'ps aux',
    ),
    TerminalExercise(
      courseId: 'lin-logs',
      title: 'Compter les échecs',
      instruction:
          'Comptez les échecs de connexion SSH (« Failed password ») dans le '
          'journal système /var/log/auth.log.',
      checks: [
        TerminalCheck(CheckKind.outputIs, 'Le résultat est 7', values: ['7']),
      ],
      hint: 'Ce journal est réservé ; grep -c compte les lignes.',
      solution: 'sudo grep -c "Failed password" /var/log/auth.log',
    ),
    TerminalExercise(
      courseId: 'lin-variables',
      title: 'Une variable',
      instruction:
          'Créez une variable LAB qui contient cyberlab, puis affichez sa '
          'valeur avec echo.',
      checks: [
        _cmd('Utiliser \$LAB', r'\$\{?LAB'),
        _out('« cyberlab » s\'affiche', ['cyberlab']),
      ],
      hint: 'NOM=valeur (sans espace), puis echo \$NOM.',
      solution: 'LAB=cyberlab\necho \$LAB',
    ),
    TerminalExercise(
      courseId: 'lin-pipes',
      title: 'Liste des attaquants',
      instruction:
          'Enregistrez dans rapports/ips.txt la liste, sans doublon, des '
          'adresses IP qui ont échoué à se connecter (logs/auth.log).',
      checks: [
        _cmd('Utiliser un tube |', r'\|'),
        TerminalCheck(
          CheckKind.contains,
          'rapports/ips.txt contient les deux IP',
          path: '~/rapports/ips.txt',
          values: ['203.0.113.7', '192.0.2.44'],
        ),
      ],
      hint:
          'grep "Failed password", puis grep -oE pour isoler les IP, sort -u, et > pour écrire.',
      solution:
          'grep "Failed password" logs/auth.log | $_ip | sort -u > rapports/ips.txt',
    ),
    TerminalExercise(
      courseId: 'lin-grep',
      title: 'Où est sqlmap ?',
      instruction:
          'Affichez, avec leur numéro de ligne, les lignes de logs/access.log '
          'qui contiennent sqlmap.',
      checks: [
        _out('Lignes numérotées (3:…)', ['3:203.0.113.7', 'sqlmap']),
      ],
      hint: 'grep a une option pour numéroter les lignes.',
      solution: 'grep -n sqlmap logs/access.log',
    ),
    TerminalExercise(
      courseId: 'lin-find',
      title: 'Tous les scripts',
      instruction: 'Trouvez tous les fichiers .sh de votre dossier personnel.',
      checks: [
        _cmd('Utiliser find', r'^find\b'),
        _out('Les deux scripts sont trouvés', [
          'analyse_logs.sh',
          'scan_local.sh',
        ]),
      ],
      hint: 'find . -name "motif" ; le joker * remplace n\'importe quel texte.',
      solution: 'find . -name "*.sh"',
    ),
    TerminalExercise(
      courseId: 'lin-network',
      title: 'Votre adresse IP',
      instruction: 'Affichez la configuration réseau de la machine.',
      checks: [
        _out('L\'adresse 192.168.1.42 apparaît', ['192.168.1.42']),
      ],
      hint: 'ip a ou ifconfig.',
      solution: 'ip a',
    ),
    TerminalExercise(
      courseId: 'lin-curl',
      title: 'Le site local',
      instruction:
          'Récupérez la page d\'accueil du serveur web local (localhost).',
      checks: [
        _out('La page « Hello CyberLab » s\'affiche', ['Hello CyberLab']),
      ],
      hint: 'curl suivi de l\'adresse http://…',
      solution: 'curl http://localhost',
    ),
    TerminalExercise(
      courseId: 'lin-ssh',
      title: 'Root et SSH',
      instruction:
          'Vérifiez dans la configuration du serveur SSH si root peut se '
          'connecter directement.',
      checks: [
        _out('La directive est trouvée', ['PermitRootLogin yes']),
      ],
      hint:
          'Le fichier est /etc/ssh/sshd_config ; cherchez « root » sans tenir compte de la casse.',
      solution: 'grep -i root /etc/ssh/sshd_config',
    ),

    // ----------------------------------------------------------- Bash
    TerminalExercise(
      courseId: 'bash-intro',
      title: 'Votre premier script',
      instruction:
          'Créez scripts/bonjour.sh qui affiche Bonjour, rendez-le exécutable, '
          'puis lancez-le avec ./scripts/bonjour.sh',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Le script contient un echo',
          path: '~/scripts/bonjour.sh',
          values: ['echo'],
        ),
        TerminalCheck(
          CheckKind.mode,
          'Le script est exécutable',
          path: '~/scripts/bonjour.sh',
          values: ['u+x'],
        ),
        _cmd('Lancé avec ./', r'^\./scripts/bonjour\.sh'),
        _out('« Bonjour » s\'affiche', ['Bonjour']),
      ],
      hint: 'echo \'echo Bonjour\' > fichier, puis chmod +x.',
      solution:
          "echo 'echo Bonjour' > scripts/bonjour.sh\nchmod +x scripts/bonjour.sh\n./scripts/bonjour.sh",
    ),
    TerminalExercise(
      courseId: 'bash-variables',
      title: 'Saluer',
      instruction:
          'Stockez votre prénom dans la variable NOM, puis affichez « Salut » '
          'suivi de cette variable.',
      checks: [
        _cmd('Utiliser \$NOM', r'\$\{?NOM'),
        TerminalCheck(
          CheckKind.outputRegex,
          '« Salut … » s\'affiche',
          values: [r'^Salut \S+'],
        ),
      ],
      hint: 'NOM=Ada puis echo "Salut \$NOM".',
      solution: 'NOM=Ada\necho "Salut \$NOM"',
    ),
    TerminalExercise(
      courseId: 'bash-conditions',
      title: 'Le fichier existe-t-il ?',
      instruction:
          'Écrivez une condition qui affiche « présent » si notes.txt existe '
          'et « absent » sinon.',
      checks: [
        _cmd('Utiliser if ou [ ]', r'^(if|\[|test)\b'),
        _out('« présent » s\'affiche', ['présent']),
      ],
      hint: 'if [ -f fichier ]; then …; else …; fi',
      solution: 'if [ -f notes.txt ]; then echo présent; else echo absent; fi',
    ),
    TerminalExercise(
      courseId: 'bash-loops',
      title: 'Trois fichiers d\'un coup',
      instruction:
          'Avec une boucle for, créez fichier1.txt, fichier2.txt et '
          'fichier3.txt dans rapports/.',
      checks: [
        _cmd('Utiliser une boucle for', r'^for\b'),
        for (var i = 1; i <= 3; i++)
          TerminalCheck(
            CheckKind.isFile,
            'rapports/fichier$i.txt',
            path: '~/rapports/fichier$i.txt',
          ),
      ],
      hint: 'for i in 1 2 3; do touch …\$i…; done',
      solution: 'for i in 1 2 3; do touch rapports/fichier\$i.txt; done',
    ),
    TerminalExercise(
      courseId: 'bash-functions',
      title: 'Une fonction',
      instruction:
          'Définissez une fonction salut qui affiche « Salut » suivi de son '
          'premier argument, puis appelez-la avec votre prénom.',
      checks: [
        _cmd('Définir salut()', r'salut\s*\(\)'),
        _cmd('Appeler salut avec un argument', r'^salut\s+\S'),
        TerminalCheck(
          CheckKind.outputRegex,
          '« Salut … » s\'affiche',
          values: [r'^Salut \S+'],
        ),
      ],
      hint: 'salut() { echo Salut \$1; } puis salut Ada',
      solution: 'salut() { echo Salut \$1; }\nsalut Ada',
    ),
    TerminalExercise(
      courseId: 'bash-arguments',
      title: 'Un argument',
      instruction:
          'Créez scripts/args.sh qui affiche son premier argument, puis '
          'lancez : bash scripts/args.sh test',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Le script utilise \$1',
          path: '~/scripts/args.sh',
          values: [r'$1'],
        ),
        _cmd('Lancé avec l\'argument test', r'scripts/args\.sh\s+test\b'),
        TerminalCheck(
          CheckKind.outputIs,
          '« test » s\'affiche',
          values: ['test'],
        ),
      ],
      hint:
          'Entre apostrophes, \$1 est écrit tel quel dans le fichier : echo \'echo \$1\' > …',
      solution: "echo 'echo \$1' > scripts/args.sh\nbash scripts/args.sh test",
    ),
    TerminalExercise(
      courseId: 'bash-files',
      title: 'Ajouter sans écraser',
      instruction:
          'Créez rapports/rapport.txt contenant « début », puis ajoutez la '
          'ligne « fin du rapport » à la fin, sans effacer la première.',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Les deux lignes sont présentes',
          path: '~/rapports/rapport.txt',
          values: ['début', 'fin du rapport'],
        ),
      ],
      hint: '> écrase, >> ajoute à la fin.',
      solution:
          'echo début > rapports/rapport.txt\necho "fin du rapport" >> rapports/rapport.txt',
    ),
    TerminalExercise(
      courseId: 'bash-parsing',
      title: 'Les codes HTTP',
      instruction:
          'Extrayez de logs/access.log la colonne des codes de réponse HTTP '
          '(9e champ).',
      checks: [
        _cmd('Utiliser cut ou awk', r'\b(cut|awk)\b'),
        _out('Les codes 403 et 500 apparaissent', ['403', '500']),
      ],
      hint: "awk '{print \$9}' fichier, ou cut -d ' ' -f 9.",
      solution: "awk '{print \$9}' logs/access.log",
    ),
    TerminalExercise(
      courseId: 'bash-automation',
      title: 'Sauvegarde automatique',
      instruction:
          'Créez scripts/sauve.sh qui copie notes.txt dans rapports/, puis '
          'exécutez-le.',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Le script utilise cp',
          path: '~/scripts/sauve.sh',
          values: ['cp'],
        ),
        TerminalCheck(
          CheckKind.isFile,
          'rapports/notes.txt existe',
          path: '~/rapports/notes.txt',
        ),
      ],
      hint:
          'Utilisez des chemins complets (~/…) dans le script, puis bash scripts/sauve.sh.',
      solution:
          "echo 'cp ~/notes.txt ~/rapports/' > scripts/sauve.sh\nbash scripts/sauve.sh",
    ),
    TerminalExercise(
      courseId: 'bash-logs',
      title: 'Top des adresses',
      instruction:
          'Comptez les requêtes par adresse IP dans logs/access.log, de la '
          'plus active à la moins active.',
      checks: [
        _cmd(
          'Compter avec uniq -c et trier',
          r'uniq\s+-c.*sort|sort.*uniq\s+-c',
        ),
        _out('Les IP sont comptées', ['198.51.100.10', '203.0.113.7']),
      ],
      hint: 'cut le 1er champ, sort, uniq -c, puis sort -nr.',
      solution: "cut -d ' ' -f 1 logs/access.log | sort | uniq -c | sort -nr",
    ),
    TerminalExercise(
      courseId: 'bash-admin',
      title: 'Comptes interactifs',
      instruction:
          'Enregistrez dans rapports/comptes.txt les noms (seulement) des '
          'comptes qui utilisent /bin/bash.',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'root, learner et backup listés',
          path: '~/rapports/comptes.txt',
          values: ['root', 'learner', 'backup'],
        ),
        TerminalCheck(
          CheckKind.notContains,
          'Seulement les noms (pas les lignes complètes)',
          path: '~/rapports/comptes.txt',
          values: ['/bin/bash', 'daemon'],
        ),
      ],
      hint: 'grep /bin/bash, puis cut -d : -f 1.',
      solution:
          'grep /bin/bash /etc/passwd | cut -d : -f 1 > rapports/comptes.txt',
    ),
    TerminalExercise(
      courseId: 'bash-analyzer',
      title: 'Archiver une analyse',
      instruction:
          'Lancez scripts/analyse_logs.sh et enregistrez son résultat dans '
          'rapports/analyse.txt.',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Le résultat est enregistré',
          path: '~/rapports/analyse.txt',
          values: ['Tentatives échouées', '203.0.113.7'],
        ),
      ],
      hint: 'bash script > fichier',
      solution: 'bash scripts/analyse_logs.sh > rapports/analyse.txt',
    ),

    // ------------------------------------------- Autres niveaux
    TerminalExercise(
      courseId: 'ns-firewall',
      title: 'Le refus du pare-feu',
      instruction:
          'Trouvez dans /var/log/syslog la connexion bloquée par le pare-feu.',
      checks: [
        _out('La ligne UFW BLOCK s\'affiche', ['UFW BLOCK', 'DPT=3306']),
      ],
      hint: 'Journal réservé à root ; cherchez « UFW BLOCK ».',
      solution: 'sudo grep "UFW BLOCK" /var/log/syslog',
    ),
    TerminalExercise(
      courseId: 'ns-scan',
      title: 'Versions des services',
      instruction:
          'Lancez un scan nmap de détection de versions sur localhost.',
      checks: [
        _cmd('nmap avec -sV', r'nmap\b.*-sV'),
        _out('La version d\'OpenSSH apparaît', ['OpenSSH']),
      ],
      hint: 'L\'option de détection de versions est -sV.',
      solution: 'nmap -sV localhost',
    ),
    TerminalExercise(
      courseId: 'web-misconfig',
      title: 'La fuite du site',
      instruction:
          'Trouvez le mot de passe de test oublié dans la page d\'accueil du '
          'site (/var/www/html/index.html).',
      checks: [
        _out('Le mot de passe apparaît', ['admin123']),
      ],
      hint: 'Affichez le code source de la page.',
      solution: 'cat /var/www/html/index.html',
    ),
    TerminalExercise(
      courseId: 'cr-encoding',
      title: 'Encoder et décoder',
      instruction:
          'Encodez CyberLab en Base64 (sans saut de ligne), puis décodez le '
          'résultat.',
      checks: [
        _out('Encodage Q3liZXJMYWI=', ['Q3liZXJMYWI=']),
        _cmd('Décoder avec base64 -d', r'base64\s+(-d|--decode)'),
      ],
      hint: 'echo -n n\'ajoute pas de saut de ligne.',
      solution: 'echo -n CyberLab | base64\necho Q3liZXJMYWI= | base64 -d',
    ),
    TerminalExercise(
      courseId: 'cr-hash',
      title: 'Empreinte d\'un fichier',
      instruction: 'Calculez l\'empreinte SHA-256 de notes.txt.',
      checks: [
        TerminalCheck(
          CheckKind.outputRegex,
          'Une empreinte de 64 caractères pour notes.txt',
          values: [r'^[0-9a-f]{64}\s+notes\.txt$'],
        ),
      ],
      hint: 'La commande porte le nom de l\'algorithme, suivi de « sum ».',
      solution: 'sha256sum notes.txt',
    ),
    TerminalExercise(
      courseId: 'ir-containment',
      title: 'La persistance',
      instruction:
          'Trouvez la tâche planifiée qui exécute un script du compte backup.',
      checks: [
        _out('Le script planifié apparaît', ['/home/backup/sauvegarde.sh']),
      ],
      hint: 'Les tâches planifiées système sont dans /etc/crontab.',
      solution: 'cat /etc/crontab',
    ),
    TerminalExercise(
      courseId: 'ir-evidence',
      title: 'Sceller les preuves',
      instruction:
          'Enregistrez les empreintes SHA-256 de logs/auth.log et de '
          'logs/access.log dans rapports/empreintes.txt.',
      checks: [
        TerminalCheck(
          CheckKind.contains,
          'Les deux empreintes sont enregistrées',
          path: '~/rapports/empreintes.txt',
          values: ['logs/auth.log', 'logs/access.log'],
        ),
      ],
      hint: 'sha256sum accepte plusieurs fichiers ; > écrit dans un fichier.',
      solution:
          'sha256sum logs/auth.log logs/access.log > rapports/empreintes.txt',
    ),
    TerminalExercise(
      courseId: 'ir-logs',
      title: 'Le compte utilisé',
      instruction:
          'Trouvez avec quel compte l\'adresse 203.0.113.7 a réussi à se '
          'connecter (logs/auth.log).',
      checks: [
        _out('La connexion réussie apparaît', ['Accepted password for backup']),
      ],
      hint: 'Une connexion réussie contient « Accepted ».',
      solution: 'grep Accepted logs/auth.log | grep 203.0.113.7',
    ),
  ])
    e.courseId: e,
};
