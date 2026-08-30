import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> bashCourses() => [
  _bashIntro(),
  _bashVariables(),
  _bashConditions(),
  _bashLoops(),
  _bashFunctions(),
  _bashArguments(),
  _bashFiles(),
  _bashParsing(),
  _bashAutomation(),
  _bashLogAnalysis(),
  _bashAdmin(),
  _bashAnalyzer(),
];

Course _bashIntro() => Course(
  id: 'bash-intro',
  title: 'Introduction à Bash',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Comprendre ce qu\'est un script shell',
    'Savoir créer et exécuter un script',
    'Connaître le shebang et les droits',
  ],
  prerequisites: ['Niveau 2 Linux'],
  sections: [
    sec('Un script shell, c\'est quoi ?', [
      text(
        'Un script Bash est un fichier texte contenant une série de commandes Linux, exécutées automatiquement dans l\'ordre. C\'est le moyen d\'automatiser des tâches répétitives (analyse, vérifications, administration).',
      ),
      text(
        'En cybersécurité, on écrit des scripts pour traiter des logs, surveiller des fichiers, automatiser des vérifications.',
      ),
    ]),
    sec('Créer et exécuter un script', [
      code(
        '#!/bin/bash                     # shebang : dit quel interpréteur\n'
        'echo "Bonjour, ceci est mon script"\n'
        'whoami\n'
        'date',
        label: 'Mon premier script',
      ),
      text('Pour l\'exécuter :'),
      code(
        'chmod +x script.sh    # le rend exécutable\n'
        './script.sh          # l\'exécute\n'
        'bash script.sh       # ou l\'exécute via bash',
        label: 'Exécution',
      ),
    ]),
    sec('Le shebang', [
      text(
        'La première ligne #!/bin/bash indique au système quel programme doit interpréter le script. C\'est essentiel pour l\'exécution directe (./script.sh).',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Nommer vos scripts avec .sh.\n'
        '- Commencer par #!/bin/bash.\n'
        '- Ajouter des commentaires (#) pour expliquer.\n'
        '- Rendre lisible avec des sauts de ligne.\n'
        '- Tester avant de déployer.',
      ),
    ]),
  ],
  commonMistakes: ['Oublier le chmod +x', 'Ne pas mettre le shebang'],
  summary:
      'Un script Bash est un fichier de commandes automatisées. Shebang, droits d\'exécution et commentaires sont les bases.',
  quiz: [
    q(const [
      'q1',
      'Que fait la ligne #!/bin/bash ?',
      'qcm',
      'elle indique l\'interpréteur à utiliser|elle commente le script|elle exécute le script|elle le chiffre',
      '0',
      'Le shebang déclare l\'interpréteur.',
    ]),
  ],
  exercises: [
    ex(
      'Créer',
      'Écrivez un script simple qui affiche "Hello Cyber" puis la date. Décrivez les 2 étapes pour le rendre exécutable.',
    ),
  ],
  xp: 80,
);

