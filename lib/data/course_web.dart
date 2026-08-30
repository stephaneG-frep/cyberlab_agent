import 'package:cyberlab_agent/models/course.dart';
import 'builders.dart';

List<Course> webSecurityCourses() => [
  _webIntro(),
  _httpMethods(),
  _headers(),
  _cookies(),
  _sessions(),
  _jwt(),
  _auth(),
  _api(),
  _cors(),
  _owaspIntro(),
  _owaspAccess(),
  _owaspInjection(),
];

Course _webIntro() => Course(
  id: 'web-intro',
  title: 'Comment fonctionne le web',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre le modèle client-serveur',
    'Comprendre navigateur, serveur, HTTP',
    'Comprendre la surface d\'attaque web',
  ],
  prerequisites: ['Niveau 1 Réseau (HTTP/HTTPS)'],
  sections: [
    sec('Client et serveur', [
      text(
        'Le web fonctionne sur le modèle client-serveur : votre navigateur (client) envoie des requêtes HTTP à un serveur (Apache, nginx...), qui répond avec des pages et données. C\'est le couple requête → réponse.',
      ),
      text(
        'Le serveur exécute aussi souvent du code applicatif (PHP, Python, Node) et interroge une base de données.',
      ),
    ]),
    sec('Les briques d\'un site', [
      list(
        '- **Front-end** : HTML, CSS, JavaScript qui s\'affichent dans le navigateur.\n'
        '- **Back-end** : logique serveur et traitement des requêtes.\n'
        '- **Serveur web** : sert les fichiers et le trafic HTTP.\n'
        '- **Base de données** : stocke les données (utilisateurs, produits...).',
      ),
    ]),
    sec('Comprendre la surface d\'attaque', [
      text(
        'Chaque brique peut contenir des vulnérabilités : code serveur (injections), base de données (SQLi), configuration (mauvais réglages), authentification (failles de session), front-end (XSS). La sécurité web couvre tout cela.',
      ),
    ]),
    sec('L\'importance des APIs', [
      text(
        'Aujourd\'hui, les sites et surtout les applications mobiles communiquent via des APIs (REST) qui échangent du JSON. Sécuriser les APIs est devenu un enjeu central.',
      ),
    ]),
  ],
  commonMistakes: [
    'Penser qu\'un site "sécurisé" se limite au HTTPS',
    'Négliger la sécurité du back-end et des APIs',
  ],
  summary:
      'Le web = client (navigateur) + serveur + base de données via HTTP. Chaque brique est une surface d\'attaque à sécuriser.',
  quiz: [
    q(const [
      'q1',
      'Dans le modèle web, le navigateur est...',
      'qcm',
      'le client|le serveur|la base de données|le pare-feu',
      '0',
      'Le navigateur est le client qui envoie des requêtes.',
    ]),
  ],
  exercises: [
    ex(
      'Schéma',
      'Dessinez le flux : navigateur → serveur → base de données, et indiquez où peuvent se situer des vulnérabilités.',
    ),
  ],
  xp: 80,
);

