# CyberLab Agent

Application Flutter d'apprentissage de la cybersécurité pour Android : cours, quiz, challenges CTF, terminal simulé, simulateur SOC, filtres Wireshark et coach IA facultatif.

> Apprentissage uniquement, sur systèmes autorisés. Le terminal et les labs sont **simulés** : aucune commande n'est exécutée sur l'appareil.

Version : **1.1.0** (code 2).

## Fonctionnalités

- **Apprendre** : 95 cours en 6 catégories (Fondamentaux 12, Linux 21, Réseau 26, Bash 12, Python 12, Web 12).
- **Quiz** : QCM et vrai/faux (le moteur gère aussi la réponse libre et la commande). Il propose des indices qui ne donnent pas la réponse, affiche la bonne réponse en clair et l'explique. On peut recommencer un quiz.
- **CTF** : 12 challenges (Linux, Web, Réseau, Crypto, Logs, Forensic, Scripting). Indices progressifs, solution sur demande. Les variantes de réponse sont listées une par une. Pour les commandes, majuscules et minuscules comptent.
- **Lab** : terminal Linux simulé, simulateur SOC (alertes fictives, correction rédigée à l'avance), filtres Wireshark, gestionnaire de labs en simulation.
- **CyberCoach** : professeur IA **facultatif** (Ollama, OpenAI, Anthropic, Gemini, Mistral, API compatible OpenAI). Il garde la mémoire de la conversation.
- **Progression** : XP, niveaux, 11 badges, compétences, série quotidienne, temps d'apprentissage.
- **Notes**, **Docs** (10 cheat sheets), mode sombre ou clair.

## Règles de progression

- Les **XP ne s'obtiennent qu'une fois** par cours, par exercice, par question de quiz réussie, par alerte SOC et par CTF. Tout reste rejouable pour s'entraîner, mais sans gain répété.
- Une réponse de quiz d'abord fausse rapporte ses XP quand elle est réussie plus tard.
- **Niveaux** : le niveau *n* commence à 250 × (n−1) × n XP, soit 0, 500, 1500, 3000, 5000… La barre affiche la progression entre le début du niveau actuel et le suivant.
- **Série** : un jour compte dès qu'on ouvre un cours, répond à un quiz, valide un exercice, tente un CTF ou analyse une alerte SOC. Les dates sont locales et chaque jour n'est compté qu'une fois. La série retombe à 0 après un jour sans activité.
- **Temps d'apprentissage** : c'est le temps passé avec l'application **au premier plan**. L'arrière-plan et l'écran verrouillé ne comptent pas.
- **Badges** : ils sont calculés à un seul endroit, partagé par l'accueil et le profil.

## Mode hors ligne

Cours, quiz, CTF, cheat sheets, terminal et simulateurs fonctionnent **sans connexion**.
Sans modèle IA configuré ou joignable, le coach **ne génère rien**. Il affiche une « information de l'application » clairement distincte d'une réponse IA. Les corrections du simulateur SOC sont des fiches rédigées à l'avance, pas des générations IA.

## Configurer le CyberCoach (facultatif)

**Tiroir → Paramètres → CyberCoach / IA.** Chaque fournisseur a sa propre configuration : changer de fournisseur ne reprend ni l'adresse ni la clé du précédent.

| Fournisseur | Adresse par défaut | Clé | Remarque |
|---|---|---|---|
| OpenAI | `https://api.openai.com/v1` | obligatoire | HTTPS obligatoire |
| Mistral | `https://api.mistral.ai/v1` | obligatoire | HTTPS obligatoire |
| Anthropic | `https://api.anthropic.com/v1` | obligatoire | HTTPS obligatoire |
| Gemini | `https://generativelanguage.googleapis.com/v1beta` | obligatoire | clé envoyée dans l'en-tête `x-goog-api-key` |
| Ollama | — (à saisir, ex. `http://192.168.1.20:11434`) | aucune | HTTP accepté **seulement** vers un hôte local |
| API compatible OpenAI | — (à saisir) | facultative | HTTP accepté **seulement** vers un hôte local |

- **Le modèle est obligatoire.** Saisissez l'identifiant exact indiqué par la documentation du fournisseur, ou par `ollama list`. L'application ne suppose aucun modèle par défaut.
- **Hôte local** : `localhost`, 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16, IPv6 `::1`, `fc00::/7`, `fe80::/10`, ou un nom `*.local`.
- Pour Ollama, le serveur doit écouter sur le réseau, par exemple `OLLAMA_HOST=0.0.0.0`, et le téléphone doit être sur le même réseau.
- Vos **messages**, et les derniers échanges de la conversation (12 messages et 6000 caractères au maximum), sont transmis au fournisseur sélectionné. Le bouton « Nouvelle conversation » efface l'historique local.
- Les erreurs sont affichées sous forme de messages compréhensibles : authentification, quota, modèle introuvable, serveur inaccessible, délai dépassé. Le contenu brut des réponses n'est jamais affiché.

## Stockage, secrets et sauvegardes

- **Progression, notes, réglages non secrets et historique du coach** : `SharedPreferences`, sur l'appareil. Les écritures se font dans l'ordre et les erreurs s'affichent dans un bandeau. Si des données sont illisibles, elles sont **copiées** sous une clé `*_corrupt_<horodatage>` au lieu d'être écrasées.
- **Clés API** : `flutter_secure_storage`, un stockage chiffré adossé à l'Android Keystore. Les clés ne sont jamais journalisées et jamais incluses dans un rapport.
- **Migration depuis la v1.0** : une ancienne clé stockée en clair est copiée dans le stockage sécurisé, puis relue. Elle n'est supprimée des préférences qu'après une relecture identique. En cas d'échec, elle reste utilisable, un avertissement s'affiche et une nouvelle tentative a lieu au démarrage suivant.
- **Sauvegardes Android** : les règles sont des **listes blanches** (`res/xml/backup_rules.xml` et `res/xml/data_extraction_rules.xml`). Seul `FlutterSharedPreferences.xml` est sauvegardé et transféré entre appareils. Les fichiers du stockage sécurisé n'y figurent jamais, quel que soit leur nom. Après une restauration, il faut donc ressaisir les clés API.

## Sécurité réseau

- La permission `INTERNET` est déclarée dans le manifeste principal.
- `network_security_config.xml` interdit le HTTP en clair et n'accepte que les certificats système. La validation TLS n'est jamais désactivée.
- **Limite vérifiée** : cette configuration Android ne sait pas exprimer des plages d'IP. De plus, le client HTTP de Dart ne la consulte pas : le moteur Flutter lui transmet une politique vide. La restriction HTTP n'est donc pas assurée par Android. Elle est appliquée **dans le code** (`lib/services/ai_service.dart`) : HTTP refusé vers tout hôte non local, HTTPS imposé aux fournisseurs distants, identifiants interdits dans l'URL.

## Terminal simulé et Command Guard

Le terminal imite Linux et n'exécute rien. Le **Command Guard** est une **règle pédagogique** du simulateur, pas une protection système. Il analyse les arguments de la commande réellement appelée, et non le texte brut :

- il bloque `rm` lorsqu'il est à la fois récursif et forcé : `-rf`, `-fr`, `-r -f`, `-Rf`, `--recursive --force`… ;
- il bloque `dd` avec `of=` ;
- il analyse chaque segment séparé par `;`, `&&`, `||`, `|`, et ignore les préfixes `sudo`, `env`… ;
- il ne bloque pas `echo "rm -rf /"`, `man rm` ni `grep "rm -rf" notes.txt`.

## Développement

Prérequis : Flutter 3.44+ / Dart 3.12+ et Android SDK (`minSdk` 24).

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --release
```

### Signature release

La signature release lit des secrets **externes et non versionnés** :

- soit `android/key.properties` (ignoré par Git) :
  ```properties
  storeFile=/chemin/absolu/release.jks
  storePassword=...
  keyAlias=...
  keyPassword=...
  ```
- soit les variables d'environnement `CYBERLAB_STORE_FILE`, `CYBERLAB_STORE_PASSWORD`, `CYBERLAB_KEY_ALIAS` et `CYBERLAB_KEY_PASSWORD`.

Sans ces secrets, Gradle affiche un avertissement et signe la variante release avec la **clé debug**. L'APK obtenu est alors un **APK de test**, non destiné à la production. Aucune clé n'est jamais générée automatiquement.

> ⚠️ Android refuse de mettre à jour une installation existante si le nouvel APK est signé avec un autre certificat. Le passage d'un APK de test à un APK signé en production, ou d'une machine de build à une autre en signature debug, impose de désinstaller l'application, ce qui efface les données locales.

L'`applicationId` (`com.cyberlab.cyberlab_agent`) est conservé, car l'application a déjà été distribuée sous cet identifiant.

## Structure

```
lib/
  models/       Course/Quiz, CTF, Note, UserState (niveaux, récompenses, série), CoachMessage, AnswerMatcher
  services/     AppState (règles métier), Storage, SecretStore, AiService, BadgeService, TerminalEngine + CommandGuard
  data/         Contenu des cours, CTF, cheat sheets, badges
  screens/      Écrans (Accueil, Apprendre, Lab, CTF, Profil, Coach, Notes, Docs, Paramètres)
  widgets/      Composants réutilisables (Quiz, SOC, Common)
test/           Modèles, progression/migration, IA (clients HTTP simulés), Command Guard, widgets
```
