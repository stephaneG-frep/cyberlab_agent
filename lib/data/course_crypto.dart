import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

/// Niveau 7 - Cryptographie.
List<Course> cryptoCourses() => [
  _encoding(),
  _hash(),
  _passwords(),
  _symmetric(),
  _asymmetric(),
  _signatures(),
  _pki(),
  _tls(),
];

const _level = 'Niveau 7 - Cryptographie';
const _cat = 'crypto';

Course _encoding() => Course(
  id: 'cr-encoding',
  title: 'Encoder, hacher, chiffrer : ne pas confondre',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Distinguer encodage, hachage et chiffrement",
    "Savoir lequel est réversible, et avec quoi",
    "Reconnaître Base64 et un hash à l'œil",
  ],
  prerequisites: ["Aucun prérequis technique"],
  sections: [
    sec("Trois opérations différentes", [
      code(
        "Encodage     réversible SANS secret   Base64, URL, hexadécimal\n"
        "Hachage      NON réversible            SHA-256, bcrypt\n"
        "Chiffrement  réversible AVEC une clé   AES, RSA",
        label: "À retenir",
      ),
      text(
        "L'encodage change seulement la représentation des données pour les "
        "transporter (Base64 dans un e-mail, %20 dans une URL). N'importe qui "
        "peut le décoder : il ne protège rien.",
      ),
    ]),
    sec("Les reconnaître", [
      list(
        "- **Base64** : lettres, chiffres, + et /, souvent terminé par = ou ==.\n"
        "- **Hash** : longueur fixe en hexadécimal (64 caractères pour SHA-256), quel que soit le texte d'origine.\n"
        "- **Chiffré** : octets d'apparence aléatoire, souvent présentés en Base64.",
      ),
      code(
        "echo -n CyberLab | base64          Q3liZXJMYWI=\n"
        "echo Q3liZXJMYWI= | base64 -d      CyberLab\n"
        "echo -n CyberLab | sha256sum       (64 caractères hexadécimaux)",
        label: "Dans le terminal du Lab",
      ),
    ]),
    sec("Pourquoi c'est important", [
      warn(
        "« On a chiffré les mots de passe en Base64 » est une erreur classique "
        "et grave : Base64 se décode instantanément.",
      ),
    ]),
  ],
  commonMistakes: [
    "Croire que Base64 protège des données",
    "Dire qu'on « décrypte » un hash : un hash ne se déchiffre pas",
  ],
  summary:
      "Encodage : réversible par tous. Hachage : à sens unique. Chiffrement : "
      "réversible seulement avec la clé.",
  quiz: [
    q(const [
      'q1',
      "Laquelle de ces opérations est réversible SANS aucun secret ?",
      'qcm',
      "L'encodage Base64|Le hachage SHA-256|Le chiffrement AES|Le hachage bcrypt",
      '0',
      "Base64 se décode par n'importe qui.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : on peut retrouver le texte d'origine d'un hash SHA-256 en le « déchiffrant ».",
      'tf',
      'Faux',
      null,
      "Un hash est à sens unique ; on ne peut que tester des candidats.",
    ]),
    q(const [
      'q3',
      "Quelle longueur, en caractères hexadécimaux, a une empreinte SHA-256 ?",
      'qcm',
      "64|32|128|Elle dépend du texte",
      '0',
      "256 bits = 32 octets = 64 caractères hexadécimaux, quelle que soit l'entrée.",
    ]),
  ],
  exercises: [
    ex(
      "Les trois dans le terminal",
      "Dans le terminal du Lab : encodez votre prénom avec echo -n … | base64, "
          "décodez le résultat, puis calculez son empreinte avec sha256sum. "
          "Lequel ne peut pas revenir en arrière ?",
    ),
  ],
);

