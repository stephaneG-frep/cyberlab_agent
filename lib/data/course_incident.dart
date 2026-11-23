import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

/// Niveau 8 - Réponse à incident et forensic.
List<Course> incidentCourses() => [
  _cycle(),
  _triage(),
  _containment(),
  _evidence(),
  _logs(),
  _timeline(),
  _ioc(),
  _report(),
];

const _level = 'Niveau 8 - Réponse à incident';
const _cat = 'incident_response';

Course _cycle() => Course(
  id: 'ir-cycle',
  title: 'Le cycle de réponse à incident',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Connaître les phases de la réponse à incident",
    "Comprendre pourquoi la préparation est décisive",
    "Savoir qui intervient pendant un incident",
  ],
  prerequisites: ["Le SOC (Security Operations Center)"],
  sections: [
    sec("Les phases", [
      code(
        "1. Préparation\n"
        "2. Détection et analyse\n"
        "3. Confinement, éradication et restauration\n"
        "4. Retour d'expérience",
        label: "Modèle classique (NIST SP 800-61)",
      ),
      text(
        "Ces phases ne sont pas strictement linéaires : une nouvelle "
        "découverte pendant l'éradication peut renvoyer à l'analyse.",
      ),
    ]),
    sec("La préparation", [
      list(
        "- Un plan de réponse écrit, connu et testé.\n"
        "- Des contacts à jour : direction, juridique, communication, CERT, assureur.\n"
        "- Des journaux centralisés et conservés assez longtemps.\n"
        "- Des sauvegardes hors ligne testées.\n"
        "- Des exercices réguliers (simulations sur table).",
      ),
      tip(
        "Le pire moment pour chercher le numéro du prestataire de réponse à "
        "incident, c'est pendant l'incident.",
      ),
    ]),
    sec("Qui fait quoi ?", [
      text(
        "Un incident sérieux mobilise une cellule de crise : un responsable "
        "qui décide, des techniciens qui analysent et contiennent, et des "
        "personnes chargées du juridique et de la communication. Tout est "
        "noté dans un journal de bord horodaté.",
      ),
    ]),
  ],
  commonMistakes: [
    "Improviser faute de plan écrit",
    "Restaurer les systèmes avant d'avoir compris comment l'attaquant est entré",
    "Sauter le retour d'expérience",
  ],
  summary:
      "Préparation, détection et analyse, confinement-éradication-"
      "restauration, retour d'expérience. Un plan testé, des contacts à jour "
      "et un journal de bord font la différence.",
  quiz: [
    q(const [
      'q1',
      "Quelle phase vient en premier dans la réponse à incident ?",
      'qcm',
      "La préparation|Le confinement|L'éradication|Le retour d'expérience",
      '0',
      "Tout se joue avant l'incident : plan, contacts, journaux, sauvegardes.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : on peut restaurer les systèmes avant de savoir comment l'attaquant est entré.",
      'tf',
      'Faux',
      null,
      "Sans corriger le point d'entrée, l'attaquant reviendra par le même chemin.",
    ]),
    q(const [
      'q3',
      "À quoi sert le journal de bord pendant un incident ?",
      'qcm',
      "Garder une trace horodatée des constats et des décisions|Remplacer les journaux système|Prévenir les clients automatiquement|Rien",
      '0',
      "Il sert à la coordination, au rapport et parfois à la justice.",
    ]),
  ],
  exercises: [
    ex(
      "Fiche réflexe",
      "Rédigez une fiche d'une page : qui appeler, dans quel ordre, et les 5 "
          "premières actions en cas de rançongiciel.",
    ),
  ],
);

