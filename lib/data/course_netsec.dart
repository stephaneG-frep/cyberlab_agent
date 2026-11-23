import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

/// Niveau 5 - Sécurité réseau.
List<Course> networkSecurityCourses() => [
  _osi(),
  _segmentation(),
  _firewall(),
  _idsIps(),
  _vpn(),
  _wifi(),
  _mitm(),
  _scan(),
  _traffic(),
  _hardening(),
];

const _level = 'Niveau 5 - Sécurité réseau';
const _cat = 'network_security';

Course _osi() => Course(
  id: 'ns-osi',
  title: 'Le modèle OSI et les attaques par couche',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Connaître les 7 couches du modèle OSI et leur rôle",
    "Faire le lien entre OSI et TCP/IP",
    "Associer des attaques et des défenses à chaque couche",
  ],
  prerequisites: ["Les protocoles réseau", "TCP"],
  sections: [
    sec("Les 7 couches", [
      code(
        "7 Application   HTTP, DNS, SMTP, SSH\n"
        "6 Présentation  encodage, chiffrement (TLS au sens large)\n"
        "5 Session       ouverture et maintien des échanges\n"
        "4 Transport     TCP, UDP (ports)\n"
        "3 Réseau        IP, ICMP (adresses IP, routage)\n"
        "2 Liaison       Ethernet, Wi-Fi, ARP (adresses MAC)\n"
        "1 Physique      câbles, ondes, signaux",
        label: "Modèle OSI",
      ),
      text(
        "Le modèle OSI est un modèle de référence : il découpe la communication "
        "en 7 couches qui se rendent service les unes aux autres. Le modèle "
        "TCP/IP, réellement utilisé, regroupe ces couches en 4 : application "
        "(5-6-7), transport (4), internet (3) et accès réseau (1-2).",
      ),
    ]),
    sec("Une attaque, une couche", [
      list(
        "- **Couche 1** : écoute d'un câble, brouillage radio, accès physique à une prise.\n"
        "- **Couche 2** : usurpation ARP, saturation de la table MAC d'un commutateur, saut de VLAN.\n"
        "- **Couche 3** : usurpation d'adresse IP, attaques ICMP, détournement de routes.\n"
        "- **Couche 4** : scan de ports, inondation SYN.\n"
        "- **Couche 7** : injections web, hameçonnage, usurpation DNS.",
      ),
      tip(
        "Situer une attaque sur la bonne couche aide à choisir la bonne "
        "défense : un pare-feu IP (couche 3-4) ne voit pas une injection SQL "
        "(couche 7), qui demande un WAF.",
      ),
    ]),
    sec("Défense en profondeur", [
      text(
        "Aucune protection ne couvre toutes les couches. On les empile : "
        "contrôle d'accès physique, sécurité des ports des commutateurs, "
        "filtrage IP, chiffrement TLS, validation applicative. Si une couche "
        "cède, la suivante limite les dégâts.",
      ),
    ]),
  ],
  commonMistakes: [
    "Croire qu'un pare-feu réseau protège contre les attaques applicatives",
    "Confondre adresse MAC (couche 2) et adresse IP (couche 3)",
  ],
  summary:
      "OSI découpe le réseau en 7 couches, TCP/IP en 4. Chaque couche a ses "
      "attaques (ARP en 2, scan en 4, injection en 7) et ses défenses : on les "
      "combine en défense en profondeur.",
  quiz: [
    q(const [
      'q1',
      "À quelle couche OSI se situe l'usurpation ARP ?",
      'qcm',
      "Couche 2 (liaison)|Couche 3 (réseau)|Couche 4 (transport)|Couche 7 (application)",
      '0',
      "ARP associe adresses IP et MAC sur le réseau local : c'est la couche 2.",
    ]),
    q(const [
      'q2',
      "Un scan de ports vise surtout la couche...",
      'qcm',
      "4 (transport)|1 (physique)|2 (liaison)|6 (présentation)",
      '0',
      "Les ports sont une notion de la couche transport (TCP, UDP).",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : un pare-feu qui filtre les adresses IP et les ports bloque aussi les injections SQL.",
      'tf',
      'Faux',
      null,
      "L'injection passe par un port autorisé (443) : il faut une protection applicative (code sûr, WAF).",
    ]),
  ],
  exercises: [
    ex(
      "Classer des attaques",
      "Classez par couche OSI : hameçonnage, usurpation ARP, inondation SYN, "
          "vol d'un câble réseau, usurpation DNS.",
    ),
  ],
);

