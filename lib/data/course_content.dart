import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> fundamentalsCourses() => [
  _intro(),
  _hackerEthique(),
  _cybercriminalite(),
  _redTeam(),
  _blueTeam(),
  _pentest(),
  _soc(),
  _vulnerabilite(),
  _malware(),
  _phishing(),
  _ransomware(),
  _securiteNumerique(),
];

Course _intro() => Course(
  id: 'fund-intro',
  title: "Qu'est-ce que la cybersécurité ?",
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est la cybersécurité et pourquoi elle existe',
    'Connaître les enjeux et les grandes menaces',
    'Savoir distinguer sécurité physique et sécurité numérique',
  ],
  prerequisites: ['Aucun prérequis - parfait pour débuter !'],
  sections: [
    sec('La cybersécurité en un mot', [
      text(
        'La cybersécurité est l\'ensemble des moyens, techniques et pratiques qui protègent les systèmes informatiques, les réseaux, les programmes et les données contre les attaques, les dommages ou les accès non autorisés.',
      ),
      text(
        'Imaginez un château fort au Moyen Âge. Les murs protègent des envahisseurs, les portes contrôlent qui entre, et les coffres protègent les trésors. En numérique, vos \'murs\' sont les pare-feux, vos \'portes\' sont les mots de passe, et vos \'trésors\' sont vos données personnelles et professionnelles.',
      ),
      tip(
        'La cybersécurité, c\'est protéger ce qui compte pour vous dans le monde numérique : vos comptes, vos photos, votre argent, et parfois votre entreprise.',
      ),
    ]),
    sec('Les trois piliers (CIA)', [
      text(
        'La sécurité de l\'information repose sur trois piliers, souvent résumés par les initiales CIA (en anglais) :',
      ),
      list(
        '- **Confidentialité** : seules les personnes autorisées accèdent aux données.\n'
        '- **Intégrité** : les données ne sont pas modifiées sans autorisation.\n'
        '- **Disponibilité** : les données et services sont accessibles quand on en a besoin.',
      ),
      text(
        'Exemple : votre messagerie. Confidentialité = personne d\'autre ne lit vos emails. Intégrité = personne ne modifie vos messages en cours de route. Disponibilité = vous pouvez accéder à vos emails quand vous voulez.',
      ),
      warn(
        'Si un de ces trois piliers tombe, la sécurité est compromise. Un ransomware qui chiffre vos fichiers attaque la disponibilité et l\'intégrité. Un pirate qui vole des mots de passe attaque la confidentialité.',
      ),
    ]),
    sec('Pourquoi c\'est important ?', [
      text(
        'Aujourd\'hui, presque tout est connecté : banques, santé, transports, énergie. Une cyberattaque peut donc avoir des conséquences bien réelles sur le monde physique.',
      ),
      list(
        '- Le coût mondial de la cybercriminalité se compte en milliers de milliards par an.\n'
        '- 90% des attaques réussies commencent par une erreur humaine (phishing).\n'
        '- La majorité des incidents pourraient être évités par de bonnes pratiques de base.',
      ),
    ]),
    sec('Apprentissage, test autorisé, attaque illégale', [
      text('Il est ESSENTIEL de comprendre dès le début la différence entre :'),
      list(
        '- **Apprentissage** : vous apprenez comment fonctionnent les systèmes pour les protéger. Une compétence.\n'
        '- **Test autorisé** : vous testez un système qui VOUS appartient, ou pour lequel vous avez une autorisation écrite. Un travail légitime.\n'
        '- **Attaque illégale** : vous ciblez un système qui ne vous appartient pas, sans autorisation. Un délit, puni par la loi.',
      ),
      warn(
        'CyberLab Agent est destiné UNIQUEMENT à l\'apprentissage et aux tests sur vos propres systèmes ou des environnements autorisés (CTF, labos). Les compétences offensives s\'utilisent toujours dans ce cadre.',
      ),
    ]),
    sec('Erreurs fréquentes', [
      text(
        '- Croire que la cybersécurité = anti-virus (c\'est bien plus large).\n'
        '- Penser que seuls les grandes entreprises sont ciblées.\n'
        '- Oublier que le facteur humain est la plus grande faille.',
      ),
    ]),
  ],
  commonMistakes: [
    'Penser qu\'un antivirus suffit à la sécurité',
    'Croire que les particuliers ne sont pas ciblés',
    'Négliger le facteur humain',
  ],
  summary:
      'La cybersécurité protège la confidentialité, l\'intégrité et la disponibilité des systèmes et données. Elle concerne tout le monde. La règle d\'or : vous n\'attaquez que ce qui vous appartient ou vous est autorisé.',
  quiz: [
    q(const [
      'q1',
      'Quels sont les trois piliers de la sécurité de l\'information ?',
      'qcm',
      'Confidentialité, Intégrité, Disponibilité|Vitesse, Mémoire, Processeur|SHA, AES, RSA|Clavier, souris, écran',
      '0',
      'Les trois piliers (CIA) sont la Confidentialité, l\'Intégrité et la Disponibilité. SHA/AES/RSA sont des outils cryptographiques, pas des piliers.',
    ]),
    q(const [
      'q2',
      'Une attaque illégale consiste à...',
      'qcm',
      'tester son propre système|apprendre en pratique|attaquer un système tiers sans autorisation|utiliser un antivirus',
      '2',
      'Attaquer un système qui ne vous appartient pas, sans autorisation, est un délit. Les autres options sont légitimes.',
    ]),
    q(const [
      'q3',
      'Un ransomware attaque surtout quel pilier ?',
      'qcm',
      'Confidentialité uniquement|Disponibilité et intégrité|Complètement aucun|La vitesse',
      '1',
      'Le ransomware chiffre vos fichiers (intégrité) et vous bloque l\'accès (disponibilité).',
    ]),
    q(const [
      'q4',
      'Vrai ou faux : seuls les grands groupes sont victimes de cyberattaques.',
      'tf',
      'Faux',
      null,
      'Les particuliers et les petites structures sont très souvent ciblés, parfois plus facilement.',
    ]),
    q(const [
      'q5',
      'Quelle est la bonne approche pour s\'entraîner en cybersécurité offensive ?',
      'qcm',
      'cibler n\'importe quel site|utiliser uniquement un labo ou des systèmes autorisés|pirater son voisin|télécharger des outils et les lancer au hasard',
      '1',
      'On s\'entraîne dans un environnement isolé (CTF, labo) ou sur des systèmes dont on a l\'autorisation explicite.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Listez 3 exemples de la vie quotidienne où la confidentialité, l\'intégrité et la disponibilité sont importantes pour vous.',
    ),
    ex(
      'Mise en situation',
      'Un ami vous demande de "tester" la sécurité du site de son école pour voir s\'il est vulnérable. Que lui répondez-vous ? (Indice : autorisation)',
    ),
  ],
  xp: 100,
);

