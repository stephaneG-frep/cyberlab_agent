import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> networkingCourses() => [
  _computer(),
  _os(),
  _files(),
  _processes(),
  _memory(),
  _users(),
  _permissions(),
  _networkIntro(),
  _ip(),
  _ipv4(),
  _ipv6(),
  _mac(),
  _ports(),
  _protocols(),
  _tcp(),
  _udp(),
  _dns(),
  _dhcp(),
  _http(),
  _https(),
  _ssh(),
  _ftp(),
  _smtp(),
  _vpn(),
  _firewall(),
  _nat(),
];

Course _computer() => Course(
  id: 'net-computer',
  title: 'Comment fonctionne un ordinateur',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre les composants d\'un ordinateur',
    'Distinguer matériel et logiciel',
    'Comprendre le rôle du processeur et de la mémoire',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('L\'ordinateur en bref', [
      text(
        'Un ordinateur traite des informations. Il combine du matériel (hardware : composants physiques) et des logiciels (software : programmes). On peut le voir comme un bureau : le processeur est le chef qui calcule, la mémoire est le bureau où l\'on pose tout, le disque est le classeur où l\'on range.',
      ),
    ]),
    sec('Les composants clés', [
      list(
        '- **CPU (processeur)** : effectue les calculs, "le cerveau".\n'
        '- **RAM (mémoire)** : stockage temporaire ultra-rapide pour les programmes en cours.\n'
        '- **Disque (HDD/SSD)** : stockage permanent des données et programmes.\n'
        '- **Carte mère** : relie tous les composants.\n'
        '- **Carte réseau** : permet de communiquer sur le réseau.\n'
        '- **GPU** : accélère l\'affichage et certains calculs.',
      ),
      text(
        'Le CPU exécute des milliards d\'opérations par seconde, la RAM est assez grande pour les programmes actifs, le disque conserve les données à long terme.',
      ),
    ]),
    sec('Matériel vs logiciel', [
      text(
        'Le matériel est physique (vous pouvez le toucher), le logiciel est des instructions (vous ne pouvez pas le toucher). Un système d\'exploitation est un logiciel qui gère le matériel et lance les programmes.',
      ),
      text(
        'Cette distinction est importante : une vulnérabilité peut venir du logiciel (bug de code) comme du matériel (faille processeur).',
      ),
    ]),
    sec('Le boot', [
      text(
        'Au démarrage, l\'ordinateur : allume le matériel, le BIOS/UEFI initialise les composants, puis charge le système d\'exploitation depuis le disque vers la RAM, qui lance les services et l\'interface.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre RAM (temporaire) et disque (permanent)',
    'Penser que le matériel n\'est pas vulnérable',
  ],
  summary:
      'Un ordinateur combine matériel (CPU, RAM, disque) et logiciels. Le CPU calcule, la RAM est temporaire, le disque conserve.',
  quiz: [
    q(const [
      'q1',
      'La RAM sert à...',
      'qcm',
      'stocker définitivement les données|stocker temporairement les programmes en cours|afficher|naviguer',
      '1',
      'La RAM est un stockage temporaire rapide pour ce qui tourne actuellement.',
    ]),
    q(const [
      'q2',
      'Le composant qui effectue les calculs est...',
      'qcm',
      'le CPU|le disque dur|la carte réseau|le clavier',
      '0',
      'Le CPU (processeur) fait les calculs.',
    ]),
  ],
  exercises: [
    ex(
      'Analogie',
      'Expliquez avec la métaphore du bureau (chef, bureau, classeur) à quoi correspondent le CPU, la RAM et le disque.',
    ),
  ],
  xp: 70,
);

Course _os() => Course(
  id: 'net-os',
  title: 'Le système d\'exploitation',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle d\'un OS',
    'Connaître les principaux OS',
    'Comprendre le noyau (kernel)',
  ],
  prerequisites: ['Comment fonctionne un ordinateur'],
  sections: [
    sec('Rôle du système d\'exploitation', [
      text(
        'Le système d\'exploitation (OS) est le logiciel fondamental qui gère le matériel, lance les programmes, gère les fichiers, les utilisateurs et le réseau. Il fait le pont entre le matériel et les applications.',
      ),
      text(
        'Sans OS, on ne pourrait pas utiliser l\'ordinateur : c\'est lui qui organise tout.',
      ),
    ]),
    sec('Les principaux OS', [
      list(
        '- **Linux** : open source, très utilisé en serveurs et en cybersécurité.\n'
        '- **Windows** : commercial, très répandu sur les postes de travail.\n'
        '- **macOS** : Apple, Unix-like.\n'
        '- **Android / iOS** : systèmes mobiles, basés sur Linux/Unix.',
      ),
      text(
        'En cybersécurité, Linux (et en particulier des distributions comme Kali ou Parrot) est l\'outil de référence, mais on doit aussi connaître Windows qui est la cible numéro un des attaquants.',
      ),
    ]),
    sec('Le noyau (kernel)', [
      text(
        'Le noyau (kernel) est le cœur de l\'OS : il gère la mémoire, les processus, les pilotes matériels et la sécurité de base. Il fonctionne en mode privilégié.',
      ),
      text(
        'Une vulnérabilité dans le noyau est très critique car elle peut donner un contrôle total (élévation vers root). Les mises à jour du noyau sont donc essentielles.',
      ),
    ]),
    sec('Modes utilisateur et noyau', [
      text(
        'Le processeur a deux modes : le mode noyau (tout est permis) et le mode utilisateur (restreint). Les programmes normaux tournent en mode utilisateur et demandent au noyau via des appels système (syscalls) pour accéder au matériel.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre un logiciel et l\'OS',
    'Sous-estimer l\'importance du noyau et de ses mises à jour',
  ],
  summary:
      'L\'OS gère le matériel, les fichiers, les processus et le réseau. Le noyau en est le cœur privilégié. Linux est la référence en sécurité.',
  quiz: [
    q(const [
      'q1',
      'Le noyau (kernel) est...',
      'qcm',
      'le cœur privilégié de l\'OS|un navigateur|un jeu|un antivirus',
      '0',
      'Le noyau gère le matériel et tourne en mode privilégié.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi une faille dans le noyau est-elle particulièrement dangereuse ?',
    ),
  ],
  xp: 60,
);

Course _files() => Course(
  id: 'net-files',
  title: 'Les fichiers et le stockage',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre la notion de fichier',
    'Distinguer fichiers et dossiers',
    'Comprendre les systèmes de fichiers',
  ],
  prerequisites: ['Comment fonctionne un ordinateur'],
  sections: [
    sec('Les fichiers', [
      text(
        'Un fichier est une unité de données stockée avec un nom et un type. Tout ce que l\'ordinateur utilise (documents, images, programmes, configuration) est un fichier.',
      ),
      text(
        'Un dossier (répertoire) est un conteneur d\'autres fichiers ou dossiers, permettant d\'organiser le stockage en arborescence.',
      ),
    ]),
    sec('Types et extensions', [
      text(
        'Le type d\'un fichier est souvent indiqué par son extension (.txt, .png, .exe, .conf) et par son contenu réel (magic bytes). En sécurité, on vérifie toujours le VRAI type d\'un fichier, car une extension peut être trompeuse (ex: image.exe).',
      ),
    ]),
    sec('Systèmes de fichiers', [
      text(
        'Le système de fichiers est l\'organisation logique du stockage. Chaque OS a ses systèmes : NTFS (Windows), ext4 (Linux), APFS (macOS). Ils gèrent où et comment les données sont écrites et les permissions.',
      ),
    ]),
    sec('Stockage et sauvegarde', [
      text(
        'Trois copies (règle 3-2-1) : gardez au moins 3 copies, sur 2 supports différents, dont 1 hors site. C\'est fondamental contre les pannes et les ransomwares.',
      ),
    ]),
  ],
  commonMistakes: [
    'Se fier à l\'extension plutôt qu\'au contenu réel',
    'Ne pas sauvegarder',
  ],
  summary:
      'Les fichiers stockent des données organisées en dossiers. Le système de fichiers les gère. On vérifie le vrai type, pas seulement l\'extension.',
  quiz: [
    q(const [
      'q1',
      'Un dossier est...',
      'qcm',
      'un conteneur de fichiers|un type de processeur|un protocole|une carte réseau',
      '0',
      'Le dossier organise le stockage.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi un fichier "CV.exe" prétendant être un document est-il suspect ?',
    ),
  ],
  xp: 60,
);

Course _processes() => Course(
  id: 'net-processes',
  title: 'Les processus',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre la notion de processus',
    'Distinguer processus et programme',
    'Comprendre les threads et la concurrence',
  ],
  prerequisites: ['Comment fonctionne un ordinateur'],
  sections: [
    sec('Programme vs processus', [
      text(
        'Un programme est un code stocké sur le disque (inerte). Dès qu\'on le lance, il devient un processus : une instance active en mémoire avec son propre espace, son état et son identifiant (PID).',
      ),
      text(
        'Un même programme peut avoir plusieurs processus si on le lance plusieurs fois.',
      ),
    ]),
    sec('Le rôle de l\'OS', [
      text(
        'Le système d\'exploitation crée, planifie et termine les processus. Il leur attribue du temps CPU, de la mémoire et des priorités. Le CPU bascule rapidement entre les processus, donnant l\'illusion qu\'ils tournent en même temps (multitâche).',
      ),
    ]),
    sec('Threads et concurrence', [
      text(
        'Un processus peut contenir plusieurs "threads" (fils) qui partagent sa mémoire et s\'exécutent en parallèle. C\'est utile pour la concurrence mais introduit des risques de "course" si plusieurs threads modifient les mêmes données.',
      ),
    ]),
    sec('Processus et sécurité', [
      text(
        'Chaque processus tourne avec l\'identité d\'un utilisateur. Un processus lancé par un attaquant peut espionner ou manipuler le système selon les droits de cet utilisateur. C\'est pourquoi le moindre privilège est important.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre programme (disque) et processus (en exécution)',
    'Ignorer que les processus ont des droits',
  ],
  summary:
      'Un processus est un programme en cours d\'exécution, géré par l\'OS, avec des droits. Les threads permettent la concurrence.',
  quiz: [
    q(const [
      'q1',
      'La différence entre programme et processus est...',
      'qcm',
      'le programme est passif, le processus est en exécution|rien|le processus est plus petit|le programme est en mémoire',
      '0',
      'Le programme est du code stocké ; le processus est cette exécution active.',
    ]),
  ],
  exercises: [
    ex(
      'Exemple',
      'Donnez un exemple où un processus malveillant profite des droits d\'un utilisateur.',
    ),
  ],
  xp: 60,
);

Course _memory() => Course(
  id: 'net-memory',
  title: 'La mémoire et les données',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre les types de mémoire',
    'Distinguer les unités de stockage',
    'Comprendre le rôle de la mémoire vive',
  ],
  prerequisites: ['Comment fonctionne un ordinateur'],
  sections: [
    sec('Les types de mémoire', [
      text(
        'On distingue plusieurs mémoires selon leur vitesse et leur persistance :',
      ),
      list(
        '- **Registres / cache CPU** : ultra-rapides, très petites.\n'
        '- **RAM** : rapide, temporaire, volait au redémarrage.\n'
        '- **Disque (SSD/HDD)** : lent, permanent.',
      ),
      text(
        'Plus on descend, plus c\'est grand mais lent. Le système fait remonter les données dont il a besoin dans la RAM.',
      ),
    ]),
    sec('Registres, cache, RAM', [
      text(
        'Le CPU lit/écrit ses données dans les registres et le cache. Comme ils sont trop petits, il utilise la RAM comme stockage "proche". Quand un processus s\'arrête, sa RAM est libérée.',
      ),
    ]),
    sec('La mémoire et la sécurité', [
      text(
        'Des attaques célèbres (Heartbleed, Meltdown, Spectre, Rowhammer) exploitent des défauts de gestion de la mémoire. La mémoire contient des données sensibles en clair (mots de passe, clés), c\'est pourquoi l\'analyse mémoire (forensique) est une discipline.',
      ),
      warn(
        'Ne stockez jamais de secrets en dur dans des fichiers ou des scripts en clair. Utilisez des variables d\'environnement ou un gestionnaire de secrets.',
      ),
    ]),
    sec('Unités de mesure', [
      text(
        'Octets → Kilo (Ko), Méga (Mo), Giga (Go), Téra (To). 1 Go ≈ 1000 Mo ≈ 1 milliard d\'octets. La RAM se compte en Go, les disques en Go/To.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre RAM et disque',
    'Stocker des secrets en clair dans la mémoire de scripts',
  ],
  summary:
      'La mémoire va des registres (rapides) au disque (persistant). Elle contient des données sensibles, source de vulnérabilités et matière forensique.',
  quiz: [
    q(const [
      'q1',
      'Quelle mémoire est temporaire et s\'efface au redémarrage ?',
      'qcm',
      'la RAM|le disque|le SSD|le CD-ROM',
      '0',
      'La RAM est volatile, elle se vide au redémarrage.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi une attaque qui lit la mémoire d\'un processus est-elle dangereuse ?',
    ),
  ],
  xp: 60,
);

Course _users() => Course(
  id: 'net-users',
  title: 'Les utilisateurs et les comptes',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre la notion de compte utilisateur',
    'Distinguer utilisateur normal et administrateur',
    'Comprendre l\'authentification',
  ],
  prerequisites: ['Système d\'exploitation'],
  sections: [
    sec('Les comptes utilisateurs', [
      text(
        'Un système multi-utilisateurs associe chaque personne à un compte avec une identité, des droits et parfois un dossier personnel. Les actions sont traçables au nom du compte.',
      ),
      text(
        'L\'authentification vérifie qui vous êtes (mot de passe, biométrie), l\'autorisation décide ce que vous pouvez faire. Ces deux notions sont distinctes.',
      ),
    ]),
    sec('Utilisateur normal vs administrateur', [
      text(
        'L\'administrateur (root sous Linux, administrateur sous Windows) peut tout faire. Un utilisateur normal a des droits limités. On recommande de travailler en compte normal et d\'élever ponctuellement les droits (sudo).',
      ),
      warn(
        'Utiliser un compte administrateur au quotidien est risqué : une erreur ou un malware agit avec tous les droits.',
      ),
    ]),
    sec('Mots de passe et stockage', [
      text(
        'Les mots de passe ne doivent jamais être stockés en clair. Ils sont hachés et salés (voir cours cryptographie). /etc/shadow sous Linux contient les hashes de mots de passe, protégé en lecture root.',
      ),
    ]),
    sec('La sécurité des comptes', [
      text(
        'Les attaques de brute-force et de credential stuffing visent les comptes. Un bon mot de passe, le 2FA, et le verrouillage après plusieurs échecs sont essentiels.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser un compte admin au quotidien',
    'Confondre authentification et autorisation',
  ],
  summary:
      'Les comptes identifient et limitent les utilisateurs. On distingue authentification (qui êtes-vous) et autorisation (que pouvez-vous faire).',
  quiz: [
    q(const [
      'q1',
      'L\'authentification consiste à...',
      'qcm',
      'vérifier qui vous êtes|définir ce que vous pouvez faire|installer un logiciel|naviguer',
      '0',
      'L\'authentification prouve votre identité ; l\'autorisation définit vos droits.',
    ]),
  ],
  exercises: [
    ex(
      'Analyse',
      'Expliquez la différence entre "il se connecte" et "il a le droit de lire ce fichier" en termes d\'authentification/autorisation.',
    ),
  ],
  xp: 60,
);

Course _permissions() => Course(
  id: 'net-permissions',
  title: 'Les permissions d\'accès',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le but des permissions',
    'Distinguer les modèles de contrôle d\'accès',
    'Comprendre le moindre privilège',
  ],
  prerequisites: ['Utilisateurs'],
  sections: [
    sec('Pourquoi des permissions ?', [
      text(
        'Les permissions déterminent qui peut faire quoi sur chaque ressource (fichier, service, donnée). Elles implémentent l\'autorisation et sont la base de la sécurité des données.',
      ),
    ]),
    sec('Modèles de contrôle d\'accès', [
      text('Il existe plusieurs modèles de permissions, dont :'),
      list(
        '- **DAC (discretionary)** : le propriétaire contrôle ses ressources (Linux classique).\n'
        '- **MAC (mandatory)** : des règles centrales imposées (SELinux, très sécurisé).\n'
        '- **RBAC (par rôles)** : droits attribués selon le rôle (courant dans les applications).',
      ),
    ]),
    sec('Le moindre privilège', [
      text(
        'Le principe du moindre privilège : chaque utilisateur, processus ou service n\'a que les droits strictement nécessaires. Cela réduit les dégâts en cas de compromission.',
      ),
      warn(
        'C\'est LA règle d\'or en sécurité. Une application qui tourne en admin "pour simplifier" est une faille en attendant.',
      ),
    ]),
    sec('Exemples de vulnérabilités', [
      text(
        'Les failles de contrôle d\'accès (OWASP) surviennent quand on peut accéder à des ressources sans être autorisé, par exemple en modifiant une URL ou un ID. Elles seront détaillées au niveau Web Security.',
      ),
    ]),
  ],
  commonMistakes: [
    'Donner trop de droits "pour simplifier"',
    'Ignorer les failles de contrôle d\'accès',
  ],
  summary:
      'Les permissions contrôlent l\'accès aux ressources. Le modèle Linux est un DAC. Le moindre privilège limite les risques.',
  quiz: [
    q(const [
      'q1',
      'Le moindre privilège signifie...',
      'qcm',
      'donner le minimum de droits nécessaires|donner tous les droits|aucun droit|des droits aléatoires',
      '0',
      'On ne donne que ce qui est nécessaire.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi une application tournant avec des droits admin est-elle risquée ?',
    ),
  ],
  xp: 60,
);

Course _networkIntro() => Course(
  id: 'net-intro',
  title: 'Le réseau : introduction',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre ce qu\'est un réseau',
    'Distinguer réseau local et Internet',
    'Comprendre le rôle du réseau en sécurité',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('C\'est quoi un réseau ?', [
      text(
        'Un réseau est un ensemble de machines (ordinateurs, serveurs, téléphones) connectées entre elles pour échanger des données. Localement dans une maison ou une entreprise, ou mondialement via Internet.',
      ),
      text(
        'Imaginez un réseau postal : chaque maison a une adresse (IP), le courrier est trié et livré par étapes (routage).',
      ),
    ]),
    sec('Réseau local et Internet', [
      list(
        '- **LAN (local)** : un réseau local, ex. votre maison ou une entreprise. Adresses privées.\n'
        '- **WAN (étendu)** : Internet relie les LAN entre eux.\n'
        '- **PAN** : très petit (Bluetooth).\n'
        '- **MAN** : une ville.',
      ),
      text(
        'Le routeur (box) fait le lien entre votre LAN et Internet, grâce au NAT (voir cours NAT).',
      ),
    ]),
    sec('Pourquoi le réseau est central en sécurité', [
      text(
        '90% des cyberattaques passent par le réseau : connexions, ports ouverts, services exposés, trafic malveillant. Comprendre le réseau est LA compétence fondamentale en cybersécurité, pour attaquer comme pour défendre.',
      ),
    ]),
    sec('La communication en couches', [
      text(
        'La communication réseau se modélise en couches (modèle OSI, vu plus loin). Chaque couche a un rôle : physique, adressage, routage, transport, application. On peut les voir comme les étapes d\'envoi d\'un colis.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre adresse IP et adresse MAC',
    'Penser que le réseau n\'est qu\'un sujet "avancé"',
  ],
  summary:
      'Un réseau connecte des machines pour échanger des données. Internet relie les LAN. Le réseau est au cœur de la sécurité.',
  quiz: [
    q(const [
      'q1',
      'Un LAN est...',
      'qcm',
      'un réseau local|le processeur|l\'ordinateur|un virus',
      '0',
      'LAN = Local Area Network, réseau local.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Expliquez avec la métaphore postale ce que sont l\'adresse d\'une machine (IP) et le routage.',
    ),
  ],
  xp: 60,
);

Course _ip() => Course(
  id: 'net-ip',
  title: 'L\'adresse IP',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre ce qu\'est une adresse IP',
    'Distinguer IP privée et publique',
    'Comprendre la notion de masque',
  ],
  prerequisites: ['Introduction aux réseaux'],
  sections: [
    sec('C\'est quoi une adresse IP ?', [
      text(
        'L\'adresse IP (Internet Protocol) est un numéro unique qui identifie une machine sur un réseau, comme votre adresse postale. Elle permet d\'acheminer les données jusqu\'à la bonne destination.',
      ),
      text(
        'Deux versions existent : IPv4 (ex. 192.168.1.42) et IPv6 (ex. 2001:db8::1), vues ensuite.',
      ),
    ]),
    sec('Adresse privée vs publique', [
      text(
        'Une adresse publique est visible sur Internet (votre box a une IP publique). Une adresse privée est utilisée à l\'intérieur d\'un réseau local (192.168.x.x, 10.x.x.x, 172.16-31.x.x) et n\'est pas routable sur Internet directement.',
      ),
      code(
        'IP privées courantes :\n'
        '  192.168.0.0 - 192.168.255.255\n'
        '  10.0.0.0 - 10.255.255.255\n'
        '  172.16.0.0 - 172.31.255.255\n'
        'loopback local : 127.0.0.1 (localhost)',
        label: 'Privées',
      ),
    ]),
    sec('Le masque de sous-réseau', [
      text(
        'Le masque définit quelle partie de l\'adresse désigne le réseau et quelle partie désigne la machine. Ex : 255.255.255.0 (ou /24) signifie que les 3 premiers octets = réseau, le dernier = la machine.',
      ),
      code(
        '192.168.1.0/24  → réseau 192.168.1, machines 192.168.1.1 à .254',
        label: 'Exemple',
      ),
    ]),
    sec('Réseau, passerelle, DNS', [
      text(
        'Dans chaque réseau : l\'adresse réseau (ex .0), la plage de machines, et la passerelle (gateway, ex .1) qui est la sortie vers l\'extérieur. On configure souvent aussi le DNS (résolution de noms).',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre IP pub/privée',
    'Oublier que 127.0.0.1 est la boucle locale',
  ],
  summary:
      'L\'IP identifie une machine sur un réseau. La privée est interne, la publique visible sur Internet. Le masque découpe réseau/machine.',
  quiz: [
    q(const [
      'q1',
      '127.0.0.1 correspond à...',
      'qcm',
      'la machine elle-même (loopback)|n\'importe quelle machine|un serveur DNS|une adresse MAC',
      '0',
      '127.0.0.1 (localhost) désigne votre propre machine.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Quelle est la différence entre une adresse IP privée et publique, et à quoi sert la passerelle ?',
    ),
  ],
  xp: 70,
);

Course _ipv4() => Course(
  id: 'net-ipv4',
  title: 'IPv4',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le format IPv4',
    'Connaître la plage et les classes',
    'Comprendre les adresses spéciales',
  ],
  prerequisites: ['L\'adresse IP'],
  sections: [
    sec('Le format IPv4', [
      text(
        'IPv4 utilise des adresses de 32 bits, écrites en 4 octets séparés par des points : de 0.0.0.0 à 255.255.255.255. Ex : 192.168.1.1.',
      ),
      text(
        'Ce format permet environ 4,3 milliards d\'adresses uniques, ce qui est insuffisant aujourd\'hui, d\'où l\'arrivée d\'IPv6.',
      ),
    ]),
    sec('Adresses spéciales', [
      list(
        '- **127.0.0.1** : loopback (la machine elle-même).\n'
        '- **0.0.0.0** : adresse non spécifiée / "tout".\n'
        '- **255.255.255.255** : broadcast (diffusion à tous).\n'
        '- **169.254.x.x** : APIPA, quand pas de DHCP.\n'
        '- **192.168.x.x / 10.x.x.x / 172.16-31.x.x** : privées.',
      ),
    ]),
    sec('Classes et CIDR', [
      text(
        'Historiquement les adresses étaient divisées en classes (A, B, C) correspondant à des masques. Aujourd\'hui on utilise surtout la notation CIDR /x qui indique le nombre de bits du réseau.',
      ),
      code(
        '/8  → 255.0.0.0   (réseaux très grands)\n'
        '/16 → 255.255.0.0\n'
        '/24 → 255.255.255.0  (réseaux locaux typiques)\n'
        '/32 → une seule machine',
        label: 'CIDR',
      ),
    ]),
    sec('Pourquoi comprendre IPv4', [
      text(
        'Tout l\'écosystème réseau classique (NAT, scan, analyse) repose sur IPv4. Les adresses privées et la plage loopback sont essentielles pour vos laboratoires.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier qu\'IPv4 est épuisé en adresses publiques',
    'Confondre broadcast et loopback',
  ],
  summary:
      'IPv4 = 32 bits en 4 octets. Des adresses spéciales (loopback, broadcast, privées) et la notation CIDR structurent les réseaux.',
  quiz: [
    q(const [
      'q1',
      'Combien d\'octets compose une adresse IPv4 ?',
      'qcm',
      '4|2|8|16',
      '0',
      'IPv4 = 4 octets (32 bits).',
    ]),
  ],
  exercises: [
    ex(
      'Analyse',
      'Identifiez si l\'adresse 192.168.10.5 est publique ou privée, et à quoi correspond 127.0.0.1.',
    ),
  ],
  xp: 60,
);

Course _ipv6() => Course(
  id: 'net-ipv6',
  title: 'IPv6',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre pourquoi IPv6 existe',
    'Lire une adresse IPv6',
    'Connaître les adresses spéciales IPv6',
  ],
  prerequisites: ['IPv4'],
  sections: [
    sec('Pourquoi IPv6 ?', [
      text(
        'IPv4 (32 bits) ne permet que ~4,3 milliards d\'adresses, insuffisant pour tous les appareils connectés. IPv6 utilise 128 bits, offrant un nombre quasi infini d\'adresses (3,4 × 10^38).',
      ),
    ]),
    sec('Le format IPv6', [
      text(
        'IPv6 s\'écrit en 8 groupes de 4 chiffres hexadécimaux, séparés par des « : ». On peut raccourcir en supprimant les zéros de tête et en remplaçant une longue suite de 0 par « :: ».',
      ),
      code(
        'Format complet : 2001:0db8:0000:0000:0000:ff00:0042:8329\n'
        'Raccourci     : 2001:db8::ff00:42:8329',
        label: 'IPv6',
      ),
    ]),
    sec('Adresses spéciales IPv6', [
      list(
        '- **::1** : loopback (équivalent de 127.0.0.1).\n'
        '- **::** : adresse non spécifiée.\n'
        '- **fe80::/10** : adresses link-local (autoconfiguration locale).\n'
        '- **fd00::/8** : adresses locales uniques (privées).',
      ),
    ]),
    sec('IPv6 et la sécurité', [
      text(
        'Beaucoup de réseaux migrent vers IPv6, mais certaines configurations IPv6 négligées créent des failles (tunnel, double pile). Un attaquant peut contourner une sécurité conçue pour IPv4 en passant par IPv6. Comprendre les deux versions est important.',
      ),
    ]),
  ],
  commonMistakes: [
    'Se fier à IPv6 pour "résoudre" tout',
    'Ignorer qu\'IPv6 coexiste souvent avec IPv4',
  ],
  summary:
      'IPv6 (128 bits) résout l\'épuisement d\'IPv4. Format hexadécimal, loopback ::1, et des subtilités de sécurité à connaître.',
  quiz: [
    q(const [
      'q1',
      'L\'adresse IPv6 loopback est...',
      'qcm',
      '::1|127.0.0.1|0.0.0.0|fe80::',
      '0',
      '::1 est l\'équivalent IPv6 de 127.0.0.1.',
    ]),
  ],
  exercises: [
    ex(
      'Lecture',
      'Combien de bits utilise-t-on en IPv6 et pourquoi IPv6 a-t-il été créé ?',
    ),
  ],
  xp: 60,
);

Course _mac() => Course(
  id: 'net-mac',
  title: 'L\'adresse MAC',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre ce qu\'est une adresse MAC',
    'Distinguer MAC et IP',
    'Comprendre l\'adressage de couche 2',
  ],
  prerequisites: ['L\'adresse IP'],
  sections: [
    sec('C\'est quoi une adresse MAC ?', [
      text(
        'L\'adresse MAC (Media Access Control) est un identifiant unique attribué à chaque carte réseau par son fabricant. Elle intervient au niveau physique/logique de liaison (couche 2 du modèle OSI).',
      ),
      text(
        'Format : 12 chiffres hexadécimaux en 6 octets, ex : 08:00:27:9a:3c:11. Les 3 premiers octets identifient le fabricant (OUI).',
      ),
    ]),
    sec('MAC vs IP', [
      text(
        'La différence clé : l\'IP est logique et peut changer (elle identifie la machine sur le réseau/Internet), la MAC est physique et normalement fixe (elle identifie la carte). L\'IP sert à router à distance, la MAC à communiquer localement sur le même segment.',
      ),
      text(
        'Analogie : l\'IP est votre adresse postale (change si vous déménagez), la MAC est votre nom physique / identité fixe.',
      ),
    ]),
    sec('ARP et la traduction', [
      text(
        'Le protocole ARP relie l\'IP à la MAC au sein d\'un réseau local : il interroge "qui a cette IP ?" et reçoit la MAC correspondante. C\'est aussi une cible d\'attaques (ARP spoofing, interception locale).',
      ),
    ]),
    sec('La MAC et la sécurité', [
      text(
        'La MAC peut être "spoofée" (usurpée), donc ce n\'est pas un contrôle de sécurité fiable à elle seule. Le filtrage MAC est une fausse sécurité car simulable. En revanche, la MAC sert à l\'identification en forensique et à la trace locale.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre IP et MAC',
    'Croire que la MAC est une vraie sécurité',
  ],
  summary:
      'La MAC est l\'identité physique de la carte réseau, fixe, liée au fabricant. Diffère de l\'IP (logique). ARP fait le lien. Elle est spoofable.',
  quiz: [
    q(const [
      'q1',
      'L\'adresse MAC...',
      'qcm',
      'est un identifiant physique de la carte réseau|est l\'adresse postale|change à chaque reboot|est utilisée sur Internet',
      '0',
      'La MAC est l\'identifiant physique de la carte.',
    ]),
  ],
  exercises: [
    ex(
      'Comparaison',
      'Résumez en une phrase la différence entre adresse IP et adresse MAC.',
    ),
  ],
  xp: 70,
);

Course _ports() => Course(
  id: 'net-ports',
  title: 'Les ports',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre la notion de port',
    'Connaître les ports courants',
    'Comprendre pourquoi les ports comptent en sécurité',
  ],
  prerequisites: ['L\'adresse IP'],
  sections: [
    sec('C\'est quoi un port ?', [
      text(
        'Un port est un numéro (0 à 65535) qui identifie un "service" ou une application au sein d\'une machine. Une IP vous amène à la bonne machine, le port vous amène au bon programme sur cette machine.',
      ),
      text(
        'Analogie : l\'IP est l\'immeuble, le port est le numéro d\'appartement/le service (22 = SSH, 80 = web, etc.).',
      ),
    ]),
    sec('Les ports bien connus', [
      code(
        '20/21  FTP\n'
        '22     SSH\n'
        '25     SMTP (mail)\n'
        '53     DNS\n'
        '80     HTTP\n'
        '110/143/993/995  POP/IMAP (mail)\n'
        '443    HTTPS\n'
        '3389   RDP (Windows)\n'
        '8080   Proxy/HTTP alternatif',
        label: 'Ports courants',
      ),
    ]),
    sec('Ports ouverts = surface d\'attaque', [
      text(
        'Un port ouvert signifie qu\'un service écoute et accepte des connexions. Chaque port ouvert est une porte potentielle pour un attaquant. C\'est pourquoi on réduit les services et on filtre les ports (firewall).',
      ),
      warn(
        'L\'analyse des ports (scan, avec nmap) DOIT se faire uniquement sur des machines autorisées ou localhost. Scanner un réseau tiers sans autorisation est illégal.',
      ),
    ]),
    sec('TCP vs UDP et l\'état des ports', [
      text(
        'Les ports existent en TCP et UDP (protozoïques de transport). Un port peut être "open" (service qui répond), "closed" (pas de service, mais accessible) ou "filtered" (bloqué par un firewall). Ces états sont ce qu\'analyse nmap.',
      ),
    ]),
  ],
  commonMistakes: [
    'Scanner des ports sans autorisation',
    'Confondre port (service) et IP (machine)',
  ],
  summary:
      'Le port identifie un service sur une machine. Chaque port ouvert est une surface d\'attaque. On ne scanne que des cibles autorisées.',
  quiz: [
    q(const [
      'q1',
      'Quel service utilise le port 22 ?',
      'qcm',
      'SSH|HTTP|DNS|FTP',
      '0',
      'Le port 22 est SSH.',
    ]),
    q(const [
      'q2',
      'Vrai ou faux : scanner les ports d\'un réseau tiers sans autorisation est illégal.',
      'tf',
      'Vrai',
      null,
      'Tout scan sans autorisation peut être illégal.',
    ]),
  ],
  exercises: [
    ex(
      'Mémoriser',
      'Citez les ports de SSH, HTTP, HTTPS et DNS. Pourquoi un port ouvert est-il une surface d\'attaque ?',
    ),
  ],
  xp: 80,
);

Course _protocols() => Course(
  id: 'net-protocols',
  title: 'Les protocoles réseau',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre ce qu\'est un protocole',
    'Connaître les principaux protocoles',
    'Comprendre le modèle en couches',
  ],
  prerequisites: ['Adresses IP', 'Ports'],
  sections: [
    sec('C\'est quoi un protocole ?', [
      text(
        'Un protocole est un ensemble de règles qui définissent comment les machines communiquent : le format des données, l\'ordre des échanges, la gestion des erreurs. Sans protocole commun, deux machines ne pourraient pas se comprendre.',
      ),
      text(
        'On peut le voir comme une langue et des règles de politesse convenues entre machines.',
      ),
    ]),
    sec('Les grandes familles', [
      list(
        '- **Application** : HTTP, HTTPS, DNS, SSH, FTP, SMTP, DHCP...\n'
        '- **Transport** : TCP (fiable), UDP (rapide).\n'
        '- **Réseau** : IP (adressage et routage), ICMP (ping).\n'
        '- **Liaison** : Ethernet, ARP, WiFi.',
      ),
      code(
        'Exemples :\n'
        'Tapez une URL → DNS traduit le nom en IP → HTTP charge la page.\n'
        'Ouvrez un terminal distant → SSH se connecte sur le port 22.',
        label: 'En pratique',
      ),
    ]),
    sec('Le modèle en couches (OSI / TCP/IP)', [
      text(
        'Pour simplifier, les communications se font en couches empilées. Chaque couche ajoute son "en-tête" (informations) aux données, comme les couches d\'un colis (étiquette d\'adresse, d\'expédition, de contenu).',
      ),
      text(
        'Le modèle OSI a 7 couches ; le modèle TCP/IP (réellement utilisé) en a 4 : application, transport, réseau, liaison. Vous verrez les détails au niveau 5 - Sécurité réseau.',
      ),
    ]),
    sec('Pourquoi comprendre les protocoles', [
      text(
        'Chaque protocole est une surface possible d\'exploitation. Comprendre HTTP, DNS, TCP, etc., permet d\'analyser le trafic (Wireshark) et de détecter les anomalies. C\'est le cœur de l\'analyse réseau.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre les protocoles et leurs rôles',
    'Déclarer HTTP et TCP au même niveau',
  ],
  summary:
      'Les protocoles sont les règles de communication. Ils s\'organisent en couches (application, transport, réseau, liaison). Les maîtriser, c\'est analyser le réseau.',
  quiz: [
    q(const [
      'q1',
      'À quelle couche appartiennent HTTP et DNS ?',
      'qcm',
      'application|transport|réseau|laison',
      '0',
      'HTTP et DNS sont des protocoles de la couche application.',
    ]),
  ],
  exercises: [
    ex(
      'Associer',
      'À quel protocole correspond : "traduit un nom de domaine en IP" et "charge une page web" ? Réponse : DNS, HTTP.',
    ),
  ],
  xp: 80,
);

Course _tcp() => Course(
  id: 'net-tcp',
  title: 'TCP',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle de TCP',
    'Comprendre la fiabilité (handshake)',
    'Comprendre les états et le numéro de port',
  ],
  prerequisites: ['Les protocoles'],
  sections: [
    sec('Le rôle de TCP', [
      text(
        'TCP (Transmission Control Protocol) est un protocole de la couche transport qui fournit une communication fiable, ordonnée et vérifiée entre deux machines.',
      ),
      text(
        'TCP garantit que tous les paquets arrivent, dans le bon ordre, sans erreur, et retransmet si besoin. L\'analogie : une conversation avec confirmation ("tu as bien reçu ?"), contrairement à UDP qui envoie sans vérifier.',
      ),
    ]),
    sec('La poignée de main TCP (three-way handshake)', [
      text(
        'Avant d\'échanger des données, TCP établit une connexion en 3 étapes :',
      ),
      code(
        '1. Client envoie SYN      (je veux me connecter)\n'
        '2. Serveur répond SYN-ACK (d\'accord, je te reçois)\n'
        '3. Client envoie ACK       (parfait, connexion établie)',
        label: 'Handshake',
      ),
      text(
        'Ce mécanisme garantit que les deux machines sont prêtes avant l\'échange. Vous le verrez dans Wireshark.',
      ),
    ]),
    sec('Fiabilité', [
      text(
        'TCP numérote les segments, accuse réception (ACK), retransmet les segments perdus, et remet les données dans l\'ordre. En contrepartie, il est plus lent et plus "lourd" qu\'UDP.',
      ),
    ]),
    sec('TCP et la sécurité', [
      text(
        'L\'en-tête TCP contient un champ "flags" (SYN, ACK, FIN, RST...). Ces flags permettent des attaques : SYN flood (saturation), scan SYN (détection de ports ouverts). Comprendre les flags aide à analyser le trafic et à détecter les scans.',
      ),
      tip(
        'On distingue souvent les scans "full" (connexion complète) des scans "stealth" (SYN seul). Vous verrez ça en réseau avancé.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier les 3 étapes du handshake',
    'Confondre fiabilité TCP et rapidité UDP',
  ],
  summary:
      'TCP fournit une communication fiable via une poignée de main en 3 étapes (SYN, SYN-ACK, ACK) et une vérification des données. Plus lent mais sûr.',
  quiz: [
    q(const [
      'q1',
      'Les 3 étapes du handshake TCP sont...',
      'qcm',
      'SYN, SYN-ACK, ACK|SYN, ACK, FIN|GET, POST, HEAD|hello, ok, bye',
      '0',
      'Le three-way handshake est SYN → SYN-ACK → ACK.',
    ]),
  ],
  exercises: [
    ex(
      'Expliquer',
      'Expliquez avec vos mots pourquoi TCP est "fiable" et en quoi le handshake y contribue.',
    ),
  ],
  xp: 90,
);

Course _udp() => Course(
  id: 'net-udp',
  title: 'UDP',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre la différence avec TCP',
    'Connaître les usages d\'UDP',
    'Comprendre ses forces et faiblesses',
  ],
  prerequisites: ['TCP'],
  sections: [
    sec('Le rôle d\'UDP', [
      text(
        'UDP (User Datagram Protocol) est un protocole de transport simple et rapide qui envoie des paquets (datagrammes) sans établir de connexion ni vérifier la réception.',
      ),
      text(
        'Là où TCP confirme tout, UDP "envoie et oublie". C\'est moins fiable mais beaucoup plus rapide et léger.',
      ),
    ]),
    sec('Fiabilité vs rapidité', [
      code(
        'TCP : fiable, ordonné, vérifié, plus lent\n'
        'UDP : non fiable, non vérifié, très rapide',
        label: 'Comparaison',
      ),
      text(
        'UDP ne garantit ni l\'arrivée, ni l\'ordre, ni l\'absence de doublons. L\'application en charge de gérer ces cas si nécessaire.',
      ),
    ]),
    sec('Quand utilise-t-on UDP ?', [
      text(
        'UDP convient quand la vitesse prime et qu\'une perte occasionnelle est acceptable, ou quand on n\'a pas besoin de connexion :',
      ),
      list(
        '- DNS (rapidité de résolution).\n'
        '- VoIP et streaming (tolèrent la perte).\n'
        '- Jeux en ligne temps réel.\n'
        '- DHCP (découverte).\n'
        '- SNMP (supervision).',
      ),
    ]),
    sec('UDP et la sécurité', [
      text(
        'Comme UDP n\'a pas de handshake ni de rapport de flux, il est plus difficile à filtrer et à analyser. Il peut être utilisé pour des attaques d\'amplification (DNS/ample, NTP) où un petit paquet en génère un énorme vers la victime.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser UDP quand on a besoin de fiabilité',
    'Oublier que UDP est un vecteur d\'amplification DDoS',
  ],
  summary:
      'UDP est rapide et léger mais non fiable (pas de handshake ni de confirmation). Idéal pour DNS, streaming ; utilisé dans des attaques d\'amplification.',
  quiz: [
    q(const [
      'q1',
      'Un avantage d\'UDP est...',
      'qcm',
      'la rapidité et la légèreté|la fiabilité absolue|l\'ordre garanti|la vérification des données',
      '0',
      'UDP privilégie la vitesse au détriment de la fiabilité.',
    ]),
  ],
  exercises: [
    ex(
      'Comparer',
      'Donnez deux exemples d\'usages où UDP est préféré à TCP et expliquez pourquoi.',
    ),
  ],
  xp: 80,
);

Course _dns() => Course(
  id: 'net-dns',
  title: 'DNS : la résolution de noms',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle du DNS',
    'Comprendre la hiérarchie DNS',
    'Connaître les types d\'enregistrements',
  ],
  prerequisites: ['IP', 'Protocoles'],
  sections: [
    sec('Le rôle du DNS', [
      text(
        'Le DNS (Domain Name System) traduit les noms de domaines (ex: exemple.com) en adresses IP (ex: 93.184.216.34). C\'est "l\'annuaire téléphonique" d\'Internet : vous tapez un nom facile à retenir, le DNS trouve l\'adresse.',
      ),
      text(
        'Sans DNS, il faudrait retenir des milliers de numéros IP. Le DNS est invisible mais absolument essentiel.',
      ),
    ]),
    sec('La résolution', [
      text(
        'Quand vous tapez exemple.com : votre machine interroge un résolveur DNS, qui parcourt la hiérarchie (serveurs racine, TLD, autoritaires) pour trouver l\'IP, puis met en cache le résultat.',
      ),
      code(
        'exemple.com\n'
        '   → serveurs racines (.)\n'
        '   → TLD (.com)\n'
        '   → serveur autoritaire de exemple.com\n'
        '   → renvoie l\'IP 93.184.216.34',
        label: 'Hiérarchie',
      ),
    ]),
    sec('Types d\'enregistrements', [
      list(
        '- **A** : nom → IPv4.\n'
        '- **AAAA** : nom → IPv6.\n'
        '- **CNAME** : alias vers un autre nom.\n'
        '- **MX** : serveur de messagerie.\n'
        '- **NS** : serveur de noms autoritaire.\n'
        '- **TXT** : texte libre (souvent SPF/validation).',
      ),
    ]),
    sec('DNS et la sécurité', [
      text(
        'Le DNS est une surface critique : DNS spoofing (empoisonnement de cache), DNS tunnelling (exfiltration), phishing (sites d\'apparence similaire), et il enquêtrice sur les résolutions (le SIEM y porte attention). Le DNS chiffré (DoH/DoT) protège les requêtes.',
      ),
      warn(
        'Un outil comme nslookup/dig interroge le DNS pour vérifier une résolution. Utilisez-le pour diagnostiquer des problèmes, pas pour attaquer.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre un nom de domaine et une URL (l\'URL inclut le protocole et le chemin)',
    'Oublier que le DNS peut être compromis (spoofing)',
  ],
  summary:
      'Le DNS est l\'annuaire qui traduit les noms en IP. Hiérarchie, enregistrements A/AAAA/MX... et source de failles de sécurité à connaître.',
  quiz: [
    q(const [
      'q1',
      'Le DNS sert à...',
      'qcm',
      'traduire un nom de domaine en IP|crypter les fichiers|compresser les vidéos|bloquer les virus',
      '0',
      'DNS = résolution nom → IP.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Dans le terminal simulé, tapez "nslookup exemple.com" puis "dig exemple.com" et observez les enregistrements A.',
    ),
  ],
  xp: 90,
);

Course _dhcp() => Course(
  id: 'net-dhcp',
  title: 'DHCP : l\'attribution automatique d\'IP',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle de DHCP',
    'Connaître le déroulement DORA',
    'Comprendre les risques',
  ],
  prerequisites: ['IP', 'Réseau'],
  sections: [
    sec('Le rôle du DHCP', [
      text(
        'Le DHCP (Dynamic Host Configuration Protocol) attribue automatiquement les adresses IP et autres paramètres réseau (masque, passerelle, DNS) aux machines, sans configuration manuelle.',
      ),
      text(
        'Quand votre téléphone se connecte au WiFi, c\'est le DHCP qui lui donne une IP locale.',
      ),
    ]),
    sec('Le processus DORA', [
      text('Le DHCP procède en 4 étapes (DORA) :'),
      code(
        'D - Discover : la machine cherche un serveur DHCP\n'
        'O - Offer    : le serveur propose une IP\n'
        'R - Request  : la machine demande cette IP\n'
        'A - Ack      : le serveur confirme et fournit les paramètres',
        label: 'DORA',
      ),
    ]),
    sec('Bail DHCP', [
      text(
        'L\'IP attribuée est un "bail" pour une durée limitée. À expiration, la machine renouvelle. Les IP peuvent donc changer (contrairement à une IP statique configurée à la main).',
      ),
    ]),
    sec('DHCP et la sécurité', [
      text(
        'Un serveur DHCP malveillant ("rogue DHCP") peut attribuer une mauvaise passerelle ou un mauvais DNS pour intercepter le trafic. La table de liaison DHCP (IP ↔ MAC) est aussi utilisée en forensique pour retracer un appareil.',
      ),
    ]),
  ],
  commonMistakes: [
    'Oublier que DHCP signifie que l\'IP peut changer',
    'Ignorer le risque de rogue DHCP',
  ],
  summary:
      'Le DHCP attribue automatiquement IP et paramètres réseau via le processus DORA. Les IP sont des baux limités ; un faux serveur est un risque.',
  quiz: [
    q(const [
      'q1',
      'Les 4 étapes du DHCP sont...',
      'qcm',
      'Discover, Offer, Request, Ack|SYN, ACK, FIN, RST|GET, POST, PUT, DELETE|A, AAAA, CNAME, MX',
      '0',
      'DORA = Discover, Offer, Request, Ack.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi un réseau peut-il "donner" une IP différente à votre appareil un jour sur deux ?',
    ),
  ],
  xp: 70,
);

Course _http() => Course(
  id: 'net-http',
  title: 'HTTP',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le fonctionnement de HTTP',
    'Connaître les méthodes HTTP',
    'Connaître les codes de statut',
  ],
  prerequisites: ['Protocoles', 'Ports'],
  sections: [
    sec('Le rôle de HTTP', [
      text(
        'HTTP (HyperText Transfer Protocol) est le protocole utilisé pour charger des pages web. Le navigateur envoie une requête au serveur via le port 80 (HTTP) et reçoit une réponse.',
      ),
      text(
        'HTTP est en clair : tout le trafic peut être lu. C\'est pourquoi HTTPS (chiffré) est la norme aujourd\'hui.',
      ),
    ]),
    sec('Les méthodes HTTP', [
      text(
        'Le navigateur précise une "méthode" (action) pour chaque requête :',
      ),
      code(
        'GET    récupérer une ressource (page, image)\n'
        'POST   envoyer des données (formulaire, connexion)\n'
        'PUT    remplacer une ressource\n'
        'DELETE supprimer une ressource\n'
        'HEAD   comme GET mais sans le corps (en-têtes seuls)\n'
        'OPTIONS renseigne les méthodes autorisées',
        label: 'Méthodes',
      ),
    ]),
    sec('Les codes de statut', [
      code(
        '2xx : succès      (200 OK)\n'
        '3xx : redirection (301, 302)\n'
        '4xx : erreur client (404 non trouvé, 403 interdit)\n'
        '5xx : erreur serveur (500, 503)',
        label: 'Codes',
      ),
    ]),
    sec('Requête et réponse', [
      text(
        'Une requête HTTP contient : la méthode, l\'URL, la version, des en-têtes (headers) et parfois un corps. La réponse contient : un code de statut, des en-têtes et un corps (le contenu de la page). Les en-têtes sont importants en sécurité (voir cours Web Security).',
      ),
      tip(
        'Dans le terminal simulé, tapez "curl -v localhost" pour voir la requête et la réponse en détail.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre HTTP et HTTPS',
    'Oublier d\'inspecter les en-têtes',
  ],
  summary:
      'HTTP est le protocole du web, en clair. Méthodes (GET, POST...), codes de statut (2xx, 4xx, 5xx) et en-têtes structurent les échanges.',
  quiz: [
    q(const [
      'q1',
      'Quelle méthode HTTP envoie des données (formulaire) ?',
      'qcm',
      'POST|GET|DELETE|HEAD',
      '0',
      'POST envoie des données ; GET récupère.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Dans le terminal simulé, tapez "curl -v localhost". Notez la méthode, le code de statut et les en-têtes visibles.',
    ),
  ],
  xp: 80,
);

Course _https() => Course(
  id: 'net-https',
  title: 'HTTPS et le chiffrement TLS',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre pourquoi HTTPS existe',
    'Comprendre le rôle de TLS',
    'Comprendre les certificats',
  ],
  prerequisites: ['HTTP'],
  sections: [
    sec('Pourquoi HTTPS ?', [
      text(
        'HTTPS = HTTP + chiffrement TLS (autrefois SSL). Il protège trois choses : la confidentialité (personne ne lit le trafic), l\'intégrité (personne ne le modifie) et l\'authentification (on est sûr du serveur).',
      ),
      text(
        'Sans HTTPS, un mot de passe envoyé sur un réseau (WiFi public, etc.) peut être lu par n\'importe qui. HTTPS chiffre le contenu.',
      ),
    ]),
    sec('Le rôle de TLS', [
      text(
        'TLS (Transport Layer Security) établit une session chiffrée entre le client et le serveur. Une poignée de main négocie la version, s\'échange des clés, et chiffre ensuite toutes les données avec des clés de session.',
      ),
    ]),
    sec('Les certificats et l\'authentification', [
      text(
        'Les serveurs HTTPS présentent un certificat numérique émis par une autorité de certification (AC). Le navigateur vérifie que le certificat est valide et correspond au domaine, garantissant que vous parlez bien au bon serveur, pas à un imposteur.',
      ),
      warn(
        'Un site HTTPS ne signifie pas qu\'il est légitime : un site de phishing peut aussi utiliser HTTPS. HTTPS protège la connexion, pas le contenu.',
      ),
    ]),
    sec('Le verrou dans le navigateur', [
      text(
        'Le cadenas et le "https://" indiquent une connexion chiffrée. Vérifiez toujours l\'URL complète avant de saisir des données sensibles.',
      ),
    ]),
  ],
  commonMistakes: [
    'Croire qu\'HTTPS = site sûr (c\'est le site légitime qui importe)',
    'Confondre SSL (ancien, obsolète) et TLS (actuel)',
  ],
  summary:
      'HTTPS chiffre le trafic web via TLS et authentifie le serveur par certificat. Il protège la connexion, pas la légitimité du site.',
  quiz: [
    q(const [
      'q1',
      'HTTPS protège...',
      'qcm',
      'la connexion (chiffrement)|la légitimité du site|la vitesse|le disque dur',
      '0',
      'HTTPS chiffre la connexion. Il ne rend pas le site légitime.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi un site de phishing peut-il afficher un cadenas HTTPS, et pourquoi faut-il vérifier l\'URL ?',
    ),
  ],
  xp: 80,
);

Course _ssh() => Course(
  id: 'net-ssh',
  title: 'SSH : accès distant sécurisé',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle et la sécurité de SSH',
    'Distinguer SSH et telnet',
    'Comprendre l\'authentification par clés',
  ],
  prerequisites: ['Niveau Réseau'],
  sections: [
    sec('Le rôle de SSH', [
      text(
        'SSH (Secure Shell) permet d\'accéder à distance et de façon chiffrée à une machine, en ligne de commande. C\'est l\'outil standard d\'administration des serveurs.',
      ),
      text(
        'Il s\'agit d\'un protocole réseau (port 22 par défaut) qui remplace telnet, qui transmettait tout en clair.',
      ),
    ]),
    sec('SSH vs telnet', [
      code(
        'telnet : non chiffré, mot de passe visible → À ÉVITER\n'
        'ssh    : tout chiffré → à utiliser',
        label: 'Comparaison',
      ),
    ]),
    sec('Authentification', [
      text(
        'SSH peut s\'authentifier par mot de passe ou par clés (publique/privée). Les clés sont plus sûres et permettent l\'automatisation sans saisir de mot de passe.',
      ),
      code(
        'ssh-keygen -t ed25519\n'
        'ssh-copy-id user@hote\n'
        'ssh user@hote',
        label: 'Clés',
      ),
    ]),
    sec('Sécuriser SSH', [
      list(
        '- Désactiver la connexion root par mot de passe.\n'
        '- Privilégier les clés.\n'
        '- Mettre en place un pare-feu limitant SSH (ex: une IP autorisée).\n'
        '- Changer le port par défaut pour l\'obfuscation.\n'
        '- Surveiller un échecs de connexion (auth.log).',
      ),
      warn(
        'SSH exposé sur Internet avec mot de passe faible est une cible permanente de brute-force.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser telnet à la place de SSH',
    'Laisser l\'authentification root par mot de passe',
  ],
  summary:
      'SSH donne un accès distant chiffré. Plus sûr que telnet, il privilégie l\'authentification par clés et une bonne configuration.',
  quiz: [
    q(const [
      'q1',
      'Pourquoi préférer SSH à telnet ?',
      'qcm',
      'SSH est chiffré|telnet est plus rapide|SSH est gratuit uniquement|telnet n\'existe pas',
      '0',
      'SSH chiffre toute la session, pas telnet.',
    ]),
  ],
  exercises: [
    ex(
      'Sécurité',
      'Listez 3 mesures pour sécuriser un serveur SSH accessible depuis Internet.',
    ),
  ],
  xp: 80,
);

Course _ftp() => Course(
  id: 'net-ftp',
  title: 'FTP et le transfert de fichiers',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle de FTP',
    'Connaître ses limites (non chiffré)',
    'Connaître les alternatives sécurisées',
  ],
  prerequisites: ['Ports', 'SSH'],
  sections: [
    sec('Le rôle de FTP', [
      text(
        'FTP (File Transfer Protocol) sert à transférer des fichiers entre machines, via les ports 20/21. Il permet de téléverser et télécharger des fichiers sur un serveur.',
      ),
    ]),
    sec('Les limites de FTP', [
      text(
        'Le gros défaut de FTP : il transmet tout en clair (identifiants, données). Une personne du réseau peut intercepter le mot de passe et les fichiers. Comme telnet, il est obsolète d\'un point de vue sécurité.',
      ),
    ]),
    sec('Alternatives sécurisées', [
      code(
        'SFTP   : FTP sécurisé via SSH (chiffré)\n'
        'FTPS   : FTP sur TLS (chiffré)\n'
        'SCP    : copie via SSH (chiffré)\n'
        'rsync  : synchro efficace (peut être chiffrée)',
        label: 'Alternatives',
      ),
      text(
        'On privilégie SFTP/SCP car ils s\'appuient sur SSH et le chiffrement.',
      ),
    ]),
    sec('FTP et la sécurité', [
      text(
        'Un serveur FTP anonyme ou avec mot de passe faible expose des fichiers. Vérifiez toujours qui peut lire/écrire, et préférez les protocoles chiffrés.',
      ),
      warn(
        'Ne transmettez jamais d\'identifiants ou de fichiers sensibles en FTP clair. Utilisez SFTP.',
      ),
    ]),
  ],
  commonMistakes: [
    'Utiliser FTP pour des données sensibles',
    'Lancer des serveurs FTP anonymes',
  ],
  summary:
      'FTP transfère des fichiers mais en clair. On lui préfère SFTP/FTPS/SCP (chiffrés) pour toute donnée sensible.',
  quiz: [
    q(const [
      'q1',
      'Pourquoi éviter le FTP classique ?',
      'qcm',
      'il transmet en clair|lent à vitesse constante|pas de fichiers|ne marche pas sur Linux',
      '0',
      'FTP transmet identifiants et données en clair.',
    ]),
  ],
  exercises: [
    ex(
      'Choisir',
      'Quel protocole de transfert sécurisé choisiriez-vous et pourquoi : FTP, SFTP ou FTPS ?',
    ),
  ],
  xp: 70,
);

Course _smtp() => Course(
  id: 'net-smtp',
  title: 'SMTP et le courrier électronique',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle de SMTP',
    'Distinguer envoi et lecture du mail',
    'Connaître les protocoles mail',
  ],
  prerequisites: ['Ports', 'Protocoles'],
  sections: [
    sec('Le rôle de SMTP', [
      text(
        'SMTP (Simple Mail Transfer Protocol) est le protocole d\'envoi du courrier électronique. C\'est lui qui achemine un email de votre boîte vers le serveur du destinataire, via le port 25 (ou 587/465 pour les envois authentifiés et chiffrés).',
      ),
    ]),
    sec('Envoi vs lecture', [
      text(
        'On distingue deux phases : l\'envoi (SMTP) et la lecture du courrier reçu (POP3 ou IMAP) :',
      ),
      code(
        'SMTP : envoi du mail (port 25/587/465)\n'
        'POP3 : télécharge les mails (port 110/995)\n'
        'IMAP : synchronise les mails (port 143/993)',
        label: 'Protocoles mail',
      ),
    ]),
    sec('Le danger : le spam et le phishing', [
      text(
        'Le SMTP est à la base du spam et du phishing. Les attaquants envoient des emails imitant des organismes légitimes pour voler des données ou diffuser des malwares (voir cours phishing).',
      ),
    ]),
    sec('Sécuriser l\'email', [
      list(
        '- Chiffrer les mails (PGP/S/MIME) pour les données sensibles.\n'
        '- Vérifier les en-têtes et l\'expéditeur réel.\n'
        '- Se méfier des pièces jointes inattendues.\n'
        '- Utiliser des protocoles de validation (SPF, DKIM, DMARC) côté serveur.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre SMTP (envoi) et POP/IMAP (lecture)',
    'Ouvrir toute pièce jointe reçue',
  ],
  summary:
      'SMTP envoie le mail, POP/IMAP le lit. SMTP est le vecteur du spam/phishing ; la vigilance et les bonnes pratiques protègent.',
  quiz: [
    q(const [
      'q1',
      'Le SMTP sert à...',
      'qcm',
      'envoyer des emails|lire les emails reçus|naviguer sur le web|traduire des domaines',
      '0',
      'SMTP achémine/envoie le courrier.',
    ]),
  ],
  exercises: [
    ex(
      'Distinguer',
      'Expliquez la différence entre SMTP (envoi) et IMAP (lecture/synchronisation).',
    ),
  ],
  xp: 70,
);

Course _vpn() => Course(
  id: 'net-vpn',
  title: 'VPN',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre ce qu\'est un VPN',
    'Comprendre le tunneling chiffré',
    'Connaître les usages professionnels',
  ],
  prerequisites: ['IP', 'HTTPS/TLS'],
  sections: [
    sec('Le rôle d\'un VPN', [
      text(
        'Un VPN (Virtual Private Network) crée un tunnel chiffré entre votre appareil et un serveur (ou un réseau). Tout votre trafic passe par ce tunnel, ce qui protège la confidentialité et permet de rejoindre un réseau privé à distance.',
      ),
      text(
        'Deux usages : sécuriser sa connexion (surtout sur un réseau public) et accéder au réseau interne d\'une entreprise depuis l\'extérieur.',
      ),
    ]),
    sec('Le tunneling chiffré', [
      text(
        'Le VPN encapsule et chiffre vos données dans un tunnel. Personne sur le réseau local ou le chemin ne peut les lire. C\'est comme une enveloppe scellée à l\'intérieur du courrier public.',
      ),
    ]),
    sec('Types de VPN', [
      list(
        '- **Remote access** : un employé se connecte au réseau d\'entreprise depuis chez lui.\n'
        '- **Site-à-site** : relie deux sites d\'une même organisation.\n'
        '- **Client personnel** : un particulier sécurise sa navigation sur un réseau public.',
      ),
      text(
        'Les protocoles VPN : IPsec, OpenVPN, WireGuard (moderne et rapide).',
      ),
    ]),
    sec('VPN et la sécurité', [
      text(
        'Un VPN n\'est pas une baguette magique : il chiffre le trafic entre vous et le serveur VPN, mais pas "tout Internet". Il ne protège pas contre le phishing ni les logiciels installés. C\'est un outil parmi d\'autres.',
      ),
      warn(
        'Votre navigateur doit être à jour et vous restez responsable de ce que vous faites, VPN ou pas.',
      ),
    ]),
  ],
  commonMistakes: [
    'Croire qu\'un VPN rend anonyme (il cache à votre FAI, pas à tout)',
    'Penser qu\'un VPN protège contre toutes les menaces',
  ],
  summary:
      'Un VPN crée un tunnel chiffré pour protéger le trafic et accéder à des réseaux privés à distance. À utiliser comme une couche de sécurité, pas une solution magique.',
  quiz: [
    q(const [
      'q1',
      'Un VPN sert principalement à...',
      'qcm',
      'créer un tunnel chiffré vers un réseau|accélérer son ordinateur|supprimer les virus|crypter son disque',
      '0',
      'Le VPN crée un tunnel chiffré entre vous et un réseau/serveur.',
    ]),
  ],
  exercises: [
    ex(
      'Usage',
      'Dans quel scénario (réseau public, télétravail, etc.) un VPN est-il utile et pourquoi ?',
    ),
  ],
  xp: 70,
);

Course _firewall() => Course(
  id: 'net-firewall',
  title: 'Le pare-feu (firewall)',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle du firewall',
    'Comprendre le filtrage par règles',
    'Connaître les bases de iptables/nftables',
  ],
  prerequisites: ['IP', 'Ports'],
  sections: [
    sec('Le rôle du pare-feu', [
      text(
        'Un pare-feu (firewall) filtre le trafic réseau selon des règles, pour autoriser ou bloquer les connexions entrantes et sortantes. C\'est la première ligne de défense du réseau.',
      ),
      text(
        'Il examine les paquets selon l\'IP source/destination, le port et le protocole, et applique une politique (ACCEPTER ou REFUSER).',
      ),
    ]),
    sec('Règles et politiques', [
      text(
        'Le principe : définir quelle communication est autorisée. Une bonne politique est souvent "tout est refusé par défaut, on ouvre ce qui est nécessaire".',
      ),
      code(
        'Accorder : SSH depuis l\'IP de l\'admin\n'
        'Accorder : HTTP/HTTPS vers le serveur web\n'
        'Refuser :  le reste par défaut',
        label: 'Exemple de politique',
      ),
    ]),
    sec('Par logiciel et par matériel', [
      text(
        'Les pare-feux existent en logiciel (iptables/nftables sous Linux, pare-feu Windows) et en matériel (appliances dédiées). Un même réseau peut cumuler plusieurs couches de filtrage.',
      ),
    ]),
    sec('Les bases de iptables', [
      code(
        'iptables -A INPUT -p tcp --dport 22 -s 192.168.1.5 -j ACCEPT\n'
        'iptables -P INPUT DROP     # refuse tout par défaut\n'
        'iptables -L                # liste les règles\n'
        '# (simulation - à tester avec prudence)',
        label: 'iptables',
      ),
      warn(
        'Une mauvaise règle de pare-feu peut couper tout votre accès réseau. Testez avec précaution et conservez un accès de secours.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ouvrir trop de ports inutiles',
    'Configurer le firewall en oubliant la règle par défaut',
  ],
  summary:
      'Le pare-feu filtre le trafic selon des règles (IP, port, protocole). Une politique stricte "tout refusé par défaut" limite la surface d\'attaque.',
  quiz: [
    q(const [
      'q1',
      'Le rôle du pare-feu est...',
      'qcm',
      'filtrer le trafic réseau selon des règles|crypter les fichiers|trier les emails|analyser les disques',
      '0',
      'Le firewall filtre le trafic réseau.',
    ]),
  ],
  exercises: [
    ex(
      'Concevoir',
      'Écrivez une politique de pare-feu simple pour un serveur web qui n\'a besoin que de SSH et HTTP/HTTPS.',
    ),
  ],
  xp: 90,
);

Course _nat() => Course(
  id: 'net-nat',
  title: 'NAT : la traduction d\'adresses',
  category: 'networking',
  level: 'Niveau 1 - Informatique et réseaux',
  levelNumber: 1,
  objectives: [
    'Comprendre le rôle du NAT',
    'Comprendre pourquoi il existe',
    'Distinguer NAT et PAT',
  ],
  prerequisites: ['IP privée/publique'],
  sections: [
    sec('Le rôle du NAT', [
      text(
        'Le NAT (Network Address Translation) traduit les adresses IP. Il permet à plusieurs machines d\'un réseau local (avec des IP privées) de partager une seule adresse IP publique pour accéder à Internet.',
      ),
      text(
        'C\'est votre box qui fait le NAT : vos appareils (192.168.x.x) sortent vers Internet tous avec la même IP publique.',
      ),
    ]),
    sec('Comment ça marche', [
      text(
        'Quand vous demandez une page web, votre box remplace votre IP privée par son IP publique dans le paquet sortant, et en mémoire quelle machine a fait la demande pour renvoyer la réponse au bon appareil (via la table NAT).',
      ),
    ]),
    sec('NAT vs PAT', [
      text(
        'Le NAT simple traduit une IP en une autre. Le PAT (Port Address Translation) est la version courante qui, en plus, utilise les ports pour que plusieurs machines passent derrière une seule IP publique. Quand on dit "NAT" dans une box, on parle souvent de PAT.',
      ),
    ]),
    sec('NAT et la sécurité', [
      text(
        'Le NAT masque les machines du réseau local aux yeux d\'Internet (les connexions entrantes non sollicitées ne trouvent pas de destination). C\'est une forme de protection par obfuscation, mais PAS un pare-feu au sens propre : il faut toujours filtrer explicitement.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre NAT et pare-feu',
    'Croire que le NAT suffit à protéger',
  ],
  summary:
      'Le NAT traduit des IP privées en une IP publique partagée pour accéder à Internet. Le PAT utilise les ports pour multiplexer. Ce n\'est pas un vrai pare-feu.',
  quiz: [
    q(const [
      'q1',
      'Le NAT permet de...',
      'qcm',
      'faire partager une IP publique à plusieurs machines (privées)|crypter le trafic|trier les emails|surveiller les disques',
      '0',
      'NAT traduit et fait partager l\'IP publique.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Expliquez comment différents appareils de votre maison partagent une seule adresse IP publique grâce au NAT/PAT.',
    ),
  ],
  xp: 80,
);