Course _httpMethods() => Course(
  id: 'web-httpmethods',
  title: 'Méthodes HTTP et leur usage',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Maîtriser les méthodes HTTP',
    'Comprendre leur rôle en sécurité',
    'Comprendre GET vs POST vs PUT/DELETE',
  ],
  prerequisites: ['HTTP depuis le niveau 1'],
  sections: [
    sec('Les méthodes courantes', [
      code(
        'GET      récupérer une ressource (paramètres en URL)\n'
        'POST     envoyer des données (paramètres dans le corps)\n'
        'PUT      remplacer une ressource\n'
        'DELETE   supprimer une ressource\n'
        'PATCH    modification partielle\n'
        'HEAD     en-têtes seuls\n'
        'OPTIONS  méthodes autorisées',
        label: 'Méthodes',
      ),
    ]),
    sec('GET vs POST', [
      text(
        'GET met les paramètres dans l\'URL (?id=5), visibles et mis en cache/historique. POST les met dans le corps de la requête. On n\'envoie JAMAIS de données sensibles (mots de passe) en GET.',
      ),
      warn(
        'Les paramètres GET apparaissent dans l\'historique, les logs et les referrers. Utilisez POST pour les données sensibles.',
      ),
    ]),
    sec('Méthodes dangereuses', [
      text(
        'PUT/DELETE/PATCH modifient des ressources. Si un serveur les accepte sans contrôle d\'accès, un attaquant peut écrire ou supprimer. Vérifiez toujours les autorisations et la validation.',
      ),
    ]),
    sec('En sécurité', [
      text(
        'Pour un test HTTP (pentest web) on manipule les méthodes avec Burp Suite ou curl : envoyer des requêtes modifiées, tester l\'autorisation, détecter des changements de comportement selon la méthode.',
      ),
    ]),
  ],
  commonMistakes: [
    'Mettre des données sensibles en GET',
    'Autoriser PUT/DELETE sans contrôle d\'accès',
  ],
  summary:
      'GET récupère (paramètres visibles en URL), POST envoie des données (dans le corps). PUT/DELETE modifient : à protéger par contrôle d\'accès.',
  quiz: [
    q(const [
      'q1',
      'Pourquoi éviter les données sensibles en GET ?',
      'qcm',
      'elles apparaissent dans l\'URL/logs/historique|GET est plus lent|POST est plus sûr uniquement|rien de tout ça',
      '0',
      'Les paramètres GET sont visibles et journalisés.',
    ]),
  ],
  exercises: [
    ex(
      'Pratique',
      'Avec curl, envoyez une requête GET puis POST vers localhost et comparez comment les paramètres sont transmis.',
    ),
  ],
  xp: 80,
);

Course _headers() => Course(
  id: 'web-headers',
  title: 'Les en-têtes HTTP',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre les en-têtes HTTP',
    'Connaître les en-têtes de sécurité',
    'Inspecter une requête/réponse',
  ],
  prerequisites: ['HTTP'],
  sections: [
    sec('Les en-têtes', [
      text(
        'Les en-têtes (headers) sont des métadonnées envoyées avec la requête et la réponse HTTP : type de contenu, cookies, serveur, etc. Ils sont précieux pour analyser et sécuriser le web.',
      ),
      code(
        'Réponse typique:\n'
        'HTTP/1.1 200 OK\n'
        'Content-Type: text/html\n'
        'Server: nginx/1.24.0\n'
        'Set-Cookie: session=abcd1234; HttpOnly',
        label: 'Exemple',
      ),
    ]),
    sec('En-têtes de sécurité essentiels', [
      code(
        'Strict-Transport-Security (HSTS) : force HTTPS\n'
        'X-Frame-Options               : anti clickjacking\n'
        'Content-Security-Policy (CSP) : limite sources de scripts\n'
        'X-Content-Type-Options        : empêche le sniffing MIME\n'
        'Referrer-Policy               : contrôle le referrer',
        label: 'Sécurité',
      ),
    ]),
    sec('En-têtes à analyser', [
      text(
        'Un en-tête Server qui révèle la version exacte (ex: Apache/2.4.1) aide un attaquant à chercher des vulnérabilités connues. Le X-Powered-By révèle la technologie. On documente ces informations en pentest.',
      ),
    ]),
    sec('Inspector les en-têtes', [
      text(
        'Le navigateur (outils de développement, onglet Réseau), curl -I ou Burp montrent les en-têtes. Vérifier la présence des en-têtes de sécurité est un premier audit rapide.',
      ),
      code(
        'curl -I https://exemple.com   # affiche les en-têtes de réponse',
        label: 'curl',
      ),
    ]),
  ],
  commonMistakes: [
    'Ignorer l\'en-tête Server qui révèle des versions',
    'Oublier de configurer les en-têtes de sécurité (HSTS, CSP)',
  ],
  summary:
      'Les en-têtes HTTP transportent métadonnées et cookie. Les en-têtes de sécurité (HSTS, CSP, X-Frame-Options) renforcent la protection.',
  quiz: [
    q(const [
      'q1',
      'Quel en-tête force l\'utilisation de HTTPS ?',
      'qcm',
      'Strict-Transport-Security|Content-Type|Server|Set-Cookie',
      '0',
      'HSTS force le navigateur à utiliser HTTPS.',
    ]),
  ],
  exercises: [
    ex(
      'Audit',
      'Via curl -I localhost (dans le terminal simulé) ou un site que vous contrôlez, listez les en-têtes et identifiez ceux de sécurité.',
    ),
  ],
  xp: 80,
);

