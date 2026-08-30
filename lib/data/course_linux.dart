import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> linuxCourses() => [
  _term(),
  _fs(),
  _navigation(),
  _users(),
  _groups(),
  _permissions(),
  _chmod(),
  _chown(),
  _sudo(),
  _processes(),
  _services(),
  _systemd(),
  _logs(),
  _network(),
  _packages(),
  _variables(),
  _pipes(),
  _grep(),
  _find(),
  _curl(),
  _ssh(),
];

Course _term() => Course(
  id: 'lin-terminal',
  title: 'Le terminal Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre ce qu\'est un terminal',
    'Découvrir le shell et l\'invite de commandes',
    'Exécuter ses premières commandes',
  ],
  prerequisites: ['Niveau 0 et 1 recommandés'],
  sections: [
    sec('C\'est quoi un terminal ?', [
      text(
        'Le terminal (ou console) est une interface en mode texte qui permet de piloter l\'ordinateur en tapant des commandes. Contrairement à l\'interface graphique (souris, fenêtres), on contrôle tout par le clavier.',
      ),
      text(
        'En cybersécurité, le terminal est INDISPENSABLE : la majorité des outils (nmap, grep, python, etc.) s\'utilisent en ligne de commande. Maîtriser le terminal, c\'est débloquer la puissance de Linux.',
      ),
    ]),
    sec('Le shell', [
      text(
        'Le shell est le programme qui interprète vos commandes. Sous Linux, le shell le plus courant est Bash (Bourne Again SHell). Il lit votre commande, l\'exécute et affiche le résultat.',
      ),
      text(
        'Lorsque vous ouvrez un terminal, vous voyez une "invite" (prompt) qui vous attend, par exemple :',
      ),
      code('learner@cyberlab:~\$', label: 'Prompt'),
      text(
        'Signification : utilisateur (learner) @ machine (cyberlab), dans le répertoire ~ (votre dossier personnel). Le \$ indique que vous êtes un utilisateur normal (voir # pour root).',
      ),
    ]),
    sec('Vos premières commandes', [
      text('Voyons quelques commandes de base :'),
      code(
        'whoami            # affiche votre nom d\'utilisateur\n'
        'pwd               # affiche le répertoire courant\n'
        'hostname          # nom de la machine\n'
        'echo "Salut"      # affiche du texte\n'
        'date              # date et heure',
        label: 'Exemples',
      ),
      text(
        'Chaque commande peut avoir des options (commencent par -) et des arguments (les cibles). Exemple : ls -l /home.',
      ),
    ]),
    sec('Essayez dans le terminal simulé', [
      text(
        'Ouvrez le Terminal simulé de l\'application et tapez ces commandes. La pratique est indispensable.',
      ),
      tip(
        'Astuce : pour connaître une commande, tapez "man <commande>" (manuel) ou consultez les fiches Docs.',
      ),
    ]),
  ],
  commonMistakes: [
    'Penser qu\'il faut mémoriser toutes les commandes',
    'Oublier que l\'autocomplétion (TAB) et l\'historique (flèche haut) existent',
  ],
  summary:
      'Le terminal est une interface texte pour piloter Linux. Le shell (Bash) interprète vos commandes affichées après l\'invite.',
  quiz: [
    q(const [
      'q1',
      'Qu\'est-ce que le shell ?',
      'qcm',
      'une coquille d\'escargot|le programme qui interprète vos commandes|un antivirus|un navigateur',
      '1',
      'Le shell interprète et exécute vos commandes. Sous Linux, c\'est souvent Bash.',
    ]),
    q(const [
      'q2',
      'La commande "pwd" affiche...',
      'qcm',
      'le mot de passe|le répertoire de travail courant|le processeur|les périphériques',
      '1',
      'pwd = "print working directory", affiche où vous êtes.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : le \$ dans l\'invite signifie que vous êtes root.',
      'tf',
      'Faux',
      null,
      'Le \$ signifie utilisateur normal. Root est indiqué par #.',
    ]),
    q(const [
      'q4',
      'Dans "ls -l /home", que sont les options et arguments ?',
      'qcm',
      'options: -l, argument: /home|options: /home, argument: -l|tout est option|rien de tout ça',
      '0',
      'Le -l est une option (format détaillé), /home est l\'argument (cible).',
    ]),
  ],
  exercises: [
    ex(
      'Explorer',
      'Dans le terminal simulé, tapez pwd, whoami, hostname et echo. Notez ce que chacun affiche.',
    ),
  ],
  xp: 100,
);