Course _hackerEthique() => Course(
  id: 'fund-hacker-ethique',
  title: 'Le hacker éthique',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est un hacker éthique',
    'Distinguer hacker éthique, hacker malveillant et hacker récréatif',
    'Connaître le cadre légal et déontologique',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('De quoi parle-t-on ?', [
      text(
        'Un hacker éthique (ou "white hat") est un expert en sécurité qui utilise ses compétences pour trouver et corriger des failles, avec l\'autorisation expresse du propriétaire. C\'est un métier légal et très demandé.',
      ),
      text(
        'Historiquement, "hacker" désignait une personne passionnée qui explorait les systèmes pour les comprendre, sans forcément nuire. Le grand public a ensuite associé le terme à la criminalité, mais c\'est un abus de langage.',
      ),
    ]),
    sec('Les trois "chapeaux"', [
      list(
        '- **Chapeau blanc (white hat)** : éthique, avec autorisation, aide à sécuriser. Le hacker éthique.\n'
        '- **Chapeau gris (grey hat)** : peut explorer sans autorisation formelle mais sans intention nuisible. Zone grise légalement.\n'
        '- **Chapeau noir (black hat)** : malveillant, agit sans autorisation, motive par le gain ou le vandalisme. Illégal.',
      ),
      warn(
        'Dans ce cours, nous visons exclusivement le chapeau blanc. Toute pratique offensive doit se faire dans un environnement autorisé.',
      ),
    ]),
    sec('Le métier de hacker éthique', [
      text('Le hacker éthique est engagé par une organisation pour :'),
      list(
        '- Réaliser des tests d\'intrusion (pentests) autorisés.\n'
        '- Auditer la sécurité des systèmes et applications.\n'
        '- Former les équipes aux bonnes pratiques.\n'
        '- Aider à corriger les vulnérabilités trouvées.',
      ),
      text(
        'Le client donne un périmètre précis : ce qui peut être testé, quand, et comment. Toute action hors périmètre est interdite, même avec de bonnes intentions.',
      ),
    ]),
    sec('Cadre légal et déontologie', [
      list(
        '- **Autorisation écrite** : toujours un contrat ou une autorisation formelle avant de tester.\n'
        '- **Périmètre défini** : ne jamais tester ce qui n\'est pas dans le contrat.\n'
        '- **Confidentialité** : ne jamais divulguer les failles trouvées sans accord.\n'
        '- **Absence de dégâts** : les tests ne doivent pas endommager les systèmes.\n'
        '- **Reporting** : communiquer les résultats de manière professionnelle.',
      ),
      warn(
        'Même le "hacker les plus compétents" peuvent être poursuivis s\'ils agissent sans autorisation. La compétence ne justifie jamais l\'intrusion illégale.',
      ),
    ]),
  ],
  commonMistakes: [
    'Croire que hacker = criminel',
    'Penser que l\'intention suffit (il faut l\'autorisation)',
    'Confondre chapeau gris et chapeau blanc',
  ],
  summary:
      'Le hacker éthique est un professionnel qui sécurise les systèmes avec autorisation. L\'éthique et le cadre légal sont non-négociables.',
  quiz: [
    q(const [
      'q1',
      'Un "white hat" est un hacker qui...',
      'qcm',
      'attaque sans autorisation|aide à sécuriser avec autorisation|vend des données volées|crée des virus pour tester',
      '1',
      'Le white hat est le hacker éthique : il protège, avec un cadre autorisé.',
    ]),
    q(const [
      'q2',
      'La première condition avant un pentest est...',
      'qcm',
      'avoir beaucoup de compétences|avoir l\'autorisation écrite du propriétaire|posséder de bons outils|être anonyme',
      '1',
      'L\'autorisation écrite et le périmètre défini sont indispensables, avant les compétences et les outils.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : si vos intentions sont bonnes, vous pouvez tester un site sans autorisation.',
      'tf',
      'Faux',
      null,
      'Non. De bonnes intentions ne remplacent jamais l\'autorisation. C\'est la base de l\'éthique.',
    ]),
    q(const [
      'q4',
      'Un hacker "grey hat"...',
      'qcm',
      'est toujours légal|peut explorer sans autorisation formelle, zone grise|est toujours malveillant|ne connaît pas l\'informatique',
      '1',
      'Le grey hat agit dans une zone grise juridique : sans autorisation formelle mais sans intention de nuire.',
    ]),
  ],
  exercises: [
    ex(
      'Recherche',
      'Cherchez dans l\'actualité un exemple d\'un vrai pentest autorisé d\'une grande entreprise et notez comment l\'autorisation fonctionne.',
    ),
  ],
  xp: 100,
);

