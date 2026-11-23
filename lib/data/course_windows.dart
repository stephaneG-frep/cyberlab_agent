import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

/// Niveau 9 - Windows et Active Directory (angle défensif).
List<Course> windowsCourses() => [
  _basics(),
  _powershell(),
  _events(),
  _accounts(),
  _ad(),
  _kerberos(),
  _adAttacks(),
  _hardening(),
];

const _level = 'Niveau 9 - Windows et Active Directory';
const _cat = 'windows';

Course _basics() => Course(
  id: 'win-basics',
  title: 'Windows pour la cybersécurité',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Connaître les éléments clés de la sécurité Windows",
    "Comprendre le rôle de l'UAC, de NTFS et du registre",
    "Situer Windows face à Linux",
  ],
  prerequisites: ["Le système d'exploitation", "Les permissions d'accès"],
  sections: [
    sec("Les briques", [
      list(
        "- **Comptes** locaux ou de domaine, identifiés par un SID.\n"
        "- **NTFS** : permissions fines (lecture, écriture, modification, contrôle total) par utilisateur ou groupe.\n"
        "- **Registre** : base de configuration du système et des logiciels.\n"
        "- **Services** : programmes lancés en arrière-plan, souvent avec des droits élevés.\n"
        "- **UAC** : même un administrateur travaille avec des droits limités et doit confirmer les élévations.",
      ),
    ]),
    sec("Lieux à surveiller", [
      code(
        r"HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
        "\n"
        r"HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
        "\n"
        r"%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
        "\n"
        "Tâches planifiées et services",
        label: "Emplacements de démarrage automatique (persistance)",
      ),
      text(
        "Les malwares cherchent à se relancer à chaque démarrage. Ces "
        "emplacements sont les premiers à examiner lors d'une investigation "
        "(l'outil Autoruns de Sysinternals les liste tous).",
      ),
    ]),
    sec("Windows et Linux", [
      text(
        "Les concepts se retrouvent : comptes et groupes, permissions, "
        "services et démons, journaux. Les noms et les outils changent : "
        "Observateur d'événements au lieu de /var/log, PowerShell au lieu de "
        "Bash, GPO pour configurer un parc entier.",
      ),
    ]),
  ],
  commonMistakes: [
    "Travailler au quotidien avec un compte administrateur",
    "Désactiver l'UAC parce que les confirmations agacent",
  ],
  summary:
      "Comptes et SID, permissions NTFS, registre, services, UAC. Les clés Run "
      "et les tâches planifiées sont des lieux de persistance à surveiller.",
  quiz: [
    q(const [
      'q1',
      "À quoi sert l'UAC ?",
      'qcm',
      "Faire travailler même les administrateurs avec des droits limités par défaut|Chiffrer le disque|Bloquer les sites web|Sauvegarder le registre",
      '0',
      "Les élévations de privilèges doivent être confirmées.",
    ]),
    q(const [
      'q2',
      "Pourquoi les clés de registre « Run » intéressent-elles les enquêteurs ?",
      'qcm',
      "Elles lancent des programmes à chaque ouverture de session|Elles contiennent les mots de passe|Elles stockent les e-mails|Elles gèrent l'imprimante",
      '0',
      "C'est un mécanisme de persistance très utilisé par les malwares.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : il est recommandé d'utiliser un compte administrateur pour le travail quotidien.",
      'tf',
      'Faux',
      null,
      "Moindre privilège : un compte standard au quotidien, un compte admin séparé si besoin.",
    ]),
  ],
  exercises: [
    ex(
      "Explorer son démarrage",
      "Sur votre propre PC Windows, ouvrez le Gestionnaire des tâches, onglet "
          "Démarrage : identifiez chaque programme et désactivez ceux qui sont "
          "inutiles.",
    ),
  ],
);