Course _segmentation() => Course(
  id: 'ns-segmentation',
  title: 'Segmentation, VLAN et DMZ',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Comprendre pourquoi on segmente un réseau",
    "Savoir ce qu'est un VLAN et une DMZ",
    "Limiter les déplacements d'un attaquant (mouvement latéral)",
  ],
  prerequisites: ["Le modèle OSI et les attaques par couche"],
  sections: [
    sec("Pourquoi segmenter ?", [
      text(
        "Dans un réseau « plat », tout le monde voit tout le monde : un poste "
        "compromis peut atteindre directement les serveurs sensibles. La "
        "segmentation découpe le réseau en zones séparées, et seuls les flux "
        "nécessaires passent d'une zone à l'autre.",
      ),
      list(
        "- Zone utilisateurs (postes de travail)\n"
        "- Zone serveurs internes (fichiers, bases de données)\n"
        "- Zone d'administration (accès réservé aux administrateurs)\n"
        "- Zone invités (Wi-Fi visiteurs, isolé de tout le reste)\n"
        "- DMZ (services exposés à Internet)",
      ),
    ]),
    sec("Les VLAN", [
      text(
        "Un VLAN (réseau local virtuel) sépare logiquement des machines "
        "branchées sur les mêmes commutateurs. Deux VLAN ne communiquent "
        "qu'en passant par un routeur ou un pare-feu, où l'on applique des "
        "règles de filtrage.",
      ),
      warn(
        "Un VLAN seul n'est pas un pare-feu : sans règles de filtrage entre "
        "VLAN, la séparation n'apporte presque rien.",
      ),
    ]),
    sec("La DMZ", [
      text(
        "La zone démilitarisée héberge les serveurs joignables depuis "
        "Internet (site web, relais de messagerie). Si l'un d'eux est "
        "compromis, l'attaquant reste dans la DMZ : le pare-feu l'empêche "
        "d'atteindre le réseau interne.",
      ),
    ]),
    sec("Mouvement latéral", [
      text(
        "Après un premier accès, l'attaquant cherche à rebondir de machine en "
        "machine. La segmentation, le principe du moindre privilège et la "
        "surveillance des flux internes freinent ce mouvement latéral.",
      ),
    ]),
  ],
  commonMistakes: [
    "Mettre le Wi-Fi invités sur le même réseau que les serveurs",
    "Créer des VLAN sans filtrer les flux entre eux",
  ],
  summary:
      "Segmenter, c'est découper le réseau en zones (utilisateurs, serveurs, "
      "administration, invités, DMZ) reliées par des règles de filtrage. Cela "
      "limite le mouvement latéral d'un attaquant.",
  quiz: [
    q(const [
      'q1',
      "À quoi sert une DMZ ?",
      'qcm',
      "Isoler les serveurs exposés à Internet du réseau interne|Relier directement le réseau interne et Internet sans filtrage|Chiffrer les échanges entre les postes de travail|Donner un accès Wi-Fi rapide aux visiteurs de l'entreprise",
      '0',
      "Un serveur compromis en DMZ ne donne pas d'accès direct au réseau interne.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : des VLAN différents suffisent à bloquer le trafic, même sans règles de filtrage.",
      'tf',
      'Faux',
      null,
      "La séparation n'a de valeur que si le routage entre VLAN est filtré.",
    ]),
    q(const [
      'q3',
      "Comment appelle-t-on le fait, pour un attaquant, de rebondir de machine en machine ?",
      'qcm',
      "Le mouvement latéral|L'exfiltration|Le phishing|Le déni de service",
      '0',
      "La segmentation vise justement à freiner ce mouvement latéral.",
    ]),
  ],
  exercises: [
    ex(
      "Dessiner un réseau segmenté",
      "Pour une petite entreprise (20 postes, un serveur de fichiers, un "
          "site web, un Wi-Fi invités), dessinez les zones et listez les seuls "
          "flux autorisés entre elles.",
    ),
  ],
);