Course _triage() => Course(
  id: 'ir-triage',
  title: 'Détecter et qualifier un incident',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Distinguer événement, alerte et incident",
    "Évaluer la gravité et l'urgence",
    "Savoir quand escalader",
  ],
  prerequisites: ["Le cycle de réponse à incident"],
  sections: [
    sec("Événement, alerte, incident", [
      list(
        "- **Événement** : tout ce qui est journalisé (une connexion, un fichier ouvert).\n"
        "- **Alerte** : un événement jugé suspect par un outil ou une personne.\n"
        "- **Incident** : une atteinte confirmée ou très probable à la confidentialité, l'intégrité ou la disponibilité.",
      ),
    ]),
    sec("Qualifier", [
      text(
        "Pour chaque alerte, l'analyste répond à quelques questions : est-ce "
        "réel ? Qu'est-ce qui est touché ? L'attaque est-elle en cours ? "
        "Quelles données ou quels services sont en jeu ? La gravité dépend de "
        "l'impact et de la sensibilité des actifs.",
      ),
      tip(
        "Le simulateur SOC du Lab entraîne exactement ce réflexe : une "
        "gravité, puis une décision (clôturer, surveiller, investiguer, "
        "contenir).",
      ),
    ]),
    sec("Escalader", [
      text(
        "On escalade dès que l'impact dépasse son périmètre : données "
        "personnelles exposées, systèmes critiques touchés, rançongiciel, "
        "compte à privilèges compromis. Mieux vaut escalader à tort que trop "
        "tard.",
      ),
    ]),
  ],
  commonMistakes: [
    "Traiter chaque alerte isolément sans chercher de lien",
    "Attendre une certitude absolue avant d'escalader",
  ],
  summary:
      "Événement → alerte → incident. On qualifie par l'impact et la "
      "sensibilité, et on escalade tôt quand des données, des systèmes "
      "critiques ou des comptes à privilèges sont en jeu.",
  quiz: [
    q(const [
      'q1',
      "Une connexion réussie journalisée, sans rien de suspect, est...",
      'qcm',
      "Un événement|Un incident|Une alerte critique|Une compromission",
      '0',
      "Tout ce qui est journalisé est un événement ; il ne devient alerte que s'il est suspect.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : il vaut mieux escalader à tort que trop tard.",
      'tf',
      'Vrai',
      null,
      "Un retard d'escalade peut transformer un incident maîtrisable en crise.",
    ]),
    q(const [
      'q3',
      "Lequel de ces cas justifie une escalade immédiate ?",
      'qcm',
      "Un compte administrateur compromis|Un scan bloqué par le pare-feu|Une mise à jour planifiée|Un mot de passe mal saisi",
      '0',
      "Un compte à privilèges compromis met tout le système en danger.",
    ]),
  ],
  exercises: [
    ex(
      "S'entraîner au tri",
      "Dans le Lab, onglet SOC : qualifiez 5 alertes et notez pour chacune "
          "la question qui vous a permis de décider.",
    ),
  ],
);

Course _containment() => Course(
  id: 'ir-containment',
  title: 'Contenir sans détruire les preuves',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Choisir une mesure de confinement adaptée",
    "Comprendre pourquoi il ne faut pas éteindre une machine à la hâte",
    "Enchaîner éradication et restauration",
  ],
  prerequisites: ["Détecter et qualifier un incident"],
  sections: [
    sec("Isoler, pas éteindre", [
      text(
        "Éteindre une machine efface sa mémoire vive : processus malveillants, "
        "connexions en cours, clés de chiffrement. On préfère l'isoler du "
        "réseau (câble débranché, VLAN de quarantaine, isolement par l'EDR) "
        "en la laissant allumée, le temps de collecter les preuves volatiles.",
      ),
      warn(
        "Exception : face à un rançongiciel qui chiffre activement, couper "
        "vite peut sauver des données. La décision se prend en connaissance "
        "de cause et se note dans le journal de bord.",
      ),
    ]),
    sec("Mesures de confinement", [
      list(
        "- Isoler les machines touchées.\n"
        "- Désactiver les comptes compromis, révoquer leurs sessions et jetons.\n"
        "- Bloquer les adresses et domaines malveillants (pare-feu, DNS).\n"
        "- Couper un partage réseau ou un service exposé.",
      ),
    ]),
    sec("Éradication et restauration", [
      text(
        "Une fois le périmètre compris : supprimer les accès de l'attaquant "
        "(comptes, clés SSH, tâches planifiées, web shells), corriger la "
        "faille d'entrée, puis reconstruire depuis une source saine et "
        "restaurer les données depuis des sauvegardes vérifiées. On surveille "
        "ensuite de près pour détecter un retour.",
      ),
    ]),
  ],
  commonMistakes: [
    "Éteindre la machine, et perdre toute la mémoire vive",
    "Nettoyer un seul symptôme (un fichier) sans chercher la persistance",
    "Restaurer depuis une sauvegarde déjà compromise",
  ],
  summary:
      "Isoler plutôt qu'éteindre, désactiver les comptes compromis, bloquer "
      "les indicateurs. Puis éradiquer la persistance, corriger la faille, "
      "reconstruire et restaurer depuis une source saine.",
  quiz: [
    q(const [
      'q1',
      "Pourquoi éviter d'éteindre une machine compromise ?",
      'qcm',
      "On perd la mémoire vive et ses preuves|Elle ne redémarrera plus|Cela prévient l'attaquant par e-mail|C'est interdit par la loi",
      '0',
      "Processus, connexions et clés n'existent qu'en mémoire.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : supprimer le fichier malveillant suffit à éradiquer une compromission.",
      'tf',
      'Faux',
      null,
      "Il faut aussi retirer la persistance (comptes, clés, tâches planifiées) et corriger l'entrée.",
    ]),
    q(const [
      'q3',
      "Quelle mesure de confinement s'applique à un compte volé ?",
      'qcm',
      "Le désactiver et révoquer ses sessions|Changer son nom d'affichage|L'ajouter au groupe administrateurs|Ne rien faire",
      '0',
      "Cela coupe immédiatement l'accès de l'attaquant.",
    ]),
  ],
  exercises: [
    ex(
      "Chercher la persistance",
      "Dans le terminal du Lab, listez les mécanismes de persistance "
          "possibles : cat /etc/crontab, cat ~/.ssh/authorized_keys. Lequel est "
          "lié au compte backup compromis ?",
    ),
  ],
);