Course _powershell() => Course(
  id: 'win-powershell',
  title: 'PowerShell pour la défense',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Utiliser les cmdlets de base",
    "Comprendre le pipeline d'objets",
    "Savoir pourquoi les attaquants aiment PowerShell, et comment le surveiller",
  ],
  prerequisites: ["Windows pour la cybersécurité"],
  sections: [
    sec("Les cmdlets", [
      code(
        "Get-Process | Sort-Object CPU -Descending | Select-Object -First 5\n"
        "Get-Service | Where-Object Status -eq 'Running'\n"
        "Get-LocalUser\n"
        "Get-NetTCPConnection -State Established\n"
        "Get-WinEvent -LogName Security -MaxEvents 20",
        label: "PowerShell",
      ),
      text(
        "Les commandes suivent le modèle Verbe-Nom. Contrairement à Bash, le "
        "pipeline transporte des objets avec leurs propriétés, pas du texte : "
        "on filtre avec Where-Object et on choisit les colonnes avec "
        "Select-Object.",
      ),
    ]),
    sec("Une arme à double tranchant", [
      text(
        "PowerShell est présent partout et peut tout faire : les attaquants "
        "l'utilisent pour télécharger et exécuter du code en mémoire, souvent "
        "avec une commande encodée en Base64 (-EncodedCommand) pour la "
        "masquer.",
      ),
      warn(
        "La politique d'exécution (ExecutionPolicy) n'est pas une barrière de "
        "sécurité : elle évite les erreurs, mais se contourne facilement.",
      ),
    ]),
    sec("Surveiller PowerShell", [
      list(
        "- Activer la journalisation des blocs de script (événement 4104).\n"
        "- Activer la journalisation des modules et la transcription.\n"
        "- Laisser l'AMSI actif : il permet à l'antivirus d'inspecter les scripts.\n"
        "- Alerter quand Word, Excel ou un navigateur lance PowerShell.",
      ),
    ]),
  ],
  commonMistakes: [
    "Croire que l'ExecutionPolicy empêche l'exécution de scripts malveillants",
    "Ne pas journaliser PowerShell sur les postes et serveurs",
  ],
  summary:
      "Cmdlets Verbe-Nom et pipeline d'objets. Très utilisé par les "
      "attaquants (commandes encodées, exécution en mémoire) : journalisation "
      "des blocs de script (4104), AMSI et alertes sur les processus parents "
      "inhabituels.",
  quiz: [
    q(const [
      'q1',
      "Que transporte le pipeline PowerShell ?",
      'qcm',
      "Des objets|Uniquement du texte|Des fichiers zip|Des paquets réseau",
      '0',
      "On manipule directement les propriétés (Name, CPU, Status...).",
    ]),
    q(const [
      'q2',
      "Quel événement journalise le contenu des scripts PowerShell exécutés ?",
      'qcm',
      "4104|4624|7045|1102",
      '0',
      "4104 : journalisation des blocs de script.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : l'ExecutionPolicy est une protection solide contre les scripts malveillants.",
      'tf',
      'Faux',
      null,
      "Elle se contourne facilement ; ce n'est pas une frontière de sécurité.",
    ]),
  ],
  exercises: [
    ex(
      "Décoder une commande",
      "Une alerte montre powershell -EncodedCommand suivi de Base64. "
          "PowerShell encode en UTF-16 : décrivez comment vous la décoderiez sans "
          "l'exécuter. Revoyez aussi l'alerte « PowerShell lancé par Word » du "
          "simulateur SOC.",
    ),
  ],
);

