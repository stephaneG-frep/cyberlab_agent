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

  // ------------------------------------------------------------------
  // Challenges à résoudre dans le terminal simulé du Lab (fichiers
  // virtuels). Les tests vérifient que chaque `terminalCommand` affiche
  // bien la réponse.
  // ------------------------------------------------------------------
  CtfChallenge(
    id: 'ctf-logs-2',
    title: 'Qui frappe à la porte ?',
    category: 'Logs',
    difficulty: 'Facile',
    xp: 80,
    objective:
        'Identifier l\'adresse IP la plus active dans les échecs de connexion.',
    environment: 'Terminal du Lab : ~/logs/auth.log',
    puzzle:
        'Le fichier ~/logs/auth.log contient des tentatives SSH échouées '
        '(« Failed password »). Quelle adresse IP en a fait le plus ?',
    hints: [
      'Commencez par ne garder que les lignes « Failed password » avec grep.',
      'grep -o (avec -E) n\'affiche que la partie qui correspond au motif : '
          'un motif d\'adresse IPv4 isole les adresses.',
      'sort | uniq -c compte les lignes identiques ; sort -nr met la plus '
          'fréquente en premier.',
    ],
    answer: '203.0.113.7',
    terminalCommand:
        'grep "Failed password" ~/logs/auth.log | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" | sort | uniq -c | sort -nr',
    explanation:
        '203.0.113.7 totalise 5 échecs (admin puis root). Compter les '
        'occurrences par adresse est le premier réflexe d\'analyse d\'une '
        'force brute ; c\'est aussi ce que fait fail2ban pour bannir.',
  ),
  CtfChallenge(
    id: 'ctf-logs-3',
    title: 'Le compte compromis',
    category: 'Logs',
    difficulty: 'Moyen',
    xp: 100,
    objective: 'Repérer la connexion réussie de l\'attaquant.',
    environment: 'Terminal du Lab : ~/logs/auth.log',
    puzzle:
        'Après ses échecs, 203.0.113.7 a fini par réussir à se connecter. '
        'Avec quel compte ?',
    hints: [
      'Une connexion SSH réussie est journalisée avec le mot « Accepted ».',
      'Combinez deux filtres : les lignes « Accepted » qui contiennent '
          'l\'adresse de l\'attaquant.',
      'Le nom du compte se trouve juste après « for ».',
    ],
    answer: 'backup',
    terminalCommand: 'grep Accepted ~/logs/auth.log | grep 203.0.113.7',
    explanation:
        'Le compte backup s\'est connecté par mot de passe depuis l\'IP de '
        'l\'attaquant : ce compte de service avait sans doute un mot de passe '
        'faible. Il faut le désactiver, changer son mot de passe et vérifier '
        'ce qu\'il a fait (voir aussi /etc/crontab).',
  ),
  CtfChallenge(
    id: 'ctf-linux-4',
    title: 'Le drapeau de root',
    category: 'Linux',
    difficulty: 'Moyen',
    xp: 100,
    objective:
        'Utiliser sudo pour lire un fichier du dossier personnel de root.',
    environment: 'Terminal du Lab',
    puzzle:
        'Un fichier flag.txt se trouve dans le dossier personnel de root. '
        'Que contient-il ? (réponse au format FLAG{...})',
    hints: [
      'Le dossier personnel de root n\'est pas dans /home.',
      'learner n\'a pas le droit d\'entrer dans ce dossier : « Permission non '
          'accordée ».',
      'Préfixez la commande de lecture par sudo, ou devenez root avec sudo -i.',
    ],
    answer: 'FLAG{root_lit_tout_mais_ne_touche_a_rien}',
    caseSensitive: true,
    terminalCommand: 'sudo cat /root/flag.txt',
    explanation:
        'Le dossier /root est réservé à root (droits 700). sudo exécute une '
        'commande avec les droits de root, ce qui est tracé dans les journaux. '
        'Avec de grands pouvoirs… on lit, on ne casse rien.',
  ),
  CtfChallenge(
    id: 'ctf-linux-5',
    title: 'Comptes interactifs',
    category: 'Linux',
    difficulty: 'Moyen',
    xp: 90,
    objective: 'Compter les comptes qui peuvent ouvrir un shell.',
    environment: 'Terminal du Lab : /etc/passwd',
    puzzle:
        'Combien de comptes de /etc/passwd ont /bin/bash comme shell de '
        'connexion ?',
    hints: [
      'Le shell est le dernier champ de chaque ligne de /etc/passwd.',
      'grep peut compter les lignes qui correspondent, sans les afficher.',
      'grep -c "/bin/bash" /etc/passwd',
    ],
    answer: '3',
    terminalCommand: 'grep -c /bin/bash /etc/passwd',
    explanation:
        'root, learner et backup peuvent ouvrir un shell. Les comptes de '
        'service (www-data, sshd, daemon) ont /usr/sbin/nologin : ils ne '
        'doivent jamais permettre de connexion interactive.',
  ),
  CtfChallenge(
    id: 'ctf-linux-6',
    title: 'Configuration à durcir',
    category: 'Linux',
    difficulty: 'Moyen',
    xp: 90,
    objective: 'Trouver le réglage SSH dangereux.',
    environment: 'Terminal du Lab : /etc/ssh/sshd_config',
    puzzle:
        'Dans la configuration du serveur SSH du lab, quelle directive '
        'autorise la connexion directe du compte root ?',
    hints: [
      'Le fichier de configuration du serveur SSH est /etc/ssh/sshd_config.',
      'Cherchez une ligne qui parle de root, en ignorant la casse (grep -i).',
      'La directive commence par « Permit ».',
    ],
    answer: 'PermitRootLogin',
    acceptedAnswers: ['PermitRootLogin yes'],
    terminalCommand: 'grep -i root /etc/ssh/sshd_config',
    explanation:
        'PermitRootLogin yes permet de viser directement root, cible n°1 des '
        'attaques par force brute. Bonne pratique : PermitRootLogin no, '
        'connexion avec un compte nominatif puis sudo, et PasswordAuthentication '
        'no au profit des clés SSH.',
  ),
  CtfChallenge(
    id: 'ctf-forensic-2',
    title: 'Tâche planifiée',
    category: 'Forensic',
    difficulty: 'Moyen',
    xp: 100,
    objective: 'Repérer un mécanisme de persistance.',
    environment: 'Terminal du Lab : /etc/crontab',
    puzzle:
        'Une tâche planifiée système lance un script toutes les 5 minutes. '
        'Quel est le chemin complet de ce script ?',
    hints: [
      'Les tâches planifiées système sont décrites dans /etc/crontab.',
      '« */5 » dans le champ des minutes signifie « toutes les 5 minutes ».',
      'Le chemin est le dernier élément de la ligne.',
    ],
    answer: '/home/backup/sauvegarde.sh',
    caseSensitive: true,
    terminalCommand: 'cat /etc/crontab',
    explanation:
        'Le compte backup exécute /home/backup/sauvegarde.sh toutes les 5 '
        'minutes. Comme ce compte a été compromis (voir « Le compte '
        'compromis »), l\'attaquant peut modifier ce script pour revenir à '
        'volonté : la crontab est un point de contrôle essentiel.',
  ),
  CtfChallenge(
    id: 'ctf-web-3',
    title: 'L\'outil de l\'attaquant',
    category: 'Web',
    difficulty: 'Facile',
    xp: 80,
    objective: 'Identifier un outil automatisé dans un journal web.',
    environment: 'Terminal du Lab : ~/logs/access.log',
    puzzle:
        'Dans ~/logs/access.log, des requêtes tentent une injection SQL '
        '(« OR 1=1 »). Quel outil automatisé l\'attaquant a-t-il utilisé ?',
    hints: [
      'Le dernier champ entre guillemets d\'une ligne de journal web est le '
          'User-Agent : le logiciel qui a envoyé la requête.',
      'Affichez les lignes de l\'IP 203.0.113.7.',
      'C\'est un outil open source bien connu d\'exploitation d\'injections SQL.',
    ],
    answer: 'sqlmap',
    terminalCommand: 'grep 203.0.113.7 ~/logs/access.log',
    explanation:
        'Le User-Agent « sqlmap/1.8 » trahit l\'outil. Un attaquant peut le '
        'masquer, mais beaucoup ne le font pas : c\'est un indicateur simple à '
        'surveiller, que les WAF bloquent souvent par défaut.',
  ),
  CtfChallenge(
    id: 'ctf-web-4',
    title: 'Commentaire bavard',
    category: 'Web',
    difficulty: 'Facile',
    xp: 70,
    objective:
        'Repérer une fuite d\'information dans le code source d\'une page.',
    environment: 'Terminal du Lab : /var/www/html',
    puzzle:
        'La page d\'accueil du serveur web du lab (/var/www/html/index.html) '
        'contient un commentaire oublié. Quel mot de passe y fuit ?',
    hints: [
      'Le code HTML d\'une page est visible par tous ses visiteurs.',
      'Les commentaires HTML s\'écrivent <!-- ... -->.',
      'cat /var/www/html/index.html',
    ],
    answer: 'admin123',
    caseSensitive: true,
    terminalCommand: 'cat /var/www/html/index.html',
    explanation:
        'Les commentaires HTML sont envoyés au navigateur : « Afficher le code '
        'source » suffit à les lire. Ne jamais y laisser d\'identifiants, de '
        'chemins internes ou de notes de développement.',
  ),
  CtfChallenge(
    id: 'ctf-web-5',
    title: 'Accès refusé',
    category: 'Web',
    difficulty: 'Très facile',
    xp: 50,
    objective: 'Connaître les codes de statut HTTP.',
    environment: 'Réflexion',
    puzzle:
        'Dans le journal web, la requête vers /admin a reçu le code 403. Que '
        'signifie ce code (en anglais ou en français) ?',
    hints: [
      'Les codes 4xx indiquent une erreur côté client.',
      '401 signifie « non authentifié » ; 403 va plus loin.',
      'Le serveur a compris la requête mais refuse d\'y répondre.',
    ],
    answer: 'Forbidden',
    acceptedAnswers: ['interdit', 'accès interdit', 'acces interdit'],
    explanation:
        '403 Forbidden : le serveur refuse l\'accès, même authentifié. À ne pas '
        'confondre avec 401 Unauthorized (authentification requise) et 404 Not '
        'Found. Une rafale de 403 sur des chemins sensibles signale souvent une '
        'reconnaissance.',
  ),
  CtfChallenge(
    id: 'ctf-net-3',
    title: 'Le port du DNS',
    category: 'Réseau',
    difficulty: 'Très facile',
    xp: 50,
    objective: 'Connaître les ports standard.',
    environment: 'Réflexion',
    puzzle: 'Sur quel numéro de port fonctionne le service DNS ?',
    hints: [
      'Le DNS traduit les noms de domaine en adresses IP.',
      'Il utilise surtout UDP, et TCP pour les gros échanges.',
      'C\'est un nombre à deux chiffres, entre 50 et 60.',
    ],
    answer: '53',
    explanation:
        'Le DNS utilise le port 53 (UDP, et TCP pour les transferts de zone ou '
        'les réponses volumineuses). Un trafic DNS anormal peut révéler un '
        'tunnel d\'exfiltration (voir le module Réseau du Lab).',
  ),
  CtfChallenge(
    id: 'ctf-net-4',
    title: 'Adresse privée',
    category: 'Réseau',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Reconnaître les plages d\'adresses privées (RFC 1918).',
    environment: 'Réflexion',
    puzzle:
        'Laquelle de ces adresses est privée (non routable sur Internet) : '
        '8.8.8.8, 192.168.1.42 ou 203.0.113.7 ?',
    hints: [
      'Les plages privées sont 10.0.0.0/8, 172.16.0.0/12 et 192.168.0.0/16.',
      '8.8.8.8 est un résolveur DNS public bien connu.',
      'Votre box internet distribue souvent des adresses de cette forme.',
    ],
    answer: '192.168.1.42',
    explanation:
        '192.168.1.42 appartient à 192.168.0.0/16, une plage privée. '
        '203.0.113.0/24 est réservée à la documentation, et 8.8.8.8 est '
        'publique. Savoir distinguer interne et externe est la base du triage '
        'des alertes.',
  ),
  CtfChallenge(
    id: 'ctf-net-5',
    title: 'Le service visé',
    category: 'Réseau',
    difficulty: 'Moyen',
    xp: 90,
    objective: 'Lire un journal de pare-feu.',
    environment: 'Terminal du Lab : /var/log/syslog',
    puzzle:
        'Le pare-feu a bloqué une connexion de 203.0.113.7 (ligne « UFW BLOCK » '
        'de /var/log/syslog). Quel service était visé ?',
    hints: [
      '/var/log/syslog n\'est lisible qu\'avec des droits élevés.',
      'DPT est le port de destination.',
      'Le port 3306 est celui d\'une base de données très répandue.',
    ],
    answer: 'MySQL',
    acceptedAnswers: ['3306', 'MariaDB', 'MySQL/MariaDB'],
    terminalCommand: 'sudo grep "UFW BLOCK" /var/log/syslog',
    explanation:
        'DPT=3306 : le port de MySQL/MariaDB. Une base de données ne doit '
        'jamais être exposée sur Internet ; le pare-feu a bien fait de bloquer.',
  ),
  CtfChallenge(
    id: 'ctf-forensic-3',
    title: 'Le vrai type d\'un fichier',
    category: 'Forensic',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Identifier un fichier sans se fier à son extension.',
    environment: 'Terminal du Lab',
    puzzle:
        'Une extension se change facilement. Quelle commande Linux identifie le '
        'vrai type d\'un fichier en lisant son contenu ? (le nom de la commande)',
    hints: [
      'Elle lit les premiers octets (« nombre magique ») du fichier.',
      'Son nom est un mot anglais de quatre lettres.',
      'Essayez-la sur ~/documents/notes.pdf et ~/scripts/analyse_logs.sh.',
    ],
    answer: 'file',
    acceptedAnswers: ['file documents/notes.pdf', 'file ~/documents/notes.pdf'],
    caseSensitive: true,
    terminalCommand: 'file documents/notes.pdf scripts/analyse_logs.sh',
    explanation:
        'file examine le contenu (signature %PDF, ligne #!/bin/bash…) et non '
        'l\'extension. Les attaquants renomment souvent un exécutable en '
        '.pdf ou .jpg pour tromper la vigilance.',
  ),
  CtfChallenge(
    id: 'ctf-crypto-3',
    title: 'Message encodé',
    category: 'Crypto',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Décoder du Base64.',
    environment: 'Terminal du Lab',
    puzzle:
        'Ce message a été trouvé dans un script suspect :\n'
        'RkxBR3tiYXNlNjRfbmVzdF9wYXNfZHVfY2hpZmZyZW1lbnR9\n'
        'Que contient-il ? (réponse au format FLAG{...})',
    hints: [
      'Lettres, chiffres, + et / : la signature d\'un encodage très courant.',
      'La commande base64 sait encoder… et décoder avec une option.',
      'echo LE_MESSAGE | base64 -d',
    ],
    answer: 'FLAG{base64_nest_pas_du_chiffrement}',
    caseSensitive: true,
    terminalCommand:
        'echo RkxBR3tiYXNlNjRfbmVzdF9wYXNfZHVfY2hpZmZyZW1lbnR9 | base64 -d',
    explanation:
        'Base64 est un ENCODAGE : n\'importe qui le décode, sans clé. Il sert '
        'à transporter des données binaires en texte, pas à les protéger. Les '
        'malwares l\'utilisent souvent pour masquer des commandes.',
  ),
  CtfChallenge(
    id: 'ctf-crypto-4',
    title: 'Le décalage de César',
    category: 'Crypto',
    difficulty: 'Moyen',
    xp: 90,
    objective: 'Inverser un chiffrement par décalage (ROT13).',
    environment: 'Terminal du Lab ou papier',
    puzzle:
        'Ce mot a été chiffré en décalant chaque lettre de 13 places dans '
        'l\'alphabet (ROT13) : PLOREFRPHEVGR. Quel est le mot d\'origine ?',
    hints: [
      'L\'alphabet compte 26 lettres : appliquer ROT13 deux fois redonne le '
          'texte d\'origine.',
      'P devient C, L devient Y…',
      'Dans le terminal : echo PLOREFRPHEVGR | tr \'A-Z\' \'N-ZA-M\'',
    ],
    answer: 'CYBERSECURITE',
    terminalCommand: "echo PLOREFRPHEVGR | tr 'A-Z' 'N-ZA-M'",
    explanation:
        'ROT13 est un chiffre de César de décalage 13 : aucune clé secrète, il '
        'se casse instantanément (25 décalages possibles seulement). Il sert '
        'à masquer un spoiler, jamais à protéger des données.',
  ),
  CtfChallenge(
    id: 'ctf-scripting-2',
    title: 'Rendre un script exécutable',
    category: 'Scripting',
    difficulty: 'Facile',
    xp: 70,
    objective: 'Comprendre le droit d\'exécution.',
    environment: 'Terminal du Lab : ~/scripts',
    puzzle:
        'Depuis votre dossier personnel, ./scripts/scan_local.sh répond « '
        'Permission non accordée ». Quelle commande rend ce script exécutable ?',
    hints: [
      'ls -l scripts montre les droits : il manque un « x ».',
      'La commande qui change les droits est chmod.',
      'En mode symbolique, « +x » ajoute le droit d\'exécution.',
    ],
    answer: 'chmod +x scripts/scan_local.sh',
    acceptedAnswers: [
      'chmod +x ./scripts/scan_local.sh',
      'chmod +x ~/scripts/scan_local.sh',
      'chmod u+x scripts/scan_local.sh',
      'chmod u+x ./scripts/scan_local.sh',
      'chmod u+x ~/scripts/scan_local.sh',
      'chmod 755 scripts/scan_local.sh',
      'chmod 744 scripts/scan_local.sh',
      'chmod 700 scripts/scan_local.sh',
    ],
    caseSensitive: true,
    terminalCommand:
        'chmod +x scripts/scan_local.sh && ./scripts/scan_local.sh',
    explanation:
        'Sous Linux, un fichier ne s\'exécute que s\'il porte le droit x. '
        'chmod +x l\'ajoute (u+x pour le seul propriétaire). Vérifiez toujours '
        'le contenu d\'un script avant de le rendre exécutable.',
  ),
];