Course _hash() => Course(
  id: 'cr-hash',
  title: 'Les fonctions de hachage',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Connaître les propriétés d'une fonction de hachage",
    "Vérifier l'intégrité d'un fichier",
    "Savoir pourquoi MD5 et SHA-1 sont dépassés",
  ],
  prerequisites: ["Encoder, hacher, chiffrer : ne pas confondre"],
  sections: [
    sec("Les propriétés", [
      list(
        "- **Taille fixe** : l'empreinte a toujours la même longueur.\n"
        "- **Déterministe** : même entrée, même empreinte.\n"
        "- **Effet avalanche** : changer un seul caractère change toute l'empreinte.\n"
        "- **Sens unique** : impossible de remonter à l'entrée.\n"
        "- **Résistance aux collisions** : impossible en pratique de trouver deux entrées de même empreinte.",
      ),
    ]),
    sec("Vérifier l'intégrité", [
      text(
        "Les éditeurs publient l'empreinte SHA-256 de leurs fichiers. Après "
        "téléchargement, on recalcule l'empreinte : si elle diffère, le "
        "fichier a été corrompu ou modifié.",
      ),
      code(
        "sha256sum notes.txt\n"
        "echo -n bonjour | sha256sum\n"
        "echo -n Bonjour | sha256sum     (empreinte totalement différente)",
        label: "Dans le terminal du Lab",
      ),
      warn(
        "Une empreinte ne prouve l'authenticité que si elle provient d'une "
        "source sûre : un attaquant qui remplace le fichier peut aussi "
        "remplacer l'empreinte affichée sur la même page. D'où les signatures.",
      ),
    ]),
    sec("Algorithmes dépassés", [
      text(
        "Des collisions ont été produites pour MD5 et SHA-1 : on sait "
        "fabriquer deux fichiers différents de même empreinte. Ils ne doivent "
        "plus servir pour la sécurité. On utilise SHA-256, SHA-512 ou SHA-3.",
      ),
    ]),
  ],
  commonMistakes: [
    "Utiliser MD5 ou SHA-1 pour la sécurité",
    "Faire confiance à une empreinte publiée au même endroit que le fichier",
  ],
  summary:
      "Un hash donne une empreinte fixe, déterministe, à sens unique, très "
      "sensible au moindre changement. SHA-256 vérifie l'intégrité ; MD5 et "
      "SHA-1 sont cassés pour les collisions.",
  quiz: [
    q(const [
      'q1',
      "Que se passe-t-il si l'on change une seule lettre d'un fichier ?",
      'qcm',
      "Son empreinte change complètement|Son empreinte change d'un caractère|Son empreinte ne change pas|Le fichier devient illisible",
      '0',
      "C'est l'effet avalanche.",
    ]),
    q(const [
      'q2',
      "Pourquoi MD5 ne doit-il plus servir pour la sécurité ?",
      'qcm',
      "On sait produire des collisions|Il est trop lent|Il est payant|Il produit des empreintes trop longues",
      '0',
      "Deux fichiers différents peuvent avoir la même empreinte MD5.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : une même entrée donne toujours la même empreinte SHA-256.",
      'tf',
      'Vrai',
      null,
      "Une fonction de hachage est déterministe.",
    ]),
  ],
  exercises: [
    ex(
      "Effet avalanche",
      "Dans le terminal du Lab, comparez echo -n bonjour | sha256sum et "
          "echo -n Bonjour | sha256sum. Combien de caractères sont identiques ?",
    ),
  ],
);