Course _events() => Course(
  id: 'win-events',
  title: 'Les journaux d\'événements Windows',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Connaître les identifiants d'événements essentiels",
    "Repérer force brute, création de compte et effacement de journaux",
    "Comprendre l'apport de Sysmon",
  ],
  prerequisites: ["PowerShell pour la défense", "Analyser les journaux"],
  sections: [
    sec("Les événements à connaître", [
      code(
        "4624  ouverture de session réussie\n"
        "4625  échec d'ouverture de session\n"
        "4672  privilèges spéciaux attribués (session administrateur)\n"
        "4688  création de processus\n"
        "4720  compte utilisateur créé\n"
        "4728/4732  membre ajouté à un groupe de sécurité\n"
        "4740  compte verrouillé\n"
        "7045  nouveau service installé (journal Système)\n"
        "1102  journal de sécurité effacé",
        label: "Journal Sécurité (sauf 7045)",
      ),
    ]),
    sec("Lire les signaux", [
      list(
        "- Rafale de 4625 sur un compte : force brute ; sur des centaines de comptes : pulvérisation de mots de passe.\n"
        "- 4720 puis 4732 (ajout aux administrateurs) en pleine nuit : compte dérobé.\n"
        "- 7045 avec un service au nom étrange : persistance ou mouvement latéral.\n"
        "- 1102 : quelqu'un efface ses traces.",
      ),
      code(
        "Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 50",
        label: "Lister les échecs de connexion",
      ),
    ]),
    sec("Aller plus loin avec Sysmon", [
      text(
        "Sysmon (Sysinternals) enrichit la journalisation : création de "
        "processus avec la ligne de commande complète et l'empreinte du "
        "fichier (événement 1), connexions réseau (3), et bien d'autres. "
        "Envoyés vers un SIEM, ces journaux sont la base de la détection.",
      ),
      tip(
        "Centralisez les journaux : un attaquant qui efface le journal local "
        "(1102) ne peut pas effacer la copie déjà envoyée au SIEM.",
      ),
    ]),
  ],
  commonMistakes: [
    "Garder les journaux uniquement sur la machine",
    "Ne pas activer l'audit des créations de processus",
  ],
  summary:
      "4624/4625 (connexions), 4672 (admin), 4688 (processus), 4720/4732 "
      "(comptes et groupes), 7045 (service), 1102 (effacement). Sysmon "
      "enrichit, le SIEM centralise.",
  quiz: [
    q(const [
      'q1',
      "Quel identifiant correspond à un échec d'ouverture de session ?",
      'qcm',
      "4625|4624|4720|7045",
      '0',
      "4624 est la réussite, 4625 l'échec.",
    ]),
    q(const [
      'q2',
      "Que signale l'événement 1102 ?",
      'qcm',
      "L'effacement du journal de sécurité|Une mise à jour Windows|Un nouvel utilisateur|Une connexion réussie",
      '0',
      "C'est souvent le signe d'un attaquant qui efface ses traces.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : des centaines de 4625 sur des comptes différents, depuis une même source, évoquent une pulvérisation de mots de passe.",
      'tf',
      'Vrai',
      null,
      "Peu d'essais par compte mais beaucoup de comptes : password spraying.",
    ]),
  ],
  exercises: [
    ex(
      "Associer événements et alertes",
      "Pour les alertes SOC « Pulvérisation de mots de passe » et « Journaux "
          "effacés », indiquez quels identifiants d'événements Windows vous "
          "auraient permis de les détecter.",
    ),
  ],
);