Course _firewall() => Course(
  id: 'ns-firewall',
  title: 'Le pare-feu en pratique',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Comprendre le filtrage à état (stateful)",
    "Écrire des règles selon le principe « tout refuser sauf »",
    "Lire des règles iptables, nftables ou ufw",
  ],
  prerequisites: ["Le pare-feu (firewall)", "Segmentation, VLAN et DMZ"],
  sections: [
    sec("Refuser par défaut", [
      text(
        "Une bonne politique de pare-feu refuse tout par défaut, puis autorise "
        "explicitement les seuls flux nécessaires. L'inverse (tout autoriser "
        "et bloquer ce qui gêne) laisse forcément passer des oublis.",
      ),
      code(
        "ufw default deny incoming\n"
        "ufw default allow outgoing\n"
        "ufw allow from 192.168.1.0/24 to any port 22 proto tcp\n"
        "ufw allow 443/tcp\n"
        "ufw enable",
        label: "ufw (Ubuntu)",
      ),
    ]),
    sec("Filtrage à état", [
      text(
        "Un pare-feu à état mémorise les connexions établies. On autorise "
        "l'ouverture d'une connexion sortante, et les réponses reviennent "
        "automatiquement, sans ouvrir de port entrant. C'est le cas de tous "
        "les pare-feu modernes.",
      ),
      code(
        "iptables -P INPUT DROP\n"
        "iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT\n"
        "iptables -A INPUT -i lo -j ACCEPT\n"
        "iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT",
        label: "iptables",
      ),
    ]),
    sec("Ordre et journalisation", [
      text(
        "Les règles sont lues dans l'ordre : la première qui correspond "
        "s'applique. Une règle trop large placée en haut rend les suivantes "
        "inutiles. On journalise les refus pour repérer scans et tentatives.",
      ),
      tip(
        "Filtrez aussi le trafic sortant des serveurs : un serveur web n'a "
        "pas besoin de contacter n'importe quelle adresse sur Internet, et ce "
        "filtrage gêne beaucoup un attaquant (téléchargement d'outils, "
        "exfiltration).",
      ),
    ]),
  ],
  commonMistakes: [
    "Ouvrir un port « temporairement » et l'oublier",
    "Exposer l'administration (SSH, RDP, bases de données) à tout Internet",
    "Ne jamais filtrer le trafic sortant",
  ],
  summary:
      "Politique « tout refuser sauf », filtrage à état, règles lues dans "
      "l'ordre, refus journalisés. Le trafic sortant se filtre aussi.",
  quiz: [
    q(const [
      'q1',
      "Quelle politique par défaut est recommandée pour le trafic entrant ?",
      'qcm',
      "Tout refuser, puis autoriser le nécessaire|Tout autoriser, puis bloquer le dangereux|Autoriser les ports inférieurs à 1024|Aucune politique",
      '0',
      "Le refus par défaut évite que les oublis restent ouverts.",
    ]),
    q(const [
      'q2',
      "Que permet un pare-feu à état (stateful) ?",
      'qcm',
      "Laisser revenir les réponses des connexions établies|Chiffrer les connexions établies avec l'extérieur|Bloquer les virus contenus dans les fichiers téléchargés|Attribuer des adresses IP aux nouvelles machines",
      '0',
      "Il suit l'état des connexions : les réponses sont acceptées sans ouvrir de port entrant.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : l'ordre des règles d'un pare-feu n'a pas d'importance.",
      'tf',
      'Faux',
      null,
      "La première règle qui correspond s'applique : l'ordre est essentiel.",
    ]),
  ],
  exercises: [
    ex(
      "Écrire une politique",
      "Écrivez les règles ufw d'un serveur web : HTTPS ouvert à tous, SSH "
          "seulement depuis 192.168.1.0/24, tout le reste refusé.",
    ),
    ex(
      "Lire un journal",
      "Dans le terminal du Lab : sudo grep \"UFW BLOCK\" /var/log/syslog. "
          "Quel port était visé, et quel service tourne habituellement dessus ?",
    ),
  ],
);

