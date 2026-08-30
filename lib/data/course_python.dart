import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> pythonCourses() => [
  _pySyntax(),
  _pyVariables(),
  _pyConditions(),
  _pyLoops(),
  _pyFunctions(),
  _pyFiles(),
  _pyJson(),
  _pyRegex(),
  _pySockets(),
  _pyHttp(),
  _pyHashing(),
  _pyAnalyzer(),
];

Course _pySyntax() => Course(
  id: 'py-syntax',
  title: 'Python : syntaxe de base',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Comprendre la syntaxe Python',
    'Utiliser print et les commentaires',
    'Comprendre l\'indentation',
  ],
  prerequisites: ['Bases Linux/Bash'],
  sections: [
    sec('Pourquoi Python ?', [
      text(
        'Python est le langage de référence en cybersécurité : lisible, riche en bibliothèques, idéal pour l\'analyse, l\'automatisation et les petits outils (parsage de logs, requêtes HTTP, etc.).',
      ),
      text(
        'La particularité de Python : l\'indentation (les espaces) structure le code. Elle n\'est pas optionnelle.',
      ),
    ]),
    sec('Premier programme', [
      code(
        '# Ceci est un commentaire\n'
        'print("Bonjour CyberLab")\n'
        'print(2 + 3)\n'
        'print(f"Le résultat est {2*4}")   # f-string',
        label: 'Exemple',
      ),
      text(
        'Pour exécuter : python3 mon_script.py. print affiche, les # sont des commentaires.',
      ),
    ]),
    sec('L\'indentation', [
      code(
        'if True:\n'
        '    print("indenté de 4 espaces")   # obligatoire\n'
        'print("hors du bloc")',
        label: 'Indentation',
      ),
      text(
        'Les blocs se marquent à l\'indentation (généralement 4 espaces). Une indentation incohérente provoque une erreur.',
      ),
    ]),
    sec('Types de base', [
      code(
        '# int, float, str, bool\n'
        'age = 25          # int\n'
        'taille = 1.80     # float\n'
        'nom = "Alice"     # str\n'
        'ok = True         # bool',
        label: 'Types',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier les deux points ":" après if/for/def',
    'Mélanger les espaces et les tabulations',
  ],
  summary:
      'Python est lisible et structuré par l\'indentation. print, commentaires et types de base (int, float, str, bool) sont les fondations.',
  quiz: [
    q(const [
      'q1',
      'Comment Python définit-il les blocs de code ?',
      'qcm',
      'par l\'indentation|par les accolades {}|par les points-virgules|par la couleur',
      '0',
      'Python utilise l\'indentation pour structurer les blocs.',
    ]),
    q(const [
      'q2',
      'Quel type est "Alice" ?',
      'qcm',
      'str|int|float|bool',
      '0',
      '"Alice" entre guillemets est une chaîne (str).',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez un programme Python qui affiche votre nom, votre âge (int), votre taille (float) et un booléen.',
    ),
  ],
  xp: 80,
);

Course _pyVariables() => Course(
  id: 'py-variables',
  title: 'Variables et opérations',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Manipuler des variables',
    'Faire des opérations',
    'Utiliser les f-strings',
  ],
  prerequisites: ['Syntaxe Python'],
  sections: [
    sec('Les variables', [
      code(
        'ip = "192.168.1.42"\n'
        'port = 8080\n'
        'actif = True\n'
        'print(ip)\n'
        'print(type(ip))   # affiche <class \'str\'>',
        label: 'Variables',
      ),
    ]),
    sec('Opérations', [
      code(
        'a = 10; b = 3\n'
        'print(a + b)   # 13\n'
        'print(a - b)   # 7\n'
        'print(a * b)   # 30\n'
        'print(a / b)   # 3.33... (division)\n'
        'print(a // b)  # 3 (division entière)\n'
        'print(a % b)   # 1 (reste)\n'
        'print(a ** 2)  # 100 (puissance)',
        label: 'Calculs',
      ),
    ]),
    sec('Les chaînes et f-strings', [
      code(
        'proto = "HTTPS"\n'
        '# f-string : insertion de variables\n'
        'print(f"Protocole : {proto}") \n'
        '# méthodes de chaînes\n'
        'print(proto.lower())   # https\n'
        'print(proto.upper())   # HTTPS\n'
        'print(len(proto))      # 5',
        label: 'Chaînes',
      ),
    ]),
    sec('Entrée utilisateur', [
      code(
        'port = input("Entrez un port : ")\n'
        'print(f"Vous avez choisi le port {port}")\n'
        '# note: input renvoie une str, convertir si besoin\n'
        'port_int = int(port)',
        label: 'input',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier de convertir (input renvoie une str)',
    'Confondre / (réel) et // (entier)',
  ],
  summary:
      'Les variables stockent données et types. Les opérations arithmétiques et les f-strings facilitent l\'affichage. input lit l\'utilisateur.',
  quiz: [
    q(const [
      'q1',
      'f"{port}" permet de...',
      'qcm',
      'insérer port dans une chaîne|déclarer port|supprimer port|multiplier port',
      '0',
      'Les f-strings insèrent des variables dans un texte.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Écrivez un programme qui demande une adresse IP et un port puis les affiche dans une phrase.',
    ),
  ],
  xp: 80,
);

Course _pyConditions() => Course(
  id: 'py-conditions',
  title: 'Les conditions en Python',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Utiliser if/elif/else',
    'Comparer des valeurs',
    'Combiner des conditions',
  ],
  prerequisites: ['Variables Python'],
  sections: [
    sec('La structure', [
      code(
        'port = 80\n'
        'if port == 80:\n'
        '    print("HTTP")\n'
        'elif port == 443:\n'
        '    print("HTTPS")\n'
        'else:\n'
        '    print("Autre port")',
        label: 'if/elif/else',
      ),
    ]),
    sec('Comparateurs', [
      code(
        '==   égal\n'
        '!=   différent\n'
        '>    supérieur\n'
        '<    inférieur\n'
        '>=   >= \n'
        '<=   <=',
        label: 'Comparateurs',
      ),
    ]),
    sec('Conditions combinées', [
      code(
        'ip = "10.0.0.1"\n'
        'if ip.startswith("10.") and len(ip) > 5:\n'
        '    print("IP privée (10.x)")\n'
        'if port < 1024 or port == 8080:\n'
        '    print("port courant")',
        label: 'and/or',
      ),
    ]),
    sec('Vérité et type', [
      code(
        'actif = True\n'
        'if actif:\n'
        '    print("actif")\n'
        '# vérifier un type / présence\n'
        'liste = []\n'
        'if not liste:\n'
        '    print("liste vide")',
        label: 'Tests',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser = (affectation) au lieu de == (comparaison)',
    'Oublier les : et l\'indentation',
  ],
  summary:
      'if/elif/else guide le flux selon des conditions comparées et combinées (and/or). == compare, = affecte.',
  quiz: [
    q(const [
      'q1',
      'Quel opérateur compare l\'égalité ?',
      'qcm',
      '==|=|= =|is égal',
      '0',
      '== teste l\'égalité, = affecte.',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez un programme qui dit si un port est "courant" (< 1024) ou "utilisateur" (>= 1024).',
    ),
  ],
  xp: 80,
);

Course _pyLoops() => Course(
  id: 'py-loops',
  title: 'Les boucles en Python',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Utiliser for et while',
    'Parcourir des listes',
    'Utiliser range',
  ],
  prerequisites: ['Conditions Python'],
  sections: [
    sec('La boucle for', [
      code(
        '# parcourir une liste\n'
        'ports = [22, 80, 443, 8080]\n'
        'for p in ports:\n'
        '    print(f"Port {p} ouvert")\n'
        '\n'
        '# parcourir une plage\n'
        'for i in range(5):   # 0..4\n'
        '    print(i)',
        label: 'for',
      ),
      text(
        'range(n) génère 0..n-1, range(a,b) génère a..b-1, range(a,b,c) avec pas c.',
      ),
    ]),
    sec('Parcourir des fichiers et chaînes', [
      code(
        'with open("logs.txt") as f:\n'
        '    for ligne in f:\n'
        '        ligne = ligne.strip()\n'
        '        if "ERROR" in ligne:\n'
        '            print(ligne)',
        label: 'Fichier',
      ),
      code(
        'mot = "cyber"\n'
        'for c in mot:\n'
        '    print(c)   # chaque caractère',
        label: 'Chaîne',
      ),
    ]),
    sec('La boucle while', [
      code(
        'tentatives = 0\n'
        'while tentatives < 3:\n'
        '    print(f"Tentative {tentatives+1}")\n'
        '    tentatives += 1',
        label: 'while',
      ),
    ]),
    sec('break et continue', [
      code(
        'for p in range(1, 1001):\n'
        '    if p == 443:\n'
        '        print("trouvé 443")\n'
        '        break        # sort de la boucle\n'
        '    if p < 22:\n'
        '        continue     # passe à l\'itération suivante\n'
        '    print(p)',
        label: 'break/continue',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier l\'indentation dans la boucle',
    'Boucle while infinie (pas d\'incrément)',
  ],
  summary:
      'for parcourt listes/plages/fichiers, while répète tant qu\'une condition est vraie. break sort, continue passe à la suite.',
  quiz: [
    q(const [
      'q1',
      'range(5) génère...',
      'qcm',
      '0 à 4|1 à 5|0 à 5|1 à 4',
      '0',
      'range(5) va de 0 à 4 inclus.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Écrivez une boucle for qui affiche les ports [22,80,443] avec un message, et une boucle qui parcourt les lignes d\'un fichier en cherchant "ERROR".',
    ),
  ],
  xp: 80,
);

Course _pyFunctions() => Course(
  id: 'py-functions',
  title: 'Les fonctions en Python',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Définir et appeler des fonctions',
    'Passer des paramètres',
    'Retourner des valeurs',
  ],
  prerequisites: ['Conditions, boucles'],
  sections: [
    sec('Définir une fonction', [
      code(
        'def analyser_port(port):\n'
        '    if port < 1024:\n'
        '        return "Port privilégié"\n'
        '    else:\n'
        '        return "Port utilisateur"\n'
        '\n'
        'print(analyser_port(22))    # Port privilégié\n'
        'print(analyser_port(8080))  # Port utilisateur',
        label: 'def/return',
      ),
    ]),
    sec('Paramètres par défaut et retour multiple', [
      code(
        'def scanner(ip, ports=[22, 80, 443]):\n'
        '    print(f"Scan de {ip}")\n'
        '    return ports\n'
        '\n'
        'def extraire(ip, port):\n'
        '    return ip, port   # retourne un tuple\n'
        '\n'
        'a, b = extraire("10.0.0.1", 80)\n'
        'print(a, b)',
        label: 'Exemples',
      ),
    ]),
    sec('Les fonctions en cybersécurité', [
      text(
        'On structure ses outils en fonctions réutilisables : une fonction pour analyser un log, une pour faire une requête, une pour comparer des hashes. Cela rend le code clair et testable.',
      ),
    ]),
    sec('Variables locales et globales', [
      text(
        'Une variable définie dans une fonction est locale. Pour utiliser une globale, on déclare global (à éviter au profit des paramètres/retours).',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier return (la fonction renvoie None)',
    'Utiliser des globales plutôt que des paramètres',
  ],
  summary:
      'Les fonctions encapsulent du code réutilisable, acceptent des paramètres (avec valeurs par défaut) et renvoient des valeurs. Essentielles pour outils structurés.',
  quiz: [
    q(const [
      'q1',
      'Pour renvoyer une valeur, une fonction utilise...',
      'qcm',
      'return|print|break|yield',
      '0',
      'return renvoie une valeur à l\'appelant.',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez une fonction qui prend une IP et un port et retourne une phrase. Testez-la.',
    ),
  ],
  xp: 80,
);

Course _pyFiles() => Course(
  id: 'py-files',
  title: 'Travailler avec des fichiers',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Lire et écrire des fichiers',
    'Traiter des lignes',
    'Utiliser with open()',
  ],
  prerequisites: ['Fonctions Python'],
  sections: [
    sec('Lire un fichier', [
      code(
        'with open("auth.log") as f:\n'
        '    contenu = f.read()        # tout\n'
        '    lignes = f.readlines()    # liste de lignes',
        label: 'Lecture',
      ),
      text(
        'avec with, le fichier est fermé automatiquement, c\'est la bonne pratique.',
      ),
    ]),
    sec('Parcourir ligne par ligne', [
      code(
        'with open("auth.log") as f:\n'
        '    for ligne in f:\n'
        '        ligne = ligne.strip()\n'
        '        if "Failed password" in ligne:\n'
        '            print(ligne)',
        label: 'Lignes',
      ),
    ]),
    sec('Écrire un fichier', [
      code(
        'with open("rapport.txt", "w") as f:   # w = écrire\n'
        '    f.write("Rapport d\'analyse\\n")\n'
        '    f.write("3 échecs détectés\\n")\n'
        '\n'
        'with open("rapport.txt", "a") as f:    # a = ajouter\n'
        '    f.write("Fin du rapport\\n")',
        label: 'Écriture',
      ),
      text('"w" écrase, "a" ajoute à la fin, "r" lit (défaut).'),
    ]),
    sec('Manipuler des chemins', [
      code(
        'import os\n'
        'print(os.path.exists("auth.log"))  # True/False\n'
        'print(os.listdir("/var/log"))       # liste\n'
        'import glob\n'
        'for f in glob.glob("/var/log/*.log"):\n'
        '    print(f)',
        label: 'os/glob',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier with (fichier jamais fermé)',
    'Confondre "w" (écrase) et "a" (ajoute)',
  ],
  summary:
      'with open() lit/écrit les fichiers proprement. On parcourt ligne par ligne pour analyser, et on écrit des rapports avec "w"/"a".',
  quiz: [
    q(const [
      'q1',
      'Quel mode ouvre un fichier en écriture (écrase) ?',
      'qcm',
      '"w"|"r"|"a"|"rb"',
      '0',
      '"w" ouvre en écriture et écrase le contenu.',
    ]),
    q(const [
      'q2',
      'Quel mode ajoute à la fin ?',
      'qcm',
      '"a"|"w"|"r"|"x"',
      '0',
      '"a" (append) ajoute sans écraser.',
    ]),
  ],
  exercises: [
    ex(
      'Analyse',
      'Écrivez un programme Python qui compte les lignes contenant "ERROR" dans un fichier et écrit le résultat dans un rapport.',
    ),
  ],
  xp: 80,
);

Course _pyJson() => Course(
  id: 'py-json',
  title: 'JSON et les données structurées',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Comprendre JSON',
    'Lire et écrire du JSON',
    'Naviguer dans les structures',
  ],
  prerequisites: ['Fichiers Python'],
  sections: [
    sec('Qu\'est-ce que JSON ?', [
      text(
        'JSON (JavaScript Object Notation) est un format de données structuré, très utilisé par les APIs et la configuration. Il est lisible, avec des objets {clé: valeur} et des listes [ ].',
      ),
      code(
        '{\n'
        '  "utilisateur": "alice",\n'
        '  "roles": ["admin", "audit"],\n'
        '  "actif": true,\n'
        '  "id": 42\n'
        '}',
        label: 'Exemple JSON',
      ),
    ]),
    sec('Travailler avec json', [
      code(
        'import json\n'
        'data = {"utilisateur": "alice", "roles": ["admin"]}\n'
        'chaine = json.dumps(data)      # dict → JSON (str)\n'
        'retour = json.loads(chaine)    # JSON → dict\n'
        'print(retour["utilisateur"])   # alice',
        label: 'json',
      ),
    ]),
    sec('Lire un fichier JSON', [
      code(
        'import json\n'
        'with open("config.json") as f:\n'
        '    data = json.load(f)      # décode le fichier\n'
        'print(data["serveur"]["ip"])\n'
        'for role in data["roles"]:\n'
        '    print(role)',
        label: 'Fichier',
      ),
    ]),
    sec('APIs et JSON', [
      text(
        'Les APIs REST renvoient souvent du JSON. On le décodera avec la bibliothèque requests (ou http) pour l\'analyser. C\'est un pilier de l\'interaction avec les API en cybersécurité.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier json.load (fichier) vs json.loads (chaîne)',
    'Oublier que True devient true en JSON et vice-versa',
  ],
  summary:
      'JSON structure les données (objets et listes). attention data est un format de données et non un langage. json.dumps encode, json.loads décode.',
  quiz: [
    q(const [
      'q1',
      'Pour décoder une chaîne JSON en dict, on utilise...',
      'qcm',
      'json.loads()|json.dumps()|json.load()|json.open()',
      '0',
      'json.loads() décode une chaîne, json.dumps() encode un dict.',
    ]),
    q(const [
      'q2',
      'Pour décoder un fichier JSON, on utilise...',
      'qcm',
      'json.load(fichier)|json.loads(fichier)|json.dumps(fichier)|json.decode(fichier)',
      '0',
      'json.load() lit et décode depuis un fichier.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Écrivez un dict Python représentant une alerte (titre, gravité, ip), encodez-le en JSON avec dumps, puis redécodez-le avec loads.',
    ),
  ],
  xp: 80,
);

Course _pyRegex() => Course(
  id: 'py-regex',
  title: 'Les expressions régulières',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: ['Comprendre les regex', 'Chercher et extraire', 'Utiliser re'],
  prerequisites: ['Fichiers, JSON'],
  sections: [
    sec('C\'est quoi une regex ?', [
      text(
        'Une expression régulière (regex) est un motif pour chercher du texte. Elle permet d\'extraire des IP, des emails, des motifs précis depuis des logs. C\'est un outil puissant en cybersécurité.',
      ),
    ]),
    sec('Les motifs de base', [
      code(
        're = module Python\n'
        '\\d   un chiffre\n'
        '\\w   un caractère alphanumérique\n'
        '\\s   un espace\n'
        '.    n\'importe quel caractère\n'
        '*    répétition (0+)\n'
        '+    répétition (1+)\n'
        '{n}  exactement n\n'
        '[abc] un de ces caractères\n'
        '^    début de ligne\n'
        '\$    fin de ligne',
        label: 'Motifs',
      ),
    ]),
    sec('Chercher et extraire', [
      code(
        'import re\n'
        'texte = "connecté depuis 192.168.1.42 le 2024-01-01"\n'
        'ip = re.search(r"\\d+\\.\\d+\\.\\d+\\.\\d+", texte)\n'
        'if ip:\n'
        '    print(ip.group())    # 192.168.1.42\n'
        '\n'
        '# toutes les correspondances\n'
        'ips = re.findall(r"\\d{1,3}(\\.\\d{1,3}){3}", texte)\n'
        'print(ips)',
        label: 're.search/findall',
      ),
    ]),
    sec('Exemple : analyser des logs', [
      code(
        'import re\n'
        'motif_ip = r"\\d{1,3}(\\.\\d{1,3}){3}"\n'
        'with open("auth.log") as f:\n'
        '    for ligne in f:\n'
        '        if "Failed password" in ligne:\n'
        '            m = re.search(motif_ip, ligne)\n'
        '            if m:\n'
        '                print(m.group())',
        label: 'Logs',
      ),
      text(
        'On préfixe les motifs bruts par r"..." pour éviter les échappements.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier r"..." devant le motif',
    'Échapper les points et barres (le point est "n\'importe quel caractère")',
  ],
  summary:
      'Les regex décrivent des motifs de texte (\\d, \\w, *, +, [ ]). re.search/findall les utilisent pour filtrer et extraire des logs.',
  quiz: [
    q(const [
      'q1',
      'Le motif \\d+ correspond à...',
      'qcm',
      'un ou plusieurs chiffres|une lettre|un espace|un point',
      '0',
      '\\d = chiffre, + = un ou plusieurs.',
    ]),
  ],
  exercises: [
    ex(
      'Écrire',
      'Écrivez une regex Python qui extrait les adresses IP d\'une chaîne et testez-la sur un exemple de log.',
    ),
  ],
  xp: 90,
);

Course _pySockets() => Course(
  id: 'py-sockets',
  title: 'Python et les sockets',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Comprendre les sockets',
    'Se connecter à un serveur',
    'Créer un mini-scanner local',
  ],
  prerequisites: ['Réseau (ports, TCP)'],
  sections: [
    sec('Qu\'est-ce qu\'un socket ?', [
      text(
        'Un socket est un point de connexion réseau : il permet de communiquer avec un autre programme sur le réseau. En Python, le module socket permet d\'ouvrir des connexions (client) et d\'écouter (serveur).',
      ),
      text(
        'Pour la cybersécurité, on l\'utilise pour des tests de connectivité, des requêtes bas niveau, et des mini-scanners sur son propre réseau/lab.',
      ),
    ]),
    sec('Un client simple', [
      code(
        'import socket\n'
        's = socket.socket()\n'
        's.settimeout(2)\n'
        'try:\n'
        '    s.connect(("localhost", 80))\n'
        '    print("Port 80 ouvert")\n'
        '    s.send(b"GET / HTTP/1.1\\r\\nHost: localhost\\r\\n\\r\\n")\n'
        '    print(s.recv(1024))\n'
        'except Exception as e:\n'
        '    print("Échec :", e)\n'
        'finally:\n'
        '    s.close()',
        label: 'Client',
      ),
    ]),
    sec('Mini-scanner local (autorisé)', [
      code(
        'import socket\n'
        'ip = "127.0.0.1"\n'
        'for port in [22, 80, 443, 8080]:\n'
        '    s = socket.socket()\n'
        '    s.settimeout(1)\n'
        '    result = s.connect_ex((ip, port))\n'
        '    if result == 0:\n'
        '        print(f"Port {port} : ouvert")\n'
        '    else:\n'
        '        print(f"Port {port} : fermé")\n'
        '    s.close()',
        label: 'Scanner localhost',
      ),
      warn(
        'Ce scanner ne doit cibler QUE localhost (127.0.0.1), votre machine ou un laboratoire autorisé. Ne scannez jamais un réseau tiers.',
      ),
    ]),
    sec('Le module http et l\'API', [
      text(
        'Pour des requêtes HTTP plus riches (méthodes, headers, JSON), on préfère la bibliothèque requests ou http.client au lieu des sockets bas niveau. Vu dans le cours HTTP.',
      ),
    ]),
  ],
  commonMistakes: [
    'Scanner des machines sans autorisation',
    'Oublier settimeout (blocage infini) et close()',
  ],
  summary:
      'Les sockets permettent d\'ouvrir des connexions réseau en Python. On peut créer des clients et des mini-scanners, réservés à localhost/lab autorisé.',
  quiz: [
    q(const [
      'q1',
      'Que renvoie connect_ex() si le port est ouvert ?',
      'qcm',
      '0|1|-1|None',
      '0',
      'connect_ex renvoie 0 si la connexion réussit (port ouvert).',
    ]),
  ],
  exercises: [
    ex(
      'Scanner',
      'Écrivez un scanner Python de ports sur localhost pour [22, 80, 443]. Rappel : uniquement localhost ou lab autorisé.',
    ),
  ],
  xp: 90,
);

Course _pyHttp() => Course(
  id: 'py-http',
  title: 'Python et HTTP / API',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Faire des requêtes HTTP',
    'Analyser les réponses',
    'Interagir avec des APIs',
  ],
  prerequisites: ['JSON, HTTP'],
  sections: [
    sec('Faire une requête GET', [
      text(
        'On utilise la bibliothèque requests (standard de facto) pour interagir avec le web et les APIs. Elle gère méthodes, headers et JSON.',
      ),
      code(
        'import requests\n'
        'r = requests.get("https://exemple.com")\n'
        'print(r.status_code)   # 200\n'
        'print(r.headers)       # en-têtes\n'
        'print(r.text)          # corps',
        label: 'GET',
      ),
    ]),
    sec('Envoyer des paramètres et données', [
      code(
        'import requests\n'
        'r = requests.get("https://api.exemple.com/users",\n'
        '                  params={"limit": 10})\n'
        'r2 = requests.post("https://api.exemple.com/login",\n'
        '                   data={"user": "alice", "pass": "x"})\n'
        '# en JSON\n'
        'r3 = requests.post("https://api.exemple.com/item",\n'
        '                    json={"nom": "test"})',
        label: 'params/payload',
      ),
    ]),
    sec('Analyseur d\'en-têtes', [
      code(
        'import requests\n'
        'r = requests.get("https://exemple.com")\n'
        'for k, v in r.headers.items():\n'
        '    print(f"{k}: {v}")\n'
        '# Vérifier des headers de sécurité\n'
        'securisation = ["X-Frame-Options", "Strict-Transport-Security",\n'
        '                "Content-Security-Policy"]\n'
        'for h in securisation:\n'
        '    statut = "présent" if h in r.headers else "MANQUANT"\n'
        '    print(f"{h}: {statut}")',
        label: 'Headers',
      ),
    ]),
    sec('http.client (sans bibliothèque)', [
      text(
        'Sans requests, on peut utiliser http.client ou le module socket. Mais requests est plus simple et plus riche. (Pour ce cours, on suppose requests installé.)',
      ),
    ]),
  ],
  commonMistakes: [
    'Ne pas vérifier le status_code avant d\'utiliser la réponse',
    'Envoyer des requêtes vers des cibles non autorisées',
  ],
  summary:
      'requests permet GET/POST, params, json et l\'analyse des réponses. On vérifie les en-têtes de sécurité et le statut. Sur cibles autorisées uniquement.',
  quiz: [
    q(const [
      'q1',
      'Quel attribut donne le code de statut ?',
      'qcm',
      'r.status_code|r.text|r.headers|r.code',
      '0',
      'r.status_code contient le code HTTP.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Écrivez une fonction qui fait un GET et vérifie la présence des en-têtes de sécurité manquants.',
    ),
  ],
  xp: 90,
);

Course _pyHashing() => Course(
  id: 'py-hash',
  title: 'Hashing avec Python',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Comprendre le hashing',
    'Calculer des hashs (MD5, SHA1, SHA256)',
    'Vérifier l\'intégrité de fichiers',
  ],
  prerequisites: ['Fichiers, fonctions'],
  sections: [
    sec('Le hashing', [
      text(
        'Un hash est une empreinte numérique fixe et unique d\'une donnée. Quelle que soit la taille du fichier, le hash (ex: SHA256) fait toujours la même taille et change si la donnée change ne serait-ce que d\'un bit.',
      ),
      warn(
        'MD5 et SHA1 sont cassés (collisions) : on utilise SHA256 ou plus pour la sécurité. MD5/sha1 restent utiles pour identifier des fichiers, pas pour la sécurité.',
      ),
    ]),
    sec('Calculer un hash de fichier', [
      code(
        'import hashlib\n'
        'def hash_fichier(chemin, algo="sha256"):\n'
        '    h = hashlib.new(algo)\n'
        '    with open(chemin, "rb") as f:\n'
        '        for bloc in iter(lambda: f.read(4096), b""):\n'
        '            h.update(bloc)\n'
        '    return h.hexdigest()\n'
        '\n'
        'print(hash_fichier("fichier.txt"))',
        label: 'Calcul',
      ),
    ]),
    sec('Vérifier l\'intégrité', [
      text(
        'Les outils téléchargés publient souvent leur hash SHA256. On calcule le hash du fichier et on le compare : s\'il correspond, le fichier est authentique et intact.',
      ),
      code(
        'import hashlib\n'
        'attendu = "hash_attendu..."\n'
        'calcule = hash_fichier("outil.bin")\n'
        'if calcule == attendu:\n'
        '    print("Intègre ✔")\n'
        'else:\n'
        '    print("Hash différent - fichier douteux !")',
        label: 'Vérification',
      ),
    ]),
    sec('Hash de chaînes', [
      code(
        'import hashlib\n'
        'print(hashlib.sha256(b"mot de passe").hexdigest())\n'
        'print(hashlib.md5(b"texte").hexdigest())',
        label: 'Chaînes',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser MD5/sha1 pour la sécurité (cassés)',
    'Oublier de lire en mode binaire "rb" pour les fichiers',
  ],
  summary:
      'Le hash est une empreinte unique (SHA256). On l\'utilise pour vérifier l\'intégrité et l\'authenticité des fichiers. MD5/sha1 sont obsolètes en sécurité.',
  quiz: [
    q(const [
      'q1',
      'Quel algo est recommandé pour la sécurité ?',
      'qcm',
      'SHA256|MD5|SHA1|CRC32',
      '0',
      'SHA256 est sûr ; MD5 et SHA1 sont cassés.',
    ]),
  ],
  exercises: [
    ex(
      'Vérifier',
      'Écrivez une fonction qui calcule le SHA256 d\'un fichier et compare à une valeur attendue pour vérifier l\'intégrité.',
    ),
  ],
  xp: 90,
);

Course _pyAnalyzer() => Course(
  id: 'py-analyzer',
  title: 'Projet : analyseur de logs Python',
  category: 'python',
  level: 'Niveau 4 - Python pour la cybersécurité',
  levelNumber: 4,
  objectives: [
    'Réaliser un projet Python complet',
    'Analyser des logs avec Python',
    'Regrouper les notions apprises',
  ],
  prerequisites: ['Tous les cours Python'],
  sections: [
    sec('Le projet', [
      text(
        'Réalisons un analyseur de logs Python qui lit un fichier de logs, détecte les tentatives d\'échec, extrait les IP avec regex, les compte et produit un rapport. C\'est un outil défensif concret.',
      ),
    ]),
    sec('Le script complet', [
      code(
        'import re\n'
        'from collections import Counter\n'
        '\n'
        'def extraire_ips(chemin):\n'
        '    motif_ip = r"\\d{1,3}(\\.\\d{1,3}){3}"\n'
        '    ips = []\n'
        '    try:\n'
        '        with open(chemin) as f:\n'
        '            for ligne in f:\n'
        '                if "Failed password" in ligne:\n'
        '                    m = re.search(motif_ip, ligne)\n'
        '                    if m:\n'
        '                        ips.append(m.group())\n'
        '    except FileNotFoundError:\n'
        '        print("Fichier introuvable")\n'
        '    return ips\n'
        '\n'
        'def rapport(chemin):\n'
        '    ips = extraire_ips(chemin)\n'
        '    print(f"Total échecs : {len(ips)}")\n'
        '    for ip, n in Counter(ips).most_common(5):\n'
        '        print(f"{ip} : {n}")\n'
        '\n'
        'rapport("auth.log")',
        label: 'analyseur.py',
      ),
    ]),
    sec('Améliorations possibles', [
      list(
        '- Compter aussi les succès "Accepted".\n'
        '- Filtrer les IP selon un seuil (brute-force).\n'
        '- Écrire le rapport dans un fichier.\n'
        '- Chercher d\'autres motifs (sudo, erreurs).',
      ),
    ]),
    sec('Conclure', [
      text(
        'Vous savez désormais analyser des logs, interagir avec des APIs, calculer des hashes et créer des outils en Python. Ces compétences serviront en Blue Team, Web Security et CTF.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ne pas gérer l\'absence de fichier',
    'Oublier de fermer le fichier (with)',
  ],
  summary:
      'Le projet analyseur de logs combine regex, fichiers, comptage et rapport. C\'est un outil défensif qui clôt le parcours Python.',
  quiz: [
    q(const [
      'q1',
      'Quel outil Python compte les occurrences ?',
      'qcm',
      'collections.Counter|list.append|print|open',
      '0',
      'Counter à compter les occurrences d\'éléments.',
    ]),
  ],
  exercises: [
    ex(
      'Projet final',
      'Améliorez l\'analyseur : ajoutez le comptage des connexions réussies ("Accepted") et écrivez le rapport dans un fichier.',
    ),
  ],
  xp: 100,
);