Course _cookies() => Course(
  id: 'web-cookies',
  title: 'Les cookies',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre le rôle des cookies',
    'Distinguer cookies de session et de suivi',
    'Comprendre les attributs de sécurité',
  ],
  prerequisites: ['Headers HTTP'],
  sections: [
    sec('C\'est quoi un cookie ?', [
      text(
        'Un cookie est une petite donnée que le serveur demande au navigateur de stocker et de renvoyer à chaque requête. Il sert à "se souvenir" de l\'état (connexion, préférences).',
      ),
    ]),
    sec('Cookie de session et de suivi', [
      list(
        '- **Session** : identifie une session authentifiée (ex: mot de passe de session).\n'
        '- **Suivi** : analysis, publicité (suivre l\'utilisateur entre sites).',
      ),
    ]),
    sec('Attributs de sécurité d\'un cookie', [
      code(
        'Secure      : envoyé uniquement en HTTPS\n'
        'HttpOnly    : inaccessible au JavaScript (anti-XSS)\n'
        'SameSite    : limites d\'envoi cross-site (anti-CSRF)\n'
        'Domain/Path : portée du cookie\n'
        'Expires/Max-Age : durée de vie',
        label: 'Attributs',
      ),
      text(
        'Un cookie de session SANS HttpOnly peut être volé par un script XSS. SANS Secure, il transite en clair. Il doit aussi être aléatoire et difficile à deviner.',
      ),
    ]),
    sec('Les attaques sur les cookies', [
      text(
        'Les cookies sont ciblés par : le vol de session (via XSS, sniffing), la prédiction (session faible), et le fixation (imposer un cookie avant l\'authentification). Utiliser des cookies HttpOnly, Secure, SameSite et aléatoires limite ces risques.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ne pas mettre HttpOnly sur les cookies de session',
    'Utiliser des cookies de session prévisibles',
  ],
  summary:
      'Les cookies stockent l\'état côté navigateur. Les attributs Secure, HttpOnly, SameSite et l\'aléatoire protègent contre XSS, CSRF et vol de session.',
  quiz: [
    q(const [
      'q1',
      'Quel attribut rend un cookie inaccessible au JavaScript ?',
      'qcm',
      'HttpOnly|Secure|SameSite|Expires',
      '0',
      'HttpOnly bloque l\'accès par le JavaScript.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Dans le terminal simulé, exécutez "curl -v localhost" et observez les éventuels cookies et en-têtes Set-Cookie dans la réponse.',
    ),
  ],
  xp: 90,
);

Course _sessions() => Course(
  id: 'web-sessions',
  title: 'Les sessions et l\'authentification',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre le mécanisme de session',
    'Comprendre le cycle login/logout',
    'Connaître les attaques sur les sessions',
  ],
  prerequisites: ['Cookies'],
  sections: [
    sec('Le mécanisme de session', [
      text(
        'Quand vous vous authentifiez, le serveur crée une session et vous délivre un identifiant de session (souvent dans un cookie). Pour les requêtes suivantes, le navigateur renvoie cet identifiant, et le serveur reconnaît votre état connecté.',
      ),
    ]),
    sec('Le cycle de vie', [
      text(
        'Une session doit : être créée à la connexion, expirer après inactivité ou durée maximale, et être invalidée à la déconnexion. Une session qui ne se termine jamais est un risque.',
      ),
    ]),
    sec('Les attaques sur les sessions', [
      list(
        '- **Vol de session** : l\'attaquant vole l\'identifiant (XSS, man-in-the-middle).\n'
        '- **Fixation** : l\'attaquant impose son propre identifiant avant la connexion.\n'
        '- **Prédiction** : si l\'identifiant est prévisible, on le devine.\n'
        '- **Expiration** : session jamais expirée, exploitable plus tard.',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Identifiants de session longs et aléatoires.\n'
        '- Régénérer l\'identifiant après connexion.\n'
        '- Expirer par inactivité et durée maximale.\n'
        '- Invalidé la session à la déconnexion.\n'
        '- Cookie HttpOnly, Secure, SameSite.',
      ),
    ]),
  ],
  commonMistakes: [
    'Ne pas régénérer l\'identifiant après login',
    'Sessions sans expiration',
  ],
  summary:
      'Les sessions maintiennent l\'état connecté via un identifiant. Leur sécurité repose sur l\'aléatoire, la régénération, l\'expiration et les attributs du cookie.',
  quiz: [
    q(const [
      'q1',
      'Une bonne pratique de session est...',
      'qcm',
      'régénérer l\'identifiant après connexion|garder la session éternelle|un identifiant court et prévisible|ignorer l\'expiration',
      '0',
      'On régénère l\'identifiant et on fait expirer la session.',
    ]),
  ],
  exercises: [
    ex(
      'Sécurité',
      'Listez 3 mesures pour protéger les sessions contre le vol d\'identifiant.',
    ),
  ],
  xp: 90,
);

Course _jwt() => Course(
  id: 'web-jwt',
  title: 'JWT',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre JWT',
    'Décomposer header, payload, signature',
    'Connaître les failles JWT courantes',
  ],
  prerequisites: ['Sessions, crypto (hashing)'],
  sections: [
    sec('C\'est quoi JWT ?', [
      text(
        'JWT (JSON Web Token) est un format de jeton d\'authentification : un morceau de données signé qui contient des informations (claims) et des preuves d\'authenticité. Utilisé dans les APIs sans état (stateless).',
      ),
    ]),
    sec('La structure', [
      text(
        'Un JWT = 3 parties Base64URL, séparées par des points : en-tête.payLoad.signature',
      ),
      code(
        'header.payLoad.signature\n'
        'ex: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYWxpY2UifQ.mNq...',
        label: 'Structure',
      ),
      list(
        '- **Header** : algorithme de signature (ex: HS256, RS256).\n'
        '- **Payload** : les claims (utilisateur, rôle, expiration exp, iat).\n'
        '- **Signature** : garantit l\'intégrité (hash + clé).',
      ),
    ]),
    sec('Signé mais PAS chiffré', [
      text(
        'Le payload d\'un JWT n\'est pas chiffré : il est seulement encodé en Base64URL. N\'y mettez jamais de secret. La signature (avec une clé) assure que personne ne peut le modifier sans la clé.',
      ),
    ]),
    sec('Les failles JWT', [
      list(
        '- **Clé faible** : une clé secrète devinable permet de forger des jetons.\n'
        '- **alg: none** : si le serveur accepte "none", on peut supprimer la signature.\n'
        '- **Confusion d\'algorithme** : passer de RS256 à HS256 avec la clé publique.\n'
        '- **Manipulation du payload** : modifier les rôles si la vérification est faible.',
      ),
      warn(
        'En test, on essaie de deviner la clé ou de trafiquer le jeton. Uniquement sur vos propres applications/lab.',
      ),
    ]),
  ],
  commonMistakes: [
    'Mettre des secrets dans le payload',
    'Ne pas vérifier la signature/expiration',
  ],
  summary:
      'JWT est un jeton signé (header.payload.signature) pour l\'authentification des APIs. Les failles : clé faible, alg none, confusion d\'algo.',
  quiz: [
    q(const [
      'q1',
      'Le payload d\'un JWT est...',
      'qcm',
      'encodé en Base64URL, pas chiffré|crypté avec AES|vidé|toujours chiffré',
      '0',
      'Le payload est encodé, pas chiffré : pas de secrets dedans.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Décodez un JWT fictif en 3 parties et expliquez ce que la signature protège. (Pensez à la crypto pour le HS256.)',
    ),
  ],
  xp: 90,
);

Course _auth() => Course(
  id: 'web-auth',
  title: 'Authentification et autorisation',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Distinguer authentification et autorisation',
    'Connaître les méthodes d\'authentification',
    'Comprendre les failles',
  ],
  prerequisites: ['Sessions'],
  sections: [
    sec('Authentification vs autorisation', [
      text(
        'L\'authentification prouve QUI vous êtes (identité). L\'autorisation définit CE QUE vous pouvez faire (droits). Les deux sont distincts : se connecter (authn) ≠ avoir le droit d\'accéder (authz).',
      ),
    ]),
    sec('Méthodes d\'authentification', [
      list(
        '- Mot de passe.\n'
        '- 2FA (code, clé, biométrie).\n'
        '- SSO / JWT / OAuth.\n'
        '- Clés API pour les machines.',
      ),
      text(
        'Pour un mot de passe, on vérifie un hash salé, jamais le mot de passe en clair (voir crypto).',
      ),
    ]),
    sec('Failles d\'authentification courantes', [
      list(
        '- Mots de passe faibles / par défaut.\n'
        '- Pas de limitation de tentatives (brute-force).\n'
        '- Énumération d\'utilisateurs (réponses différentes).\n'
        '- Fonction "mot de passe oublié" vulnérable.\n'
        '- Verification d\'identité insuffisante.',
      ),
    ]),
    sec('Failles d\'autorisation', [
      text(
        'Les failles de contrôle d\'accès (voir cours OWASP Access) surviennent quand on peut accéder à des ressources sans être autorisé : modifier un ID dans l\'URL, accéder à un admin autrement, etc.',
      ),
    ]),
  ],
  commonMistakes: [
    'Confondre authentification et autorisation',
    'Ne pas limiter les tentatives de connexion',
  ],
  summary:
      'L\'authentification prouve qui vous êtes, l\'autorisation ce que vous pouvez faire. Les failles touchent les deux (brute-force, mauvaise gestion des droits).',
  quiz: [
    q(const [
      'q1',
      'Vérifier le mot de passe relève de...',
      'qcm',
      'l\'authentification|l\'autorisation|la disponibilité|le stockage',
      '0',
      'Vérifier l\'identité = authentification.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Donnez un exemple où l\'authentification réussit mais où l\'autorisation était insuffisante (accès non autorisé à une ressource).',
    ),
  ],
  xp: 90,
);

Course _api() => Course(
  id: 'web-api',
  title: 'APIs et REST',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre les APIs REST',
    'Comprendre les enjeux de sécurité',
    'Connaître les bonnes pratiques',
  ],
  prerequisites: ['Méthodes HTTP, JSON'],
  sections: [
    sec('C\'est quoi une API REST ?', [
      text(
        'Une API REST expose des opérations sur des ressources via les méthodes HTTP et échange souvent du JSON. Une application mobile ou un front-end appelle ces API pour lire/écrire des données.',
      ),
      code(
        'GET    /api/users/1      → lire l\'utilisateur 1\n'
        'POST   /api/users        → créer un utilisateur\n'
        'PUT    /api/users/1      → remplacer\n'
        'DELETE /api/users/1      → supprimer',
        label: 'REST',
      ),
    ]),
    sec('L\'authentification des APIs', [
      text(
        'Les APIs s\'authentifient souvent par JWT, clés API ou OAuth. Une clé API est un secret : elle ne doit jamais apparaître dans le front-end, le code source (dépôt git) ou les logs.',
      ),
      warn(
        'Ne JAMAIS stocker de clé API dans le code source, un ZIP publié ou un dépôt git. Utilisez des variables d\'environnement ou un gestionnaire de secrets sécurisé.',
      ),
    ]),
    sec('Failles API courantes', [
      list(
        '- Manque de validation des entrées.\n'
        '- Contrôle d\'accès défaillant (accès à des ressources d\'autres utilisateurs).\n'
        '- Sensibilité aux injections (jSON/SQL).\n'
        '- Exposition de données sensibles (listes massives).\n'
        '- Réponse excessive (trop d\'info dans le JSON).\n'
        '- Rate limiting absent (consommation abusive).',
      ),
    ]),
    sec('Bonnes pratiques', [
      list(
        '- Valider et limiter les entrées.\n'
        '- Contrôler l\'accès à chaque ressource.\n'
        '- Ne renvoyer que les champs nécessaires.\n'
        '- Implémenter le rate limiting.\n'
        '- Ne pas exposer de clés. Protéger par TLS.',
      ),
    ]),
  ],
  commonMistakes: [
    'Exposer des clés API dans le front-end',
    'Renvoyer trop de données (fuite d\'informations)',
  ],
  summary:
      'Les APIs REST échangent des données via HTTP/JSON. Sécuriser consiste à valider les entrées, contrôler l\'accès, limiter les réponses et protéger les clés.',
  quiz: [
    q(const [
      'q1',
      'Une clé API doit idéalement être stockée...',
      'qcm',
      'dans une variable d\'environnement côté serveur|dans le front-end|dans le dépôt git|dans les logs',
      '0',
      'Les clés vont dans des variables d\'environnement ou un gestionnaire de secrets, jamais exposées.',
    ]),
  ],
  exercises: [ex('Sécurité', 'Listez 4 failles API courantes et leur remède.')],
  xp: 90,
);

Course _cors() => Course(
  id: 'web-cors',
  title: 'CORS et Same-Origin Policy',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre la Same-Origin Policy',
    'Comprendre le rôle de CORS',
    'Connaître les risques CORS',
  ],
  prerequisites: ['Cookies, APIs'],
  sections: [
    sec('La Same-Origin Policy', [
      text(
        'La Same-Origin Policy (SOP) est une règle de sécurité du navigateur : un script d\'une origine ne peut pas lire librement les données d\'une autre origine. Une origine = protocole + domaine + port.',
      ),
      text(
        'Cette règle empêche par exemple un site malveillant de voler les données d\'un site de banque ouvert dans un autre onglet.',
      ),
    ]),
    sec('Le problème CORS', [
      text(
        'Parfois, on veut légitimement qu\'un site appelle une API d\'un autre domaine. CORS (Cross-Origin Resource Sharing) est un mécanisme d\'en-têtes qui autorise (ou non) ces échanges cross-origin.',
      ),
    ]),
    sec('Les en-têtes CORS', [
      code(
        'Access-Control-Allow-Origin: https://site-légitime.com\n'
        'Access-Control-Allow-Credentials: true',
        label: 'CORS',
      ),
      text(
        'Si le serveur renvoie Access-Control-Allow-Origin: * (tout le monde) AVEC Allow-Credentials, ou s\'il reflète n\'importe quelle origine, alors un site malveillant peut lire les réponses et voler des données.',
      ),
    ]),
    sec('Les failles CORS', [
      list(
        '- **Reflexion de l\'origine** : le serveur renvoie l\'origine reçue sans la vérifier.\n'
        '- **Wildcard avec credentials** : * autorisé avec cookies.\n'
        '- **Origines mal vérifiées** : accepter site.example vs exemple.fr.',
      ),
      text(
        'Un mauvais CORS peut permettre l\'exfiltration de données (lecture de réponses sensibles) par un site tiers.',
      ),
    ]),
  ],
  commonMistakes: [
    'Autoriser * avec Allow-Credentials',
    'Réfléchir l\'origine sans liste blanche',
  ],
  summary:
      'La SOP protège les données cross-origin. CORS assouplit cette règle via des en-têtes, mais un mauvais CORS (wildcard, reflection) crée des failles.',
  quiz: [
    q(const [
      'q1',
      'Une origine - c\'est...',
      'qcm',
      'protocole + domaine + port|juste le domaine|juste le port|l\'adresse MAC',
      '0',
      'L\'origine combine protocole, domaine et port.',
    ]),
  ],
  exercises: [
    ex(
      'Analyser',
      'Expliquez pourquoi "Access-Control-Allow-Origin: *" avec credentials est dangereux.',
    ),
  ],
  xp: 90,
);