Course _cybercriminalite() => Course(
  id: 'fund-cybercrime',
  title: 'La cybercriminalité',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est la cybercriminalité',
    'Connaître les principaux types de crimes numériques',
    'Comprendre les enjeux légaux',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'La cybercriminalité regroupe toutes les infractions commises via ou contre des systèmes informatiques et des réseaux. Elle peut cibler des personnes, des entreprises ou des États.',
      ),
    ]),
    sec('Principales catégories', [
      list(
        '- **Vol de données** : soustraire des informations personnelles ou professionnelles.\n'
        '- **Fraude financière** : phishing, arnaques, détournement de paiement.\n'
        '- **Ransomware** : chiffrer les données d\'une victime et demander une rançon.\n'
        '- **DDoS** : rendre un service indisponible en le surchargeant.\n'
        '- **Intrusion** : accès non autorisé à des systèmes.\n'
        '- **Vol d\'identité** : usurper l\'identité d\'une personne.\n'
        '- **Cyberharcèlement** et contenus illégaux.',
      ),
    ]),
    sec('Les motivations', [
      text('Les cybercriminels sont motivés par :'),
      list(
        '- L\'argent (la majorité des cas).\n'
        '- L\'espionnage industriel ou étatique.\n'
        '- Le vandalisme ou la revendication idéologique (hacktivisme).\n'
        '- Simple volonté de nuire ou défi personnel.',
      ),
    ]),
    sec('Conséquences', [
      text(
        'Une cyberattaque peut causer des pertes financières, la fuite de données sensibles, l\'atteinte à la réputation, et dans certains cas des impacts physiques (hôpitaux, infrastructures).',
      ),
      warn(
        'Comprendre la cybercriminalité ne veut pas dire la pratiquer. Écrire du code malveillant, même "pour voir", est illégal et dangereux.',
      ),
    ]),
    sec('Comment se protéger', [
      list(
        '- Mots de passe forts et uniques, géré par un gestionnaire.\n'
        '- Authentification à deux facteurs (2FA).\n'
        '- Mises à jour régulières.\n'
        '- Vigilance face au phishing.\n'
        '- Sauvegardes de données.',
      ),
    ]),
  ],
  commonMistakes: [
    'Sous-estimer les conséquences des crimes numériques',
    'Penser qu\'on est "trop petit" pour être ciblé',
  ],
  summary:
      'La cybercriminalité est vaste et motivée surtout par l\'argent. La défense passe par les bonnes pratiques et la vigilance.',
  quiz: [
    q(const [
      'q1',
      'Qu\'est-ce qu\'un ransomware ?',
      'qcm',
      'un logiciel qui chiffre vos données et demande une rançon|un antivirus|un pare-feu|un jeu',
      '0',
      'Le ransomware chiffre vos fichiers puis exige une rançon pour les débloquer.',
    ]),
    q(const [
      'q2',
      'La principale motivation des cybercriminels est...',
      'qcm',
      'l\'argent|le sport|l\'art|la science',
      '0',
      'L\'argent motive la grande majorité des cyberattaques.',
    ]),
    q(const [
      'q3',
      'Vrai ou faux : écrire un virus "juste pour tester" est sans conséquence.',
      'tf',
      'Faux',
      null,
      'Créer et diffuser du code malveillant est illégal, même si c\'est "pour tester".',
    ]),
    q(const [
      'q4',
      'Quelle est une bonne pratique de protection ?',
      'qcm',
      'réutiliser le même mot de passe|activer la double authentification|cliquer sur tous les liens|désactiver les antivirus',
      '1',
      'Le 2FA ajoute une couche de protection. Les autres options sont dangereuses.',
    ]),
  ],
  exercises: [
    ex(
      'Analyse',
      'Identifiez 3 moyens par lesquels vous pouvez renforcer la sécurité de vos comptes personnels dès aujourd\'hui.',
    ),
  ],
  xp: 100,
);