Course _passwords() => Course(
  id: 'cr-passwords',
  title: 'Stocker les mots de passe correctement',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Comprendre pourquoi un hash rapide ne suffit pas",
    "Connaître le rôle du sel",
    "Choisir un algorithme adapté (Argon2id, bcrypt, scrypt)",
  ],
  prerequisites: ["Les fonctions de hachage"],
  sections: [
    sec("Ne jamais stocker en clair", [
      text(
        "Un serveur ne doit jamais connaître les mots de passe en clair, ni "
        "même chiffrés : il stocke une empreinte et compare l'empreinte du "
        "mot de passe saisi à la connexion.",
      ),
    ]),
    sec("Le sel", [
      text(
        "Sans sel, deux utilisateurs au même mot de passe ont la même "
        "empreinte, et des tables précalculées retrouvent instantanément les "
        "mots de passe courants. Le sel est une valeur aléatoire propre à "
        "chaque utilisateur, ajoutée avant le hachage et stockée à côté.",
      ),
    ]),
    sec("Lent, exprès", [
      text(
        "SHA-256 est conçu pour être rapide : une carte graphique en teste "
        "des milliards par seconde. Pour les mots de passe, on utilise des "
        "fonctions volontairement lentes et coûteuses en mémoire.",
      ),
      list(
        "- **Argon2id** : recommandé aujourd'hui.\n"
        "- **bcrypt** et **scrypt** : solides et très répandus.\n"
        "- **PBKDF2** : acceptable avec beaucoup d'itérations.",
      ),
      code(
        r"$2b$12$<sel de 22 caractères><empreinte>",
        label: "Format d'une empreinte bcrypt (coût 12)",
      ),
    ]),
    sec("Côté utilisateur", [
      tip(
        "La meilleure défense reste un mot de passe long et unique par site, "
        "géré par un gestionnaire de mots de passe, avec l'authentification "
        "multifacteur.",
      ),
    ]),
  ],
  commonMistakes: [
    "Stocker les mots de passe avec SHA-256 sans sel",
    "Chiffrer les mots de passe (réversible) au lieu de les hacher",
    "Réutiliser le même sel pour tous les comptes",
  ],
  summary:
      "Jamais en clair ni chiffrés : une empreinte salée, avec une fonction "
      "lente (Argon2id, bcrypt, scrypt). Le sel est unique par utilisateur.",
  quiz: [
    q(const [
      'q1',
      "À quoi sert le sel ?",
      'qcm',
      "À rendre chaque empreinte unique, même pour des mots de passe identiques|À chiffrer la base de données|À accélérer la connexion|À remplacer le mot de passe",
      '0',
      "Il rend inutiles les tables précalculées et masque les mots de passe identiques.",
    ]),
    q(const [
      'q2',
      "Quel algorithme est adapté au stockage des mots de passe ?",
      'qcm',
      "Argon2id|MD5|SHA-1|Base64",
      '0',
      "Argon2id est lent et gourmand en mémoire, exprès.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : la rapidité de SHA-256 est un avantage pour stocker des mots de passe.",
      'tf',
      'Faux',
      null,
      "Rapide pour vous, rapide aussi pour l'attaquant qui teste des milliards de candidats.",
    ]),
  ],
  exercises: [
    ex(
      "Voir l'intérêt du sel",
      "Dans le terminal du Lab : echo -n Soleil2026 | sha256sum, puis "
          "echo -n x7Q2Soleil2026 | sha256sum (le sel x7Q2 en préfixe). Pourquoi "
          "un attaquant ne peut-il plus utiliser une table de mots de passe "
          "courants déjà hachés ?",
    ),
    ex(
      "Regarder /etc/shadow",
      "Dans le terminal du Lab : sudo cat /etc/shadow. Le préfixe \$6\$ "
          "désigne l'algorithme (SHA-512 itéré) ; repérez où se trouvent le sel "
          "et l'empreinte.",
    ),
  ],
);