Course _owaspIntro() => Course(
  id: 'web-owasp',
  title: 'OWASP : top des risques Web',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre ce qu\'est l\'OWASP',
    'Connaître les grandes catégories de risques',
    'Savoir où apprendre les vulnérabilités',
  ],
  prerequisites: ['Sécurité Web'],
  sections: [
    sec('L\'OWASP', [
      text(
        'L\'OWASP (Open Worldwide Application Security Project) est une communauté qui publie des ressources de référence sur la sécurité des applications web, dont le fameux "Top 10" des risques les plus critiques.',
      ),
      text(
        'Le Top 10 est un excellent point de départ pour comprendre où concentrer ses efforts.',
      ),
    ]),
    sec('Grandes catégories de risques', [
      list(
        '- **Défaillance concernant le contrôle d\'accès**.\n'
        '- **Failles cryptographiques**.\n'
        '- **Injection (SQL, commandes)**.\n'
        '- **Conception non sécurisée**.\n'
        '- **Mauvaise configuration de sécurité**.\n'
        '- **Composants vulnérables et obsolètes**.\n'
        '- **Échec de l\'identification et de l\'authentification**.\n'
        '- **Problèmes d\'intégrité des logiciels et des données**.\n'
        '- **Défaillance de surveillance et de journalisation**.\n'
        '- **Falsification de requête côté serveur (SSRF)**.',
      ),
      text(
        'Pour chaque risque, on apprend : explication, exemple, impact, démonstration en lab, exercice, correction, bonnes pratiques.',
      ),
    ]),
    sec('Une méthode pour chaque vulnérabilité', [
      text(
        'Dans CyberLab, chaque vulnérabilité se traite avec une démarche : 1) explication, 2) exemple, 3) impact, 4) démonstration en labo, 5) exercice, 6) correction, 7) bonnes pratiques. On privilégie toujours l\'apprentissage de la correction.',
      ),
    ]),
  ],
  commonMistakes: [
    'Se limiter au Top 10 (il évolue, restez à jour)',
    'Apprendre à attaquer sans apprendre à corriger',
  ],
  summary:
      'L\'OWASP publie le Top 10 des risques web. On étudie chaque vulnérabilité avec une méthode complète, en privilégiant la correction.',
  quiz: [
    q(const [
      'q1',
      'L\'OWASP est...',
      'qcm',
      'une communauté/ressource de référence sur la sécurité web|un antivirus|un serveur|un langage',
      '0',
      'L\'OWASP est une communauté de référence sur la sécurité applicative.',
    ]),
  ],
  exercises: [
    ex(
      'Recherche',
      'Citez 3 catégories du Top 10 OWASP que vous connaissez et donnez un exemple bref pour chacune.',
    ),
  ],
  xp: 80,
);