Course _evidence() => Course(
  id: 'ir-evidence',
  title: 'Collecter les preuves',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Respecter l'ordre de volatilité",
    "Garantir l'intégrité des preuves par empreinte",
    "Tenir une chaîne de possession",
  ],
  prerequisites: [
    "Contenir sans détruire les preuves",
    "Les fonctions de hachage",
  ],
  sections: [
    sec("Ordre de volatilité", [
      code(
        "1. Mémoire vive, processus, connexions réseau\n"
        "2. Fichiers temporaires\n"
        "3. Disque\n"
        "4. Journaux distants et sauvegardes",
        label: "Du plus volatil au plus durable (d'après la RFC 3227)",
      ),
      text(
        "On collecte d'abord ce qui disparaît le plus vite. Chaque commande "
        "lancée sur la machine la modifie un peu : on privilégie des outils "
        "fiables, apportés sur un support externe, et on note tout.",
      ),
    ]),
    sec("Intégrité", [
      text(
        "On travaille sur une copie, jamais sur l'original. On calcule "
        "l'empreinte (SHA-256) de chaque élément collecté au moment de la "
        "collecte : la même empreinte plus tard prouve qu'il n'a pas changé.",
      ),
      code(
        "sha256sum logs/auth.log\n"
        "sha256sum logs/auth.log > rapports/empreintes.txt",
        label: "Dans le terminal du Lab",
      ),
    ]),
    sec("Chaîne de possession", [
      text(
        "Pour chaque preuve : qui l'a collectée, quand, comment, où elle est "
        "stockée, et chaque transfert d'une personne à une autre. Sans cette "
        "traçabilité, une preuve peut être contestée devant un juge.",
      ),
      tip(
        "En cas de dépôt de plainte, rapprochez-vous tôt des enquêteurs "
        "spécialisés et suivez leurs consignes de préservation.",
      ),
    ]),
  ],
  commonMistakes: [
    "Analyser directement le disque original",
    "Oublier de calculer les empreintes à la collecte",
    "Commencer par le disque et perdre la mémoire vive",
  ],
  summary:
      "Collecter du plus volatil au plus durable, travailler sur des copies, "
      "calculer les empreintes à la collecte et tenir la chaîne de "
      "possession.",
  quiz: [
    q(const [
      'q1',
      "Que collecte-t-on en premier ?",
      'qcm',
      "La mémoire vive et les connexions en cours|Les sauvegardes|Le disque dur|Les journaux archivés",
      '0',
      "C'est le plus volatil : tout disparaît à l'extinction.",
    ]),
    q(const [
      'q2',
      "À quoi sert l'empreinte SHA-256 d'une preuve ?",
      'qcm',
      "Prouver qu'elle n'a pas été modifiée depuis la collecte|La chiffrer|La compresser|L'anonymiser",
      '0',
      "Une empreinte identique plus tard démontre l'intégrité.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : on peut analyser le disque original pour gagner du temps.",
      'tf',
      'Faux',
      null,
      "On travaille sur une copie pour ne pas altérer l'original.",
    ]),
  ],
  exercises: [
    ex(
      "Empreintes de preuves",
      "Dans le terminal du Lab : calculez l'empreinte de logs/auth.log et de "
          "logs/access.log, et enregistrez-les dans rapports/empreintes.txt.",
    ),
  ],
);