Course _fs() => Course(
  id: 'lin-filesystem',
  title: 'Le système de fichiers Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre la hiérarchie des répertoires Linux',
    'Connaître le rôle des dossiers principaux',
    'Comprendre la notion de chemin',
  ],
  prerequisites: ['Le terminal Linux'],
  sections: [
    sec('Une arborescence unique', [
      text(
        'Contrairement à Windows (où chaque disque a sa lettre C:, D:...), Linux organise TOUT dans une seule arborescence qui part de la racine /. Les disques et partitions sont "montés" dans des dossiers.',
      ),
      text(
        'Exemple : votre disque dur externe sera accessible dans /media/... et non D:\\. Tout est un dossier ou un fichier dans l\'arborescence.',
      ),
    ]),
    sec('Les répertoires principaux', [
      list(
        '- **/** : la racine, tout part d\'ici.\n'
        '- **/home** : les dossiers personnels des utilisateurs (ex: /home/learner).\n'
        '- **/etc** : fichiers de configuration du système.\n'
        '- **/var** : données variables (logs dans /var/log, mail...).\n'
        '- **/usr** : logiciels installés (programmes, bibliothèques).\n'
        '- **/bin** et **/sbin** : binaires (commandes) essentielles.\n'
        '- **/tmp** : fichiers temporaires.\n'
        '- **/dev** : périphériques.\n'
        '- **/proc** : informations sur les processus et le système en cours.',
      ),
      warn(
        'En cybersécurité, les répertoires critiques à surveiller : /etc (config), /var/log (logs), /home (données utilisateurs).',
      ),
    ]),
    sec('Chemins absolus et relatifs', [
      text('Un chemin peut être :'),
      list(
        '- **Absolu** : commence par / et décrit tout le chemin depuis la racine. Ex : /home/learner/logs.\n'
        '- **Relatif** : décrit le chemin depuis là où vous êtes. Ex : entrez dans logs si vous êtes dans /home/learner.\n'
        '- **.** = répertoire courant, **..** = répertoire parent.',
      ),
      code(
        'cd /home/learner   # allez dans learner (chemin absolu)\n'
        'cd logs            # entrez dans logs (relatif)\n'
        'cd ..              # revenez au dossier parent',
        label: 'Exemples',
      ),
    ]),
    sec('Fichiers cachés', [
      text(
        'Les fichiers dont le nom commence par un point (.) sont cachés par défaut. Ex : .bashrc, .ssh. Utilisez ls -a pour les voir.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre chemin absolu et relatif',
    'Oublier que Linux est sensible à la casse (File ≠ file)',
  ],
  summary:
      'Linux organise tout sous une racine /, avec des dossiers standard (etc, var, home...). Les chemins se naviguent en absolu ou relatif.',
  quiz: [
    q(const [
      'q1',
      'La racine du système de fichiers Linux est...',
      'qcm',
      'C:/|/|\\|deux points',
      '1',
      'Tout part de la racine "/".',
    ]),
    q(const [
      'q2',
      'Les fichiers de configuration du système sont dans...',
      'qcm',
      '/home|/etc|/tmp|/dev',
      '1',
      '/etc contient les fichiers de configuration.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : sur Linux, "Fichier" et "fichier" sont identiques.',
      'tf',
      'Faux',
      null,
      'Linux est sensible à la casse : les noms diffèrent.',
    ]),
    q(const [
      'q4',
      'Quel chemin est absolu ?',
      'qcm',
      '../logs|logs|/home/learner/logs|documents/',
      '2',
      'Un chemin absolu commence par /. Les autres sont relatifs.',
    ]),
  ],
  exercises: [
    ex(
      'Explorer l\'arborescence',
      'Dans le terminal simulé, tapez "ls", puis "tree" pour visualiser la structure. Identifiez /etc, /var, /home.',
    ),
  ],
  xp: 100,
);

Course _navigation() => Course(
  id: 'lin-navigation',
  title: 'Naviguer et manipuler les fichiers',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Maîtriser ls, cd, pwd',
    'Créer, copier, déplacer, supprimer des fichiers',
    'Comprendre les critères glob (wildcards)',
  ],
  prerequisites: ['Le terminal Linux', 'Système de fichiers'],
  sections: [
    sec('Les commandes de navigation', [
      code(
        'pwd        # où suis-je ?\n'
        'ls         # liste le contenu du dossier\n'
        'ls -l      # liste détaillée (permissions, taille, date)\n'
        'ls -a      # inclut les fichiers cachés\n'
        'ls -h      # tailles lisibles (Ko, Mo)\n'
        'cd dossier # entre dans un dossier\n'
        'cd ..      # remonte d\'un niveau\n'
        'cd ~       # va dans votre dossier personnel',
        label: 'Navigation',
      ),
      text(
        'ls -l donne une ligne par fichier. La 1ère colonne indique le type et les permissions (voir cours chmod).',
      ),
    ]),
    sec('Manipuler fichiers et dossiers', [
      code(
        'touch fichier.txt   # crée un fichier vide\n'
        'mkdir dossier       # crée un dossier\n'
        'cp source cible     # copie\n'
        'mv source cible     # déplace OU renomme\n'
        'rm fichier          # supprime un fichier\n'
        'rm -r dossier       # supprime un dossier et son contenu\n'
        'cat fichier         # affiche le contenu\n'
        'less fichier        # affiche avec pagination\n'
        'head fichier        # premières lignes\n'
        'tail fichier        # dernières lignes',
        label: 'Manipulation',
      ),
      warn(
        'Attention à "rm -rf /" : cela détruit tout le système (r = récursif, f = forcer). C\'est l\'exemple type de commande destructrice. Ne l\'utilisez JAMAIS hors laboratoire.',
      ),
    ]),
    sec('Les jokers (wildcards) avec * et ?', [
      text('Les jokers permettent de viser plusieurs fichiers :'),
      code(
        'ls *.log      # tous les fichiers finissant par .log\n'
        'ls log?.txt   # log1.txt, logA.txt... (? = 1 caractère)\n'
        'rm *~         # supprime les fichiers de sauvegarde',
        label: 'Wildcards',
      ),
    ]),
    sec('Redirections basiques', [
      text(
        'La sortie d\'une commande peut être redirigée vers un fichier avec > (écraser) ou >> (ajouter).',
      ),
      code(
        'echo "hello" > fichier.txt     # écrit hello dans fichier\n'
        'echo "ligne2" >> fichier.txt   # ajoute ligne2 au bout',
        label: 'Redirection',
      ),
      text(
        'Les redirections seront approfondies dans le cours Pipes et redirections.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser "rm -rf" sans vérifier le chemin',
    'Confondre cp et mv',
    'Oublier que rm supprime définitivement (pas de corbeille)',
  ],
  summary:
      'ls, cd, cp, mv, rm, mkdir, cat, head, tail et les jokers permettent de naviguer et manipuler l\'arborescence.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande copie un fichier ?',
      'qcm',
      'mv|cp|rm|cd',
      '1',
      'cp copie, mv déplace/renomme, rm supprime.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : rm supprime définitivement sans corbeille.',
      'tf',
      'Vrai',
      null,
      'Sous Linux, rm efface directement. Pas de corbeille par défaut.',
    ]),
    q(const [
      'q3',
      'Un fichier dont le nom est "log?.txt" correspond à...',
      'qcm',
      'log.txt exclusivement|un fichier avec 1 caractère entre log et txt (ex log1.txt)|n\'importe quel fichier|logAAA.txt',
      '1',
      'Le ? remplace exactement un caractère.',
    ]),
    q(const [
      'q4',
      'Quelle commande affiche les dernières lignes d\'un fichier ?',
      'qcm',
      'head|tail|cat|less',
      '1',
      'tail affiche la fin, head le début.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Dans le terminal simulé, "touch log1.txt", "mkdir scripts", "ls -l", "cp log1.txt scripts/", "mv scripts/log1.txt notes.txt". Observez chaque sortie.',
    ),
  ],
  xp: 100,
);

Course _users() => Course(
  id: 'lin-users',
  title: 'Les utilisateurs Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre la notion d\'utilisateur',
    'Connaître root et les comptes système',
    'Gérer les utilisateurs',
  ],
  prerequisites: ['Terminal Linux', 'Système de fichiers'],
  sections: [
    sec('Qu\'est-ce qu\'un utilisateur ?', [
      text(
        'Linux est un système multi-utilisateurs : chaque personne (ou processus) agit sous une identité avec des droits précis. Chaque utilisateur possède un UID (identifiant numérique), un nom, un dossier personnel et un shell.',
      ),
      text(
        'Les actions effectuées sont attribuées à cet utilisateur : c\'est la base des permissions et de la traçabilité des logs.',
      ),
    ]),
    sec('Root', [
      text(
        'Root est le super-utilisateur : il a TOUS les droits sur la machine, sans restriction. C\'est un compte très puissant et donc dangereux s\'il est compromis ou mal utilisé.',
      ),
      warn(
        'On évite de travailler en root au quotidien. On préfère un compte normal et on utilise "sudo" ponctuellement pour les opérations à privilèges.',
      ),
    ]),
    sec('Comptes système et utilisateurs', [
      text(
        'On distingue : les comptes humains (dans /home) et les comptes système (services comme www-data, nobody) qui n\'ont pas de dossier personnel et servent à isoler les services.',
      ),
      code(
        'whoami                # utilisateur courant\n'
        'id                    # uid, gid, groupes\n'
        'who                   # utilisateurs connectés',
        label: 'Voir',
      ),
    ]),
    sec('Commandes de gestion', [
      code(
        'sudo useradd -m alice   # crée l\'utilisateur alice avec /home/alice\n'
        'sudo userdel -r alice   # supprime alice et son dossier\n'
        'sudo passwd alice       # définit son mot de passe\n'
        'su - alice              # change d\'utilisateur',
        label: 'Gestion',
      ),
      tip(
        'En cybersécurité, on crée souvent des utilisateurs par service pour minimiser les droits (principe du moindre privilège).',
      ),
    ]),
  ],
  commonMistakes: [
    'Travailler tout le temps en root',
    'Créer un utilisateur avec trop de droits',
  ],
  summary:
      'Linux est multi-utilisateurs. Root a tous les droits, on préfère des comptes dédiés avec sudo pour limiter les risques.',
  quiz: [
    q(const [
      'q1',
      'Quel utilisateur a tous les droits ?',
      'qcm',
      'root|nobody|www-data|learner',
      '0',
      'Root est le super-utilisateur avec tous les droits.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : on recommande de travailler toujours en root.',
      'tf',
      'Faux',
      null,
      'On évite root au quotidien, on utilise sudo ponctuellement.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi est-ce une bonne pratique d\'avoir un compte normal plutôt que de tout faire en root ?',
    ),
  ],
  xp: 80,
);

Course _groups() => Course(
  id: 'lin-groups',
  title: 'Les groupes Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le rôle des groupes',
    'Gérer les groupes',
    'Comprendre le moindre privilège',
  ],
  prerequisites: ['Les utilisateurs Linux'],
  sections: [
    sec('À quoi servent les groupes ?', [
      text(
        'Un groupe est un ensemble d\'utilisateurs partageant des droits communs. Les groupes simplifient la gestion des permissions : au lieu de donner un accès à 10 personnes une à une, on crée un groupe et on l\'associe aux fichiers.',
      ),
      code(
        'groups            # groupes de l\'utilisateur courant\n'
        'id                # uid, gid de l\'utilisateur\n'
        'groupadd devs     # crée le groupe devs\n'
        'usermod -aG devs alice   # ajoute alice au groupe devs\n'
        'groupdel devs     # supprime le groupe',
        label: 'Gestion des groupes',
      ),
    ]),
    sec('Le principe du moindre privilège', [
      text(
        'Le principe du moindre privilège veut qu\'un utilisateur n\'ait que les droits strictement nécessaires à son travail. C\'est une règle d\'or en sécurité : limiter les accès limite les dégâts en cas de compromission.',
      ),
      text(
        'Un utilisateur peut appartenir à un groupe principal (son groupe par défaut) et plusieurs groupes secondaires. Un fichier créé appartient au groupe principal de son créateur.',
      ),
    ]),
    sec('Cas pratique en sécurité', [
      text(
        'Imaginons : seuls les membres du groupe "admin-serveur" peuvent lire les logs sensibles. On associe donc le fichier /var/log/auth.log au groupe admin-serveur avec les bonnes permissions (voir cours permissions/chmod).',
      ),
    ]),
  ],
  commonMistakes: [
    'Ajouter trop d\'utilisateurs au groupe sudo/root',
    'Ne pas se servir des groupes pour gérer les accès',
  ],
  summary:
      'Les groupes regroupent des utilisateurs pour partager des droits. Le moindre privilège limite les risques.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande ajoute un utilisateur à un groupe ?',
      'qcm',
      'groupdel|usermod -aG groupe user|userdel|passwd',
      '1',
      'usermod -aG ajoute (a=append) au groupe.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Donnez un exemple où l\'utilisation d\'un groupe rend la gestion des accès plus simple et plus sûre.',
    ),
  ],
  xp: 80,
);