Course _symmetric() => Course(
  id: 'cr-symmetric',
  title: 'Le chiffrement symétrique',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Comprendre le principe d'une clé partagée",
    "Connaître AES et ses modes",
    "Identifier le problème de l'échange de clé",
  ],
  prerequisites: ["Encoder, hacher, chiffrer : ne pas confondre"],
  sections: [
    sec("Une seule clé", [
      text(
        "En chiffrement symétrique, la même clé chiffre et déchiffre. C'est "
        "très rapide : on l'utilise pour les disques, les fichiers et le "
        "trafic réseau. AES (128 ou 256 bits) est le standard actuel ; "
        "ChaCha20 est une alternative performante sur mobile.",
      ),
    ]),
    sec("Les modes", [
      list(
        "- **ECB** : chaque bloc chiffré séparément ; des blocs identiques donnent des blocs chiffrés identiques. À proscrire.\n"
        "- **CBC** : enchaîne les blocs, exige un vecteur d'initialisation (IV) imprévisible.\n"
        "- **GCM** : chiffre ET authentifie (détecte toute modification). Recommandé.",
      ),
      warn(
        "Avec GCM, ne jamais réutiliser le même nonce avec la même clé : "
        "cela ruine la sécurité.",
      ),
    ]),
    sec("Le problème de la clé", [
      text(
        "Comment deux personnes qui ne se sont jamais rencontrées "
        "partagent-elles une clé secrète sur un réseau espionné ? C'est le "
        "problème que résout la cryptographie asymétrique.",
      ),
    ]),
  ],
  commonMistakes: [
    "Utiliser le mode ECB",
    "Écrire la clé en dur dans le code source",
    "Inventer son propre algorithme de chiffrement",
  ],
  summary:
      "Une clé pour chiffrer et déchiffrer, rapide : AES (mode GCM de "
      "préférence) ou ChaCha20. Le point faible est l'échange de la clé.",
  quiz: [
    q(const [
      'q1',
      "Quel mode de chiffrement est à proscrire ?",
      'qcm',
      "ECB|GCM|CBC avec IV aléatoire|ChaCha20-Poly1305",
      '0',
      "ECB laisse voir les motifs : deux blocs identiques restent identiques une fois chiffrés.",
    ]),
    q(const [
      'q2',
      "Quel est le principal défi du chiffrement symétrique ?",
      'qcm',
      "Partager la clé de façon sûre|Sa lenteur|Sa taille de fichier|Son incompatibilité avec les disques",
      '0',
      "Il faut transmettre la même clé secrète à l'autre partie.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : le mode GCM détecte si le message chiffré a été modifié.",
      'tf',
      'Vrai',
      null,
      "GCM est un mode de chiffrement authentifié.",
    ]),
  ],
  exercises: [
    ex(
      "Choisir un mode",
      "Un collègue propose AES en mode ECB avec une clé écrite dans le code. "
          "Listez les deux problèmes et ce que vous proposez à la place.",
    ),
  ],
);