Course _idsIps() => Course(
  id: 'ns-idsips',
  title: 'Détection et prévention d\'intrusion (IDS / IPS)',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Différencier IDS et IPS",
    "Comprendre détection par signature et par anomalie",
    "Gérer les faux positifs",
  ],
  prerequisites: ["Le pare-feu en pratique"],
  sections: [
    sec("IDS ou IPS ?", [
      list(
        "- **IDS** (système de détection d'intrusion) : observe une copie du trafic et lève des alertes.\n"
        "- **IPS** (système de prévention) : placé en coupure, il peut bloquer le trafic malveillant en temps réel.",
      ),
      text(
        "Snort et Suricata sont deux moteurs libres très répandus. On parle de "
        "NIDS pour le réseau et de HIDS pour une machine (ex. Wazuh, OSSEC).",
      ),
    ]),
    sec("Signatures et anomalies", [
      text(
        "La détection par signature compare le trafic à des motifs connus : "
        "efficace et précise, mais aveugle aux attaques nouvelles. La "
        "détection par anomalie apprend ce qui est « normal » et alerte sur "
        "les écarts : elle repère l'inédit, mais produit plus de faux positifs.",
      ),
      code(
        'alert tcp any any -> \$HOME_NET 22 (msg:"Tentatives SSH répétées"; '
        'flags:S; threshold:type both, track by_src, count 10, seconds 60; '
        'sid:1000001;)',
        label: "Règle de style Snort/Suricata",
      ),
    ]),
    sec("Faux positifs et réglage", [
      text(
        "Un IDS mal réglé noie les analystes sous les alertes, qui finissent "
        "par les ignorer. On ajuste les seuils, on exclut les flux connus et "
        "légitimes, et on documente chaque exception.",
      ),
      warn(
        "Un IPS mal réglé peut bloquer du trafic légitime : on le déploie "
        "souvent d'abord en mode détection seule, puis on active le blocage "
        "règle par règle.",
      ),
    ]),
  ],
  commonMistakes: [
    "Installer un IDS sans personne pour lire ses alertes",
    "Activer le blocage IPS sur toutes les règles dès le premier jour",
  ],
  summary:
      "L'IDS alerte, l'IPS bloque. Signatures : précises mais limitées au "
      "connu ; anomalies : repèrent l'inédit mais génèrent du bruit. Le "
      "réglage des faux positifs est un travail continu.",
  quiz: [
    q(const [
      'q1',
      "Quelle est la différence principale entre un IDS et un IPS ?",
      'qcm',
      "L'IPS peut bloquer le trafic, l'IDS seulement alerter|L'IDS peut bloquer le trafic, l'IPS seulement alerter|L'IPS surveille les postes, l'IDS surveille les e-mails|Il n'y en a aucune, ce sont deux noms du même outil",
      '0',
      "L'IPS est en coupure et peut agir ; l'IDS observe et alerte.",
    ]),
    q(const [
      'q2',
      "Quelle détection repère le mieux une attaque totalement nouvelle ?",
      'qcm',
      "Par anomalie|Par signature|Par liste noire d'adresses|Aucune",
      '0',
      "Une signature n'existe que pour ce qui est déjà connu.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : plus un IDS produit d'alertes, plus le réseau est protégé.",
      'tf',
      'Faux',
      null,
      "Trop d'alertes (faux positifs) épuise les analystes et fait rater les vraies.",
    ]),
  ],
  exercises: [
    ex(
      "Qualifier des alertes",
      "Dans le Lab, onglet SOC : qualifiez trois alertes, dont au moins un "
          "faux positif. Notez ce qui vous a permis de le reconnaître.",
    ),
  ],
);

Course _vpn() => Course(
  id: 'ns-vpn',
  title: 'VPN : IPsec, WireGuard et OpenVPN',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Comprendre ce qu'est un tunnel chiffré",
    "Distinguer VPN site à site et accès distant",
    "Connaître les limites d'un VPN",
  ],
  prerequisites: ["VPN", "Le modèle OSI et les attaques par couche"],
  sections: [
    sec("Le principe du tunnel", [
      text(
        "Un VPN encapsule le trafic dans un tunnel chiffré et authentifié "
        "entre deux points. Sur un réseau non fiable (Wi-Fi public, "
        "Internet), un observateur ne voit qu'un flux chiffré vers "
        "l'extrémité du tunnel.",
      ),
      list(
        "- **Site à site** : relie deux réseaux (siège et agence) en permanence.\n"
        "- **Accès distant** : un télétravailleur rejoint le réseau de l'entreprise.",
      ),
    ]),
    sec("Les protocoles", [
      list(
        "- **IPsec** : standard très répandu (couche 3), souvent pour le site à site ; configuration riche mais complexe.\n"
        "- **OpenVPN** : basé sur TLS, flexible, éprouvé.\n"
        "- **WireGuard** : moderne, code très court, cryptographie fixe et performante.",
      ),
    ]),
    sec("Ce qu'un VPN ne fait pas", [
      text(
        "Un VPN protège le transport, pas les extrémités. Si le poste du "
        "télétravailleur est infecté, le malware passe dans le tunnel avec "
        "lui. L'accès VPN doit donc être protégé par l'authentification "
        "multifacteur et limité aux ressources utiles.",
      ),
      warn(
        "Les passerelles VPN exposées sur Internet sont une cible de choix : "
        "leurs mises à jour de sécurité sont à appliquer en priorité.",
      ),
    ]),
  ],
  commonMistakes: [
    "Penser qu'un VPN rend une connexion « anonyme » ou un poste « sûr »",
    "Donner à tout utilisateur VPN l'accès à tout le réseau interne",
    "Laisser une passerelle VPN sans mises à jour",
  ],
  summary:
      "Un VPN crée un tunnel chiffré (IPsec, OpenVPN, WireGuard), site à site "
      "ou en accès distant. Il protège le transport, pas les postes : MFA, "
      "accès limité et mises à jour restent indispensables.",
  quiz: [
    q(const [
      'q1',
      "Un VPN « site à site » sert à...",
      'qcm',
      "Relier deux réseaux de façon permanente|Connecter un télétravailleur de temps en temps|Masquer son adresse IP à un site web|Relier deux écrans à un même poste",
      '0',
      "Il relie par exemple le réseau du siège et celui d'une agence.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : un VPN empêche un poste infecté de contaminer le réseau de l'entreprise.",
      'tf',
      'Faux',
      null,
      "Le tunnel transporte aussi le trafic du malware : il faut sécuriser le poste et limiter les accès.",
    ]),
    q(const [
      'q3',
      "Quel protocole VPN est réputé pour son code très court et moderne ?",
      'qcm',
      "WireGuard|Telnet|FTP|PPTP",
      '0',
      "WireGuard tient en quelques milliers de lignes, ce qui facilite son audit.",
    ]),
  ],
  exercises: [
    ex(
      "Politique d'accès distant",
      "Rédigez en 5 points la politique VPN d'une entreprise : qui y a accès, "
          "avec quelle authentification, vers quelles ressources, et comment les "
          "connexions sont journalisées.",
    ),
  ],
);

