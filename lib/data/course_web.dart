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
  _xss(),
  _csrf(),
  _ssrf(),
  _upload(),
  _misconfig(),
  _components(),
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
    q(const [
      'q2',
      "Quelle brique d'un site s'exécute dans le navigateur ?",
      'qcm',
      "Le front-end|Le back-end|La base de données|Le serveur web",
      '0',
      "HTML, CSS et JavaScript s'exécutent côté client.",
    ]),
    q(const [
      'q3',
      "Dans quel format les API REST échangent-elles le plus souvent ?",
      'qcm',
      "PDF|JSON|CSS|ZIP",
      '1',
      "C'est le format courant des applications web et mobiles.",
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
      "elles apparaissent dans l'URL/logs/historique|elles sont limitées à quelques caractères seulement|elles sont modifiées par le serveur à la réception|GET ne fonctionne pas en HTTPS",
      '0',
      'Les paramètres GET sont visibles et journalisés.',
    ]),
    q(const [
      'q2',
      "Quelle méthode modifie partiellement une ressource ?",
      'qcm',
      "HEAD|GET|PATCH|OPTIONS",
      '2',
      "PUT remplace la ressource entière.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : accepter DELETE sans contrôle d'accès est dangereux.",
      'tf',
      'Vrai',
      null,
      "N'importe qui pourrait supprimer des ressources.",
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
      "Strict-Transport-Security|Access-Control-Allow-Origin|X-Content-Type-Options|Content-Disposition",
      '0',
      'HSTS force le navigateur à utiliser HTTPS.',
    ]),
    q(const [
      'q2',
      "Quel risque pose un en-tête Server trop précis ?",
      'qcm',
      "Révéler une version vulnérable|Ralentir les réponses du serveur|Bloquer les navigateurs|Désactiver les cookies",
      '0',
      "L'attaquant cherche les failles connues de cette version.",
    ]),
    q(const [
      'q3',
      "Quel en-tête limite les sources de scripts autorisées ?",
      'qcm',
      "Strict-Transport-Security|Content-Security-Policy|X-Content-Type-Options|Referrer-Policy",
      '1',
      "La CSP réduit l'impact d'une XSS.",
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
        '- **Session** : identifie une session authentifiée (ex: un identifiant de session).\n'
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
    q(const [
      'q2',
      "Que garantit l'attribut Secure ?",
      'qcm',
      "L'invisibilité au JavaScript|Le chiffrement sur le disque|L'envoi uniquement en HTTPS|L'expiration à la fermeture",
      '2',
      "HttpOnly protège de JavaScript ; Secure, du transport en clair.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : SameSite aide à limiter la CSRF.",
      'tf',
      'Vrai',
      null,
      "Il restreint l'envoi du cookie depuis d'autres sites.",
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
    q(const [
      'q2',
      "Qu'est-ce que la fixation de session ?",
      'qcm',
      "Imposer un identifiant avant la connexion|Voler un identifiant grâce à un script XSS|Deviner un mot de passe faible|Bloquer le compte de la victime",
      '0',
      "D'où la régénération de l'identifiant après connexion.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : une session doit rester valide après la déconnexion.",
      'tf',
      'Faux',
      null,
      "Elle doit être invalidée côté serveur.",
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
      "encodé en Base64URL, pas chiffré|chiffré avec la clé du serveur (AES)|haché avec SHA-256, illisible|compressé en gzip, donc illisible",
      '0',
      'Le payload est encodé, pas chiffré : pas de secrets dedans.',
    ]),
    q(const [
      'q2',
      "Que garantit la signature d'un JWT ?",
      'qcm',
      "Le secret du contenu|L'anonymat du client|L'intégrité du jeton|La vitesse de l'API",
      '2',
      "Sans la clé, personne ne peut modifier le contenu sans être détecté.",
    ]),
    q(const [
      'q3',
      "En quoi l'attaque alg: none consiste-t-elle ?",
      'qcm',
      "À deviner la clé secrète du serveur|À chiffrer le jeton une seconde fois|À prolonger la durée du jeton|À faire accepter un jeton sans signature",
      '3',
      "Le serveur doit imposer l'algorithme attendu.",
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
    q(const [
      'q2',
      "Qu'est-ce que l'énumération d'utilisateurs ?",
      'qcm',
      "Déduire quels comptes existent|Compter les connexions du jour|Créer des comptes en masse|Trier les comptes par rôle",
      '0',
      "Des réponses différentes trahissent l'existence d'un compte.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : être connecté donne automatiquement accès à toutes les ressources.",
      'tf',
      'Faux',
      null,
      "Authentification et autorisation sont distinctes.",
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
      "dans une variable d'environnement côté serveur|dans le code JavaScript envoyé au navigateur|dans un fichier versionné du dépôt Git public|dans les journaux, pour la retrouver facilement",
      '0',
      'Les clés vont dans des variables d\'environnement ou un gestionnaire de secrets, jamais exposées.',
    ]),
    q(const [
      'q2',
      "Quel est le rôle du rate limiting ?",
      'qcm',
      "Chiffrer les réponses JSON|Valider le format des données|Limiter le nombre de requêtes|Masquer l'adresse du serveur",
      '2',
      "Il freine les abus et la force brute.",
    ]),
    q(const [
      'q3',
      "Qu'est-ce qu'une réponse excessive ?",
      'qcm',
      "Une réponse envoyée trop lentement|Une réponse trop bien compressée|Une réponse sans code de statut|Une réponse qui contient trop de champs",
      '3',
      "On ne renvoie que les champs nécessaires.",
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
        'Si le serveur reflète n\'importe quelle origine AVEC Allow-Credentials, un site malveillant peut lire les réponses d\'un utilisateur connecté. La combinaison * et Allow-Credentials, elle, est refusée par les navigateurs : * n\'expose que ce qui est accessible sans connexion.',
      ),
    ]),
    sec('Les failles CORS', [
      list(
        '- **Reflexion de l\'origine** : le serveur renvoie l\'origine reçue sans la vérifier.\n'
        '- **Wildcard (*)** : à réserver aux données publiques.\n'
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
      "protocole + domaine + port|domaine + chemin de la page|adresse IP + adresse MAC|protocole + chemin + paramètres",
      '0',
      'L\'origine combine protocole, domaine et port.',
    ]),
    q(const [
      'q2',
      "Que fait la Same-Origin Policy ?",
      'qcm',
      "Empêche un site de lire les données d'un autre|Chiffre les échanges entre deux sites différents|Bloque tous les cookies tiers|Interdit les liens vers d'autres sites",
      '0',
      "CORS permet d'y faire des exceptions contrôlées.",
    ]),
    q(const [
      'q3',
      "Quelle configuration CORS est dangereuse ?",
      'qcm',
      "N'autoriser qu'une origine précise|Refléter toute origine avec les cookies|N'envoyer aucun en-tête CORS|Réserver * aux données publiques",
      '1',
      "Un site tiers pourrait lire les données d'un utilisateur connecté.",
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
    sec('Le Top 10 2025', [
      list(
        '- **A01** : défaillance du contrôle d\'accès (inclut la SSRF).\n'
        '- **A02** : mauvaise configuration de sécurité.\n'
        '- **A03** : défaillances de la chaîne d\'approvisionnement logicielle.\n'
        '- **A04** : défaillances cryptographiques.\n'
        '- **A05** : injection (SQL, commandes, XSS).\n'
        '- **A06** : conception non sécurisée.\n'
        '- **A07** : défaillances d\'authentification.\n'
        '- **A08** : défaillances d\'intégrité des logiciels ou des données.\n'
        '- **A09** : défaillances de journalisation et d\'alerte.\n'
        '- **A10** : mauvaise gestion des conditions exceptionnelles.',
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
      "une communauté/ressource de référence sur la sécurité web|un organisme public qui délivre les certificats HTTPS|un antivirus spécialisé dans l'analyse des sites web|une norme obligatoire pour héberger un site en Europe",
      '0',
      'L\'OWASP est une communauté de référence sur la sécurité applicative.',
    ]),
    q(const [
      'q2',
      "Qu'est-ce que le Top 10 de l'OWASP ?",
      'qcm',
      "Un classement des meilleurs sites|Une certification obligatoire|Une liste de risques web majeurs|Un outil d'analyse automatique",
      '2',
      "C'est un point de départ pour prioriser ses efforts.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : une mauvaise journalisation figure parmi les grands risques web.",
      'tf',
      'Vrai',
      null,
      "Sans surveillance, une attaque passe inaperçue.",
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
      "où changer un ID donne accès à la ressource d'un autre|où un mot de passe trop court est deviné par force brute|où un script s'exécute dans le navigateur d'un visiteur|où le trafic est lu faute de chiffrement TLS",
      '0',
      'IDOR = Insecure Direct Object Reference : on manipule un identifiant pour un accès non autorisé.',
    ]),
    q(const [
      'q2',
      "Où faut-il vérifier les autorisations ?",
      'qcm',
      "Côté serveur, à chaque requête|Dans l'interface, en masquant des boutons|Une seule fois, à la connexion|Dans un champ caché du formulaire",
      '0',
      "Tout ce qui est côté client peut être modifié.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : cacher le bouton d'administration suffit à protéger la page.",
      'tf',
      'Faux',
      null,
      "L'adresse reste accessible à qui la connaît ou la devine.",
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
  title: 'Les injections (OWASP A05)',
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
        'Entrée malveillante : admin\' -- \n'
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
    q(const [
      'q2',
      "Que permet souvent -- dans une injection SQL ?",
      'qcm',
      "De chiffrer le mot de passe saisi|De créer une nouvelle table|De commenter la suite de la requête|De fermer la connexion à la base",
      '2',
      "La vérification du mot de passe est alors ignorée.",
    ]),
    q(const [
      'q3',
      "Pourquoi ne pas afficher les erreurs SQL brutes ?",
      'qcm',
      "Elles ralentissent la base|Elles bloquent les visiteurs|Elles coûtent de l'espace|Elles renseignent l'attaquant",
      '3',
      "Elles révèlent la structure de la base et des requêtes.",
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

// ---------------------------------------------------------------------------
// Familles OWASP complémentaires. La numérotation citée est celle de
// l'édition 2025 du Top 10 ; le classement est révisé régulièrement, mais les
// familles de failles restent.
// ---------------------------------------------------------------------------

Course _xss() => Course(
  id: 'web-xss',
  title: 'Le cross-site scripting (XSS)',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Comprendre les XSS réfléchi, stocké et DOM",
    "Savoir ce qu'un attaquant peut faire avec une XSS",
    "Appliquer l'encodage en sortie et la CSP",
  ],
  prerequisites: ["Les injections (OWASP A05)", "Les cookies"],
  sections: [
    sec("Le principe", [
      text(
        "Une XSS survient quand une application insère dans sa page une "
        "donnée fournie par l'utilisateur sans la neutraliser. Le navigateur "
        "de la victime exécute alors le script de l'attaquant, avec les "
        "droits du site. Dans le Top 10 2025, la XSS fait partie de la "
        "famille des injections (A05).",
      ),
      code(
        "https://site.example/recherche?q=<script>alert(1)</script>",
        label: "Test classique (sur votre propre application)",
      ),
    ]),
    sec("Trois variantes", [
      list(
        "- **Réfléchie** : le script est dans le lien et renvoyé immédiatement par la page.\n"
        "- **Stockée** : le script est enregistré (commentaire, profil) et frappe chaque visiteur.\n"
        "- **DOM** : le JavaScript de la page insère lui-même la donnée dangereuse (innerHTML).",
      ),
      text(
        "Conséquences : vol de session (si le cookie n'est pas HttpOnly), "
        "actions au nom de la victime, faux formulaire de connexion, "
        "défiguration du site.",
      ),
    ]),
    sec("Se protéger", [
      list(
        "- **Encoder en sortie** selon le contexte (HTML, attribut, JavaScript, URL) ; les moteurs de gabarits modernes le font par défaut.\n"
        "- Utiliser textContent plutôt qu'innerHTML côté navigateur.\n"
        "- **Content-Security-Policy** : interdit les scripts non autorisés.\n"
        "- Cookies de session **HttpOnly**.",
      ),
      warn(
        "Filtrer « <script> » ne suffit pas : il existe des dizaines d'autres "
        "façons d'exécuter du JavaScript (attributs onerror, liens javascript:).",
      ),
    ]),
  ],
  commonMistakes: [
    "Compter sur une liste noire de mots comme « script »",
    "Désactiver l'échappement automatique du moteur de gabarits",
    "Insérer des données avec innerHTML",
  ],
  summary:
      "XSS = donnée utilisateur exécutée comme script dans la page. Trois "
      "variantes (réfléchie, stockée, DOM). Défense : encodage en sortie "
      "selon le contexte, CSP, cookies HttpOnly.",
  quiz: [
    q(const [
      'q1',
      "Quelle XSS frappe tous les visiteurs d'une page ?",
      'qcm',
      "La XSS stockée|La XSS réfléchie|La CSRF|L'injection SQL",
      '0',
      "Le script est enregistré côté serveur et servi à chaque visiteur.",
    ]),
    q(const [
      'q2',
      "Quelle est la défense principale contre la XSS ?",
      'qcm',
      "Encoder les données en sortie selon le contexte|Chiffrer les données enregistrées dans la base|Utiliser POST au lieu de GET dans les formulaires|Limiter la longueur des champs à cent caractères",
      '0',
      "Les caractères spéciaux deviennent du texte inoffensif.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : l'attribut HttpOnly empêche un script XSS de lire le cookie de session.",
      'tf',
      'Vrai',
      null,
      "Le cookie reste envoyé au serveur mais devient invisible pour JavaScript.",
    ]),
  ],
  exercises: [
    ex(
      "Repérer les points d'injection",
      "Sur une application de test que vous contrôlez (par exemple OWASP "
          "Juice Shop en local), listez les champs dont le contenu est réaffiché "
          "dans la page.",
    ),
  ],
);

Course _csrf() => Course(
  id: 'web-csrf',
  title: 'La falsification de requête (CSRF)',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Comprendre comment une CSRF abuse de la session de la victime",
    "Connaître les jetons anti-CSRF et l'attribut SameSite",
  ],
  prerequisites: ["Les sessions et l'authentification", "Les cookies"],
  sections: [
    sec("Le principe", [
      text(
        "La victime est connectée à sa banque. Elle visite une page piégée "
        "qui envoie discrètement une requête vers la banque. Le navigateur "
        "joint automatiquement le cookie de session : la banque croit que la "
        "victime a voulu faire ce virement.",
      ),
      code(
        "<form action=\"https://banque.example/virement\" method=\"POST\">\n"
        "  <input name=\"vers\" value=\"attaquant\">\n"
        "  <input name=\"montant\" value=\"500\">\n"
        "</form>\n"
        "<script>document.forms[0].submit()</script>",
        label: "Page piégée (exemple pédagogique)",
      ),
    ]),
    sec("Se protéger", [
      list(
        "- **Jeton anti-CSRF** : une valeur imprévisible liée à la session, exigée dans chaque formulaire ; la page piégée ne peut pas la connaître.\n"
        "- **SameSite=Lax ou Strict** sur le cookie de session : un formulaire POST piégé sur un autre site part sans lui. Lax l'envoie encore quand on suit un lien (GET) ; Strict ne l'envoie jamais depuis un autre site.\n"
        "- Redemander le mot de passe pour les actions sensibles.\n"
        "- Ne jamais modifier de données avec GET (SameSite=Lax ne le protège pas).",
      ),
    ]),
  ],
  commonMistakes: [
    "Changer un état (suppression, virement) avec une requête GET",
    "Croire que HTTPS protège contre la CSRF",
  ],
  summary:
      "La CSRF fait exécuter une action par le navigateur connecté de la "
      "victime. Défenses : jeton anti-CSRF, cookies SameSite, "
      "réauthentification, pas de modification par GET.",
  quiz: [
    q(const [
      'q1',
      "Sur quoi repose une attaque CSRF ?",
      'qcm',
      "Le navigateur joint automatiquement le cookie de session|Le serveur affiche un script fourni par l'utilisateur|Le mot de passe de la victime est trop facile à deviner|Le certificat TLS du site est expiré ou auto-signé",
      '0',
      "La requête forgée part du navigateur de la victime, avec ses cookies.",
    ]),
    q(const [
      'q2',
      "Quel attribut de cookie limite la CSRF ?",
      'qcm',
      "SameSite|Path|Expires|Domain",
      '0',
      "Strict n'envoie jamais le cookie depuis un autre site ; Lax ne l'envoie qu'en suivant un lien (GET).",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : HTTPS suffit à empêcher la CSRF.",
      'tf',
      'Faux',
      null,
      "La requête forgée passe elle aussi en HTTPS, avec le cookie.",
    ]),
  ],
  exercises: [
    ex(
      "Analyser un formulaire",
      "Dans les outils de développement de votre navigateur, examinez un "
          "formulaire de modification de profil sur une application que vous "
          "contrôlez : contient-il un jeton anti-CSRF ? Le cookie a-t-il "
          "l'attribut SameSite ?",
    ),
  ],
);

Course _ssrf() => Course(
  id: 'web-ssrf',
  title: 'La falsification de requête côté serveur (SSRF)',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Comprendre comment un serveur peut être utilisé comme relais",
    "Connaître les cibles typiques (réseau interne, métadonnées cloud)",
    "Mettre en place une liste d'autorisation",
  ],
  prerequisites: ["APIs et REST", "Segmentation, VLAN et DMZ"],
  sections: [
    sec("Le principe", [
      text(
        "Certaines fonctions récupèrent une URL fournie par l'utilisateur "
        "(aperçu de lien, import d'image, webhook). Si le serveur accepte "
        "n'importe quelle adresse, l'attaquant lui fait interroger des "
        "ressources internes inaccessibles depuis Internet. Catégorie "
        "A10 du Top 10 2021, la SSRF est rattachée en 2025 au contrôle "
        "d'accès (A01).",
      ),
      code(
        "POST /apercu  url=http://192.168.56.10/admin\n"
        "POST /apercu  url=http://169.254.169.254/   (métadonnées du cloud)",
        label: "Requêtes malveillantes",
      ),
    ]),
    sec("Pourquoi c'est grave", [
      text(
        "Le serveur se trouve souvent dans une zone de confiance : il voit "
        "l'intranet, les interfaces d'administration et, chez les hébergeurs "
        "cloud, un service de métadonnées qui peut délivrer des identifiants "
        "temporaires.",
      ),
    ]),
    sec("Se protéger", [
      list(
        "- **Liste d'autorisation** des domaines ou adresses joignables, plutôt qu'une liste de refus.\n"
        "- Résoudre le nom puis refuser les adresses privées, de boucle locale et lien-local, puis se connecter à l'adresse vérifiée (sinon le nom peut changer entre-temps).\n"
        "- Désactiver les redirections automatiques ou revérifier chaque destination.\n"
        "- Filtrer le trafic sortant du serveur.\n"
        "- Utiliser la version protégée du service de métadonnées (IMDSv2 chez AWS).",
      ),
      tip(
        "CyberLab vérifie lui aussi l'adresse réelle pour le coach : en HTTP, un "
        "nom .local est résolu et refusé s'il pointe vers une adresse "
        "publique.",
      ),
    ]),
  ],
  commonMistakes: [
    "Vérifier le texte de l'URL sans résoudre l'adresse réelle",
    "Suivre aveuglément les redirections",
  ],
  summary:
      "SSRF : le serveur est utilisé pour atteindre des ressources internes "
      "ou les métadonnées cloud. Défenses : liste d'autorisation, refus des "
      "adresses internes après résolution, filtrage sortant.",
  quiz: [
    q(const [
      'q1',
      "Quelle fonction est typiquement exposée à la SSRF ?",
      'qcm',
      "Un aperçu de lien qui récupère une URL fournie|Un formulaire de contact qui envoie un e-mail|Un menu déroulant qui liste les pays disponibles|Une page statique servie par un CDN",
      '0',
      "Le serveur va chercher une adresse choisie par l'utilisateur.",
    ]),
    q(const [
      'q2',
      "Pourquoi l'adresse 169.254.169.254 est-elle une cible prisée ?",
      'qcm',
      "C'est le service de métadonnées de nombreux clouds|C'est le serveur DNS public de plusieurs opérateurs|C'est l'adresse par défaut des routeurs domestiques|C'est l'adresse de diffusion du réseau local",
      '0',
      "Il peut fournir des identifiants temporaires de la machine.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : une liste d'autorisation est plus sûre qu'une liste de refus contre la SSRF.",
      'tf',
      'Vrai',
      null,
      "On n'oublie jamais une forme d'adresse quand seules les destinations prévues passent.",
    ]),
  ],
  exercises: [
    ex(
      "Concevoir le contrôle",
      "Décrivez les vérifications qu'une fonction « importer une image "
          "depuis une URL » doit faire avant d'envoyer la requête.",
    ),
  ],
);

Course _upload() => Course(
  id: 'web-upload',
  title: 'Le téléversement de fichiers',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Comprendre comment un téléversement mène à un web shell",
    "Valider type, taille et nom des fichiers",
    "Stocker les fichiers sans permettre leur exécution",
  ],
  prerequisites: ["Le contrôle d'accès (OWASP A01)"],
  sections: [
    sec("Le risque", [
      text(
        "Si un site accepte un fichier shell.php et le place dans un dossier "
        "servi par le serveur web, il suffit de l'appeler dans le navigateur "
        "pour exécuter des commandes sur le serveur. C'est un web shell (voir "
        "l'alerte correspondante du simulateur SOC).",
      ),
      code(
        "GET /uploads/shell.php?cmd=whoami\n"
        "GET /uploads/shell.php?cmd=cat+/etc/passwd",
        label: "Traces typiques dans access.log",
      ),
    ]),
    sec("Valider", [
      list(
        "- **Liste d'autorisation** des extensions (jpg, png, pdf), jamais une liste de refus.\n"
        "- Vérifier le contenu réel (signature du fichier), pas seulement l'extension ou le type annoncé par le navigateur.\n"
        "- Limiter la taille.\n"
        "- Renommer le fichier avec un nom aléatoire généré par le serveur.",
      ),
    ]),
    sec("Stocker", [
      list(
        "- Hors de la racine du site web, ou dans un stockage dédié.\n"
        "- Sans droit d'exécution, avec l'exécution de scripts désactivée dans ce dossier.\n"
        "- Servi par un script qui contrôle l'accès et impose le bon type de contenu.\n"
        "- Analysé par un antivirus si les fichiers sont partagés.",
      ),
      warn(
        "Une image peut contenir du code : le renommage et l'interdiction "
        "d'exécution restent indispensables même après validation.",
      ),
    ]),
  ],
  commonMistakes: [
    "Se fier à l'extension ou au type fourni par le navigateur",
    "Stocker les fichiers téléversés dans un dossier exécutable du site",
    "Garder le nom de fichier choisi par l'utilisateur",
  ],
  summary:
      "Un téléversement mal contrôlé mène au web shell. Liste d'autorisation, "
      "vérification du contenu, taille limitée, nom aléatoire, stockage hors "
      "racine et sans exécution.",
  quiz: [
    q(const [
      'q1',
      "Qu'est-ce qu'un web shell ?",
      'qcm',
      "Un script déposé sur le serveur qui exécute des commandes|Un navigateur en ligne de commande pour tester un site|Un pare-feu applicatif qui filtre les requêtes HTTP|Une console d'administration fournie par l'hébergeur",
      '0',
      "Il donne à l'attaquant une console sur le serveur.",
    ]),
    q(const [
      'q2',
      "Vrai ou faux : vérifier l'extension .jpg suffit à garantir qu'un fichier est une image.",
      'tf',
      'Faux',
      null,
      "L'extension se change librement ; il faut vérifier le contenu et empêcher l'exécution.",
    ]),
    q(const [
      'q3',
      "Où stocker les fichiers téléversés ?",
      'qcm',
      "Hors de la racine du site, sans droit d'exécution|Dans le dossier des scripts, avec droit d'exécution|À la racine du site, sous leur nom d'origine|Dans /etc, avec les fichiers de configuration du serveur",
      '0',
      "Ils ne doivent jamais pouvoir être exécutés par le serveur web.",
    ]),
  ],
  exercises: [
    ex(
      "Identifier un vrai type",
      "Dans le terminal du Lab : file documents/notes.pdf scripts/analyse_logs.sh. "
          "Expliquez pourquoi un serveur devrait faire la même vérification sur "
          "les fichiers reçus.",
    ),
  ],
);

Course _misconfig() => Course(
  id: 'web-misconfig',
  title: 'Les mauvaises configurations',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Reconnaître les configurations dangereuses courantes",
    "Durcir un serveur web et une application",
    "Configurer les en-têtes de sécurité",
  ],
  prerequisites: ["Les en-têtes HTTP"],
  sections: [
    sec("Les classiques", [
      list(
        "- Mode débogage actif en production (traces d'erreur détaillées).\n"
        "- Listing des répertoires activé.\n"
        "- Comptes et mots de passe par défaut.\n"
        "- Fichiers oubliés : .git, sauvegardes .bak, commentaires bavards.\n"
        "- Stockage cloud ouvert au public.\n"
        "- En-têtes de sécurité absents.",
      ),
      text(
        "La mauvaise configuration est la catégorie A02 du Top 10 2025 : "
        "aucune ligne de code n'est fautive, mais le réglage expose tout.",
      ),
    ]),
    sec("En-têtes de sécurité", [
      code(
        "Strict-Transport-Security: max-age=31536000; includeSubDomains\n"
        "Content-Security-Policy: default-src 'self'\n"
        "X-Content-Type-Options: nosniff\n"
        "Referrer-Policy: strict-origin-when-cross-origin\n"
        "Permissions-Policy: camera=(), microphone=()",
        label: "Exemple d'en-têtes",
      ),
    ]),
    sec("Durcir", [
      text(
        "Partir d'une configuration minimale, désactiver tout ce qui n'est "
        "pas utilisé, afficher des messages d'erreur génériques, et "
        "automatiser la configuration pour qu'elle soit identique et vérifiée "
        "sur tous les environnements.",
      ),
      tip(
        "Un commentaire oublié est visible dans le Lab : "
        "cat /var/www/html/index.html dans le terminal.",
      ),
    ]),
  ],
  commonMistakes: [
    "Laisser le débogage actif en production",
    "Publier le dossier .git avec le site",
    "Afficher des traces d'erreur détaillées aux visiteurs",
  ],
  summary:
      "Débogage, listing, identifiants par défaut, fichiers oubliés, en-têtes "
      "absents : la configuration expose sans faille de code. Configuration "
      "minimale, erreurs génériques, en-têtes de sécurité, automatisation.",
  quiz: [
    q(const [
      'q1',
      "Pourquoi le mode débogage est-il dangereux en production ?",
      'qcm',
      "Il révèle des détails internes (code, chemins, requêtes)|Il ralentit le chargement des images et des scripts|Il désactive le chiffrement TLS entre client et serveur|Il supprime les journaux à chaque redémarrage du serveur",
      '0',
      "Les traces d'erreur détaillées aident l'attaquant à comprendre l'application.",
    ]),
    q(const [
      'q2',
      "Quel en-tête impose HTTPS au navigateur pour les visites suivantes ?",
      'qcm',
      "Strict-Transport-Security|X-Content-Type-Options|Access-Control-Allow-Origin|Cross-Origin-Resource-Policy",
      '0',
      "C'est HSTS.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : un dossier .git accessible sur le site peut exposer tout le code source.",
      'tf',
      'Vrai',
      null,
      "L'historique Git permet de reconstruire le code, et parfois des secrets.",
    ]),
  ],
  exercises: [
    ex(
      "Trouver la fuite du lab",
      "Dans le terminal du Lab, lisez /var/www/html/index.html. Quelle "
          "information n'aurait jamais dû être publiée ?",
    ),
  ],
);

Course _components() => Course(
  id: 'web-components',
  title: 'Composants vulnérables et chaîne d\'approvisionnement',
  category: 'web_security',
  level: 'Niveau 6 - Sécurité Web',
  levelNumber: 6,
  objectives: [
    "Comprendre le risque des dépendances",
    "Suivre les CVE et appliquer les correctifs",
    "Tenir un inventaire des composants (SBOM)",
  ],
  prerequisites: ["OWASP : top des risques Web"],
  sections: [
    sec("Le code des autres", [
      text(
        "Une application moderne embarque des centaines de bibliothèques. "
        "Une faille dans l'une d'elles devient une faille de l'application. "
        "C'est la catégorie A03 du Top 10 2025 (défaillances de la chaîne "
        "d'approvisionnement logicielle), qui élargit l'ancienne A06 de 2021 "
        "(composants vulnérables et obsolètes).",
      ),
      text(
        "Exemple marquant : Log4Shell (CVE-2021-44228, fin 2021), une faille "
        "de la bibliothèque de journalisation Java Log4j, présente dans "
        "d'innombrables logiciels.",
      ),
    ]),
    sec("Suivre et corriger", [
      list(
        "- Inventorier les composants et leurs versions (SBOM).\n"
        "- Surveiller les CVE et avis de sécurité (CERT-FR, éditeurs).\n"
        "- Mettre à jour régulièrement, en priorité ce qui est exposé.\n"
        "- Utiliser des outils d'analyse de dépendances dans l'intégration continue.\n"
        "- Supprimer les dépendances inutiles.",
      ),
    ]),
    sec("La chaîne d'approvisionnement", [
      text(
        "Un attaquant peut aussi piéger un paquet populaire, publier un "
        "paquet au nom presque identique (typosquatting) ou compromettre un "
        "outil de compilation. Défenses : verrouiller les versions (fichiers "
        "de verrouillage), vérifier les signatures et l'origine, limiter les "
        "droits de l'intégration continue.",
      ),
      warn(
        "Une version épinglée n'est pas une version figée pour toujours : "
        "les mises à jour de sécurité doivent rester suivies.",
      ),
    ]),
  ],
  commonMistakes: [
    "Ne jamais mettre à jour les dépendances « tant que ça marche »",
    "Ignorer les dépendances indirectes",
    "Installer un paquet sans vérifier son nom exact",
  ],
  summary:
      "Les bibliothèques importent leurs failles. Inventaire (SBOM), veille "
      "CVE, mises à jour, analyse automatique, et vigilance sur la chaîne "
      "d'approvisionnement (typosquatting, signatures, versions verrouillées).",
  quiz: [
    q(const [
      'q1',
      "Qu'est-ce qu'une SBOM ?",
      'qcm',
      "L'inventaire des composants logiciels d'une application|La liste des utilisateurs autorisés d'une application|Un algorithme qui chiffre les dépendances d'un projet|Un test d'intrusion mené avant la mise en production",
      '0',
      "Software Bill of Materials : la liste des composants et de leurs versions.",
    ]),
    q(const [
      'q2',
      "Le typosquatting consiste à...",
      'qcm',
      "Publier un paquet au nom presque identique à un paquet connu|Deviner un mot de passe en testant des fautes de frappe|Modifier le code d'un paquet connu sur le serveur officiel|Envoyer un très grand nombre de requêtes à un dépôt",
      '0',
      "Une faute de frappe à l'installation suffit à installer le paquet piégé.",
    ]),
    q(const [
      'q3',
      "Vrai ou faux : une faille dans une bibliothèque utilisée par l'application peut compromettre l'application.",
      'tf',
      'Vrai',
      null,
      "Log4Shell en est l'exemple le plus connu.",
    ]),
  ],
  exercises: [
    ex(
      "Inventaire",
      "Choisissez un projet que vous connaissez et listez ses dépendances "
          "directes avec leur version. Cherchez si l'une d'elles a une CVE "
          "publiée.",
    ),
  ],
);
