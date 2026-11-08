import 'package:cyberlab_agent/models/ctf_challenge.dart';

List<CtfChallenge> ctfChallenges() => [
  CtfChallenge(
    id: 'ctf-linux-1',
    title: 'Le fichier caché',
    category: 'Linux',
    difficulty: 'Très facile',
    xp: 50,
    objective:
        'Trouver l\'emplacement du fichier caché dont le nom commence par un point.',
    environment: 'Terminal simulé',
    puzzle:
        'Dans un dossier, un fichier "secret.txt" est caché. Quelle commande permet de le voir ?',
    hints: [
      'Les fichiers cachés commencent par un point.',
      'Utilisez ls avec une option qui montre tout, même les fichiers cachés.',
      'L\'option est une seule lettre, celle du mot anglais « all ».',
    ],
    answer: 'ls -a',
    acceptedAnswers: ['ls -la', 'ls -al', 'ls -A'],
    caseSensitive: true,
    explanation:
        'Les fichiers dont le nom commence par "." sont cachés par défaut. L\'option -a de ls permet de les afficher. En cybersécurité, il faut toujours vérifier ces fichiers (-a) car ils peuvent cacher des données ou de la configuration.',
  ),
  CtfChallenge(
    id: 'ctf-linux-2',
    title: 'Le mot de passe de root',
    category: 'Linux',
    difficulty: 'Facile',
    xp: 70,
    objective:
        'Appliquer sudo pour lire un fichier nécessitant les droits root.',
    environment: 'Terminal simulé',
    puzzle:
        'Le fichier /etc/shadow contient les hashes de mots de passe et est réservé à root. Quelle commande permet au groupe admin de le lire ?',
    hints: [
      'Lire un fichier protégé nécessite des privilèges élevés.',
      'Le programme qui élève les privilèges commence par sudo.',
      'Combinez sudo avec la commande qui affiche le contenu d\'un fichier, suivie du chemin complet.',
    ],
    answer: 'sudo cat /etc/shadow',
    acceptedAnswers: ['sudo less /etc/shadow', 'sudo more /etc/shadow'],
    caseSensitive: true,
    explanation:
        'Le fichier /etc/shadow n\'est lisible que par root. La commande "sudo cat /etc/shadow" lit temporairement avec les droits de root. En sécurité, on utilise sudo de façon ponctuelle et encadrée.',
  ),
  CtfChallenge(
    id: 'ctf-web-1',
    title: 'Mauvaise méthode',
    category: 'Web',
    difficulty: 'Très facile',
    xp: 50,
    objective:
        'Identifier la bonne méthode HTTP pour envoyer un formulaire de connexion.',
    environment: 'Réflexion / terminal',
    puzzle:
        'Vous devez envoyer un formulaire de connexion contenant un mot de passe. Quelle méthode HTTP devez-vous utiliser plutôt que GET ?',
    hints: [
      'GET met les paramètres dans l\'URL, visibles.',
      'Une méthode envoie les données dans le corps de la requête, plus discrète.',
      'C\'est la valeur la plus courante de l\'attribut method d\'un formulaire HTML de connexion.',
    ],
    answer: 'POST',
    explanation:
        'POST envoie les données dans le corps de la requête, contrairement à GET qui les met dans l\'URL (visibles dans l\'historique et les logs). Les données sensibles (mots de passe) doivent toujours aller en POST.',
  ),
  CtfChallenge(
    id: 'ctf-net-1',
    title: 'Quel protocole ?',
    category: 'Réseau',
    difficulty: 'Très facile',
    xp: 50,
    objective: 'Reconnaître le protocole encodant une requête HTTP/TLS.',
    environment: 'Quiz / réflexion',
    puzzle:
        'Un site web montre un cadenas et ses données sont chiffrées entre votre navigateur et le serveur. Quel protocole sécurise cette connexion ?',
    hints: [
      'On parle d\'HTTPS.',
      'Le "S" de HTTPS vient de ce protocole de chiffrement.',
      'C\'est le successeur de SSL ; son sigle compte trois lettres.',
    ],
    answer: 'TLS',
    acceptedAnswers: [
      'Transport Layer Security',
      'TLS (Transport Layer Security)',
    ],
    explanation:
        'HTTPS = HTTP + TLS. TLS chiffre la connexion, protège la confidentialité et l\'intégrité. L\'ancien SSL est obsolète.',
  ),
  CtfChallenge(
    id: 'ctf-crypto-1',
    title: 'Base64 ou hash ?',
    category: 'Crypto',
    difficulty: 'Très facile',
    xp: 60,
    objective: 'Comprendre la différence entre encodage et hashing.',
    environment: 'Réflexion',
    puzzle:
        'La chaîne "aGVsbG8=" est "hello" encodé. S\'agit-il d\'un hash, d\'un encodage ou d\'un chiffrement ?',
    hints: [
      'Un hash a une taille fixe et n\'est pas réversible.',
      'Un encodage est réversible facilement (on peut le décoder).',
      'Le « = » final est un remplissage caractéristique d\'un encodage très répandu, nommé d\'après le nombre de symboles qu\'il utilise.',
    ],
    answer: 'base64',
    acceptedAnswers: ['base 64', 'encodage', 'un encodage', 'encodage base64'],
    explanation:
        'Base64 est un encodage : il transforme des données pour les transporter, mais se décode facilement. Ce n\'est PAS un hash (irréversible) ni un chiffrement (qui nécessite une clé). Il ne faut jamais considérer Base64 comme un secret.',
  ),
  CtfChallenge(
    id: 'ctf-logs-1',
    title: 'La brute-force',
    category: 'Logs',
    difficulty: 'Facile',
    xp: 80,
    objective: 'Analyser un fichier de logs pour détecter une brute-force.',
    environment: 'Analyse de logs',
    puzzle:
        'Dans auth.log il y a des lignes "Failed password for admin from 203.0.113.7". Qu\'indique la répétition de ces lignes depuis la même IP ?',
    hints: [
      'Plusieurs échecs de connexion depuis une même IP.',
      'C\'est une tentative de forçage automatisée.',
      'L\'attaquant essaie un grand nombre de mots de passe jusqu\'à trouver le bon : comment appelle-t-on cette méthode en anglais ?',
    ],
    answer: 'brute-force',
    acceptedAnswers: [
      'brute force',
      'bruteforce',
      'force brute',
      'attaque par brute-force',
      'attaque par force brute',
    ],
    explanation:
        'La répétition de "Failed password" depuis la même IP en peu de temps est le signe typique d\'une attaque par brute-force sur le service SSH. La défense : limiter les tentatives, verrouiller/délai, et surveiller ces logs.',
  ),
  CtfChallenge(
    id: 'ctf-scripting-1',
    title: 'Le compteur',
    category: 'Scripting',
    difficulty: 'Facile',
    xp: 80,
    objective: 'Écrire un pipeline qui compte des événements dans un log.',
    environment: 'Terminal / Bash',
    puzzle:
        'Quelle commande (avec pipes) compte le nombre de lignes contenant "Failed password" dans auth.log ?',
    hints: [
      'Utilisez grep pour filtrer.',
      'Utilisez wc -l pour compter les lignes.',
      'Le motif contient un espace : pensez à le mettre entre guillemets, puis reliez les deux commandes par un pipe.',
    ],
    answer: 'grep "Failed password" auth.log | wc -l',
    acceptedAnswers: [
      "grep 'Failed password' auth.log | wc -l",
      'grep -c "Failed password" auth.log',
      "grep -c 'Failed password' auth.log",
    ],
    caseSensitive: true,
    explanation:
        'grep filtre les lignes contenant le motif, wc -l compte les lignes. Le pipe | enchaîne les commandes. On obtient le nombre d\'échecs.',
  ),
  CtfChallenge(
    id: 'ctf-forensic-1',
    title: 'Le hash',
    category: 'Forensic',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Comprendre comment vérifier l\'intégrité d\'un fichier.',
    environment: 'Python / réflexion',
    puzzle:
        'Pour vérifier qu\'un fichier téléchargé est authentique et intact, quel algorithme utilise-t-on pour comparer son empreinte ?',
    hints: [
      'L\'empreinte numérique d\'un fichier s\'appelle un hash.',
      'On recommande SHA-256 plutôt que MD5.',
      'Cherchez la famille SHA-2 et la variante dont l\'empreinte fait 256 bits.',
    ],
    answer: 'sha256',
    acceptedAnswers: ['sha-256', 'sha 256', 'sha2', 'sha-2'],
    explanation:
        'Le SHA-256 calcule une empreinte numérique d\'un fichier. On compare ce hash à la valeur attendue publiée par l\'éditeur : s\'ils correspondent, le fichier est authentique et intact.',
  ),
  CtfChallenge(
    id: 'ctf-linux-3',
    title: 'Chercher dans un dossier',
    category: 'Linux',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Rechercher des fichiers par nom ou critère.',
    environment: 'Terminal simulé',
    puzzle: 'Quelle commande cherche tous les fichiers .conf dans /etc ?',
    hints: [
      'C\'est la commande find.',
      'Utilisez les options -name avec un joker.',
      'Ordre : la commande, le dossier de départ, puis le filtre de nom ; protégez le joker par des guillemets.',
    ],
    answer: 'find /etc -name "*.conf"',
    acceptedAnswers: [
      "find /etc -name '*.conf'",
      'find /etc -type f -name "*.conf"',
      "find /etc -type f -name '*.conf'",
    ],
    caseSensitive: true,
    explanation:
        'find parcourt l\'arborescence. -name "*.conf" filtre par nom avec le joker *. On obtient tous les fichiers de configuration de /etc.',
  ),
  CtfChallenge(
    id: 'ctf-web-2',
    title: 'L\'en-tête manquant',
    category: 'Web',
    difficulty: 'Moyen',
    xp: 100,
    objective: 'Comprendre et identifier les en-têtes de sécurité.',
    environment: 'Réflexion / curl',
    puzzle:
        'Une réponse HTTP manque un en-tête qui force le navigateur à n\'utiliser que HTTPS. Quel est cet en-tête ?',
    hints: [
      'Cet en-tête impose au navigateur une politique « stricte » pour la couche de transport.',
      'Son acronyme compte quatre lettres et commence par HS ; le serveur ne l\'envoie qu\'en HTTPS.',
      'Donnez le nom complet de l\'en-tête : trois mots reliés par des tirets.',
    ],
    answer: 'strict-transport-security',
    acceptedAnswers: ['hsts', 'Strict-Transport-Security (HSTS)'],
    explanation:
        'L\'en-tête Strict-Transport-Security (HSTS) indique au navigateur de n\'utiliser que HTTPS pour ce domaine, empêchant la rétrogradation en HTTP (downgrade).',
  ),
  CtfChallenge(
    id: 'ctf-net-2',
    title: 'Le port du SSH',
    category: 'Réseau',
    difficulty: 'Très facile',
    xp: 50,
    objective: 'Connaître les ports des services courants.',
    environment: 'Quiz',
    puzzle:
        'Vous voulez vous connecter à distance de façon sécurisée à un serveur. Sur quel port par défaut utilise le protocole SSH ?',
    hints: [
      'C\'est un port « bien connu », inférieur à 1024.',
      'Il est juste après celui de FTP (21) et juste avant celui de Telnet (23).',
      'Relancez « nmap localhost » dans le terminal simulé et regardez la ligne du service ssh.',
    ],
    answer: '22',
    acceptedAnswers: ['22/tcp', 'port 22'],
    explanation:
        'SSH utilise par défaut le port 22. Le connaître aide à lire les résultats de scans et à configurer des pare-feux.',
  ),
  CtfChallenge(
    id: 'ctf-crypto-2',
    title: 'Chiffré ou encodé',
    category: 'Crypto',
    difficulty: 'Moyen',
    xp: 90,
    objective: 'Différencier encodage, hash et chiffrement.',
    environment: 'Réflexion',
    puzzle:
        'Alice et Bob partagent un secret. Pour le protéger en transit, ils utilisent un processus nécessitant une clé pour déchiffrer. De quoi s\'agit-il ?',
    hints: [
      'Ce n\'est pas un hash (irréversible) ni un simple encodage.',
      'On utilise une clé pour déchiffrer.',
      'C\'est le procédé qui, avec une clé, rend un message illisible puis permet de le relire.',
    ],
    answer: 'chiffrement',
    acceptedAnswers: ['un chiffrement', 'chiffrement symétrique'],
    explanation:
        'Le chiffrement utilise une clé pour rendre le données illisibles et les redéchiffrer. Contrairement au hash (irréversible) et à l\'encodage (réversible sans clé).',
  ),
];