Course _wifi() => Course(
  id: 'ns-wifi',
  title: 'Sécuriser un réseau Wi-Fi',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Connaître WEP, WPA2 et WPA3",
    "Distinguer mode personnel (PSK) et entreprise (802.1X)",
    "Reconnaître les attaques Wi-Fi courantes",
  ],
  prerequisites: ["Le modèle OSI et les attaques par couche"],
  sections: [
    sec("Les générations", [
      list(
        "- **WEP** : cassé depuis longtemps, ne plus jamais l'utiliser.\n"
        "- **WPA2** : encore très répandu ; sûr avec une phrase de passe longue.\n"
        "- **WPA3** : remplace l'échange de clé par SAE, résistant aux attaques hors ligne sur la phrase de passe.",
      ),
    ]),
    sec("Personnel ou entreprise", [
      text(
        "En mode personnel (PSK), tout le monde partage la même phrase de "
        "passe : un départ de salarié oblige à la changer partout. En mode "
        "entreprise (802.1X), chaque utilisateur s'authentifie avec ses "
        "propres identifiants ou un certificat, via un serveur RADIUS.",
      ),
      tip(
        "Une phrase de passe WPA2 courte peut être devinée hors ligne à "
        "partir d'une poignée de main capturée : visez au moins 16 caractères "
        "aléatoires, ou WPA3.",
      ),
    ]),
    sec("Attaques courantes", [
      list(
        "- **Evil twin** : faux point d'accès portant le même nom que le vrai, pour intercepter les connexions.\n"
        "- **Désauthentification** : forcer les clients à se reconnecter pour capturer la poignée de main.\n"
        "- **WPS** : le code PIN à 8 chiffres peut être deviné ; désactivez WPS.\n"
        "- **Réseau ouvert** : tout le trafic non chiffré est lisible par les voisins.",
      ),
      warn(
        "Tester un réseau Wi-Fi qui ne vous appartient pas, même « juste pour "
        "voir », est illégal sans autorisation écrite.",
      ),
    ]),
  ],
  commonMistakes: [
    "Laisser WPS activé sur la box",
    "Mettre les invités sur le même réseau que les postes de travail",
    "Choisir une phrase de passe courte ou devinable",
  ],
  summary:
      "WEP est cassé, WPA2 sûr avec une longue phrase de passe, WPA3 "
      "préférable. Le mode entreprise donne des identifiants individuels. "
      "Méfiance envers les evil twins, WPS et les réseaux ouverts.",
  quiz: [
    q(const [
      'q1',
      "Quel protocole Wi-Fi ne faut-il plus jamais utiliser ?",
      'qcm',
      "WEP|WPA2|WPA3|802.1X",
      '0',
      "WEP se casse en quelques minutes.",
    ]),
    q(const [
      'q2',
      "Qu'est-ce qu'un « evil twin » ?",
      'qcm',
      "Un faux point d'accès imitant le vrai|Un second routeur de secours du réseau|Un virus copié d'une clé USB à l'autre|Un répéteur qui étend la portée du Wi-Fi",
      '0',
      "Il porte le même nom de réseau pour attirer les connexions et les intercepter.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : en mode entreprise (802.1X), chaque utilisateur a ses propres identifiants.",
      'tf',
      'Vrai',
      null,
      "C'est son grand avantage sur la phrase de passe partagée du mode personnel.",
    ]),
  ],
  exercises: [
    ex(
      "Audit de sa box",
      "Sur votre propre box : vérifiez le protocole (WPA2 ou WPA3), la "
          "longueur de la phrase de passe, l'état de WPS et l'existence d'un "
          "réseau invités séparé.",
    ),
  ],
);