Course _redTeam() => Course(
  id: 'fund-redteam',
  title: 'Red Team et sécurité offensive',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est une Red Team',
    'Connaître son rôle dans la sécurité',
    'Comprendre l\'utilité éthique de l\'approche offensive',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'La "Red Team" désigne une équipe qui joue le rôle de l\'attaquant pour tester les défenses d\'une organisation. Elle reproduit les techniques des vrais attaquants, mais dans un cadre autorisé et encadré.',
      ),
    ]),
    sec('Pourquoi provoquer une attaque ?', [
      text(
        'Pour bien défendre, il faut connaître les techniques d\'attaque. La Red Team permet de :',
      ),
      list(
        '- Identifier les failles avant les vrais attaquants.\n'
        '- Tester les réactions des équipes de défense.\n'
        '- Valider l\'efficacité des mesures de sécurité.\n'
        '- Sensibiliser et former.',
      ),
    ]),
    sec('Red Team vs Blue Team', [
      list(
        '- **Red Team** = attaque simulée et autorisée (offensif).\n'
        '- **Blue Team** = défense, détection, réponse (défensif).\n'
        '- Ensemble, elles forment la base de la pratique de la cybersécurité.',
      ),
      text(
        'L\'objectif pédagogique de la Red Team est de comprendre les méthodes offensives pour mieux se défendre.',
      ),
    ]),
    sec('Cadre indispensable', [
      text(
        'Toute activité Red Team réelle nécessite un cadre juridique strict et une autorisation explicite. Hors de ce cadre, les mêmes techniques deviennent des infractions.',
      ),
      warn(
        'Les techniques offensives apprises ici doivent s\'utiliser exclusivement dans un laboratoire personnel ou un environnement autorisé (CTF).',
      ),
    ]),
  ],
  commonMistakes: [
    'Croire que la Red Team sert à nuire',
    'Pratiquer sans autorisation',
    'Confondre Red Team et vraie attaque',
  ],
  summary:
      'La Red Team simule des attaques autorisées pour améliorer la défense. C\'est une discipline éthique encadrée.',
  quiz: [
    q(const [
      'q1',
      'Le rôle d\'une Red Team est de...',
      'qcm',
      'défendre un réseau|simuler des attaques autorisées pour tester les défenses|installer des antivirus|gérer les mots de passe',
      '1',
      'La Red Team joue le rôle de l\'attaquant pour renforcer la sécurité.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Expliquez en une phrase pourquoi une organisation payerait une équipe pour tenter de la pirater.',
    ),
  ],
  xp: 60,
);