Course _asymmetric() => Course(
  id: 'cr-asymmetric',
  title: 'Le chiffrement asymétrique',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Comprendre clé publique et clé privée",
    "Connaître RSA, les courbes elliptiques et Diffie-Hellman",
    "Comprendre le chiffrement hybride",
  ],
  prerequisites: ["Le chiffrement symétrique"],
  sections: [
    sec("Deux clés liées", [
      text(
        "Chaque personne possède une paire de clés. La clé publique se "
        "diffuse librement ; la clé privée ne quitte jamais son propriétaire. "
        "Ce qui est chiffré avec la clé publique ne se déchiffre qu'avec la "
        "clé privée correspondante.",
      ),
      list(
        "- **RSA** : historique ; au moins 2048 bits aujourd'hui.\n"
        "- **Courbes elliptiques** (ECC, ex. Curve25519) : même sécurité avec des clés bien plus courtes.\n"
        "- **Diffie-Hellman** : permet à deux parties de calculer un secret commun sans jamais le transmettre.",
      ),
    ]),
    sec("Le chiffrement hybride", [
      text(
        "L'asymétrique est lent. En pratique, on l'utilise pour s'accorder "
        "sur une clé symétrique, puis on chiffre les données avec AES ou "
        "ChaCha20. C'est ce que font TLS, SSH et PGP.",
      ),
    ]),
    sec("Protéger la clé privée", [
      code(
        "ssh-keygen -t ed25519 -C \"alice@laptop\"\n"
        "~/.ssh/id_ed25519      clé privée (droits 600, jamais partagée)\n"
        "~/.ssh/id_ed25519.pub  clé publique (à copier sur le serveur)",
        label: "Paire de clés SSH",
      ),
      warn(
        "Une clé privée publiée par erreur (dépôt Git, capture d'écran) est "
        "compromise : il faut la révoquer et en générer une nouvelle.",
      ),
    ]),
  ],
  commonMistakes: [
    "Envoyer sa clé privée au lieu de sa clé publique",
    "Utiliser des clés RSA de 1024 bits",
    "Laisser une clé privée lisible par tous (droits trop larges)",
  ],
  summary:
      "Clé publique pour chiffrer (ou vérifier), clé privée pour déchiffrer "
      "(ou signer). RSA 2048+, courbes elliptiques, Diffie-Hellman. En "
      "pratique : hybride, l'asymétrique sert à établir une clé symétrique.",
  quiz: [
    q(const [
      'q1',
      "Avec quelle clé déchiffre-t-on un message chiffré avec votre clé publique ?",
      'qcm',
      "Votre clé privée|Votre clé publique|N'importe quelle clé publique|Une clé AES",
      '0',
      "Seule la clé privée correspondante peut déchiffrer.",
    ]),
    q(const [
      'q2',
      "Pourquoi TLS utilise-t-il aussi un chiffrement symétrique ?",
      'qcm',
      "L'asymétrique est trop lent pour chiffrer toutes les données|Le symétrique est plus récent|Pour éviter les certificats|Par obligation légale",
      '0',
      "C'est le chiffrement hybride : l'asymétrique établit la clé, le symétrique chiffre le flux.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : la clé publique peut être diffusée librement.",
      'tf',
      'Vrai',
      null,
      "C'est son rôle ; seule la clé privée doit rester secrète.",
    ]),
  ],
  exercises: [
    ex(
      "Clés SSH du lab",
      "Dans le terminal du Lab : ls -l ~/.ssh. Quels sont les droits du "
          "dossier et de authorized_keys, et pourquoi sont-ils si restrictifs ?",
    ),
  ],
);

Course _signatures() => Course(
  id: 'cr-signatures',
  title: 'Signatures numériques et HMAC',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Comprendre comment on signe et vérifie",
    "Distinguer intégrité, authenticité et non-répudiation",
    "Savoir à quoi sert un HMAC",
  ],
  prerequisites: ["Le chiffrement asymétrique", "Les fonctions de hachage"],
  sections: [
    sec("Signer", [
      text(
        "Pour signer, on calcule l'empreinte du document puis on la "
        "transforme avec sa clé privée. Tout le monde peut vérifier la "
        "signature avec la clé publique. Si le document change d'un octet, "
        "la vérification échoue.",
      ),
      list(
        "- **Intégrité** : le contenu n'a pas été modifié.\n"
        "- **Authenticité** : il vient bien du détenteur de la clé privée.\n"
        "- **Non-répudiation** : le signataire ne peut pas nier avoir signé.",
      ),
    ]),
    sec("Partout autour de nous", [
      list(
        "- Mises à jour logicielles et paquets Linux signés.\n"
        "- Certificats TLS (signés par une autorité).\n"
        "- Jetons JWT signés.\n"
        "- Commits Git signés.",
      ),
    ]),
    sec("HMAC", [
      text(
        "Un HMAC combine une clé secrète partagée et une fonction de hachage. "
        "Il prouve l'intégrité et l'origine entre deux parties qui partagent "
        "la clé (API, webhooks, jetons de session), mais pas la "
        "non-répudiation, puisque les deux parties connaissent la clé.",
      ),
    ]),
  ],
  commonMistakes: [
    "Croire qu'une signature chiffre le document (il reste lisible)",
    "Vérifier une signature avec une clé publique obtenue par une source non fiable",
  ],
  summary:
      "Signer = empreinte transformée par la clé privée ; vérifier = clé "
      "publique. Intégrité, authenticité, non-répudiation. Le HMAC utilise "
      "une clé partagée : intégrité et origine, sans non-répudiation.",
  quiz: [
    q(const [
      'q1',
      "Avec quelle clé signe-t-on un document ?",
      'qcm',
      "Sa clé privée|Sa clé publique|La clé publique du destinataire|Un mot de passe",
      '0',
      "On signe avec la clé privée ; les autres vérifient avec la clé publique.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : une signature numérique rend le document confidentiel.",
      'tf',
      'Faux',
      null,
      "La signature garantit l'intégrité et l'origine, pas la confidentialité.",
    ]),
    q(const [
      'q3',
      "Que n'apporte PAS un HMAC ?",
      'qcm',
      "La non-répudiation|L'intégrité|La preuve d'origine entre deux parties|La détection des modifications",
      '0',
      "Les deux parties connaissent la clé : chacune aurait pu produire le HMAC.",
    ]),
  ],
  exercises: [
    ex(
      "Pourquoi signer les mises à jour ?",
      "Expliquez en quelques lignes ce qu'un attaquant pourrait faire si un "
          "logiciel installait ses mises à jour sans vérifier leur signature.",
    ),
  ],
);