Course _mitm() => Course(
  id: 'ns-mitm',
  title: 'Attaques de l\'homme du milieu',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Comprendre le principe d'une attaque de l'homme du milieu",
    "Reconnaître l'usurpation ARP et DNS",
    "Connaître les défenses (TLS, HSTS, inspection ARP)",
  ],
  prerequisites: ["L'adresse MAC", "DNS : la résolution de noms"],
  sections: [
    sec("Le principe", [
      text(
        "L'attaquant s'insère entre deux parties qui croient se parler "
        "directement. Il peut lire, modifier ou bloquer les échanges. Sur un "
        "réseau local, il y parvient souvent en trompant les mécanismes de "
        "résolution d'adresses.",
      ),
    ]),
    sec("Usurpation ARP", [
      text(
        "ARP n'a aucune authentification. L'attaquant envoie des réponses "
        "ARP non sollicitées : « l'adresse IP de la passerelle, c'est ma MAC ». "
        "Les victimes lui envoient alors tout leur trafic, qu'il relaie.",
      ),
      code(
        "2  Routeur_11:22:33  192.168.1.1 is at 3c:84:6a:11:22:33\n"
        "32 PcsCompu_66:66:66 192.168.1.1 is at 08:00:27:66:66:66 (duplicate!)",
        label: "Signe dans une capture",
      ),
      tip(
        "Ce cas est visible dans le Lab : onglet Réseau, puis Capture, filtre "
        "arp.",
      ),
    ]),
    sec("Usurpation DNS et HTTP en clair", [
      text(
        "En falsifiant les réponses DNS, l'attaquant envoie la victime vers "
        "un faux site. Si la connexion est en HTTP, il lit et modifie tout, "
        "mots de passe compris.",
      ),
    ]),
    sec("Se défendre", [
      list(
        "- **TLS partout** : le certificat permet de détecter un faux serveur.\n"
        "- **HSTS** : le navigateur refuse de revenir en HTTP.\n"
        "- **Inspection ARP dynamique** et sécurité des ports sur les commutateurs.\n"
        "- **DNSSEC** ou résolveurs de confiance.\n"
        "- Ne jamais ignorer un avertissement de certificat.",
      ),
    ]),
  ],
  commonMistakes: [
    "Cliquer sur « Continuer quand même » face à une erreur de certificat",
    "Laisser des services internes en HTTP « parce que c'est interne »",
  ],
  summary:
      "L'homme du milieu s'intercale entre deux parties, souvent par "
      "usurpation ARP ou DNS. TLS, HSTS, l'inspection ARP et la vigilance "
      "face aux certificats sont les principales défenses.",
  quiz: [
    q(const [
      'q1',
      "Pourquoi l'usurpation ARP est-elle possible ?",
      'qcm',
      "ARP n'authentifie pas les réponses|ARP est chiffré|ARP utilise le port 443|Les commutateurs l'interdisent",
      '0',
      "N'importe quel poste du réseau local peut annoncer une fausse correspondance IP-MAC.",
    ]),
    q(const [
      'q2',
      "Quelle mesure empêche le navigateur de revenir en HTTP sur un site ?",
      'qcm',
      "HSTS|ARP|DHCP|FTP",
      '0',
      "L'en-tête Strict-Transport-Security impose HTTPS pour ce site.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : un avertissement de certificat peut signaler une attaque de l'homme du milieu.",
      'tf',
      'Vrai',
      null,
      "Le faux serveur ne possède pas de certificat valide pour le domaine.",
    ]),
  ],
  exercises: [
    ex(
      "Repérer l'usurpation",
      "Dans le Lab (Réseau, puis Capture), filtrez arp et comparez les "
          "paquets 2 et 32. Quelles adresses MAC revendiquent 192.168.1.1 ?",
    ),
  ],
);