Course _blueTeam() => Course(
  id: 'fund-blreteam',
  title: 'Blue Team et défense',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre le rôle de la Blue Team',
    'Connaître les tâches de défense',
    'Comprendre les outils de détection',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'La "Blue Team" regroupe les personnes chargées de défendre une organisation : surveillance, détection, analyse et réponse aux incidents. C\'est la face défensive de la cybersécurité.',
      ),
    ]),
    sec('Les missions', [
      list(
        '- Surveiller les journaux (logs) et le trafic.\n'
        '- Détecter les comportements anormaux.\n'
        '- Répondre aux incidents (isoler, éradiquer, restaurer).\n'
        '- Analyser les menaces et les indicateurs de compromission (IOC).\n'
        '- Renforcer la configuration des systèmes.',
      ),
    ]),
    sec('Les outils', [
      text(
        'La Blue Team utilise des outils comme les SIEM (collecte et analyse de logs), les IDS/IPS (détection d\'intrusion), des EDR (protection des postes) et de nombreuses sources de menaces.',
      ),
    ]),
    sec('Une carrière très demandée', [
      text(
        'Le besoin en profils Blue Team (analyste SOC, analyste sécurité, incident responder) est immense. Ces métiers sont accessibles et gratifiants, et donnent un bagage technique solide.',
      ),
    ]),
  ],
  commonMistakes: [
    'Croire que seule l\'attaque est intéressante',
    'Sous-estimer l\'importance de l\'analyse de logs',
  ],
  summary:
      'La Blue Team défend les systèmes : surveillance, détection et réponse. C\'est un pilier essentiel de la cybersécurité.',
  quiz: [
    q(const [
      'q1',
      'La Blue Team...',
      'qcm',
      'attaque les systèmes|cible des intrusions|défend et surveille les systèmes|vend des données',
      '2',
      'La Blue Team est la défense : surveillance, détection et réponse.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'SI l\'on gardait 5 rôles différents côté défense, lesquels choisiriez-vous ? Essayez d\'en citer 3 au moins.',
    ),
  ],
  xp: 60,
);

Course _pentest() => Course(
  id: 'fund-pentest',
  title: 'Le pentest (test d\'intrusion)',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est un test d\'intrusion',
    'Connaître les grandes étapes',
    'Comprendre la différence avec une attaque réelle',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'Un test d\'intrusion (ou pentest, de "penetration test") est une simulation d\'attaque autorisée visant à évaluer la sécurité d\'un système ou d\'une application. L\'objectif est de découvrir les vulnérabilités avant les attaquants.',
      ),
      text(
        'La différence fondamentale avec une vraie attaque : le pentest est réalisé avec l\'autorisation écrite du propriétaire et suit un périmètre précis.',
      ),
    ]),
    sec('Les grandes étapes', [
      list(
        '- **Préparation et périmètre** : définir avec le client ce qui sera testé.\n'
        '- **Reconnaissance** : collecter des informations (passive puis active).\n'
        '- **Analyse et découverte** : identifier les services et vulnérabilités.\n'
        '- **Validation** : confirmer les failles et leur exploitabilité.\n'
        '- **Documentation** : consigner tout, avec preuves.\n'
        '- **Rapport final** : présentations des constats et recommandations.',
      ),
      warn(
        'Le pentest autorisé suit un contrat. Tout scan ou test hors périmètre est interdit et peut être illégal.',
      ),
    ]),
    sec('Types de pentest', [
      list(
        '- **Boîte noire (black box)** : le testeur ne connaît pas le système à l\'avance.\n'
        '- **Boîte grise (grey box)** : connaissance partielle.\n'
        '- **Boîte blanche (white box)** : accès complet au code et à la configuration.',
      ),
      text(
        'La boîte blanche est souvent la plus efficace pour un audit de sécurité, car elle couvre plus de surface.',
      ),
    ]),
    sec('Résultat : un rapport', [
      text(
        'Le principal livrable d\'un pentest est un rapport professionnel détaillant les vulnérabilités, leur criticité, les preuves, leur impact et les recommandations. Un bon rapport vaut autant que le test lui-même.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre pentest et attaque réelle',
    'Négliger le rapport (pourtant essentiel)',
    'Dépasser le périmètre autorisé',
  ],
  summary:
      'Le pentest est une simulation d\'attaque autorisée pour améliorer la sécurité. Il se termine par un rapport professionnel.',
  quiz: [
    q(const [
      'q1',
      'Un pentest se distingue d\'une attaque réelle par...',
      'qcm',
      'les outils utilisés|l\'autorisation et le périmètre contractuel|la rapidité|le niveau technique',
      '1',
      'La différence clé est le cadre : autorisation écrite et périmètre défini.',
    ]),
  ],
  exercises: [
    ex('Réflexion', 'Citez les 4 grandes étapes d\'un pentest dans l\'ordre.'),
  ],
  xp: 60,
);

Course _soc() => Course(
  id: 'fund-soc',
  title: 'Le SOC (Security Operations Center)',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est un SOC',
    'Connaître ses missions',
    'Comprendre le rôle des analystes',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'Un SOC (Centre d\'Opérations de Sécurité) est une équipe qui surveille en continu les systèmes d\'une organisation pour détecter et répondre aux incidents de sécurité.',
      ),
      text(
        'C\'est le "centre du cerveau" de la sécurité opérationnelle : toutes les alertes convergent ici.',
      ),
    ]),
    sec('Les missions', [
      list(
        '- Surveillance 24/7 des systèmes et réseaux.\n'
        '- Analyse des alertes de sécurité.\n'
        '- Triage : déterminer ce qui est réellement dangereux.\n'
        '- Réponse aux incidents.\n'
        '- Recherche de menaces (threat hunting).\n'
        '- Amélioration continue des règles de détection.',
      ),
    ]),
    sec('Le rôle des analystes', [
      text('On distingue souvent trois niveaux d\'analystes :'),
      list(
        '- **Niveau 1 (triage)** : premier regard sur les alertes, classification.\n'
        '- **Niveau 2 (investigation)** : analyse approfondie, recherche de corrélations.\n'
        '- **Niveau 3 (expert)** : chasse aux menaces, analyse forensique poussée.',
      ),
    ]),
    sec('Outils du SOC', [
      text(
        'SIEM (collecte/logs), SOAR (orchestration), EDR, tickets d\'incident, bases d\'IOC. La maîtrise des logs et de l\'analyse est cruciale.',
      ),
    ]),
  ],
  commonMistakes: [
    'Penser que le SOC n\'est que de la surveillance passive',
    'Ignorer l\'importance du triage et de la documentation',
  ],
  summary:
      'Le SOC surveille et défend en continu. Les analystes analysent les alertes, font du triage et répondent aux incidents.',
  quiz: [
    q(const [
      'q1',
      'Que fait le SOC ?',
      'qcm',
      'il attaque des systèmes|c\'est une équipe qui surveille et répond aux incidents|il installe des jeux|il gère les salaires',
      '1',
      'Le SOC surveille en continu et répond aux incidents de sécurité.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Pourquoi une organisation aurait-elle besoin d\'un SOC plutôt que d\'un simple antivirus ?',
    ),
  ],
  xp: 60,
);