Course _logs() => Course(
  id: 'ir-logs',
  title: 'Analyser les journaux',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Savoir quels journaux consulter",
    "Corréler plusieurs sources",
    "Se méfier des fuseaux horaires",
  ],
  prerequisites: ["Collecter les preuves", "Les journaux Linux (logs)"],
  sections: [
    sec("Quels journaux ?", [
      list(
        "- **Authentification** : /var/log/auth.log, journaux Windows (événements 4624, 4625).\n"
        "- **Web** : access.log, error.log.\n"
        "- **Système** : syslog, journald.\n"
        "- **Réseau** : pare-feu, DNS, proxy, VPN.\n"
        "- **Sécurité** : EDR, antivirus, IDS.",
      ),
    ]),
    sec("Corréler", [
      text(
        "Une source seule raconte une partie de l'histoire. L'IP qui a forcé "
        "SSH (auth.log) a-t-elle aussi testé le site web (access.log) ? A-t-"
        "elle été bloquée par le pare-feu (syslog) ? La corrélation transforme "
        "des indices en scénario.",
      ),
      code(
        "grep 203.0.113.7 ~/logs/auth.log\n"
        "grep 203.0.113.7 ~/logs/access.log\n"
        "sudo grep 203.0.113.7 /var/log/syslog",
        label: "Une IP, trois journaux (terminal du Lab)",
      ),
    ]),
    sec("Le piège de l'heure", [
      warn(
        "Des serveurs en UTC, d'autres en heure locale, des horloges "
        "désynchronisées : sans précaution, la chronologie est fausse. "
        "Synchronisez les horloges (NTP) et convertissez tout en UTC pour "
        "l'analyse.",
      ),
    ]),
  ],
  commonMistakes: [
    "Analyser une seule source de journaux",
    "Mélanger des horodatages de fuseaux différents",
    "Ne conserver les journaux que quelques jours",
  ],
  summary:
      "Authentification, web, système, réseau, sécurité : on corrèle les "
      "sources autour d'un indicateur (une IP, un compte) et on aligne tout "
      "sur une même heure (UTC).",
  quiz: [
    q(const [
      'q1',
      "Que signifie corréler des journaux ?",
      'qcm',
      "Relier des événements de plusieurs sources|Supprimer les doublons|Chiffrer les journaux|Les compresser",
      '0',
      "Croiser auth.log, access.log et le pare-feu reconstitue le scénario.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : des serveurs dans des fuseaux horaires différents peuvent fausser une chronologie.",
      'tf',
      'Vrai',
      null,
      "On convertit tout en UTC et on synchronise les horloges avec NTP.",
    ]),
    q(const [
      'q3',
      "Dans quel fichier Linux trouve-t-on les connexions SSH ?",
      'qcm',
      "/var/log/auth.log|/etc/passwd|/var/www/html/index.html|/etc/hosts",
      '0',
      "auth.log (ou secure selon la distribution) trace les authentifications.",
    ]),
  ],
  exercises: [
    ex(
      "Suivre une IP",
      "Dans le terminal du Lab, cherchez 203.0.113.7 dans ~/logs/auth.log, "
          "~/logs/access.log et /var/log/syslog (avec sudo). Qu'a fait cette "
          "adresse dans chaque journal ?",
    ),
  ],
);