Course _scan() => Course(
  id: 'ns-scan',
  title: 'Scanner un réseau de façon éthique',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Comprendre les types de scan nmap (-sS, -sT, -sV)",
    "Interpréter les états de ports",
    "Connaître le cadre légal d'un scan",
  ],
  prerequisites: ["Les ports", "TCP"],
  sections: [
    sec("Le cadre d'abord", [
      warn(
        "Scanner un système sans autorisation écrite de son propriétaire est "
        "illégal (en France, article 323-1 du Code pénal). On scanne son "
        "propre matériel, son lab, ou dans le cadre d'une mission signée qui "
        "précise le périmètre.",
      ),
    ]),
    sec("Les types de scan", [
      code(
        "nmap -sT 192.168.56.10      scan connect : poignée de main complète\n"
        "nmap -sS 192.168.56.10      scan SYN (semi-ouvert), droits root\n"
        "nmap -sV -p 22,80 cible     détecte les versions des services\n"
        "nmap -sn 192.168.56.0/24    découverte des hôtes, sans scan de ports",
        label: "nmap",
      ),
      text(
        "Le scan SYN envoie un SYN : un SYN, ACK indique un port ouvert, un "
        "RST un port fermé, et l'absence de réponse un port filtré par un "
        "pare-feu. Il ne termine jamais la connexion.",
      ),
    ]),
    sec("Interpréter les résultats", [
      list(
        "- **open** : un service écoute, c'est une surface d'attaque à justifier.\n"
        "- **closed** : la machine répond mais rien n'écoute.\n"
        "- **filtered** : un pare-feu bloque, on ne sait pas.",
      ),
      tip(
        "Côté défense, scannez régulièrement vos propres réseaux : un port "
        "ouvert que personne ne sait expliquer est une alerte en soi.",
      ),
    ]),
  ],
  commonMistakes: [
    "Scanner « pour voir » une adresse qui ne vous appartient pas",
    "Confondre port fermé (closed) et port filtré (filtered)",
  ],
  summary:
      "nmap -sT (connexion complète), -sS (SYN semi-ouvert), -sV (versions). "
      "open / closed / filtered. Uniquement sur un périmètre autorisé par "
      "écrit.",
  quiz: [
    q(const [
      'q1',
      "Dans un scan SYN, que signifie une réponse SYN, ACK ?",
      'qcm',
      "Le port est ouvert|Le port est fermé|Le port est filtré|La machine est éteinte",
      '0',
      "Le service accepte la connexion : le port est ouvert.",
    ]),
    q(const [
      'q2',
      "Quelle option nmap détecte la version des services ?",
      'qcm',
      "-sV|-sn|-v|-oN",
      '0',
      "-sV interroge les services pour identifier logiciel et version.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : scanner une adresse IP publique au hasard est légal tant qu'on n'exploite rien.",
      'tf',
      'Faux',
      null,
      "Sans autorisation, même un scan peut constituer une infraction.",
    ]),
  ],
  exercises: [
    ex(
      "Lire un scan",
      "Dans le Lab (Réseau, puis Capture), filtrez ip.addr == 203.0.113.7. "
          "Quels ports ont été testés, et lesquels étaient ouverts ou fermés ?",
    ),
    ex(
      "Scan simulé",
      "Dans le terminal du Lab, lancez nmap -sV localhost et listez les "
          "services trouvés avec leur version.",
    ),
  ],
);

Course _traffic() => Course(
  id: 'ns-traffic',
  title: 'Analyser le trafic et repérer les signaux faibles',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Choisir entre capture complète et NetFlow",
    "Repérer balisage (beaconing), exfiltration et tunnel DNS",
    "Mener une analyse méthodique",
  ],
  prerequisites: [
    "Scanner un réseau de façon éthique",
    "DNS : la résolution de noms",
  ],
  sections: [
    sec("Deux niveaux de visibilité", [
      list(
        "- **Capture complète** (pcap, Wireshark) : tout le contenu des paquets, très détaillé mais volumineux.\n"
        "- **Métadonnées** (NetFlow, journaux de pare-feu, DNS) : qui parle à qui, combien, quand. Léger, conservable longtemps.",
      ),
    ]),
    sec("Signaux faibles", [
      list(
        "- **Balisage** : connexions très régulières (toutes les 60 s) vers la même adresse, signe d'un malware qui contacte son serveur.\n"
        "- **Volumes anormaux** : un poste qui envoie beaucoup plus qu'il ne reçoit.\n"
        "- **DNS étrange** : noms longs et aléatoires, nombreux types TXT, domaines tout récents.\n"
        "- **Horaires** : trafic important à 3 h du matin depuis un poste de bureau.\n"
        "- **Ports inhabituels** : SSH sortant depuis un serveur web.",
      ),
    ]),
    sec("Méthode", [
      text(
        "Partez de la vue d'ensemble (statistiques, principaux interlocuteurs), "
        "retirez le bruit connu (ARP, mises à jour), puis zoomez sur ce qui "
        "reste. Notez chaque observation avec l'heure et les adresses : c'est "
        "la base du rapport.",
      ),
      tip(
        "Entraînez-vous dans le Lab : onglet Réseau, puis Capture (9 "
        "exercices de filtrage) et Analyse (4 scénarios).",
      ),
    ]),
  ],
  commonMistakes: [
    "Plonger dans les paquets sans vue d'ensemble",
    "Ignorer le DNS, souvent le premier signe d'une compromission",
  ],
  summary:
      "Capture complète pour le détail, métadonnées pour la durée. Signaux "
      "faibles : balisage régulier, volumes sortants, DNS aléatoire, horaires "
      "et ports inhabituels. Du général au particulier.",
  quiz: [
    q(const [
      'q1',
      "Des connexions vers la même adresse exactement toutes les 60 secondes évoquent...",
      'qcm',
      "Un balisage de malware|Une mise à jour normale|Un scan de ports|Une panne",
      '0',
      "La régularité mécanique est typique d'un malware qui contacte son serveur.",
    ]),
    q(const [
      'q2',
      "Quel signe peut révéler un tunnel DNS ?",
      'qcm',
      "Des noms de domaine longs et aléatoires|Des requêtes vers le DNS de l'entreprise|Un ping vers 8.8.8.8|Une adresse IPv6",
      '0',
      "Les données sont encodées dans les noms demandés.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : NetFlow contient le contenu complet des paquets.",
      'tf',
      'Faux',
      null,
      "NetFlow ne garde que des métadonnées : adresses, ports, volumes, horaires.",
    ]),
  ],
  exercises: [
    ex(
      "Tunnel DNS",
      "Dans le Lab (Réseau, puis Capture), isolez les requêtes vers "
          "exfil.example.net, puis décodez un sous-domaine dans le terminal avec "
          "base64 -d. Que contenait-il ?",
    ),
  ],
);