Course _vulnerabilite() => Course(
  id: 'fund-vuln',
  title: 'Vulnérabilités et exploits',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est une vulnérabilité',
    'Comprendre ce qu\'est un exploit',
    'Connaître la notion de CVE',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition d\'une vulnérabilité', [
      text(
        'Une vulnérabilité est une faiblesse dans un système (logiciel, réseau, configuration) qui peut être exploitée pour compromettre sa sécurité.',
      ),
      text(
        'Exemple : un formulaire de site web qui accepte du code au lieu de texte est une vulnérabilité (injection). Une porte de service qui reste ouverte par erreur est une vulnérabilité de configuration.',
      ),
    ]),
    sec('Exploit et exploitation', [
      text(
        'Un exploit est un morceau de code, une technique ou une séquence qui utilise une vulnérabilité pour obtenir un accès, élever des privilèges ou causer des dégâts. "Exploiter" une vulnérabilité, c\'est l\'utiliser pour atteindre un objectif.',
      ),
    ]),
    sec('Les CVE et le scoring CVSS', [
      text(
        'Les vulnérabilités connues sont référencées sous un identifiant unique : le CVE (Common Vulnerabilities and Exposures), par exemple CVE-2021-44228 (Log4Shell).',
      ),
      text(
        'Le score CVSS (Common Vulnerability Scoring System) évalue la gravité d\'une vulnérabilité de 0 à 10. Au-delà de 7, on parle souvent de vulnérabilité critique.',
      ),
    ]),
    sec('De la vulnérabilité à la correction', [
      text(
        'Le but du travail en cybersécurité est de trouver et corriger les vulnérabilités AVANT qu\'elles ne soient exploitées de manière malveillante. On privilégie toujours l\'apprentissage de la correction.',
      ),
      warn(
        'Exploiter une vulnérabilité sur un système tiers sans autorisation est illégal, même pour "s\'entraîner".',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre vulnérabilité et exploit (cause et conséquence)',
    'Tester des exploits hors autorisation',
  ],
  summary:
      'Une vulnérabilité est une faiblesse ; un exploit l\'utilise. Les CVE référencent les failles connues. On apprend à corriger.',
  quiz: [
    q(const [
      'q1',
      'Une vulnérabilité est...',
      'qcm',
      'une faiblesse exploitable|un antivirus|un mot de passe|un réseau',
      '0',
      'C\'est une faiblesse qui peut être exploitée.',
    ]),
  ],
  exercises: [
    ex(
      'Recherche',
      'Recherchez en ligne une CVE récente et notez son score CVSS et son rôle dans sa gravité.',
    ),
  ],
  xp: 60,
);

Course _malware() => Course(
  id: 'fund-malware',
  title: 'Les malwares (logiciels malveillants)',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre ce qu\'est un malware',
    'Connaître les grands types de malwares',
    'Comprendre comment ils se propagent',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'Un malware (de "malicious software", logiciel malveillant) est un programme conçu pour nuire : voler des données, espionner, endommager, ou contrôler une machine.',
      ),
    ]),
    sec('Les grandes familles', [
      list(
        '- **Virus** : se fixe à un programme et se propage quand on l\'exécute.\n'
        '- **Ver (worm)** : se propage tout seul par le réseau.\n'
        '- **Cheval de Troie (trojan)** : se fait passer pour un logiciel légitime.\n'
        '- **Ransomware** : chiffre les données et demande une rançon.\n'
        '- **Spyware** : espionne discrètement.\n'
        '- **Keylogger** : enregistre ce que vous tapez.\n'
        '- **Botnet** : machine contrôlée à distance pour attaquer.',
      ),
    ]),
    sec('Comment se protéger', [
      list(
        '- Ne pas ouvrir de pièces jointes suspectes.\n'
        '- Mettre à jour ses logiciels.\n'
        '- Utiliser un antivirus et un pare-feu.\n'
        '- Ne pas installer de logiciels de sources douteuses.\n'
        '- Avoir des sauvegardes hors ligne.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ouvrir des pièces jointes inconnues',
    'Désactiver les mises à jour',
  ],
  summary:
      'Les malwares sont des programmes malveillants variés. La vigilance, les mises à jour et les sauvegardes protègent.',
  quiz: [
    q(const [
      'q1',
      'Un ver se distingue d\'un virus car...',
      'qcm',
      'il se propage seul par le réseau|il est plus petit|il est sans danger|il ne peut pas se propager',
      '0',
      'Le ver se propage automatiquement par le réseau, sans action de la victime.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Citez 3 bonnes pratiques qui réduisent fortement le risque de malware.',
    ),
  ],
  xp: 60,
);

Course _phishing() => Course(
  id: 'fund-phishing',
  title: 'Le phishing (hameçonnage)',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre le phishing',
    'Reconnaître les signes d\'une tentative',
    'Savoir réagir',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Définition', [
      text(
        'Le phishing (hameçonnage) est une technique d\'attaque qui consiste à faire croire à une victime qu\'elle communique avec un interlocuteur légitime, afin de lui voler des informations (mots de passe, cartes bancaires) ou de lui faire installer un malware.',
      ),
      text(
        'Généralement, l\'attaquant envoie un email ou un SMS imitant une banque, un service web ou un collègue, avec un lien vers un site frauduleux.',
      ),
    ]),
    sec('Les signes d\'alerte', [
      list(
        '- Urgence : "votre compte va être bloqué dans 24h".\n'
        '- Fautes d\'orthographe et formulations étranges.\n'
        '- Adresse de l\'expéditeur bizarre ou légèrement modifiée.\n'
        '- Liens dont l\'adresse réelle ne correspond pas au site annoncé.\n'
        '- Demandes de mot de passe ou de codes par email.',
      ),
    ]),
    sec('Comment vérifier', [
      text(
        'Avant de cliquer, vérifiez toujours : l\'adresse de l\'expéditeur, l\'URL réelle du lien (survolez sans cliquer), et l\'urgence du message. En cas de doute, contactez l\'organisation par un autre canal.',
      ),
    ]),
    sec('Réaction', [
      text(
        'Si vous recevez un phishing : ne cliquez pas, ne répondez pas, signalez-le et supprimez-le. Si vous avez déjà cliqué, changez vos mots de passe et activez la double authentification.',
      ),
    ]),
  ],
  commonMistakes: [
    'Cliquer sans vérifier l\'expéditeur',
    'Se fier à l\'urgence du message',
  ],
  summary:
      'Le phishing manipule pour voler. Reconnaître les signes et vérifier avant de cliquer suffit souvent à se protéger.',
  quiz: [
    q(const [
      'q1',
      'Un signe typique de phishing est...',
      'qcm',
      'un message créant l\'urgence et demandant un mot de passe|une facture légitime que vous vérifiez|un message sans aucun lien|une mise à jour automatique',
      '0',
      'L\'urgence et la demande de secrets sont les marqueurs du phishing.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Trouvez un exemple réel de phishing reçu ou recherché en ligne et listez les 3 signes d\'alerte qui le trahissent.',
    ),
  ],
  xp: 60,
);