Course _accounts() => Course(
  id: 'win-accounts',
  title: 'Comptes, groupes et privilèges',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Appliquer le moindre privilège sous Windows",
    "Gérer les administrateurs locaux (LAPS)",
    "Séparer comptes standard et comptes d'administration",
  ],
  prerequisites: ["Windows pour la cybersécurité"],
  sections: [
    sec("Moindre privilège", [
      text(
        "Chaque utilisateur n'a que les droits nécessaires à son travail. Un "
        "malware lancé par un compte standard est bien plus limité que s'il "
        "tourne avec des droits d'administrateur.",
      ),
      list(
        "- Compte standard pour le travail quotidien.\n"
        "- Compte d'administration séparé, utilisé uniquement pour administrer.\n"
        "- Groupes plutôt que droits individuels, révisés régulièrement.",
      ),
    ]),
    sec("L'administrateur local", [
      text(
        "Si tous les postes partagent le même mot de passe d'administrateur "
        "local, compromettre un poste donne accès à tous les autres. LAPS "
        "(intégré à Windows) génère un mot de passe unique et changeant pour "
        "chaque poste, stocké de façon protégée dans l'annuaire.",
      ),
    ]),
    sec("Comptes de service", [
      text(
        "Les services tournent souvent avec des comptes très privilégiés et "
        "des mots de passe qui ne changent jamais. On préfère des comptes de "
        "service gérés (gMSA), dont le mot de passe long est renouvelé "
        "automatiquement, avec seulement les droits nécessaires.",
      ),
      warn(
        "Un compte de service au mot de passe faible est une cible "
        "prioritaire (voir le compte backup du lab et le Kerberoasting).",
      ),
    ]),
  ],
  commonMistakes: [
    "Le même mot de passe administrateur local sur tout le parc",
    "Des comptes de service membres des administrateurs du domaine",
    "Ne jamais réviser les membres des groupes privilégiés",
  ],
  summary:
      "Comptes standard au quotidien, comptes d'administration séparés, LAPS "
      "pour des mots de passe d'administrateur local uniques, comptes de "
      "service gérés (gMSA) aux droits limités.",
  quiz: [
    q(const [
      'q1',
      "Quel problème LAPS résout-il ?",
      'qcm',
      "Le même mot de passe administrateur local sur tous les postes|La lenteur du démarrage|Le chiffrement des e-mails|Les mises à jour",
      '0',
      "Chaque poste reçoit un mot de passe unique et renouvelé.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : il est préférable d'utiliser un compte d'administration séparé de son compte de travail quotidien.",
      'tf',
      'Vrai',
      null,
      "Le compte quotidien, exposé aux e-mails et au web, ne doit pas avoir de privilèges.",
    ]),
    q(const [
      'q3',
      "Quel type de compte convient le mieux à un service ?",
      'qcm',
      "Un compte de service géré (gMSA)|Le compte administrateur du domaine|Le compte d'un employé|Un compte sans mot de passe",
      '0',
      "Mot de passe long, renouvelé automatiquement, droits limités.",
    ]),
  ],
  exercises: [
    ex(
      "Auditer un poste",
      "Sur votre propre PC Windows, dans PowerShell : Get-LocalGroupMember "
          "Administrateurs (ou Administrators). Chaque membre est-il justifié ?",
    ),
  ],
);

Course _ad() => Course(
  id: 'win-ad',
  title: 'Active Directory : les bases',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Comprendre domaine, contrôleur de domaine et annuaire",
    "Connaître utilisateurs, groupes, unités d'organisation et GPO",
    "Savoir pourquoi AD est la cible n°1 en entreprise",
  ],
  prerequisites: ["Comptes, groupes et privilèges"],
  sections: [
    sec("L'annuaire de l'entreprise", [
      text(
        "Active Directory centralise les comptes, les ordinateurs et les "
        "droits d'une organisation. Les contrôleurs de domaine (DC) "
        "authentifient les utilisateurs et répliquent l'annuaire entre eux.",
      ),
      list(
        "- **Domaine** : périmètre d'administration (ex. corp.example).\n"
        "- **Unités d'organisation (OU)** : dossiers pour ranger comptes et machines.\n"
        "- **Groupes** : attribuer des droits à plusieurs comptes.\n"
        "- **GPO** : stratégies appliquées automatiquement aux machines et utilisateurs.",
      ),
    ]),
    sec("Les groupes sensibles", [
      code(
        "Admins du domaine (Domain Admins)\n"
        "Administrateurs de l'entreprise (Enterprise Admins)\n"
        "Administrateurs (sur les contrôleurs de domaine)\n"
        "Opérateurs de compte, de sauvegarde, de serveur",
        label: "À surveiller de très près",
      ),
    ]),
    sec("Pourquoi c'est la cible", [
      text(
        "Qui contrôle AD contrôle tout le parc : il peut créer des comptes, "
        "déployer un programme sur toutes les machines par GPO, lire tous les "
        "mots de passe hachés. Les rançongiciels visent d'abord AD pour "
        "chiffrer l'ensemble du réseau en une fois.",
      ),
      warn(
        "La compromission d'un contrôleur de domaine impose souvent une "
        "reconstruction complète de la confiance : prévention et détection "
        "précoce sont essentielles.",
      ),
    ]),
  ],
  commonMistakes: [
    "Trop de membres dans « Admins du domaine »",
    "Se connecter avec un compte Admin du domaine sur des postes ordinaires",
  ],
  summary:
      "AD centralise comptes, machines et droits ; les DC authentifient. OU, "
      "groupes et GPO organisent le parc. Le contrôler, c'est contrôler toute "
      "l'entreprise : c'est la cible prioritaire.",
  quiz: [
    q(const [
      'q1',
      "Quel serveur authentifie les utilisateurs d'un domaine Active Directory ?",
      'qcm',
      "Le contrôleur de domaine|Le serveur web|Le serveur DHCP|Le pare-feu",
      '0',
      "Les DC hébergent l'annuaire et délivrent l'authentification.",
    ]),
    q(const [
      'q2',
      "À quoi sert une GPO ?",
      'qcm',
      "Appliquer automatiquement des réglages aux machines et utilisateurs|Chiffrer le réseau|Créer un site web|Sauvegarder les e-mails",
      '0',
      "C'est aussi pourquoi un attaquant qui contrôle les GPO contrôle le parc.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : un Admin du domaine devrait se connecter sur les postes de travail ordinaires.",
      'tf',
      'Faux',
      null,
      "Ses identifiants pourraient y être volés ; il administre depuis des postes dédiés.",
    ]),
  ],
  exercises: [
    ex(
      "Cartographier",
      "Dessinez l'organisation AD d'une PME : OU par service, groupes, et les "
          "trois groupes privilégiés à surveiller en priorité.",
    ),
  ],
);