Course _permissions() => Course(
  id: 'lin-permissions',
  title: 'Comprendre les permissions',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Lire les permissions',
    'Distinguer r, w, x',
    'Comprendre propriétaire, groupe, autres',
  ],
  prerequisites: ['Utilisateurs et groupes'],
  sections: [
    sec('Les permissions en bref', [
      text(
        'Chaque fichier a un propriétaire et un groupe, et trois types de droits pour trois catégories de personnes :',
      ),
      list(
        '- Le **propriétaire** (u).\n'
        '- Le **groupe** (g).\n'
        '- Les **autres** (o).',
      ),
      text('Les droits sont : lire (r), écrire (w), exécuter (x).'),
    ]),
    sec('Comment lire ls -l', [
      text(
        'La première colonne de "ls -l" décrit le type et les permissions, exemple :',
      ),
      code(
        '-rw-r--r--  1  alice  devs  1200  Aug 28 06:00  fichier.txt',
        label: 'Exemple',
      ),
      text('Le décoder :'),
      code(
        '-    rw-   r--   r--\n'
        'type ure  grp   autres\n'
        'type: - fichier, d dossier\n'
        'rw-  propriétaire (alice) : lecture+écriture\n'
        'r--  groupe (devs) : lecture seule\n'
        'r--  autres : lecture seule',
        label: 'Décodage',
      ),
      text(
        'Pour les dossiers (d...), le x (exécuter) signifie "pouvoir entrer dedans" (y naviguer).',
      ),
    ]),
    sec('Les droits r, w, x en détail', [
      text(
        'Sur un fichier : r = lire le contenu, w = modifier, x = exécuter comme programme.\n'
        'Sur un dossier : r = lister le contenu, w = créer/supprimer des fichiers dedans, x = entrer dans le dossier (cd).',
      ),
    ]),
    sec('Pourquoi c\'est important en sécurité', [
      text(
        'Des permissions mal configurées sont une vulnérabilité fréquente : un fichier de mots de passe lisible par tous, un dossier écrit par n\'importe qui... C\'est une cause majeure de compromission.',
      ),
      warn(
        'Toujours vérifier les permissions des fichiers sensibles : /etc/shadow, clés SSH, fichiers de config.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier que x sur un dossier = pouvoir y entrer',
    'Laisser des fichiers sensibles en lecture pour tous',
  ],
  summary:
      'Chaque fichier a un propriétaire, un groupe, et des droits (r, w, x) pour trois catégories. Les permissions mal réglées sont une faille fréquente.',
  quiz: [
    q(const [
      'q1',
      'Dans "-rwxr--r--", le propriétaire peut...',
      'qcm',
      'lire, écrire, exécuter|lire seulement|écrire seulement|rien',
      '0',
      'rwx avant le premier - : le propriétaire lit, écrit, exécute.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : sur un dossier, le droit x permet d\'y entrer.',
      'tf',
      'Vrai',
      null,
      'Pour un dossier, x = pouvoir naviguer dedans (cd).',
    ]),
  ],
  exercises: [
    ex(
      'Décodage',
      'Expliquez en toutes lettres ce que signifie : "-rwxr-xr--" pour chaque catégorie (propriétaire, groupe, autres).',
    ),
  ],
  xp: 90,
);

Course _chmod() => Course(
  id: 'lin-chmod',
  title: 'Modifier les permissions avec chmod',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Utiliser chmod en notation symbolique',
    'Utiliser chmod en notation numérique',
    'Appliquer des permissions sûres',
  ],
  prerequisites: ['Comprendre les permissions'],
  sections: [
    sec('Présentation de chmod', [
      text(
        'chmod (change mode) modifie les permissions d\'un fichier ou dossier. Deux notations existent : symbolique et numérique (octale).',
      ),
      code(
        'chmod u+x script.sh   # permet au propriétaire d\'exécuter\n'
        'chmod g-w fichier     # retire l\'écriture au groupe\n'
        'chmod o+r fichier     # donne la lecture aux autres',
        label: 'Notation symbolique',
      ),
    ]),
    sec('Notation symbolique', [
      text(
        'On combine : la cible (u propriétaire, g groupe, o autres, a tous), l\'opération (+ ajouter, - retirer, = fixer exactement), et le droit (r, w, x).',
      ),
      code(
        'u+x   ajoute exécution au propriétaire\n'
        'a+r   ajoute lecture à tous\n'
        'g-wx  retire écriture et exécution au groupe\n'
        'u=rwx fixe exactement rwx pour le propriétaire',
        label: 'Symboles',
      ),
    ]),
    sec('Notation numérique (octale)', [
      text(
        'Chaque droit vaut un nombre : r=4, w=2, x=1. On additionne pour chaque catégorie, ce qui donne 3 chiffres (propriétaire, groupe, autres).',
      ),
      code(
        '7 = rwx (4+2+1)\n'
        '6 = rw- (4+2)\n'
        '5 = r-x (4+1)\n'
        '4 = r--\n'
        'chmod 755 script.sh        # rwxr-xr-x\n'
        'chmod 600 secret.txt       # rw-------\n'
        'chmod 644 page.html        # rw-r--r--',
        label: 'Numérique',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Les scripts exécutables : 755.\n'
        '- Les fichiers sensibles (clés, secrets) : 600.\n'
        '- Les fichiers web publics : 644.\n'
        '- Un dossier personnel : 700 ou 750.',
      ),
      warn(
        'Ne jamais donner de droits d\'écriture à "autres" sur des fichiers système ou des dossiers de stockage.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser chmod 777 partout (tout le monde peut tout)',
    'Donner x (exécution) inutilement',
  ],
  summary:
      'chmod modifie les permissions en notation symbolique (u+x) ou numérique (755). On applique toujours le moindre privilège.',
  quiz: [
    q(const [
      'q1',
      'chmod 600 donne...',
      'qcm',
      'lecture+écriture au propriétaire seulement|tout à tous|lecture à tous|exécution à tous',
      '0',
      '600 = rw------- : propriétaire lit+écrit, rien pour les autres.',
    ]),
    q(const [
      'q2',
      'En octal, r-x vaut...',
      'qcm',
      '5|4|6|7',
      '0',
      'r=4 + x=1 = 5.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : chmod 777 est une bonne pratique recommandée.',
      'tf',
      'Faux',
      null,
      '777 donne tous les droits à tous, à éviter absolument.',
    ]),
  ],
  exercises: [
    ex(
      'Appliquer',
      'Traduisez en notation numérique : "rwxr-xr-x", "rw-------", "rw-r--r--". Vérifiez que vous trouvez 755, 600, 644.',
    ),
  ],
  xp: 100,
);

Course _chown() => Course(
  id: 'lin-chown',
  title: 'Changer le propriétaire avec chown',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le rôle de chown',
    'Changer propriétaire et groupe',
    'Appliquer le moindre privilège',
  ],
  prerequisites: ['Utilisateurs, groupes, permissions, chmod'],
  sections: [
    sec('Présentation de chown', [
      text(
        'chown (change owner) change le propriétaire et/ou le groupe d\'un fichier. C\'est une opération qui nécessite les privilèges root (sudo).',
      ),
      code(
        'sudo chown alice fichier.txt       # propriétaire = alice\n'
        'sudo chown alice:devs fichier.txt  # propriétaire et groupe\n'
        'sudo chown :devs fichier.txt      # change seulement le groupe',
        label: 'Exemples',
      ),
    ]),
    sec('Pourquoi c\'est important', [
      text(
        'Attribuer le bon propriétaire et le bon groupe est essentiel pour les permissions. Un fichier appartient à une mauvaise personne → soit il est inaccessible, soit trop accessible.',
      ),
      text(
        'Exemple : un site web doit être lisible par le serveur web (www-data) mais modifiable uniquement par l\'administrateur. On définit le propriétaire et le groupe en conséquence.',
      ),
    ]),
    sec('Cas pratique', [
      code(
        '# Donner le dossier web au groupe devs en lecture\n'
        'sudo chown root:devs /var/www/site\n'
        'sudo chmod 750 /var/www/site\n'
        '# Le propriétaire (root) et le groupe (devs) accèdent,\n'
        '# les autres non.',
        label: 'Bonnes pratiques',
      ),
    ]),
  ],
  commonMistakes: [
    'Changer le propriétaire d\'un fichier en laissant des droits inadaptés',
    'Oublier de vérifier le groupe',
  ],
  summary:
      'chown change le propriétaire et le groupe d\'un fichier, essentiel pour adapter les permissions au moindre privilège.',
  quiz: [
    q(const [
      'q1',
      'Chown exige le plus souvent...',
      'qcm',
      'aucun droit|sudo/root|un antivirus|être en ligne',
      '1',
      'Changer le propriétaire est une opération privilégiée (sudo).',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Expliquez comment vous donneriez un dossier web en lecture au groupe "devs" tout en interdisant les autres.',
    ),
  ],
  xp: 80,
);

Course _sudo() => Course(
  id: 'lin-sudo',
  title: 'sudo et les élévations de privilèges',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre sudo',
    'Savoir quand l\'utiliser',
    'Comprendre les risques',
  ],
  prerequisites: ['Utilisateurs et permissions'],
  sections: [
    sec('C\'est quoi sudo ?', [
      text(
        'sudo (superuser do) permet d\'exécuter une commande avec les privilèges d\'un autre utilisateur (par défaut root), de manière ponctuelle et encadrée. C\'est plus sûr que de se connecter en root en permanence.',
      ),
      code(
        'sudo apt install nmap      # installe nmap avec les droits root\n'
        'sudo cat /etc/shadow      # lit un fichier sensible réservé à root',
        label: 'Exemples',
      ),
    ]),
    sec('Comment sudo vérifie', [
      text(
        'sudo vérifie que vous êtes dans la liste autorisée (fichier /etc/sudoers) : qui peut exécuter quoi. Par défaut, les membres du groupe sudo ou wheel peuvent tout exécuter, moyennant leur mot de passe.',
      ),
    ]),
    sec('Les risques', [
      text(
        'Donner sudo sans restriction (= pouvoir tout faire) à beaucoup d\'utilisateurs revient à donner root à beaucoup de monde. C\'est un risque.',
      ),
      warn(
        'En pentest/CTF, "élever ses privilèges" (passer d\'utilisateur normal à root) est un objectif classique. Vérifiez toujours les droits sudo accordés : "sudo -l" les liste.',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Utiliser sudo ponctuellement, pas en permanence.\n'
        '- Restreindre dans /etc/sudoers les commandes autorisées.\n'
        '- Surveiller qui est dans le groupe sudo.\n'
        '- Utiliser "sudo -l" pour voir vos droits.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser sudo pour tout, sans réfléchir',
    'Ajouter trop d\'utilisateurs au groupe sudo',
  ],
  summary:
      'sudo exécute une commande avec privilèges de façon ponctuelle. C\'est plus sûr que root permanent, mais à limiter.',
  quiz: [
    q(const [
      'q1',
      'sudo permet de...',
      'qcm',
      'exécuter une commande avec privilèges élevés ponctuellement|naviguer sur internet|crypter des fichiers à coup sûr|éviter les antivirus',
      '0',
      'sudo élève ponctuellement les privilèges pour une commande.',
    ]),
  ],
  exercises: [
    ex(
      'Sécurité',
      'Pourquoi est-il préférable de limiter les commandes autorisées via sudo plutôt que de tout autoriser ?',
    ),
  ],
  xp: 80,
);

Course _processes() => Course(
  id: 'lin-processes',
  title: 'Gérer les processus',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre ce qu\'est un processus',
    'Lister et surveiller les processus',
    'Tuer un processus',
  ],
  prerequisites: ['Terminal Linux'],
  sections: [
    sec('C\'est quoi un processus ?', [
      text(
        'Un processus est un programme en cours d\'exécution. Chaque programme lancé (navigateur, serveur, commande) devient un ou plusieurs processus, chacun avec un PID (identifiant de processus).',
      ),
    ]),
    sec('Lister les processus', [
      code(
        'ps              # processus de votre session\n'
        'ps aux          # tous les processus, détaillés\n'
        'ps -ef          # tous les processus au format complet\n'
        'top             # processus en temps réel (ressources)\n'
        'htop            # version améliorée de top',
        label: 'Voir les processus',
      ),
      text(
        'Dans ps aux, la colonne USER indique qui lance le processus, PID son identifiant, %CPU/%MEM les ressources, et COMMAND la commande exacte (utile pour repérer un processus suspect).',
      ),
    ]),
    sec('Signaux et terminaison', [
      text(
        'On envoie des signaux aux processus. Le plus courant : SIGTERM (15, demande polie d\'arrêt) et SIGKILL (9, arrêt forcé).',
      ),
      code(
        'kill 1234                 # envoie SIGTERM au PID 1234\n'
        'kill -9 1234             # force l\'arrêt (SIGKILL)\n'
        'pkill firefox            # tue tous les processus firefox\n'
        'killall nom_commande     # tue tous les processus par nom',
        label: 'Arrêter',
      ),
      warn(
        'kill -9 est brutal : le processus est tué sans pouvoir sauvegarder. Préférez d\'abord SIGTERM (kill simple).',
      ),
    ]),
    sec('Les processus en sécurité', [
      text(
        'Un attaquant exécute souvent des processus cachés ou nommés de façon trompeuse. Surveiller ps aux et top aide à détecter des activités anormales (CPU élevé, processus inconnus).',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre un processus anodin et un malveillant',
    'Utiliser kill -9 systématiquement',
  ],
  summary:
      'Un processus est un programme en exécution. ps/top les lister, kill les arrête. Leur surveillance aide à détecter des anomalies.',
  quiz: [
    q(const [
      'q1',
      'Le PID est...',
      'qcm',
      'l\'identifiant du processus|le chemin du programme|un mot de passe|un port réseau',
      '0',
      'PID = Process ID, identifiant unique du processus.',
    ]),
    q(const [
      'q2',
      'Quelle commande affiche tous les processus ?',
      'qcm',
      'ps aux|whoami|cd|touch',
      '0',
      'ps aux liste tous les processus.',
    ]),
  ],
  exercises: [
    ex(
      'Observer',
      'Dans le terminal simulé, tapez "ps aux". Identifiez les colonnes et devinez quel processus pourrait être la simulation d\'un scan nmap.',
    ),
  ],
  xp: 90,
);

Course _services() => Course(
  id: 'lin-services',
  title: 'Les services Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre ce qu\'est un service',
    'Démarrer, arrêter et surveiller un service',
    'Prendre conscience des services exposés',
  ],
  prerequisites: ['Processus'],
  sections: [
    sec('Qu\'est-ce qu\'un service ?', [
      text(
        'Un service (ou daemon) est un programme qui tourne en arrière-plan, sans interface, pour fournir une fonctionnalité : serveur web (Apache/nginx), SSH, base de données, etc.',
      ),
      text(
        'Un service écoute souvent un port réseau pour accepter des connexions. Comprendre les services = comprendre les ports ouverts = comprendre la surface d\'attaque.',
      ),
    ]),
    sec('Gérer un service', [
      text(
        'La gestion moderne des services passe par systemctl (voir cours systemd). Mais voici l\'essentiel :',
      ),
      code(
        'sudo systemctl start  ssh       # démarre le service ssh\n'
        'sudo systemctl stop   ssh       # l\'arrête\n'
        'sudo systemctl restart ssh      # le redémarre\n'
        'sudo systemctl status ssh       # son état\n'
        'sudo systemctl enable ssh       # démarre au boot\n'
        'sudo systemctl disable ssh      # ne démarre pas au boot',
        label: 'systemctl',
      ),
    ]),
    sec('Quels services écouter ?', [
      text(
        'La commande ss montre les ports en écoute. Réduisez les services actifs au strict minimum : chaque service exposé augmente la surface d\'attaque.',
      ),
      code(
        'ss -tlnp    # ports TCP en écoute avec le processus',
        label: 'Ports en écoute',
      ),
    ]),
    sec('Sécurité des services', [
      text(
        'Beaucoup de vulnérabilités viennent de services exposés inutilement, mal configurés, ou jamais mis à jour. Désactivez ce qui ne sert pas et mettez à jour régulièrement.',
      ),
      warn(
        'Le volet "vérification de services" est un exercice classique de la Blue Team : lister les services, identifier les anomalies.',
      ),
    ]),
  ],
  commonMistakes: [
    'Laisser des services inutiles actifs et exposés',
    'Ignorer l\'état des services',
  ],
  summary:
      'Les services tournent en arrière-plan et écoutent des ports. On les gère avec systemctl et on en réduit le nombre pour limiter la surface d\'attaque.',
  quiz: [
    q(const [
      'q1',
      'Quel commande affiche l\'état d\'un service ?',
      'qcm',
      'sudo systemctl status <service>|date|pwd|ls',
      '0',
      'systemctl status montre l\'état du service.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : un service expose toujours un port réseau.',
      'tf',
      'Faux',
      null,
      'Un service peut être local ou interne sans port réseau exposé.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Avec ss -tlnp, dressez la liste des ports en écoute. Pourquoi est-ce important pour la sécurité ?',
    ),
  ],
  xp: 90,
);

Course _systemd() => Course(
  id: 'lin-systemd',
  title: 'systemd et le démarrage',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le rôle de systemd',
    'Manipuler systemctl et journalctl',
    'Créer un service',
  ],
  prerequisites: ['Services Linux'],
  sections: [
    sec('C\'est quoi systemd ?', [
      text(
        'systemd est le gestionnaire de systèmes et de services utilisé par la majorité des distributions Linux modernes. Il est responsable du démarrage, de la gestion des services (unités) et de la journalisation.',
      ),
      text(
        'Les deux commandes clés : systemctl (gérer les unités/services) et journalctl (lire les journaux).',
      ),
    ]),
    sec('systemctl', [
      code(
        'systemctl list-units --type=service    # tous les services\n'
        'systemctl status ssh                   # état d\'un service\n'
        'systemctl start/stop/restart ssh       # contrôler\n'
        'systemctl enable/disable ssh           # au boot\n'
        'systemctl is-enabled ssh               # activé au boot ?',
        label: 'systemctl',
      ),
    ]),
    sec('Les unités (fichiers .service)', [
      text(
        'Chaque service a une définition dans /etc/systemd/system/ (ou /lib/systemd/system/) : typiquement un fichier .service décrivant quoi lancer et comment.',
      ),
      code(
        '[Unit]\n'
        'Description=Mon service de démo\n'
        'After=network.target\n'
        '\n'
        '[Service]\n'
        'ExecStart=/usr/bin/monscript.sh\n'
        'User=demo\n'
        'Restart=on-failure\n'
        '\n'
        '[Install]\n'
        'WantedBy=multi-user.target',
        label: 'Exemple de .service',
      ),
    ]),
    sec('journalctl pour les logs', [
      text('systemd centralise les journaux, consultables avec journalctl :'),
      code(
        'journalctl -u ssh          # logs du service ssh\n'
        'journalctl -u ssh -f       # suivi en direct (-f follow)\n'
        'journalctl -b              # logs depuis le dernier boot\n'
        'journalctl -p err          # seulement les erreurs',
        label: 'journalctl',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre systemctl et journalctl',
    'Oublier "enable" pour persister au reboot',
  ],
  summary:
      'systemd gère le démarrage et les services. systemctl contrôle les services, journalctl lit leurs journaux centralisés.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande lis les journaux systemd ?',
      'qcm',
      'journalctl|systemctl enable|pwd|rm',
      '0',
      'journalctl sert à lire les journaux centralisés.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : systemctl enable fait démarrer le service au reboot.',
      'tf',
      'Vrai',
      null,
      'enable configure le service pour démarrer au boot.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Décrivez les champs d\'une unité systemd et ce que "Restart=on-failure" signifie.',
    ),
  ],
  xp: 90,
);

Course _logs() => Course(
  id: 'lin-logs',
  title: 'Les journaux Linux (logs)',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le rôle des logs',
    'Savoir où sont les logs principaux',
    'Lire et exploiter les logs',
  ],
  prerequisites: ['Terminal', 'systemd'],
  sections: [
    sec('Pourquoi les logs sont cruciaux', [
      text(
        'Les journaux (logs) enregistrent les événements du système : connexions, erreurs, services, activité des utilisateurs. En cybersécurité, ils sont la matière première de la détection et de l\'analyse forensique.',
      ),
      text(
        'Sans logs, on ne peut pas savoir ce qui s\'est passé lors d\'un incident. Les logs sont la "mémoire" du système.',
      ),
    ]),
    sec('Les logs principaux', [
      code(
        '/var/log/auth.log     # connexions, sudo, SSH\n'
        '/var/log/syslog       # messages systèmes généraux\n'
        '/var/log/dpkg.log     # installation de paquets\n'
        '/var/log/kern.log     # noyau, matériel\n'
        'journalctl            # journaux centralisés systemd',
        label: 'Emplacements',
      ),
    ]),
    sec('Lire et filtrer les logs', [
      text(
        'On lit les logs avec cat/less/tail, et on filtre avec grep (voir cours grep).',
      ),
      code(
        'tail -n 50 /var/log/auth.log        # 50 dernières lignes\n'
        'grep "Failed password" /var/log/auth.log   # échecs de connexion\n'
        'grep "Accepted" /var/log/auth.log          # connexions réussies',
        label: 'Exploiter',
      ),
    ]),
    sec('Lire un événement', [
      text(
        'Une ligne de log contient : une horodatation, le programme source, le processus, et un message. Exemple :',
      ),
      code(
        'Aug 28 06:02:45 cyberlab sshd[1402]: Failed password for admin from 203.0.113.7 port 51234',
        label: 'Exemple',
      ),
      text(
        'Ici : le 28 août à 06:02:45, sur la machine cyberlab, le service sshd a enregistré un échec de mot de passe pour l\'utilisateur admin, depuis l\'IP 203.0.113.7. C\'est une information d\'investigation précieuse.',
      ),
    ]),
    sec('Logs et sécurité', [
      text(
        'Les tentatives répétées de connexion (brute force), les connexions à des heures inhabituelles, ou depuis des IP inconnues, sont des signaux que les analystes cherchent dans les logs. L\'analyse de logs est un exercice central du SOC.',
      ),
      warn(
        'Conservez des logs intègres et centralisés (SIEM) : ils sont votre meilleur outil d\'investigation après un incident.',
      ),
    ]),
  ],
  commonMistakes: [
    'Négliger les logs (on s\'y penche trop tard)',
    'Ne pas sauvegarder les logs hors du système',
  ],
  summary:
      'Les logs enregistrent les événements du système. auth.log suit les connexions. Ils sont essentiels pour détecter et investiguer.',
  quiz: [
    q(const [
      'q1',
      'Où se trouvent principalement les logs système ?',
      'qcm',
      '/var/log|/etc|/home|/bin',
      '0',
      'Les logs sont dans /var/log.',
    ]),
    q(const [
      'q2',
      'Quelle commande cherche les échecs de connexion ?',
      'qcm',
      'grep "Failed password" /var/log/auth.log|ls /var|cd /|pwd',
      '0',
      'grep filtre les lignes contenant "Failed password" dans auth.log.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : les logs servent uniquement à afficher le temps.',
      'tf',
      'Faux',
      null,
      'Les logs documentent les événements, cruciaux pour la détection et l\'investigation.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser un log',
      'Voici un extrait : "Aug 28 06:03:11 cyberlab sshd[1403]: Failed password for root from 203.0.113.7". Que révèle ce log et que feriez-vous ?',
    ),
  ],
  xp: 100,
);

Course _network() => Course(
  id: 'lin-network',
  title: 'Réseau sous Linux',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Voir la configuration réseau',
    'Tester la connectivité',
    'Utiliser les outils réseau de base',
  ],
  prerequisites: ['Niveau 1 Réseau', 'Terminal'],
  sections: [
    sec('Configuration réseau', [
      text(
        'Linux fournit des commandes pour inspecter et configurer le réseau :',
      ),
      code(
        'ip addr     # adresses IP des interfaces\n'
        'ip route    # table de routage (la passerelle "default")\n'
        'ip link     # interfaces (état, MAC)\n'
        'ifconfig    # ancienne commande, encore utilisée\n'
        'ss -tlnp    # ports en écoute',
        label: 'Voir le réseau',
      ),
    ]),
    sec('Tester la connectivité', [
      text('Diagnostiquer un problème réseau se fait par étapes :'),
      code(
        'ping 8.8.8.8    # test IP (hors DNS)\n'
        'ping google.com # test IP + DNS\n'
        'nslookup domain.com   # vérifie la résolution DNS\n'
        'dig domain.com        # interrogation DNS détaillée\n'
        'curl -v https://site.com   # test HTTP détaillé',
        label: 'Diagnostic',
      ),
      text(
        'Si ping IP fonctionne mais pas ping nom de domaine, le problème vient du DNS. Si tout échoue, vérifiez la liaison et la passerelle.',
      ),
    ]),
    sec('Analyse des ports et services', [
      text(
        'Pour cartographier les services exposés, on utilise des outils comme nmap (voir niveau Réseau). Toujours sur des cibles autorisées/localhost.',
      ),
      code('nmap localhost     # scan basique local', label: 'Exemple sûr'),
    ]),
    sec('Sécurité réseau', [
      text(
        'Surveillez les connexions actives avec "ss" ou "netstat". Un processus qui initie des connexions sortantes inhabituelles peut signaler une compromission (exfiltration de données, C&C).',
      ),
      code(
        'ss -tunap    # connexions TCP/UDP actives avec processus',
        label: 'Connexions actives',
      ),
    ]),
  ],
  commonMistakes: [
    'Scanner des machines sans autorisation',
    'Oublier de distinguer problème IP vs DNS vs application',
  ],
  summary:
      'ip addr/route, ping, nslookup/dig et ss permettent de diagnostiquer et surveiller le réseau Linux. Toujours sur cibles autorisées.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande montre les adresses IP ?',
      'qcm',
      'ip addr|ls|whoami|touch',
      '0',
      'ip addr affiche les adresses IP des interfaces.',
    ]),
  ],
  exercises: [
    ex(
      'Diagnostic',
      'Décrivez la démarche pour savoir si un problème est dû au DNS ou au réseau lui-même.',
    ),
  ],
  xp: 90,
);

Course _packages() => Course(
  id: 'lin-packages',
  title: 'Installer des logiciels (paquets)',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le système de paquets',
    'Utiliser apt',
    'Chercher et installer des outils',
  ],
  prerequisites: ['Terminal', 'sudo'],
  sections: [
    sec('La gestion des paquets', [
      text(
        'Linux n\'installe pas les logiciels comme Windows (fichier .exe à double-cliquer). On utilise des gestionnaires de paquets qui téléchargent, installent et gèrent les dépendances depuis des dépôts officiels.',
      ),
      text(
        'Sur Debian/Ubuntu, c\'est apt (et son paquet de gestion dpkg). Ex : sudo apt install nmap.',
      ),
    ]),
    sec('Les commandes apt essentielles', [
      code(
        'sudo apt update                 # met à jour la liste des paquets\n'
        'sudo apt upgrade                # met à jour les logiciels\n'
        'sudo apt install nmap           # installe nmap\n'
        'sudo apt remove nmap            # désinstalle\n'
        'sudo apt search "network scan"  # cherche un paquet\n'
        'apt show nmap                   # infos sur un paquet',
        label: 'apt',
      ),
      text(
        'Toujours commencer par "apt update" avant d\'installer, pour avoir la liste à jour.',
      ),
    ]),
    sec('Les dépôts et la sécurité', [
      text(
        'Installez uniquement depuis les dépôts officiels. Ajouter des dépôts inconnus ou installer des .deb de sources douteuses est un risque majeur de malware et de paquets piégés.',
      ),
      warn(
        'En sécurité, on installe des outils (nmap, tshark, python3, git...) via apt : c\'est la méthode sûre et vérifiée.',
      ),
    ]),
    sec('Outils d\'audit fréquents à installer', [
      code(
        'sudo apt install nmap tshark netcat-openbsd\n'
        'sudo apt install python3 python3-pip\n'
        'sudo apt install git curl wget',
        label: 'Outils courants',
      ),
    ]),
  ],
  commonMistakes: [
    'Installer depuis des sources non officielles',
    'Oublier "apt update" avant install',
  ],
  summary:
      'apt gère les paquets sur Debian/Ubuntu. Installez depuis les dépôts officiels et mettez à jour régulièrement.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande met à jour la liste des paquets ?',
      'qcm',
      'sudo apt update|sudo apt remove|sudo apt search|pwd',
      '0',
      'apt update actualise la liste des paquets disponibles.',
    ]),
  ],
  exercises: [
    ex(
      'Simulation',
      'Dans le terminal simulé, tapez "sudo apt install nmap" et observez le message sur le fonctionnement réel d\'apt.',
    ),
  ],
  xp: 80,
);