Course _ransomware() => Course(
  id: 'fund-ransom',
  title: 'Le ransomware',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Comprendre le fonctionnement d\'un ransomware',
    'Connaître les vecteurs d\'infection',
    'Comprendre la défense et la réaction',
  ],
  prerequisites: ['Notions malware'],
  sections: [
    sec('Définition', [
      text(
        'Un ransomware est un malware qui chiffre les fichiers de la victime et exige une rançon (souvent en cryptomonnaie) pour les déchiffrer. C\'est l\'une des menaces les plus dévastatrices.',
      ),
    ]),
    sec('Comment ça marche', [
      text(
        'Le ransomware s\'installe (souvent via phishing ou un exploit), puis chiffre les fichiers silencieusement. Il affiche ensuite une demande de rançon. Sans les clés, les données restent inaccessibles.',
      ),
    ]),
    sec('Vecteurs d\'infection', [
      list(
        '- Phishing et pièces jointes piégées.\n'
        '- Exploitation de services exposés (ex: RDP avec mot de passe faible).\n'
        '- Téléchargements de logiciels piratés.\n'
        '- Clés USB infectées.',
      ),
    ]),
    sec('Se protéger et réagir', [
      text(
        'La défense repose sur : des sauvegardes régulières et hors ligne, des mises à jour, un anti-ransomware, et la limitation des accès administrateurs.',
      ),
      text(
        'En cas d\'infection : déconnectez la machine du réseau immédiatement, prévenez les équipes de sécurité, ne payez pas forcément la rançon (aucune garantie), et restaurez depuis les sauvegardes.',
      ),
    ]),
  ],
  commonMistakes: [
    'Payer la rançon sans sauvegarde (risqué et aucune garantie)',
    'Ne pas faire de sauvegardes hors ligne',
  ],
  summary:
      'Le ransomware chiffre vos données et demande une rançon. Les sauvegardes hors ligne sont la meilleure défense.',
  quiz: [
    q(const [
      'q1',
      'La meilleure protection anti-ransomware est...',
      'qcm',
      'payer vite la rançon|des sauvegardes régulières et hors ligne|désactiver l\'antivirus|ouvrir toutes les pièces jointes',
      '1',
      'Les sauvegardes hors ligne permettent de restaurer sans payer.',
    ]),
  ],
  exercises: [
    ex(
      'Réflexion',
      'Expliquez pourquoi payer la rançon n\'est pas une garantie de récupérer vos données.',
    ),
  ],
  xp: 60,
);