Course _bashVariables() => Course(
  id: 'bash-variables',
  title: 'Les variables en Bash',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Utiliser les variables',
    'Distinguer affectation et lecture',
    'Utiliser les variables spéciales',
  ],
  prerequisites: ['Introduction à Bash'],
  sections: [
    sec('Déclarer et lire', [
      code(
        '#!/bin/bash\n'
        'nom="Alice"            # affectation (sans \$)\n'
        'echo "Bonjour \$nom"    # lecture (avec \$)\n'
        'echo "Bonjour \${nom} lis"   # {nom} pour délimiter',
        label: 'Variables',
      ),
      text(
        'Pas d\'espace autour du = lors de l\'affectation, sinon erreur. Les guillemets délimitent la valeur.',
      ),
    ]),
    sec('Guillemets simples vs doubles', [
      code(
        'echo "\$nom"     # double : \$ est interprété → Alice\n'
        'echo \'\$nom\'     # simple : littéral → \$nom',
        label: 'Guillemets',
      ),
      text(
        'Les doubles guillemets interprètent les variables, les simples les affichent littéralement.',
      ),
    ]),
    sec('Variables spéciales', [
      code(
        '\$0     nom du script\n'
        '\$1 \$2 ...  arguments passés au script\n'
        '\$#     nombre d\'arguments\n'
        '\$?     code de retour de la dernière commande (0 = succès)\n'
        '\$\$     PID du script\n'
        'RANDOM un nombre aléatoire',
        label: 'Spéciales',
      ),
    ]),
    sec('Variables d\'environnement', [
      code(
        'echo \$HOME\n'
        'echo \$USER\n'
        'export MA_VAR="valeur"   # la rend disponible aux sous-processus',
        label: 'Environnement',
      ),
      text(
        'On utilise export pour transmettre des variables aux programmes lancés.',
      ),
    ]),
  ],
  commonMistakes: [
    'Mettre un espace autour du =',
    'Oublier le \$ à la lecture',
    'Confondre guillemets simples et doubles',
  ],
  summary:
      'Les variables stockent des valeurs ; le \$ les lit. Double-guillemets = interprétation, simples = littéral. Variables spéciales pour arguments et état.',
  quiz: [
    q(const [
      'q1',
      'La déclaration correcte est...',
      'qcm',
      'x="valeur"|x = "valeur"|\$x="valeur"|x=valeur sans guillemets',
      '0',
      'Pas d\'espace et pas de \$ à l\'affectation.',
    ]),
    q(const [
      'q2',
      'echo \'\$x\' affiche...',
      'qcm',
      '\$x littéralement|la valeur de x|une erreur|rien',
      '0',
      'Les guillemets simples affichent littéralement.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Écrivez un script qui définit une variable, l\'affiche, puis affiche \$HOME et \$USER.',
    ),
  ],
  xp: 80,
);