Course _pki() => Course(
  id: 'cr-pki',
  title: 'Certificats et PKI',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Comprendre ce que contient un certificat",
    "Suivre une chaîne de confiance",
    "Connaître expiration et révocation",
  ],
  prerequisites: ["Signatures numériques et HMAC"],
  sections: [
    sec("Le certificat", [
      text(
        "Un certificat X.509 associe une clé publique à une identité (un nom "
        "de domaine, une organisation). Il est signé par une autorité de "
        "certification (AC) qui atteste de cette association.",
      ),
      list(
        "- Sujet (ex. www.example.com) et noms alternatifs\n"
        "- Clé publique\n"
        "- Émetteur (l'AC) et sa signature\n"
        "- Dates de validité",
      ),
    ]),
    sec("La chaîne de confiance", [
      code(
        "AC racine         (présente dans le navigateur ou le système)\n"
        "  └ AC intermédiaire  (signée par la racine)\n"
        "      └ www.example.com  (signé par l'intermédiaire)",
        label: "Chaîne",
      ),
      text(
        "Le navigateur remonte la chaîne jusqu'à une racine en laquelle il a "
        "confiance. Si un maillon manque, a expiré ou ne correspond pas au "
        "domaine, il affiche un avertissement.",
      ),
    ]),
    sec("Expiration et révocation", [
      text(
        "Les certificats ont une durée de vie courte (Let's Encrypt délivre "
        "des certificats de 90 jours, renouvelés automatiquement par ACME). "
        "Un certificat compromis avant son expiration est révoqué (CRL, "
        "OCSP).",
      ),
      warn(
        "Un certificat auto-signé chiffre la connexion mais ne prouve "
        "l'identité de personne : il ne convient pas à un site public.",
      ),
    ]),
  ],
  commonMistakes: [
    "Oublier de renouveler un certificat (site inaccessible)",
    "Utiliser un certificat auto-signé en production publique",
    "Apprendre aux utilisateurs à ignorer les avertissements",
  ],
  summary:
      "Un certificat lie une clé publique à une identité, signé par une AC. "
      "Le navigateur vérifie la chaîne jusqu'à une racine de confiance. "
      "Durée courte, renouvellement automatique, révocation si compromis.",
  quiz: [
    q(const [
      'q1',
      "Qui signe le certificat d'un site web public ?",
      'qcm',
      "Une autorité de certification|Le navigateur du visiteur|Le fournisseur d'accès|Personne",
      '0',
      "L'AC atteste que la clé publique appartient bien au domaine.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : un certificat auto-signé prouve l'identité du site auprès de tous les visiteurs.",
      'tf',
      'Faux',
      null,
      "Personne de confiance ne l'a signé : le navigateur ne peut pas vérifier l'identité.",
    ]),
    q(const [
      'q3',
      "Que fait-on d'un certificat dont la clé privée a fuité ?",
      'qcm',
      "On le révoque et on en émet un nouveau|On attend son expiration|On change le nom du site|Rien",
      '0',
      "La révocation (CRL, OCSP) signale qu'il ne faut plus lui faire confiance.",
    ]),
  ],
  exercises: [
    ex(
      "Inspecter un certificat",
      "Dans votre navigateur, cliquez sur le cadenas d'un site HTTPS et "
          "affichez son certificat : notez l'émetteur, la chaîne et la date "
          "d'expiration.",
    ),
  ],
);