Course _owaspAccess() => Course(
  id: 'web-owasp-access',
  title: 'Le contrôle d\'accès (OWASP A01)',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre les failles de contrôle d\'accès',
    'Identifier un accès non autorisé',
    'Corriger et prévenir',
  ],
  prerequisites: ['Authentification/autorisation'],
  sections: [
    sec('1. Explication', [
      text(
        'Une faille de contrôle d\'accès survient quand un utilisateur peut accéder à des fonctions ou des données pour lesquelles il n\'est pas autorisé. C\'est l\'une des vulnérabilités les plus répandues et critiques.',
      ),
    ]),
    sec('2. Exemple', [
      text(
        'Exemple : vous êtes connecté en tant qu\'utilisateur normal, mais en changeant l\'ID dans l\'URL "GET /api/users/5" en "/api/users/1", vous accédez au profil de l\'administrateur (IDOR). Ou vous retrouvez un bouton admin qui n\'apparaît pourtant pas à l\'écran.',
      ),
      code(
        'GET /api/orders/123   (normal)\n'
        'GET /api/orders/1     (accès à la commande d\'un autre)',
        label: 'IDOR',
      ),
    ]),
    sec('3. Impact', [
      text(
        'Impact : fuite de données, lecture/écriture non autorisée, élévation de privilèges. Une faille de contrôle d\'accès peut exposer les données de tous les utilisateurs.',
      ),
    ]),
    sec('4. Démonstration (labo)', [
      text(
        'Sur une application de laboratoire (DVWA, Juice Shop, WebGoat, ou votre propre app), on tente d\'accéder à une ressource en modifiant l\'ID et en se connectant avec un compte à faibles droits.',
      ),
    ]),
    sec('5. Correction', [
      text(
        'La correction : vérifier l\'autorisation côté serveur pour chaque ressource, jamais se fier à l\'interface ou à des champs cachés. On applique le principe du moindre privilège et un contrôle d\'accès centralisé.',
      ),
    ]),
    sec('6. Bonnes pratiques', [
      list(
        '- Vérifier l\'autorisation à chaque requête, pas seulement au login.\n'
        '- Refuser par défaut.\n'
        '- Utiliser des identifiants non devinables et des références indirectes.\n'
        '- Ne pas exposer d\'indices (boutons admin cachés).\n'
        '- Tester les accès avec des comptes à différents rôles.',
      ),
    ]),
  ],
  commonMistakes: [
    'Faire confiance à l\'interface (masquer, sans vérifier côté serveur)',
    'Ne tester les accès qu\'avec un seul rôle',
  ],
  summary:
      'Les failles de contrôle d\'accès permettent d\'accéder à des ressources non autorisées. On corrige en vérifiant l\'autorisation serveur à chaque accès, en refusant par défaut.',
  quiz: [
    q(const [
      'q1',
      'Un IDOR est une faille...',
      'qcm',
      'de contrôle d\'accès où on change un ID pour accéder à la ressource d\'un autre|de chiffrement|de réseau|de disque',
      '0',
      'IDOR = Insecure Direct Object Reference : on manipule un identifiant pour un accès non autorisé.',
    ]),
  ],
  exercises: [
    ex(
      'Tester (labo)',
      'Sur une app de laboratoire, connectez-vous avec un compte à faibles droits et tentez d\'accéder à une ressource d\'un autre compte en modifiant l\'ID. Puis proposez la correction.',
    ),
  ],
  xp: 100,
);