Course _timeline() => Course(
  id: 'ir-timeline',
  title: 'Construire une chronologie',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Ordonner les événements d'une attaque",
    "Identifier le premier accès et les étapes suivantes",
    "Repérer les trous d'information",
  ],
  prerequisites: ["Analyser les journaux"],
  sections: [
    sec("Pourquoi une chronologie ?", [
      text(
        "La chronologie (timeline) aligne tous les événements dans l'ordre. "
        "Elle répond aux questions clés : quand l'attaquant est-il entré, par "
        "où, qu'a-t-il fait, et est-il encore là ?",
      ),
    ]),
    sec("L'exemple du lab", [
      code(
        "06:02:45  échecs SSH « admin » depuis 203.0.113.7\n"
        "06:03:11  échecs SSH « root » depuis 203.0.113.7\n"
        "06:07:33  connexion réussie du compte backup depuis 203.0.113.7\n"
        "06:12:40  sqlmap teste le site web depuis 203.0.113.7\n"
        "toutes les 5 min  cron exécute /home/backup/sauvegarde.sh",
        label: "Chronologie reconstituée",
      ),
      text(
        "Lecture : force brute, réussite sur un compte de service au mot de "
        "passe faible, reconnaissance du site, et une tâche planifiée du "
        "compte compromis qui offre une persistance potentielle.",
      ),
    ]),
    sec("Les trous", [
      text(
        "Une chronologie révèle aussi ce qu'on ne sait pas : que s'est-il "
        "passé entre 06:07 et 06:12 ? Ces trous orientent la suite de "
        "l'enquête (autres journaux, analyse de la machine).",
      ),
      tip(
        "Notez la source de chaque ligne : une chronologie dont on ne peut "
        "pas vérifier les éléments perd sa valeur.",
      ),
    ]),
  ],
  commonMistakes: [
    "Ne pas citer la source de chaque événement",
    "S'arrêter au premier accès sans chercher la suite",
  ],
  summary:
      "La chronologie ordonne les événements de toutes les sources, avec leur "
      "origine, pour identifier le premier accès, les étapes suivantes et les "
      "zones d'ombre à creuser.",
  quiz: [
    q(const [
      'q1',
      "Dans la chronologie du lab, quel compte l'attaquant a-t-il réussi à utiliser ?",
      'qcm',
      "backup|root|admin|learner",
      '0',
      "06:07:33 : Accepted password for backup from 203.0.113.7.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : une chronologie sert aussi à repérer ce qu'on ignore encore.",
      'tf',
      'Vrai',
      null,
      "Les trous entre deux événements orientent l'enquête.",
    ]),
    q(const [
      'q3',
      "Que faut-il noter pour chaque ligne de la chronologie ?",
      'qcm',
      "La source de l'information|La couleur de l'alerte|Le nom de l'analyste uniquement|Rien de plus que l'heure",
      '0',
      "Sans source, l'événement ne peut pas être vérifié.",
    ]),
  ],
  exercises: [
    ex(
      "Votre chronologie",
      "Avec les journaux du terminal du Lab, reconstituez la chronologie de "
          "l'attaque de 203.0.113.7 dans rapports/chronologie.txt, une ligne par "
          "événement avec l'heure et la source.",
    ),
  ],
);

Course _ioc() => Course(
  id: 'ir-ioc',
  title: 'Indicateurs de compromission',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Savoir ce qu'est un IOC",
    "Comprendre la pyramide de la douleur",
    "Utiliser MITRE ATT&CK pour décrire un comportement",
  ],
  prerequisites: ["Construire une chronologie"],
  sections: [
    sec("Les indicateurs", [
      list(
        "- Adresses IP et noms de domaine malveillants\n"
        "- Empreintes de fichiers (SHA-256)\n"
        "- URL, noms de fichiers, clés de registre\n"
        "- Comptes ou clés SSH ajoutés",
      ),
      text(
        "Un IOC permet de chercher la même menace ailleurs : sur les autres "
        "machines, dans les journaux passés, et chez les partenaires grâce au "
        "partage (plateformes comme MISP, bulletins du CERT-FR).",
      ),
    ]),
    sec("La pyramide de la douleur", [
      code(
        "Comportements (TTP)    ← très coûteux à changer pour l'attaquant\n"
        "Outils\n"
        "Artefacts réseau et système\n"
        "Noms de domaine\n"
        "Adresses IP\n"
        "Empreintes de fichiers ← changent en un instant",
        label: "Du plus utile au plus fragile",
      ),
      text(
        "Bloquer une empreinte ou une IP gêne peu l'attaquant : il en change "
        "aussitôt. Détecter ses comportements (tactiques, techniques et "
        "procédures) l'oblige à changer sa façon de travailler.",
      ),
    ]),
    sec("MITRE ATT&CK", [
      text(
        "ATT&CK catalogue les techniques des attaquants avec un identifiant "
        "(T1110 pour la force brute, T1053.003 pour cron). Il donne un "
        "vocabulaire commun pour décrire une attaque et vérifier ce que l'on "
        "sait détecter.",
      ),
    ]),
  ],
  commonMistakes: [
    "Se contenter de bloquer des IP",
    "Partager des IOC sans contexte (date, confiance, source)",
  ],
  summary:
      "Un IOC (IP, domaine, empreinte) aide à chercher la menace ailleurs, "
      "mais les comportements (TTP) sont plus durables à détecter. ATT&CK "
      "fournit le vocabulaire commun.",
  quiz: [
    q(const [
      'q1',
      "D'après la pyramide de la douleur, que l'attaquant change-t-il le plus facilement ?",
      'qcm',
      "Les empreintes de fichiers|Ses comportements (TTP)|Ses outils|Ses méthodes de travail",
      '0',
      "Recompiler un fichier change son empreinte en un instant.",
    ]),
    q(const [
      'q2',
      "Quel identifiant ATT&CK correspond à la force brute ?",
      'qcm',
      "T1110|T1486|T1566|T1053",
      '0',
      "T1110 Brute Force ; T1486 est le chiffrement pour impact (rançongiciel).",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : partager des IOC avec d'autres organisations aide à détecter plus vite la même menace.",
      'tf',
      'Vrai',
      null,
      "C'est le principe des plateformes de partage comme MISP.",
    ]),
  ],
  exercises: [
    ex(
      "Lister les IOC du lab",
      "À partir des journaux du terminal et de la capture Wireshark du Lab, "
          "listez les IOC (IP, domaines, outils) et associez une technique "
          "ATT&CK à chaque comportement observé.",
    ),
  ],
);