Course _securiteNumerique() => Course(
  id: 'fund-secnum',
  title: 'Notions de sécurité numérique au quotidien',
  category: 'fundamentals',
  level: 'Niveau 0 - Découverte',
  levelNumber: 0,
  objectives: [
    'Adopter les bonnes pratiques de base',
    'Comprendre mots de passe, 2FA, mises à jour',
    'Savoir protéger ses données personnelles',
  ],
  prerequisites: ['Aucun'],
  sections: [
    sec('Les bons réflexes', [
      text(
        'La sécurité numérique commence par de simples habitudes, efficaces pour la majorité des risques :',
      ),
      list(
        '- Mots de passe longs, uniques par service.\n'
        '- Un gestionnaire de mots de passe.\n'
        '- Double authentification (2FA) partout où c\'est possible.\n'
        '- Mises à jour automatiques activées.\n'
        '- Vigilance face au phishing.',
      ),
    ]),
    sec('Construire un bon mot de passe', [
      text(
        'Un bon mot de passe est long et imprévisible. "CorrectHorseBatteryStaple" est un exemple de phrase de passe facile à retenir et difficile à deviner. Évitez les informations personnelles (dates, prénoms).',
      ),
    ]),
    sec('La double authentification (2FA)', [
      text(
        'Le 2FA ajoute une deuxième preuve d\'identité : un code sur votre téléphone, une clé physique, ou votre empreinte. Même si votre mot de passe fuit, le compte reste protégé.',
      ),
    ]),
    sec('Protéger ses données', [
      text(
        'Limitez ce que vous partagez, vérifiez les paramètres de confidentialité, évitez les réseaux WiFi publics non sécurisés pour des données sensibles, et faites des sauvegardes.',
      ),
    ]),
  ],
  commonMistakes: [
    'Réutiliser le même mot de passe partout',
    'Ne pas activer le 2FA',
    'Négliger les mises à jour',
  ],
  summary:
      'Les bons réflexes — mots de passe uniques, 2FA, mises à jour, vigilance — protègent contre la majorité des menaces.',
  quiz: [
    q(const [
      'q1',
      'Un mot de passe fort est...',
      'qcm',
      'cour et simple|long et unique par service|le même partout|une date de naissance',
      '1',
      'Un mot de passe fort est long, unique, imprévisible, et propre à chaque service.',
    ]),
  ],
  exercises: [
    ex(
      'Action',
      'Activez la double authentification sur un de vos comptes importants, si ce n\'est déjà fait. Notez la démarche.',
    ),
  ],
  xp: 60,
);