Course _kerberos() => Course(
  id: 'win-kerberos',
  title: 'Kerberos et NTLM',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Suivre le fonctionnement de Kerberos (TGT, tickets de service)",
    "Comprendre les faiblesses de NTLM",
    "Savoir ce qu'est le compte krbtgt",
  ],
  prerequisites: ["Active Directory : les bases", "Le chiffrement symétrique"],
  sections: [
    sec("Kerberos en trois temps", [
      code(
        "1. L'utilisateur s'authentifie auprès du KDC (sur le DC)\n"
        "   → il reçoit un TGT (ticket d'octroi de tickets)\n"
        "2. Avec le TGT, il demande un ticket pour un service (TGS)\n"
        "3. Il présente ce ticket au service, sans renvoyer son mot de passe",
        label: "Kerberos",
      ),
      text(
        "Les TGT sont chiffrés avec la clé du compte krbtgt : celui qui "
        "possède cette clé peut fabriquer des tickets valides pour n'importe "
        "qui (« golden ticket »). C'est pourquoi la compromission d'un DC est "
        "si grave.",
      ),
    ]),
    sec("NTLM, l'ancien", [
      text(
        "NTLM est un protocole plus ancien, encore utilisé en repli. "
        "L'empreinte NTLM d'un mot de passe suffit à s'authentifier : "
        "l'attaquant qui la vole peut la rejouer sans connaître le mot de "
        "passe (pass-the-hash).",
      ),
      list(
        "- Désactiver NTLMv1 et réduire l'usage de NTLM.\n"
        "- Activer la signature SMB et LDAP pour limiter les relais NTLM.\n"
        "- Protéger la mémoire (Credential Guard) pour éviter le vol d'empreintes.",
      ),
    ]),
    sec("Ce que voient les journaux", [
      code(
        "4768  ticket TGT demandé\n"
        "4769  ticket de service demandé\n"
        "4771  échec de pré-authentification Kerberos",
        label: "Journal Sécurité des contrôleurs de domaine",
      ),
      text(
        "Un compte qui demande en rafale des tickets de service (4769) pour "
        "de nombreux comptes de service, souvent avec un chiffrement ancien "
        "(RC4), évoque un Kerberoasting. Des 4771 en série signalent des "
        "essais de mots de passe.",
      ),
    ]),
  ],
  commonMistakes: [
    "Ne jamais changer le mot de passe du compte krbtgt",
    "Laisser NTLMv1 activé",
  ],
  summary:
      "Kerberos : TGT puis tickets de service, sans renvoyer le mot de passe. "
      "La clé krbtgt est la clé de voûte. NTLM permet le pass-the-hash : à "
      "réduire, avec signature SMB/LDAP et Credential Guard.",
  quiz: [
    q(const [
      'q1',
      "Qu'obtient l'utilisateur après son authentification Kerberos initiale ?",
      'qcm',
      "Un TGT|Un certificat TLS|Une clé SSH|Un cookie web",
      '0',
      "Le TGT sert ensuite à demander des tickets de service.",
    ]),
    q(const [
      'q2',
      "Que permet le pass-the-hash ?",
      'qcm',
      "S'authentifier avec l'empreinte NTLM sans connaître le mot de passe|Deviner un mot de passe en ligne|Chiffrer un disque|Contourner un pare-feu",
      '0',
      "L'empreinte NTLM est utilisée comme secret d'authentification.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : la clé du compte krbtgt permet de forger des tickets Kerberos valides.",
      'tf',
      'Vrai',
      null,
      "C'est le « golden ticket » ; d'où la protection absolue des DC.",
    ]),
  ],
  exercises: [
    ex(
      "Expliquer simplement",
      "Expliquez Kerberos à un collègue non technique avec l'analogie d'un "
          "parc d'attractions : bracelet d'entrée (TGT) et tickets de manège "
          "(tickets de service).",
    ),
  ],
);