Course _hardening() => Course(
  id: 'ns-hardening',
  title: 'Durcir un réseau',
  category: _cat,
  level: _level,
  levelNumber: 5,
  objectives: [
    "Réduire la surface d'attaque",
    "Sécuriser l'administration à distance",
    "Construire une liste de contrôle de durcissement",
  ],
  prerequisites: [
    "Le pare-feu en pratique",
    "Analyser le trafic et repérer les signaux faibles",
  ],
  sections: [
    sec("Réduire la surface d'attaque", [
      list(
        "- Désactiver les services et protocoles inutiles (Telnet, FTP, SMBv1).\n"
        "- Changer les mots de passe par défaut des équipements.\n"
        "- Appliquer les mises à jour, en priorité sur ce qui est exposé.\n"
        "- Inventorier : on ne protège pas ce qu'on ne connaît pas.",
      ),
    ]),
    sec("Administration à distance", [
      code(
        "# /etc/ssh/sshd_config\n"
        "PermitRootLogin no\n"
        "PasswordAuthentication no\n"
        "AllowUsers admin\n"
        "MaxAuthTries 3",
        label: "SSH durci",
      ),
      text(
        "L'administration passe par un réseau dédié ou un bastion, jamais "
        "directement depuis Internet. L'authentification multifacteur est "
        "exigée pour les comptes à privilèges.",
      ),
    ]),
    sec("Surveiller et vérifier", [
      text(
        "Centralisez les journaux (pare-feu, DNS, serveurs) dans un SIEM, "
        "vérifiez les sauvegardes, et rejouez régulièrement un scan de vos "
        "propres réseaux pour détecter les dérives.",
      ),
      tip(
        "Les guides de l'ANSSI (hygiène informatique, recommandations de "
        "configuration) sont une excellente base de liste de contrôle.",
      ),
    ]),
  ],
  commonMistakes: [
    "Laisser les identifiants par défaut d'une caméra ou d'une imprimante",
    "Exposer SSH ou RDP directement sur Internet",
    "Durcir une fois puis ne plus jamais vérifier",
  ],
  summary:
      "Moins de services, pas d'identifiants par défaut, mises à jour, "
      "administration via un bastion avec MFA, journaux centralisés et "
      "contrôles réguliers.",
  quiz: [
    q(const [
      'q1',
      "Quelle directive SSH interdit la connexion directe du compte root ?",
      'qcm',
      "PermitRootLogin no|AllowRoot false|RootSSH off|DenyRoot yes",
      '0',
      "PermitRootLogin no oblige à se connecter avec un compte nominatif.",
    ]),
    q(const [
      'q2',
      "Pourquoi désactiver Telnet ?",
      'qcm',
      "Il transmet tout en clair, mots de passe compris|Il est trop lent pour administrer un serveur moderne|Il ne fonctionne que sur le réseau local|Il exige un certificat payant pour chaque serveur",
      '0',
      "SSH le remplace avec un canal chiffré.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : on ne peut pas protéger correctement ce qu'on n'a pas inventorié.",
      'tf',
      'Vrai',
      null,
      "L'inventaire est la première étape de tout durcissement.",
    ]),
  ],
  exercises: [
    ex(
      "Durcir le SSH du lab",
      "Dans le terminal du Lab : grep -i root /etc/ssh/sshd_config. Listez "
          "les directives à modifier et la valeur recommandée pour chacune.",
    ),
  ],
);