Course _report() => Course(
  id: 'ir-report',
  title: 'Rapport et retour d\'expérience',
  category: _cat,
  level: _level,
  levelNumber: 8,
  objectives: [
    "Structurer un rapport d'incident",
    "Connaître l'obligation de notification RGPD",
    "Mener un retour d'expérience utile",
  ],
  prerequisites: ["Indicateurs de compromission"],
  sections: [
    sec("Le rapport", [
      list(
        "- **Résumé** pour la direction : quoi, quand, impact, état actuel.\n"
        "- **Chronologie** détaillée, avec les sources.\n"
        "- **Périmètre** : systèmes, comptes et données touchés.\n"
        "- **Actions menées** : confinement, éradication, restauration.\n"
        "- **IOC** et techniques observées.\n"
        "- **Recommandations** classées par priorité.",
      ),
    ]),
    sec("Notifier", [
      text(
        "En cas de violation de données personnelles présentant un risque "
        "pour les personnes, le RGPD (article 33) impose de notifier "
        "l'autorité de contrôle (la CNIL en France) dans les 72 heures après "
        "en avoir pris connaissance, si possible. Les personnes concernées "
        "doivent aussi être informées si le risque est élevé.",
      ),
      warn(
        "Le délai court dès la découverte : le juridique doit être associé "
        "tôt, pas une fois l'analyse terminée.",
      ),
    ]),
    sec("Le retour d'expérience", [
      text(
        "Quelques semaines après, on réunit les acteurs sans chercher de "
        "coupable : qu'est-ce qui a bien marché, qu'est-ce qui a manqué, "
        "qu'est-ce qu'on change ? Chaque action a un responsable et une "
        "échéance, sinon rien ne change.",
      ),
    ]),
  ],
  commonMistakes: [
    "Un rapport uniquement technique, illisible pour la direction",
    "Associer le juridique trop tard pour respecter les 72 heures",
    "Un retour d'expérience qui cherche un coupable",
  ],
  summary:
      "Rapport : résumé, chronologie, périmètre, actions, IOC, "
      "recommandations. RGPD : notification à la CNIL sous 72 heures si "
      "risque pour les personnes. Retour d'expérience sans reproche, avec "
      "des actions suivies.",
  quiz: [
    q(const [
      'q1',
      "Sous quel délai le RGPD impose-t-il de notifier une violation de données à l'autorité, si possible ?",
      'qcm',
      "72 heures|24 heures|7 jours|30 jours",
      '0',
      "Article 33 du RGPD : 72 heures après en avoir pris connaissance.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : un bon retour d'expérience cherche avant tout le responsable de l'erreur.",
      'tf',
      'Faux',
      null,
      "Sans reproche : on cherche à améliorer, sinon les gens cachent les problèmes.",
    ]),
    q(const [
      'q3',
      "À qui s'adresse le résumé en tête du rapport ?",
      'qcm',
      "À la direction et aux décideurs|Aux attaquants|Uniquement aux techniciens|Aux clients",
      '0',
      "Il doit être compréhensible sans connaissances techniques.",
    ]),
  ],
  exercises: [
    ex(
      "Compléter le rapport du lab",
      "Dans le terminal du Lab : cat documents/rapport_incident.md. Complétez "
          "ce brouillon avec la chronologie, le compte compromis et trois "
          "recommandations.",
    ),
  ],
);