Course _variables() => Course(
  id: 'lin-variables',
  title: 'Variables et environnement',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre les variables d\'environnement',
    'Créer et utiliser des variables',
    'Connaître les variables importantes',
  ],
  prerequisites: ['Terminal'],
  sections: [
    sec('Les variables', [
      text(
        'Une variable est un nom qui contient une valeur. Sous Linux, on distingue les variables de shell et les variables d\'environnement (transmises aux programmes lancés).',
      ),
      code(
        'ma_var="valeur"      # crée une variable de shell\n'
        'echo \$ma_var        # affiche sa valeur (préfixe \$)\n'
        'export ma_var       # la rend visible aux programmes lancés',
        label: 'Variables',
      ),
    ]),
    sec('Variables d\'environnement importantes', [
      code(
        'echo \$HOME    # votre dossier personnel\n'
        'echo \$USER    # votre nom d\'utilisateur\n'
        'echo \$PATH    # chemins où Linux cherche les commandes\n'
        'echo \$SHELL   # votre shell\n'
        'echo \$PWD     # répertoire courant',
        label: 'Variables courantes',
      ),
    ]),
    sec('PATH et sécurité', [
      text(
        'PATH liste les dossiers où le système cherche les exécutables. S\'il contient un dossier où un attaquant peut écrire, il peut y placer un faux "ls" ou "sudo" et détourner l\'exécution (c\'est une technique d\'élévation de privilèges classique).',
      ),
      warn(
        'Ne jamais inclure le répertoire courant (.) ou des dossiers anonymes dans PATH.',
      ),
    ]),
    sec('Exemples utiles', [
      code(
        'export MA_VARIABLE="bonjour"\n'
        'echo \$MA_VARIABLE\n'
        '# Dans un script, on utilise \$1 \$2 ... pour les arguments\n'
        'echo \$#    # nombre d\'arguments\n'
        'echo \$?    # code de retour de la dernière commande',
        label: 'Exemples',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier le \$ pour lire la valeur',
    'Confondre variable de shell et d\'environnement',
  ],
  summary:
      'Les variables stockent des valeurs ; le \$ les lit. Elles transmettent la configuration (PATH, HOME) aux programmes.',
  quiz: [
    q(const [
      'q1',
      'Pour afficher la valeur d\'une variable ma_var, on écrit...',
      'qcm',
      'echo \$ma_var|echo ma_var|print ma_var|cat ma_var',
      '0',
      'Le \$ est nécessaire pour lire la valeur.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Dans le terminal simulé, tapez "echo \$HOME", "echo \$USER", "echo \$PATH" et observez. Expliquez à quoi sert PATH.',
    ),
  ],
  xp: 80,
);

Course _pipes() => Course(
  id: 'lin-pipes',
  title: 'Pipes et redirections',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre les redirections',
    'Utiliser les pipes |',
    'Combiner les commandes',
  ],
  prerequisites: ['Navigation', 'grep'],
  sections: [
    sec('Redirection de la sortie', [
      text(
        'Les commandes produisent une sortie (stdout) et peuvent recevoir une entrée (stdin). On peut rediriger la sortie vers un fichier :',
      ),
      code(
        'ls > liste.txt          # écrit la sortie dans liste.txt (écrase)\n'
        'ls >> liste.txt         # ajoute au lieu d\'écraser\n'
        'ls 2> erreurs.txt       # redirige les erreurs\n'
        'cat liste.txt           # relit le fichier',
        label: 'Redirection',
      ),
    ]),
    sec('Les pipes : enchaîner les commandes', [
      text(
        'Le pipe | prend la sortie d\'une commande et la passe en entrée à la suivante. C\'est LA pratique Linux fondamentale pour l\'analyse.',
      ),
      code(
        'ls -l | grep "Aug"           # fichiers de la ligne "Aug"\n'
        'cat log.txt | grep ERROR | wc -l   # compte les erreurs\n'
        'ps aux | grep python         # trouve les processus python',
        label: 'Pipes',
      ),
    ]),
    sec('Exemples d\'analyse', [
      code(
        'grep "Failed" /var/log/auth.log | wc -l\n'
        '    # compte les échecs de connexion\n'
        'history | grep nmap\n'
        '    # retrouve les commandes nmap\n'
        'cat mots.txt | sort | uniq -c | sort -nr\n'
        '    # comptage des occurrences triées',
        label: 'Analyses',
      ),
    ]),
    sec('Le pouvoir de la combinaison', [
      text(
        'Un pipeline enchaîne des commandes simples pour résoudre des problèmes complexes. C\'est la base du scripting et de l\'analyse de logs. On peut enchaîner autant de pipes que nécessaire.',
      ),
      tip(
        'Souvenez-vous : un pipe | enchaîne, une redirection > sauvegarde dans un fichier.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre | et > (pipe vs redirection)',
    'Oublier que > écrase le fichier',
  ],
  summary:
      'Les redirections (>, >>) envoient vers des fichiers ; les pipes (|) enchaînent les commandes pour construire des analyses puissantes.',
  quiz: [
    q(const [
      'q1',
      'Le symbole | sert à...',
      'qcm',
      'passer la sortie d\'une commande en entrée à la suivante|rediriger vers un fichier|commenter|multiplier',
      '0',
      'Le pipe enchaîne les commandes.',
    ]),
    q(const [
      'q2',
      'La commande "ls > liste.txt"...',
      'qcm',
      'écrit la sortie de ls dans liste.txt|lit liste.txt|supprime liste.txt|affiche liste.txt',
      '0',
      '> redirige la sortie vers le fichier.',
    ]),
  ],
  exercises: [
    ex(
      'Combiner',
      'Écrivez une commande (avec pipes) qui compte le nombre de connexions réussies ("Accepted") dans auth.log.',
    ),
  ],
  xp: 100,
);

Course _grep() => Course(
  id: 'lin-grep',
  title: 'Chercher avec grep',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Rechercher des motifs dans des fichiers',
    'Utiliser les options courantes de grep',
    'Analyser des logs avec grep',
  ],
  prerequisites: ['Terminal', 'Pipes'],
  sections: [
    sec('Présentation de grep', [
      text(
        'grep (global regular expression print) recherche des motifs (du texte ou des expressions régulières) dans des fichiers ou une entrée. C\'est l\'outil de filtrage le plus utilisé en administration et en sécurité.',
      ),
      code(
        'grep "motif" fichier.txt     # cherche motif dans fichier\n'
        'grep "motif" *.log           # dans plusieurs fichiers\n'
        'cat fichier | grep "motif"   # dans un flux (pipe)',
        label: 'Syntaxe',
      ),
    ]),
    sec('Options essentielles', [
      code(
        'grep -i "motif" fichier     # ignore la casse\n'
        'grep -v "motif" fichier     # inverse : lignes SANS motif\n'
        'grep -n "motif" fichier     # numéro de ligne\n'
        'grep -c "motif" fichier     # compte les lignes\n'
        'grep -r "motif" /chemin      # récursif dans les dossiers\n'
        'grep -E "motif1|motif2" f    # expression étendue (ou)',
        label: 'Options',
      ),
    ]),
    sec('L\'analyse de logs en pratique', [
      code(
        'grep "Failed password" /var/log/auth.log\n'
        'grep "Accepted" /var/log/auth.log | wc -l\n'
        'grep "sshd" /var/log/auth.log\n'
        'grep -E "error|fatal" /var/log/syslog',
        label: 'Analyse',
      ),
    ]),
    sec('Expressions régulières', [
      text(
        'grep accepte des motifs avancés (regex) : ^ (début), \$ (fin), . (n\'importe quel caractère), * (répétition), [abc] (une classe). Ex : grep "^Aug" log.txt trouve les lignes commençant par Aug.',
      ),
      tip(
        'La maîtrise de grep + regex + pipes fait de vous un expert de l\'analyse de logs.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier -i pour ignorer la casse',
    'Confondre -v (exclure) et -c (compter)',
  ],
  summary:
      'grep cherche des motifs dans des fichiers ou flux, avec de nombreuses options (i, v, n, c, r, E) et supporte les regex.',
  quiz: [
    q(const [
      'q1',
      'grep -v "test" fichier affiche...',
      'qcm',
      'les lignes ne contenant pas "test"|les lignes avec "test"|tout le fichier|rien',
      '0',
      '-v inverse : affiche les lignes SANS le motif.',
    ]),
    q(const [
      'q2',
      'Quelle option de grep ignore la casse ?',
      'qcm',
      '-i|-v|-n|-c',
      '0',
      '-i ignore la casse (insensitive).',
    ]),
  ],
  exercises: [
    ex(
      'Analyse',
      'Écrivez une commande grep pour lister toutes les connexions réussies (Accepted) dans auth.log, avec leur numéro de ligne.',
    ),
  ],
  xp: 100,
);

Course _find() => Course(
  id: 'lin-find',
  title: 'Localiser des fichiers avec find',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Rechercher des fichiers par nom, taille, type',
    'Exécuter des actions sur les résultats',
    'Rechercher des permissions sensibles',
  ],
  prerequisites: ['Navigation', 'grep'],
  sections: [
    sec('Présentation de find', [
      text(
        'find parcourt l\'arborescence et trouve des fichiers selon des critères : nom, type, taille, date, permissions. Indispensable pour retrouver des fichiers et auditer.',
      ),
      code(
        'find /home -name "*.log"      # fichiers .log dans /home\n'
        'find / -name "shadow"          # cherche un fichier précis\n'
        'find . -type d                 # dossiers\n'
        'find / -type f -size +100M     # fichiers >100 Mo',
        label: 'Recherche',
      ),
    ]),
    sec('Recherche par permissions (très utile en sécurité)', [
      text(
        'On peut chercher les fichiers avec des permissions sensibles, utiles pour un audit :',
      ),
      code(
        'find / -perm -0002          # fichiers modifiables par tous\n'
        'find / -perm -4000 -type f  # fichiers setuid (potentiellement risqués)\n'
        'find /home -user alice      # fichiers appartenant à alice',
        label: 'Audit',
      ),
    ]),
    sec('Agir sur les résultats', [
      text(
        'Avec -exec, on exécute une commande sur chaque résultat (remplacer {} par le fichier et terminer par \\; ou +).',
      ),
      code(
        'find /var/log -name "*.log" -exec ls -l {} \\;\n'
        'find / -perm -4000 -type f -exec ls -la {} \\;',
        label: 'exec',
      ),
    ]),
    sec('Combiner avec grep', [
      text(
        'On peut chercher du contenu dans des fichiers trouvés : find /etc -type f -name "*.conf" | xargs grep "option". Ou utiliser grep -r.',
      ),
    ]),
  ],
  commonMistakes: [
    'Chercher dans tout "/" sans besoin (lent)',
    'Oublier que -type f (fichier) vs -type d (dossier)',
  ],
  summary:
      'find localise des fichiers par nom, taille, type, permissions, et peut exécuter des actions. Essentiel pour auditer les permissions sensibles.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande trouve les dossiers ?',
      'qcm',
      'find . -type d|find . -type f|ls -d|grep d',
      '0',
      '-type d recherche les dossiers (directory).',
    ]),
  ],
  exercises: [
    ex(
      'Audit',
      'Écrivez une commande find qui liste tous les fichiers setuid (-perm -4000) sur le système pour un audit.',
    ),
  ],
  xp: 90,
);

Course _curl() => Course(
  id: 'lin-curl',
  title: 'Transferts réseau avec curl et wget',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Utiliser curl pour interagir avec des serveurs',
    'Wget pour télécharger',
    'Inspecter les réponses HTTP',
  ],
  prerequisites: ['Niveau 1 Réseau', 'Terminal'],
  sections: [
    sec('Présentation de curl', [
      text(
        'curl est un outil en ligne de commande pour transférer des données via des protocoles (HTTP, HTTPS, FTP...). C\'est un couteau suisse pour interagir avec des serveurs et tester des APIs.',
      ),
      code(
        'curl https://exemple.com        # récupère la page\n'
        'curl -I https://exemple.com     # en-têtes HTTP seulement\n'
        'curl -v https://exemple.com     # verbose (détails du flux)\n'
        'curl -o page.html https://site.com  # sauvegarde dans un fichier',
        label: 'curl',
      ),
    ]),
    sec('Envoyer des requêtes', [
      text(
        'curl permet de préciser la méthode HTTP et d\'envoyer des données (utile pour tester des APIs) :',
      ),
      code(
        'curl -X POST https://api.com/login -d "user=alice&pass=secret"\n'
        'curl -X GET "https://api.com/users/1" -H "Authorization: Bearer TOKEN"\n'
        'curl -X PUT https://api.com/item/1 -d "{\\"name\\":\\"test\\"}"',
        label: 'Méthodes',
      ),
    ]),
    sec('Inspecter la réponse', [
      text(
        'L\'option -v (ou -i) montre les en-têtes de la réponse, utiles pour comprendre le comportement du serveur (code statut, cookies, redirections).',
      ),
      warn(
        'Testez curl uniquement sur vos serveurs ou des applications de laboratoire autorisées (leçon OWASP : HTTP = surface d\'attaque à comprendre).',
      ),
    ]),
    sec('wget pour télécharger', [
      text(
        'wget est préféré pour télécharger des fichiers et des sites : wget -r copie récursivement, wget -c reprend un téléchargement interrompu.',
      ),
      code(
        'wget https://exemple.com/fichier.zip\n'
        'wget -r -l 2 https://site.com    # télécharge 2 niveaux de liens',
        label: 'wget',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier -v pour déboguer',
    'Envoyer des requêtes vers des cibles non autorisées',
  ],
  summary:
      'curl interagit avec des serveurs (méthodes, en-têtes) et wget télécharge. Incontournables pour tester des APIs et analyser HTTP.',
  quiz: [
    q(const [
      'q1',
      'Quelle option curl affiche les en-têtes seulement ?',
      'qcm',
      '-I|-o|-X|-d',
      '0',
      '-I envoie une requête HEAD et affiche les en-têtes.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Dans le terminal simulé, tapez "curl -I localhost" puis "curl localhost" et observez les en-têtes HTTP. Quels informations voyez-vous ?',
    ),
  ],
  xp: 90,
);

Course _ssh() => Course(
  id: 'lin-ssh',
  title: 'SSH : connexion sécurisée à distance',
  category: 'linux',
  level: 'Niveau 2 - Linux pour la cybersécurité',
  levelNumber: 2,
  objectives: [
    'Comprendre le rôle de SSH',
    'Se connecter à une machine distante',
    'Distinguer mots de passe et clés',
  ],
  prerequisites: ['Niveau 1', 'Réseau Linux'],
  sections: [
    sec('C\'est quoi SSH ?', [
      text(
        'SSH (Secure Shell) permet d\'accéder de façon sécurisée et chiffrée à une machine distante. C\'est LE moyen standard pour administrer des serveurs Linux à distance.',
      ),
      text(
        'Contrairement à telnet (non chiffré, à éviter), SSH chiffre toute la session : commandes, sorties, mots de passe.',
      ),
    ]),
    sec('Se connecter', [
      code(
        'ssh utilisateur@192.168.1.50\n'
        'ssh -p 2222 alice@serveur.com   # port personnalisé\n'
        'ssh root@serveur.com            # se connecter en root (à éviter de préférence)',
        label: 'Connexion',
      ),
      text(
        'Par défaut, SSH utilise le port 22. À la première connexion, il vous demande d\'accepter l\'empreinte du serveur (clé d\'hôte) pour éviter les attaques par interception.',
      ),
    ]),
    sec('Mots de passe vs clés', [
      text(
        'On peut s\'authentifier par mot de passe, mais la méthode recommandée (et plus sûre) est la clé publique/privée :',
      ),
      code(
        'ssh-keygen -t ed25519     # crée une paire de clés\n'
        'ssh-copy-id user@serveur   # copie la clé publique vers le serveur\n'
        'ssh user@serveur           # connexion sans mot de passe (clé)',
        label: 'Clés',
      ),
    ]),
    sec('Sécuriser SSH', [
      list(
        '- Empêcher la connexion root directe (PermitRootLogin no).\n'
        '- Utiliser des clés plutôt que mots de passe.\n'
        '- Désactiver l\'authentification par mot de passe si possible.\n'
        '- Changer le port par défaut (obfuscation, pas sécurité).\n'
        '- Ajouter un pare-feu limitant l\'accès à SSH.',
      ),
      warn(
        'Un service SSH exposé avec un mot de passe faible est une porte d\'entrée très courante pour les attaquants (bruteforce).',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser telnet au lieu de SSH',
    'Laisser la connexion root par mot de passe activée',
  ],
  summary:
      'SSH donne un accès distant chiffré et sécurisé. On préfère les clés aux mots de passe et on sécurise la configuration.',
  quiz: [
    q(const [
      'q1',
      'Quel port SSH par défaut ?',
      'qcm',
      '22|80|443|8080',
      '0',
      'SSH écoute par défaut sur le port 22.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : SSH chiffre la session.',
      'tf',
      'Vrai',
      null,
      'SSH chiffre toute la session, contrairement à telnet.',
    ]),
  ],
  exercises: [
    ex(
      'Sécurité',
      'Dans le terminal simulé, tapez "ssh learner@serveur" et observez le message de simulation. Pourquoi préfère-t-on les clés aux mots de passe ?',
    ),
  ],
  xp: 90,
);