Course _tls() => Course(
  id: 'cr-tls',
  title: 'TLS en détail',
  category: _cat,
  level: _level,
  levelNumber: 7,
  objectives: [
    "Suivre une poignée de main TLS 1.3",
    "Comprendre la confidentialité persistante",
    "Repérer une configuration TLS faible",
  ],
  prerequisites: ["Certificats et PKI", "HTTPS et le chiffrement TLS"],
  sections: [
    sec("La poignée de main TLS 1.3", [
      code(
        "Client → Serveur : Client Hello (versions, algorithmes, part de clé, SNI)\n"
        "Serveur → Client : Server Hello (choix, part de clé)\n"
        "                   + certificat et preuve de possession de la clé privée\n"
        "Les deux         : calculent le même secret (Diffie-Hellman éphémère)\n"
        "                   puis chiffrent tout avec une clé symétrique (AES-GCM)",
        label: "Résumé",
      ),
      tip(
        "Le Client Hello est visible dans le Lab : onglet Réseau, puis "
        "Capture, paquet 8 (filtre tls).",
      ),
    ]),
    sec("Confidentialité persistante", [
      text(
        "Avec Diffie-Hellman éphémère, chaque session a sa propre clé, "
        "oubliée ensuite. Même si la clé privée du serveur fuit plus tard, "
        "les échanges enregistrés auparavant restent indéchiffrables. TLS 1.3 "
        "l'impose.",
      ),
    ]),
    sec("Configuration faible", [
      list(
        "- SSL 3.0, TLS 1.0 et 1.1 : obsolètes, à désactiver.\n"
        "- Algorithmes faibles (RC4, 3DES, MD5) : à retirer.\n"
        "- Certificat expiré ou ne couvrant pas le domaine.\n"
        "- Absence de HSTS sur un site sensible.",
      ),
      text(
        "Des outils comme testssl.sh ou SSL Labs évaluent la configuration "
        "d'un serveur, à utiliser uniquement sur vos propres serveurs.",
      ),
    ]),
  ],
  commonMistakes: [
    "Laisser TLS 1.0 activé « pour la compatibilité »",
    "Penser que le cadenas garantit qu'un site est honnête (il garantit seulement le chiffrement et le domaine)",
  ],
  summary:
      "TLS 1.3 : échange Diffie-Hellman éphémère, authentification du serveur "
      "par certificat, puis chiffrement symétrique authentifié. "
      "Confidentialité persistante imposée. Désactiver les anciennes versions.",
  quiz: [
    q(const [
      'q1',
      "Que garantit la confidentialité persistante (forward secrecy) ?",
      'qcm',
      "Les anciennes sessions restent protégées même si la clé privée fuit plus tard|Le site ne peut pas être piraté|Le certificat n'expire jamais|Le trafic est plus rapide",
      '0',
      "Chaque session utilise une clé éphémère, jamais réutilisée.",
    ]),
    q(const [
      'q2',
      "Quelles versions doivent être désactivées ?",
      'qcm',
      "SSL 3.0, TLS 1.0 et TLS 1.1|TLS 1.2 et 1.3|Uniquement TLS 1.3|Aucune",
      '0',
      "Elles sont obsolètes et vulnérables.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : le cadenas HTTPS prouve que le site est honnête.",
      'tf',
      'Faux',
      null,
      "Il prouve le chiffrement et le nom de domaine, pas les intentions du propriétaire.",
    ]),
  ],
  exercises: [
    ex(
      "Lire un Client Hello",
      "Dans le Lab (Réseau, puis Capture), touchez le paquet 8. Quel nom de "
          "domaine (SNI) est visible en clair malgré TLS ?",
    ),
  ],
);