Course _adAttacks() => Course(
  id: 'win-ad-attacks',
  title: 'Reconnaître les attaques courantes sur AD',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Connaître les attaques AD les plus fréquentes",
    "Savoir les détecter",
    "Connaître la parade de chacune",
  ],
  prerequisites: ["Kerberos et NTLM", "Les journaux d'événements Windows"],
  sections: [
    sec("Pour défendre, il faut connaître", [
      warn(
        "Ce cours décrit les attaques pour savoir les reconnaître et les "
        "prévenir. Les reproduire n'est permis que dans un lab personnel ou "
        "une mission autorisée par écrit.",
      ),
    ]),
    sec("Les grands classiques", [
      list(
        "- **Pulvérisation de mots de passe** : un mot de passe courant testé sur tous les comptes. Détection : 4625 sur de nombreux comptes. Parade : MFA, mots de passe interdits.\n"
        "- **Kerberoasting** : demander des tickets de service pour des comptes à SPN puis casser leur mot de passe hors ligne. Parade : gMSA ou mots de passe de 25+ caractères pour les comptes de service.\n"
        "- **Pass-the-hash** : rejouer une empreinte NTLM volée. Parade : LAPS, Credential Guard, moindre privilège.\n"
        "- **DCSync** : abuser des droits de réplication pour obtenir les empreintes de l'annuaire. Parade : surveiller qui détient ces droits, alerter sur les réplications hors DC.\n"
        "- **Abus de groupes et de délégations** : un droit oublié permet de s'ajouter à un groupe privilégié. Parade : audit régulier des droits (outils de cartographie des chemins d'attaque).",
      ),
    ]),
    sec("Penser en chemins", [
      text(
        "Un attaquant enchaîne : un poste compromis, un administrateur local "
        "commun, une session d'administrateur de domaine ouverte sur un "
        "serveur… jusqu'au DC. Le défenseur cherche à couper ces chemins, "
        "pas seulement à corriger des failles isolées.",
      ),
    ]),
  ],
  commonMistakes: [
    "Comptes de service à mot de passe court et jamais changé",
    "Ne jamais auditer qui détient des droits de réplication",
  ],
  summary:
      "Pulvérisation, Kerberoasting, pass-the-hash, DCSync, abus de droits : "
      "chacune a sa trace et sa parade. Le défenseur coupe les chemins "
      "d'attaque vers le contrôleur de domaine.",
  quiz: [
    q(const [
      'q1',
      "Quelle parade protège le mieux contre le Kerberoasting ?",
      'qcm',
      "Des mots de passe très longs ou des gMSA pour les comptes de service|Changer le nom du domaine|Désactiver le DNS|Utiliser HTTP",
      '0',
      "Un mot de passe long rend le cassage hors ligne irréaliste.",
    ]),
    q(const [
      'q2',
      "Sur quoi repose l'attaque DCSync ?",
      'qcm',
      "Les droits de réplication de l'annuaire|Un e-mail piégé|Une injection SQL|Une clé USB",
      '0',
      "L'attaquant se fait passer pour un contrôleur de domaine qui réplique.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : un défenseur doit raisonner en chemins d'attaque, pas seulement en failles isolées.",
      'tf',
      'Vrai',
      null,
      "C'est l'enchaînement de petites faiblesses qui mène au contrôle du domaine.",
    ]),
  ],
  exercises: [
    ex(
      "Tableau de détection",
      "Construisez un tableau à trois colonnes (attaque, trace dans les "
          "journaux, parade) pour les cinq attaques du cours.",
    ),
  ],
);