Course _owaspInjection() => Course(
  id: 'web-owasp-injection',
  title: 'Les injections (OWASP A03)',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    'Comprendre les injections SQL et commandes',
    'Identifier les injections',
    'Prévenir par les requêtes paramétrées',
  ],
  prerequisites: ['Web basics'],
  sections: [
    sec('1. Explication', [
      text(
        'Une injection se produit quand une entrée utilisateur est interprétée comme du code (SQL, commandes système, HTML). L\'attaquant "injecte" du code qui s\'exécute.',
      ),
    ]),
    sec('2. Exemple (SQLi)', [
      code(
        'Requête vulnérable :\n'
        'SELECT * FROM users WHERE user = \'\$user\' AND pass = \'\$pass\'\n'
        '\n'
        'Entrée malveillante : user = \'admin\' --   \n'
        'Résultat : SELECT * FROM users WHERE user = \'admin\' --...\n'
        '           (le -- commente le reste → contourne le mot de passe)',
        label: 'SQLi',
      ),
      text(
        'Le caractère -- (ou \' OR 1=1 --) "casse" la requête pour la détourner.',
      ),
    ]),
    sec('3. Impact', [
      text(
        'Impact : lecture/écriture de la base (données volées), bypass d\'authentification, parfois exécution de commandes, voire prise de contrôle complet.',
      ),
    ]),
    sec('4. Démonstration (labo)', [
      text(
        'Sur une application volontairement vulnérable (DVWA, WebGoat), on teste des entrées dans un formulaire de recherche et on observe les erreurs SQL ou les comportements anormaux. EN LAB UNIQUEMENT.',
      ),
    ]),
    sec('5. Correction', [
      text(
        'La correction principale : utiliser des requêtes paramétrées (requêtes préparées / prepared statements) et une validation stricte des entrées. Ne jamais concaténer les entrées dans une requête.',
      ),
      code(
        '# Requête paramétrée (sûr) :\n'
        'WHERE user = ?   (le ? est remplacé sans interprétation)',
        label: 'Correction',
      ),
    ]),
    sec('6. Bonnes pratiques', [
      list(
        '- Requêtes paramétrées / prepared statements.\n'
        '- Validation côté serveur (types, longueurs, listes blanches).\n'
        '- Principe du moindre privilège pour la base.\n'
        '- Échapper/stériliser selon le contexte.\n'
        '- Ne pas afficher les messages d\'erreur SQL bruts.',
      ),
    ]),
  ],
  commonMistakes: [
    'Concaténer les entrées dans les requêtes SQL',
    'Afficher les erreurs SQL détaillées aux utilisateurs',
  ],
  summary:
      'Les injections interprètent une entrée comme du code (SQL, commandes). On corrige par requêtes paramétrées, validation des entrées et moindre privilège.',
  quiz: [
    q(const [
      'q1',
      'La meilleure protection contre les injections SQL est...',
      'qcm',
      'les requêtes paramétrées|masquer les formulaires|chiffrer le site|supprimer la base',
      '0',
      'Les requêtes paramétrées empêchent l\'interprétation de l\'entrée comme code.',
    ]),
  ],
  exercises: [
    ex(
      'Corriger',
      'Montrez comment sécuriser la requête SQL: SELECT * FROM users WHERE user = \'\$user\'. Réponse : utiliser un paramètre.',
    ),
  ],
  xp: 100,
);