Course _bashConditions() => Course(
  id: 'bash-conditions',
  title: 'Les conditions (if/then/else)',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Utiliser if, elif, else',
    'Tester des conditions',
    'Comparer des nombres et fichiers',
  ],
  prerequisites: ['Variables Bash'],
  sections: [
    sec('La structure if', [
      code(
        '#!/bin/bash\n'
        'nombre=5\n'
        'if [ \$nombre -gt 3 ]; then\n'
        '  echo "Supérieur à 3"\n'
        'elif [ \$nombre -gt 1 ]; then\n'
        '  echo "Entre 2 et 3"\n'
        'else\n'
        '  echo "1 ou moins"\n'
        'fi',
        label: 'if/elif/else',
      ),
      text(
        'La structure se termine par fi. On teste avec des crochets [ condition ] et des ";" avant then.',
      ),
    ]),
    sec('Comparaisons numériques', [
      code(
        '-eq   égal\n'
        '-ne   différent\n'
        '-gt   plus grand\n'
        '-lt   plus petit\n'
        '-ge   >=  (greater or equal)\n'
        '-le   <=',
        label: 'Nombres',
      ),
    ]),
    sec('Tester des fichiers', [
      code(
        '-e fichier   existe\n'
        '-f fichier   est un fichier\n'
        '-d fichier   est un dossier\n'
        '-r fichier   lisible\n'
        '-w fichier   écriture\n'
        '-x fichier   exécutable\n'
        '-s fichier   non vide',
        label: 'Fichiers',
      ),
      code(
        'if [ -f /var/log/auth.log ]; then\n'
        '  echo "Le log existe"\n'
        'fi',
        label: 'Exemple',
      ),
    ]),
    sec('Conditions combinées', [
      code(
        '[ cond1 -a cond2 ]   # ET (and)\n'
        '[ cond1 -o cond2 ]   # OU (or)\n'
        '[ ! cond ]           # NON',
        label: 'Combiner',
      ),
      text(
        'On peut aussi comparer des chaînes : [ "\$var" = "valeur" ] ou !=.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier les espaces dans les crochets [ \$x -eq 1 ]',
    'Oublier le fi',
    'Tester des égalités numériques avec = au lieu de -eq',
  ],
  summary:
      'if/elif/else teste des conditions : comparaisons numériques (-eq, -gt...), tests de fichiers (-f, -d...) et combinaisons (-a, -o).',
  quiz: [
    q(const [
      'q1',
      'Quel opérateur teste si un fichier existe ?',
      'qcm',
      '-e|-eq|-f|-d',
      '0',
      '-e teste l\'existence, -f qu\'il est un fichier.',
    ]),
    q(const [
      'q2',
      'La structure if se termine par...',
      'qcm',
      'fi|endif|done|esac',
      '0',
      'if se termine par fi (if inversé).',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez un script qui vérifie si le fichier /var/log/auth.log existe et affiche un message selon le cas.',
    ),
  ],
  xp: 90,
);

Course _bashLoops() => Course(
  id: 'bash-loops',
  title: 'Les boucles',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Utiliser les boucles for et while',
    'Itérer sur des fichiers et listes',
    'Boucler sur la lecture de fichiers',
  ],
  prerequisites: ['Conditions Bash'],
  sections: [
    sec('La boucle for', [
      code(
        '#!/bin/bash\n'
        '# sur une liste\n'
        'for fruit in pomme poire banane; do\n'
        '  echo "J\'aime \$fruit"\n'
        'done\n'
        '# boucle numérique\n'
        'for i in 1 2 3 4 5; do\n'
        '  echo "Itération \$i"\n'
        'done\n'
        'for ((i=0; i<5; i++)); do\n'
        '  echo \$i\n'
        'done',
        label: 'for',
      ),
      text(
        'La boucle se termine par done. Elle itère sur une liste ou via une syntaxe en C.',
      ),
    ]),
    sec('Itérer sur des fichiers', [
      code(
        'for fichier in /var/log/*.log; do\n'
        '  echo "Analyse de \$fichier"\n'
        '  wc -l "\$fichier"\n'
        'done',
        label: 'Fichiers',
      ),
    ]),
    sec('La boucle while', [
      code(
        'compteur=0\n'
        'while [ \$compteur -lt 5 ]; do\n'
        '  echo "Compteur : \$compteur"\n'
        '  ((compteur++))\n'
        'done',
        label: 'while',
      ),
      text(
        'while répète tant que la condition est vraie. Attention aux boucles infinies (toujours un compteur ou une sortie).',
      ),
    ]),
    sec('Lire un fichier ligne par ligne', [
      code(
        'while IFS= read -r ligne; do\n'
        '  echo "Ligne : \$ligne"\n'
        'done < /var/log/auth.log',
        label: 'Lecture',
      ),
      text(
        'Le < redirige le fichier vers le while, qui lit chaque ligne. Très utile pour analyser des logs.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier done',
    'Créer une boucle infinie avec while (pas d\'incrément)',
  ],
  summary:
      'for itère sur des listes/fichiers, while répète tant qu\'une condition est vraie. On lit des logs ligne par ligne avec while + read.',
  quiz: [
    q(const [
      'q1',
      'Une boucle for se termine par...',
      'qcm',
      'done|fi|esac|end',
      '0',
      'Les boucles se terminent par done.',
    ]),
  ],
  exercises: [
    ex(
      'Automatiser',
      'Écrivez une boucle for qui compte les lignes de tous les fichiers .log de /var/log, et une boucle while qui compte de 0 à 4.',
    ),
  ],
  xp: 90,
);

Course _bashFunctions() => Course(
  id: 'bash-functions',
  title: 'Les fonctions',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Définir et appeler des fonctions',
    'Passer des arguments aux fonctions',
    'Retourner des résultats',
  ],
  prerequisites: ['Variables, conditions'],
  sections: [
    sec('Définir une fonction', [
      code(
        '#!/bin/bash\n'
        'dire_bonjour() {\n'
        '  echo "Bonjour tout le monde"\n'
        '}\n'
        'dire_bonjour    # appel de la fonction',
        label: 'Définition',
      ),
      text(
        'On peut aussi écrire "function nom() { ... }". Les fonctions doivent être définies avant leur appel (le script s\'exécute de haut en bas).',
      ),
    ]),
    sec('Passer des arguments', [
      code(
        'salutation() {\n'
        '  echo "Bonjour \$1, vous êtes \$2"\n'
        '}\n'
        'salutation Alice administrateur',
        label: 'Arguments',
      ),
      text(
        'À l\'intérieur d\'une fonction, \$1, \$2... sont les arguments de la fonction (pas du script).',
      ),
    ]),
    sec('Retourner des valeurs', [
      text(
        'On utilise return pour le code de retour (0 = succès), et echo/des variables pour "renvoyer" des données.',
      ),
      code(
        'est_pair() {\n'
        '  local n=\$1\n'
        '  if [ \$((n % 2)) -eq 0 ]; then\n'
        '    echo "pair"\n'
        '    return 0\n'
        '  else\n'
        '    echo "impair"\n'
        '    return 1\n'
        '  fi\n'
        '}\n'
        'resultat=\$(est_pair 4)   # capture la sortie\n'
        'echo "\$resultat"',
        label: 'Retour',
      ),
      text(
        '\$(commande) capture la sortie de la commande dans une variable — très utile.',
      ),
    ]),
    sec('Pourquoi des fonctions', [
      text(
        'Les fonctions évitent de répéter du code, rendent le script lisible et maintenable. C\'est essentiel pour des scripts d\'analyse propres.',
      ),
    ]),
  ],
  commonMistakes: [
    'Appeler une fonction avant sa définition',
    'Confondre les \$1 de la fonction et du script',
  ],
  summary:
      'Les fonctions regroupent du code réutilisable, acceptent des arguments (\$1...) et renvoient résultats via echo/\$(...)/return.',
  quiz: [
    q(const [
      'q1',
      'Quelle syntaxe définit une fonction ?',
      'qcm',
      'nom() { ... }|function { ... }|def nom|fn nom',
      '0',
      'On écrit nom() { commandes }.',
    ]),
  ],
  exercises: [
    ex(
      'Rédiger',
      'Créez une fonction qui prend un nom et un rôle en arguments et affiche un message personnalisé.',
    ),
  ],
  xp: 90,
);

Course _bashArguments() => Course(
  id: 'bash-arguments',
  title: 'Les arguments du script',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Lire les arguments en ligne de commande',
    'Gérer les options',
    'Vérifier le nombre d\'arguments',
  ],
  prerequisites: ['Variables Bash'],
  sections: [
    sec('Les arguments posés', [
      code(
        '#!/bin/bash\n'
        'echo "Script : \$0"\n'
        'echo "Arg 1 : \$1"\n'
        'echo "Arg 2 : \$2"\n'
        'echo "Nombre d\'arguments : \$#"\n'
        'echo "Tous : \$@"',
        label: 'Lecture',
      ),
      text('exécution : ./script.sh alice admin → \$1=alice, \$2=admin.'),
    ]),
    sec('Vérifier les arguments', [
      code(
        'if [ \$# -lt 1 ]; then\n'
        '  echo "Usage: \$0 <nom_utilisateur>"\n'
        '  exit 1\n'
        'fi\n'
        'echo "Traitement de \$1"',
        label: 'Vérification',
      ),
    ]),
    sec('Les options (getopts)', [
      text(
        'Pour de vraies options (-v, -h...), on utilise getopts dans une boucle :',
      ),
      code(
        'while getopts "vh" opt; do\n'
        '  case \$opt in\n'
        '    v) echo "Mode verbeux";;\n'
        '    h) echo "Aide"; exit 0;;\n'
        '    *) echo "Option inconnue";;\n'
        '  esac\n'
        'done',
        label: 'getopts',
      ),
    ]),
    sec('Décaler les arguments (shift)', [
      text(
        'shift décale les arguments : \$2 → \$1, \$3 → \$2... Utile pour traiter des listes d\'arguments.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser des arguments sans vérifier qu\'ils existent (\$1 vide)',
    'Ignorer \$# pour contrôler la saisie',
  ],
  summary:
      'Le script lit ses arguments via \$1, \$2, \$# et \$@. On vérifie leur nombre et on peut utiliser getopts pour les options.',
  quiz: [
    q(const [
      'q1',
      'Quelle variable donne le nombre d\'arguments ?',
      'qcm',
      '\$#|\$@|\$0|\$?',
      '0',
      '\$# compte les arguments.',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez un script qui exige au moins 1 argument et affiche une erreur sinon.',
    ),
  ],
  xp: 80,
);

Course _bashFiles() => Course(
  id: 'bash-files',
  title: 'Manipuler des fichiers en Bash',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Lire et écrire des fichiers',
    'Vérifier les fichiers',
    'Traiter des lignes',
  ],
  prerequisites: ['Boucles, conditions'],
  sections: [
    sec('Écrire et lire', [
      code(
        'echo "ligne1" > fichier.txt     # crée/écrase\n'
        'echo "ligne2" >> fichier.txt    # ajoute\n'
        'cat fichier.txt                 # lit\n'
        'while IFS= read -r l; do echo "\$l"; done < fichier.txt',
        label: 'R/W',
      ),
    ]),
    sec('Réorganiser des données', [
      code(
        'sort fichier.txt\n'
        'sort -r fichier.txt      # décroissant\n'
        'uniq fichier.txt         # retire les doublons consécutifs\n'
        'sort f.txt | uniq -c     # compte les occurrences',
        label: 'Trier',
      ),
    ]),
    sec('Découper des colonnes (cut)', [
      code(
        'cut -d: -f1 /etc/passwd     # 1re colonne séparée par :\n'
        'cut -c1-5 fichier.txt       # les 5 premiers caractères',
        label: 'cut',
      ),
    ]),
    sec('Exemple d\'analyse', [
      code(
        'grep "Failed" /var/log/auth.log \\\n'
        '  | cut -d" " -f10- | sort | uniq -c | sort -nr\n'
        '# extrait les IP et compte les échecs',
        label: 'Mini-pipeline',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre > (écrase) et >> (ajoute)',
    'Oublier de différencier le délimiteur dans cut',
  ],
  summary:
      'On lit/écrit des fichiers avec >/>>/cat, on trie avec sort/uniq, on découpe avec cut. Comme grep, outil clé de l\'analyse.',
  quiz: [
    q(const [
      'q1',
      '>> sert à...',
      'qcm',
      'ajouter à la fin du fichier|écraser le fichier|créer un dossier|supprimer',
      '0',
      '>> ajoute, > écrase.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Écrivez un pipeline qui compte les adresses IP qui ont tenté de se connecter en échec dans auth.log.',
    ),
  ],
  xp: 90,
);

Course _bashParsing() => Course(
  id: 'bash-parsing',
  title: 'Le parsing de texte',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Extraire des informations de textes',
    'Utiliser grep, cut, awk, sed',
    'Construire des analyses',
  ],
  prerequisites: ['Manipuler des fichiers'],
  sections: [
    sec('Extraire et transformer', [
      text(
        'Le parsing consiste à extraire des informations structurées depuis des textes (logs, fichiers de config). On combine grep, cut, awk et sed.',
      ),
    ]),
    sec('grep pour filtrer', [
      code(
        'grep "Accepted" /var/log/auth.log    # lignes avec Accepted\n'
        'grep -E "error|fatal" log.txt         # plusieurs motifs',
        label: 'grep',
      ),
    ]),
    sec('awk pour les colonnes', [
      text(
        'awk traite ligne par ligne et découpe en champs. \$1 = 1er champ, \$0 = ligne entière.',
      ),
      code(
        'awk \'{print \$1}\' fichier.txt     # affiche le 1er champ\n'
        'awk -F: \'{print \$1}\' /etc/passwd  # séparateur :\n'
        'awk \'{print NF}\' fichier.txt      # nombre de champs\n'
        'awk \'{sum+=\$3} END{print sum}\' f  # somme de la colonne 3',
        label: 'awk',
      ),
    ]),
    sec('sed pour remplacer', [
      text(
        'sed (stream editor) modifie le flux de texte, souvent pour remplacer :',
      ),
      code(
        'sed \'s/admin/utilisateur/g\' fichier.txt   # remplace partout\n'
        'sed \'/^#/d\' fichier.conf      # supprime les lignes commentées\n'
        'sed -n \'10,20p\' fichier.txt   # affiche les lignes 10 à 20',
        label: 'sed',
      ),
    ]),
    sec('Exemple combiné', [
      code(
        '# Compter les connexions réussies par IP\n'
        'grep "Accepted" /var/log/auth.log \\\n'
        '  | awk \'{print \$9}\' \\\n'
        '  | sort | uniq -c | sort -nr | head',
        label: 'Analyse IP',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier que awk commence à \$1 (pas \$0 pour un champ)',
    'Confondre sed (remplacer/modifier) et awk (structurer/calculer)',
  ],
  summary:
      'Le parsing combine grep (filtrer), awk (colonnes/calcul) et sed (remplacer). C\'est la boîte à outils de l\'analyse de logs.',
  quiz: [
    q(const [
      'q1',
      'Pour afficher le 1er champ d\'une ligne, awk utilise...',
      'qcm',
      '\$1|\$0|NF|\$9',
      '0',
      '\$1 est le 1er champ, \$0 la ligne entière.',
    ]),
  ],
  exercises: [
    ex(
      'Construire',
      'Écrivez un pipeline awk+grep+sort+uniq pour compter les IP des connexions réussies dans auth.log.',
    ),
  ],
  xp: 90,
);

Course _bashAutomation() => Course(
  id: 'bash-automation',
  title: 'Automatiser des tâches',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Automatiser des vérifications',
    'Planifier avec cron',
    'Gérer les erreurs',
  ],
  prerequisites: ['Tous les cours Bash précédents'],
  sections: [
    sec('Le principe', [
      text(
        'L\'automatisation consiste à faire faire au script ce que l\'on ferait à la main, de façon reproductible et planifiée. Ex : vérifier chaque nuit que les services tournent.',
      ),
    ]),
    sec('Gérer les erreurs', [
      code(
        '#!/bin/bash\n'
        'set -e    # arrête le script à la première erreur\n'
        'if ping -c 1 serveur >/dev/null 2>&1; then\n'
        '  echo "OK"\n'
        'else\n'
        '  echo "Serveur injoignable"\n'
        '  exit 1\n'
        'fi',
        label: 'Erreurs',
      ),
      text(
        'set -e arrête au moindre échec. 2>&1 redirige les erreurs vers la sortie standard. On vérifie les codes de retour avec \$?.',
      ),
    ]),
    sec('Planifier avec cron', [
      text(
        'cron exécute des scripts à intervalles réguliers. La table des tâches se configure avec crontab -e. Format : minute heure jour-mois mois jour-semaine commande.',
      ),
      code(
        '# Exécuter chaque jour à 2h30\n'
        '30 2 * * *  /home/learner/verif.sh\n'
        '\n'
        '# Toutes les heures\n'
        '0 * * * *  /home/learner/scan_local.sh\n'
        '\n'
        '# Tous les lundis à 6h\n'
        '0 6 * * 1  /home/learner/rapport.sh',
        label: 'crontab',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Tester le script avant de le planifier.\n'
        '- Rediriger la sortie vers un fichier log.\n'
        '- Utiliser set -e pour ne pas continuer après une erreur.\n'
        '- Rendre le script logique et commenté.',
      ),
    ]),
  ],
  commonMistakes: [
    'Planifier un script sans l\'avoir testé (mauvaises surprises)',
    'Ne pas journaliser la sortie du cron',
  ],
  summary:
      'L\'automatisation automatise des vérifications. Cron planifie, set -e gère les erreurs, et on journalise les sorties.',
  quiz: [
    q(const [
      'q1',
      'Que fait set -e dans un script ?',
      'qcm',
      'arrête le script à la première erreur|affiche les erreurs|ignore les erreurs|démarre en mode debug',
      '0',
      'set -e stoppe au premier échec.',
    ]),
  ],
  exercises: [
    ex(
      'Planifier',
      'Écrivez une ligne crontab qui exécute le script /home/alice/verif.sh tous les jours à 23h45, et expliquez son format.',
    ),
  ],
  xp: 90,
);

Course _bashLogAnalysis() => Course(
  id: 'bash-logs',
  title: 'Analyser des logs avec Bash',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Analyser auth.log',
    'Détecter des activités suspectes',
    'Construire un mini-analyseur',
  ],
  prerequisites: ['Parsing, boucles'],
  sections: [
    sec('Le contexte', [
      text(
        'L\'analyse de logs est un exercice central en cybersécurité : détecter des brute-forces, des connexions inhabituelles, des erreurs système. Bash est l\'outil parfait pour de premières investigations rapides.',
      ),
    ]),
    sec('Détecter une brute-force SSH', [
      text(
        'Une brute-force = beaucoup de "Failed password" depuis une même IP en peu de temps. On compte par IP :',
      ),
      code(
        'grep "Failed password" /var/log/auth.log \\\n'
        '  | awk \'{print \$(NF-3)}\' \\\n'
        '  | sort | uniq -c | sort -nr | head\n'
        '# (la position de l\'IP dépend du format)',
        label: 'Analyse brute-force',
      ),
    ]),
    sec('Construire un script d\'analyse', [
      code(
        '#!/bin/bash\n'
        'LOG=/var/log/auth.log\n'
        'echo "=== Échecs de connexion par IP ==="\n'
        'grep "Failed password" "\$LOG" | awk \'{print \$11}\' \\\n'
        '  | sort | uniq -c | sort -nr | head -10\n'
        'echo "=== Connexions réussies ==="\n'
        'grep "Accepted" "\$LOG" | tail -5',
        label: 'mini-analyseur',
      ),
    ]),
    sec('Rechercher des motifs suspects', [
      code(
        'grep -i "error\\|fatal\\|warning" /var/log/syslog | tail\n'
        'grep "sudo" /var/log/auth.log | tail        # commandes sudo\n'
        'grep "session opened" /var/log/auth.log | tail',
        label: 'Motifs',
      ),
    ]),
  ],
  commonMistakes: [
    'Mauvaise position de l\'IP selon le format de log (à vérifier)',
    'Analyser sans compter/corriger',
  ],
  summary:
      'On analyse les logs avec grep+awk+sort+uniq pour détecter brute-forces et anomalies. Un mini-script Bash automatise l\'investigation.',
  quiz: [
    q(const [
      'q1',
      'Un signe de brute-force SSH est...',
      'qcm',
      'beaucoup de "Failed password" depuis une même IP|une seule connexion réussie|aucun log|un redémarrage',
      '0',
      'La répétition d\'échecs depuis une IP signe un brute-force.',
    ]),
  ],
  exercises: [
    ex(
      'Investir',
      'Écrivez un script qui compte les "Failed password" par IP et affiche le top 5. Expliquez votre pipeline.',
    ),
  ],
  xp: 100,
);

Course _bashAdmin() => Course(
  id: 'bash-admin',
  title: 'Scripts d\'administration',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Écrire des scripts d\'administration',
    'Vérifier services, disques, processus',
    'Produire un rapport',
  ],
  prerequisites: ['Automatisation'],
  sections: [
    sec('Le principe', [
      text(
        'Les scripts d\'administration automatisent la surveillance d\'un système : vérifier qu\'un service tourne, que le disque n\'est pas plein, que des processus anormaux n\'existent pas.',
      ),
    ]),
    sec('Vérifier un service', [
      code(
        '#!/bin/bash\n'
        'if systemctl is-active --quiet ssh; then\n'
        '  echo "SSH : ACTIF"\n'
        'else\n'
        '  echo "SSH : INACTIF"\n'
        '  echo "Action: sudo systemctl start ssh"\n'
        'fi',
        label: 'Service',
      ),
    ]),
    sec('Vérifier l\'espace disque', [
      code(
        '#!/bin/bash\n'
        'usage=\$(df / | awk \'NR==2{print \$5}\' | tr -d "%")\n'
        'echo "Usage disque : \$usage%"  \n'
        'if [ "\$usage" -gt 85 ]; then\n'
        '  echo "Attention : disque presque plein !"\n'
        'fi',
        label: 'Disque',
      ),
    ]),
    sec('Surveiller des processus', [
      code(
        '#!/bin/bash\n'
        'echo "=== Processus consommant du CPU ==="\n'
        'ps aux --sort=-%cpu | head -6\n'
        'echo "=== Processus de l\'utilisateur learner ==="\n'
        'ps aux | grep "^learner"',
        label: 'Processus',
      ),
    ]),
    sec('Générer un rapport', [
      text(
        'On peut faire écrire au script un rapport dans un fichier, consultable ensuite, avec la date et les résultats.',
      ),
      code(
        'rapport=/tmp/rapport_\$(date +%F).txt\n'
        '{ date; echo "---"; echo "Connexions récentes:"; last | head -5; } > "\$rapport"\n'
        'echo "Rapport écrit : \$rapport"',
        label: 'Rapport',
      ),
    ]),
  ],
  commonMistakes: [
    'Scanner des machines tierces sans autorisation',
    'Ne pas tester l\'espace disque avant de déployer',
  ],
  summary:
      'Les scripts d\'administration automatisent le contrôle des services, du disque et des processus, et produisent des rapports.',
  quiz: [
    q(const [
      'q1',
      'Quelle commande vérifie si un service est actif ?',
      'qcm',
      'systemctl is-active --quiet <svc>|ls|cat|whoami',
      '0',
      'systemctl is-active vérifie l\'état d\'un service.',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez un script qui vérifie l\'état de SSHD et affiche un message d\'action s\'il est inactif.',
    ),
  ],
  xp: 100,
);

Course _bashAnalyzer() => Course(
  id: 'bash-analyzer',
  title: 'Construire un petit outil défensif',
  category: 'bash',
  level: 'Niveau 3 - Bash',
  levelNumber: 3,
  objectives: [
    'Réaliser un projet Bash complet',
    'Combiner toutes les notions',
    'Créer un outil d\'analyse utilisable',
  ],
  prerequisites: ['Tous les cours Bash'],
  sections: [
    sec('Le projet', [
      text(
        'Réalisons un outil défensif simple : un script qui analyse rapidement la sécurité de base d\'un système Linux en produisant un rapport. C\'est un mini-projet de fin de niveau Bash.',
      ),
    ]),
    sec('Le script type', [
      code(
        '#!/bin/bash\n'
        'echo "=== CyberCheck {date} ===\n"\n'
        '# 1. Utilisateurs connectés\n'
        'echo "[Utilisateurs connectés]"; who\n\n'
        '# 2. Connexions récentes\n'
        'echo "[Connexions SSH récentes]"\n'
        'last -n 5\n\n'
        '# 3. Ports en écoute\n'
        'echo "[Ports TCP en écoute]"\n'
        'ss -tlnp\n\n'
        '# 4. Fichiers modifiés récemment\n'
        'echo "[Fichiers modifiés (24h)]"\n'
        'find /home -type f -mtime -1 2>/dev/null\n\n'
        '# 5. Services échoués\n'
        'echo "[Services en échec]"\n'
        'systemctl --failed',
        label: 'cybercheck.sh',
      ),
    ]),
    sec('Améliorer avec des variables et fonctions', [
      text(
        'On structure le script avec des fonctions (une par vérification) et des variables pour la configuration (couleurs, fichiers). Cela le rend maintenable.',
      ),
    ]),
    sec('Conclure le parcours Bash', [
      text(
        'Vous savez désormais automatiser des analyses et créer des outils défensifs en Bash. Ces compétences sont directement réutilisées par la suite en Python et en Blue Team.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ne pas tester le script étape par étape',
    'Oublier de gérer les fichiers inexistants (2>/dev/null)',
  ],
  summary:
      'Un outil défensif Bash combine vérifications (utilisateurs, ports, fichiers, services) et produit un rapport. Projet de fin de niveau.',
  quiz: [
    q(const [
      'q1',
      'Que montre "ss -tlnp" ?',
      'qcm',
      'les ports TCP en écoute avec le processus|les utilisateurs|les mots de passe|les fichiers cachés',
      '0',
      'ss -tlnp liste les ports TCP en écoute et le processus associé.',
    ]),
  ],
  exercises: [
    ex(
      'Projet',
      'Écrivez votre propre "cybercheck.sh" avec au moins 3 vérifications (utilisateurs, ports, services) et un rapport.',
    ),
  ],
  xp: 100,
);