Course _hardening() => Course(
  id: 'win-hardening',
  title: 'Durcir Windows et Active Directory',
  category: _cat,
  level: _level,
  levelNumber: 9,
  objectives: [
    "Mettre en place un modèle d'administration par niveaux",
    "Appliquer les principales mesures de durcissement",
    "Préparer la reprise après une compromission",
  ],
  prerequisites: ["Reconnaître les attaques courantes sur AD"],
  sections: [
    sec("L'administration par niveaux", [
      code(
        "Niveau 0  contrôleurs de domaine et ce qui les administre\n"
        "Niveau 1  serveurs et applications\n"
        "Niveau 2  postes de travail",
        label: "Modèle en niveaux (tiering)",
      ),
      text(
        "Un compte d'un niveau ne se connecte jamais sur un niveau inférieur : "
        "un Admin du domaine n'ouvre pas de session sur un poste de travail, "
        "où ses identifiants pourraient être volés. L'administration se fait "
        "depuis des postes dédiés.",
      ),
    ]),
    sec("Mesures essentielles", [
      list(
        "- MFA pour les accès distants et les comptes à privilèges.\n"
        "- LAPS sur tous les postes et serveurs.\n"
        "- Désactiver SMBv1 et NTLMv1 ; signer SMB et LDAP.\n"
        "- Credential Guard et protection de LSASS.\n"
        "- Mises à jour rapides, en priorité pour les DC et les services exposés.\n"
        "- Audit et centralisation des journaux (événements clés, Sysmon).",
      ),
      tip(
        "L'ANSSI publie des recommandations détaillées pour Active Directory, "
        "et son outil ORADAD aide à évaluer la sécurité d'un annuaire.",
      ),
    ]),
    sec("Préparer le pire", [
      text(
        "Des sauvegardes hors ligne de l'annuaire et des données, une "
        "procédure de reconstruction testée, et un plan pour renouveler deux "
        "fois le mot de passe du compte krbtgt en cas de compromission du "
        "domaine.",
      ),
    ]),
  ],
  commonMistakes: [
    "Administrer les DC depuis un poste de travail ordinaire",
    "Activer la MFA partout sauf sur les comptes d'administration",
    "Ne jamais tester la restauration de l'annuaire",
  ],
  summary:
      "Administration en niveaux, postes d'administration dédiés, MFA, LAPS, "
      "fin de SMBv1/NTLMv1, Credential Guard, mises à jour et journaux "
      "centralisés. Sauvegardes hors ligne et reconstruction testée.",
  quiz: [
    q(const [
      'q1',
      "Dans le modèle en niveaux, que contient le niveau 0 ?",
      'qcm',
      "Les contrôleurs de domaine et ce qui les administre|Les postes de travail|Les imprimantes|Le Wi-Fi invités",
      '0',
      "C'est le cœur de la confiance du domaine.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : un Admin du domaine peut ouvrir une session sur n'importe quel poste de travail sans risque.",
      'tf',
      'Faux',
      null,
      "Ses identifiants pourraient y être volés : il n'utilise que des postes d'administration dédiés.",
    ]),
    q(const [
      'q3',
      "Quel protocole ancien faut-il désactiver ?",
      'qcm',
      "SMBv1|Kerberos|LDAPS|HTTPS",
      '0',
      "SMBv1 est obsolète et a été exploité massivement (WannaCry).",
    ]),
  ],
  exercises: [
    ex(
      "Plan de durcissement",
      "Classez par priorité les mesures du cours pour une PME qui n'a encore "
          "rien fait, en justifiant les trois premières.",
    ),
  ],
);
