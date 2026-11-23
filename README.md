# CyberLab Agent

Application Flutter d'apprentissage de la cybersécurité pour Android : cours, quiz, challenges CTF, terminal simulé, simulateur SOC, filtres Wireshark et coach IA facultatif.

> Apprentissage uniquement, sur systèmes autorisés. Le terminal et les labs sont **simulés** : aucune commande n'est exécutée sur l'appareil.

Version : **1.6.0** (code 7).

## Fonctionnalités

- **Apprendre** : 135 cours en 10 niveaux : Découverte (0, 12 cours), Informatique et réseaux (1, 26), Linux (2, 21), Bash (3, 12), Python (4, 12), Sécurité réseau (5, 10), Sécurité Web avec l'OWASP complet (6, 18), Cryptographie (7, 8), Réponse à incident (8, 8), Windows et Active Directory (9, 8).
- **Pratique vérifiée** : 38 cours (tous les cours Bash et 18 cours Linux) proposent un exercice dans un terminal neuf : des critères (fichier créé, droits, contenu, résultat d'une commande) se cochent automatiquement, puis la solution de référence s'affiche. 15 XP une seule fois.
- **Révision** : « Mes erreurs » reprend les questions ratées pas encore réussies (les réussir rapporte encore leurs XP) ; « Entraînement aléatoire » tire 10 questions des cours terminés. Accès depuis Apprendre (icône avec compteur) et l'Accueil.
- **Quiz** : QCM et vrai/faux (le moteur gère aussi la réponse libre et la commande). Il propose des indices qui ne donnent pas la réponse, affiche la bonne réponse en clair et l'explique. On peut recommencer un quiz.
- **CTF** : 28 challenges (Linux, Web, Réseau, Crypto, Logs, Forensic, Scripting), filtrables par catégorie. 13 d'entre eux se résolvent dans le terminal du Lab, sur ses fichiers virtuels, et la solution affiche la commande correspondante (vérifiée par les tests). Indices progressifs, solution sur demande, après confirmation : un challenge dont la solution a été affichée ne rapporte plus d'XP. Les variantes de réponse sont listées une par une. Pour les commandes, majuscules et minuscules comptent.
- **Parcours** : 10 parcours (un par niveau thématique). Le parcours choisi oriente l'Accueil (« Continuer ma formation », progression du parcours) et l'onglet Apprendre. Il se change depuis le Profil ou l'Accueil.
- **Premier lancement** : présentation et règle éthique, prénom facultatif, choix du parcours. Il n'apparaît pas si des données existent déjà.
- **Lab** :
  - terminal Linux simulé sur un système de fichiers virtuel (voir plus bas) ;
  - **simulateur SOC** : 24 alertes fictives (dont des faux positifs). On choisit une gravité et une **décision** (Clôturer, Surveiller, Investiguer, Contenir) ; la correction donne l'action recommandée et la technique MITRE ATT&CK. Les alertes pas encore réussies sont proposées en priorité ;
  - **Wireshark** : cours, mémo des filtres, **capture simulée** de 32 paquets avec de vrais filtres d'affichage (`ip.addr`, `tcp.flags.syn`, `contains`, `&&`, `||`, `!`…), 9 exercices validés sur le résultat du filtre (toute écriture équivalente est acceptée, 20 XP chacun), détail de chaque paquet, 4 scénarios d'analyse ;
  - **enquêtes guidées** : 4 scénarios (21 étapes) qui enchaînent terminal, filtres sur la capture, questions et décisions. Jusqu'à 100 XP par enquête, 10 de moins par mauvaise décision (50 au minimum), avancement conservé.
- **CyberCoach** : professeur IA **facultatif** (Ollama, OpenAI, Anthropic, Gemini, Mistral, API compatible OpenAI). Il garde la mémoire de la conversation.
- **Recherche** : dans le texte des cours, les fiches, les challenges et les notes, sans tenir compte des accents ni de la casse. Les réponses (quiz, CTF) ne sont pas indexées.
- **Statistiques** : XP et temps sur 7, 30 ou 90 jours (graphique et tableau). L'activité est datée depuis la 1.6.0 ; l'activité antérieure n'a pas été enregistrée jour par jour.
- **Progression** : XP, niveaux, 18 badges (dont « Analyste SOC », « Analyste réseau » et un par nouveau niveau), compétences, série quotidienne, temps d'apprentissage.
- **Prérequis** : chaque cours indique les cours conseillés avant lui (état et accès direct). Ce sont des recommandations : rien n'est verrouillé, mais la liste « Apprendre » signale les prérequis manquants et « Continuer ma formation » propose d'abord un cours dont les prérequis sont faits.
- **Rappel quotidien** (facultatif, désactivé par défaut) : une notification locale par jour à l'heure choisie (Paramètres → Rappel quotidien), sautée les jours où l'on a déjà pratiqué.
- **Accessibilité** : libellés pour le lecteur d'écran (TalkBack) sur les boutons, statistiques, barres de progression et compétences ; résultats du quiz et du terminal annoncés automatiquement ; affichage vérifié avec une police agrandie à 200 % ; zones tactiles d'au moins 48 dp.
- **Notes**, **Docs** (10 cheat sheets), mode sombre ou clair.

## Règles de progression

- **Fin de cours** : il faut avoir réussi au moins **70 %** des questions du quiz du cours (arrondi supérieur, une question ratée peut être retentée). Le cours se termine alors et rapporte ses XP. Les exercices se débloquent ensuite. Les cours terminés avec une version précédente le restent.
- **Solution CTF** : l'affichage de la solution est mémorisé durablement. Le challenge reste validable, sans XP.
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
- **Hôte local** : `localhost`, 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16, 100.64.0.0/10 (CGNAT, Tailscale), IPv6 `::1`, `fc00::/7`, `fe80::/10`, ou un nom `*.local`. Un nom `*.local` est résolu avant chaque envoi : la requête est refusée si une des adresses obtenues n'est pas locale.
- **Avertissements** : pendant la saisie, Paramètres signale une adresse qui n'est pas celle du fournisseur officiel (la clé y serait envoyée), une clé API transmise en clair en HTTP, ou des messages qui transitent en clair sur le réseau local.
- Pour Ollama, le serveur doit écouter sur le réseau, par exemple `OLLAMA_HOST=0.0.0.0`, et le téléphone doit être sur le même réseau.
- Vos **messages**, et les derniers échanges de la conversation (12 messages et 6000 caractères au maximum), sont transmis au fournisseur sélectionné. Le bouton « Nouvelle conversation » efface l'historique local.
- Les erreurs sont affichées sous forme de messages compréhensibles : authentification, quota, modèle introuvable, serveur inaccessible, délai dépassé. Le contenu brut des réponses n'est jamais affiché.

## Stockage, secrets et sauvegardes

- **Export / import manuel** : Paramètres → « Sauvegarde de la progression ». L'export crée un fichier JSON (`cyberlab-sauvegarde-AAAA-MM-JJ.json`) à l'emplacement choisi via le sélecteur de fichiers Android, sans permission de stockage. Il contient la progression, les notes, les réglages non secrets (thème, fournisseur, modèle, adresse) et, sur demande, l'historique du coach. Il ne contient **jamais** de clé API. L'import vérifie le fichier, montre un aperçu, demande confirmation, copie l'état actuel sous `*_corrupt_<horodatage>`, puis remplace progression et notes. Les clés API de l'appareil ne sont pas touchées.

- **Progression, notes, réglages non secrets et historique du coach** : `SharedPreferences`, sur l'appareil. Les écritures se font dans l'ordre et les erreurs s'affichent dans un bandeau. Chaque section est chargée séparément, et les notes et messages du coach sont validés un par un. Si des données sont illisibles, même partiellement, la valeur d'origine est **copiée** sous une clé `*_corrupt_<horodatage>` avant toute réécriture. Les éléments lisibles restent chargés.
- **Clés API** : `flutter_secure_storage`, un stockage chiffré adossé à l'Android Keystore. Les clés ne sont jamais journalisées et jamais incluses dans un rapport.
- **Migration depuis la v1.0** : une ancienne clé stockée en clair est copiée dans le stockage sécurisé, puis relue. Elle n'est supprimée des préférences qu'après une relecture identique. En cas d'échec, elle reste utilisable, un avertissement s'affiche et une nouvelle tentative a lieu au démarrage suivant.
- **Sauvegardes Android** : les règles sont des **listes blanches** (`res/xml/backup_rules.xml` et `res/xml/data_extraction_rules.xml`). Seul `FlutterSharedPreferences.xml` est sauvegardé et transféré entre appareils. Il contient la progression, les notes, les réglages non secrets **et l'historique du coach** (questions et réponses), ce que l'application indique dans Paramètres et dans le coach. Les fichiers du stockage sécurisé n'y figurent jamais, quel que soit leur nom. Après une restauration, il faut donc ressaisir les clés API. Exception : si la migration d'une ancienne clé v1.0 échoue, cette clé reste en clair dans les préférences jusqu'à la migration suivante, et un avertissement le signale.

## Rappel quotidien

- Notification **locale**, programmée sur l'appareil (`flutter_local_notifications`) : aucun serveur, aucune donnée envoyée.
- Désactivé par défaut. L'autorisation d'afficher des notifications (Android 13+) n'est demandée qu'au moment de l'activation ; en cas de refus, le rappel reste désactivé et un message l'explique.
- Horaire **approximatif** : aucune alarme exacte n'est demandée (pas de permission sensible), Android peut décaler le rappel de quelques minutes.
- Le rappel est replanifié à chaque ouverture de l'application et à chaque activité : s'il y a déjà eu une activité aujourd'hui, le prochain rappel est demain. Il est reprogrammé après un redémarrage du téléphone (`RECEIVE_BOOT_COMPLETED`).
- Le texte ne contient aucun chiffre (il ne peut donc pas devenir faux entre deux ouvertures). Le réglage n'est pas inclus dans les exports.

## Sécurité réseau

- La permission `INTERNET` est déclarée dans le manifeste principal.
- `network_security_config.xml` interdit le HTTP en clair et n'accepte que les certificats système. La validation TLS n'est jamais désactivée.
- **Limite vérifiée** : cette configuration Android ne sait pas exprimer des plages d'IP. De plus, le client HTTP de Dart ne la consulte pas : le moteur Flutter lui transmet une politique vide. La restriction HTTP n'est donc pas assurée par Android. Elle est appliquée **dans le code** (`lib/services/ai_service.dart`) : HTTP refusé vers tout hôte non local, HTTPS imposé aux fournisseurs distants, identifiants interdits dans l'URL.

## Terminal simulé et Command Guard

Le terminal est un **shell pédagogique écrit en Dart** qui agit uniquement sur un **système de fichiers virtuel en mémoire** (`lib/services/virtual_fs.dart`). Aucune commande n'est exécutée sur l'appareil, aucun fichier réel n'est lu ni écrit, et `ping`, `nmap`, `curl` ou `ssh` restent des simulations. Un test vérifie que le moteur n'importe pas `dart:io`.

- **Arborescence** : `/home/learner` (notes, `logs/auth.log`, `logs/access.log`, scripts, rapport d'incident), `/etc` (`passwd`, `shadow`, `hosts`, `ssh/sshd_config`…), `/var/log`, `/var/www`, `/root`, `/tmp`.
- **Commandes** : `pwd`, `cd`, `ls -la`, `cat`, `head`, `tail`, `grep` (`-i -v -n -c -l -o -E -r -w`), `wc`, `sort`, `uniq -c`, `cut`, `awk '{print $1}'`, `sed 's/a/b/g'`, `find` (`-name`, `-type`, `-user`, `-delete`, `-exec`), `tree`, `mkdir -p`, `touch`, `cp`, `mv`, `rm`, `rmdir`, `chmod`, `chown`, `file`, `stat`, `base64`, `tr`, `sha256sum`, `sha1sum`, `md5sum`, `seq`, `test` / `[ ]`, `history`, `env`, `whoami`, `id`, `sudo`…
- **Shell** : `|`, `>`, `>>`, `<`, `2>/dev/null`, `2>&1`, `;`, `&&`, `||`, variables (`X=1`, `$HOME`, `$?`), `$(…)`, `$(( calcul ))`, jokers (`*.log`), `~`, découpage en mots comme bash.
- **Structures** : `if`/`elif`/`else`/`fi`, `for … in … do … done`, `while` et `until`, fonctions `nom() { … }`, `break`, `continue`, `return`, commentaires `#`. Une boucle infinie est interrompue après 1000 commandes. Non pris en charge : un tube ou une redirection après `done` / `fi` (message explicite).
- **Droits simulés** : `/etc/shadow`, `/var/log/*` et `/root` sont refusés à `learner`. `sudo commande` ou `sudo -i` (puis `exit`) donnent les droits root.
- **Scripts** : `bash script.sh arg1 arg2`, ou `./script.sh` après `chmod +x`, exécutés en entier (blocs sur plusieurs lignes), avec `$1`…`$9`, `$#`, `$@`, `$0`. Le Command Guard examine aussi le contenu des boucles, conditions et fonctions.
- **`labreset`** restaure les fichiers d'origine. La session est conservée tant que l'application est ouverte, même en changeant d'onglet du Lab.

Le **Command Guard** est une **règle pédagogique** du simulateur, pas une protection système, et sa liste de règles n'est pas exhaustive. Il analyse la commande réellement appelée, y compris chaque ligne d'un script. Désactivé, il laisse les protections « Linux » simulées s'appliquer (`rm -r /` refusé sans `--no-preserve-root`, droits) : seul le système de fichiers virtuel peut alors être effacé, et `labreset` le restaure.

Commandes refusées :

- `rm` récursif et forcé, quelle que soit l'écriture : `-rf`, `-fr`, `-r -f`, `-Rf`, `--recursive --force`, abréviations GNU (`--rec --f`), `--interactive=never`, options placées après les fichiers ;
- `dd` avec `of=`, et une redirection `>` vers un disque (`/dev/sda`, `/dev/nvme0n1`…) ;
- formatage (`mkfs`, `mkfs.*`, `mke2fs`, `mkswap`, `wipefs`) et `shred` ;
- `find -delete` sur un répertoire système (`/`, `~`, `/etc`, `/home`…), et `find -exec` dont la commande serait refusée ;
- `chmod`, `chown` et `chgrp` récursifs sur un répertoire système ;
- la bombe fork `:(){ :|:& };:`.

Analyse :

- chaque segment séparé par `;`, `&&`, `||`, `|` ou `&` ;
- préfixes ignorés, avec leurs options : `sudo`, `doas`, `env`, `nohup`, `time`, `command`, `builtin`, `exec`, `nice`, `ionice`, `timeout`, `xargs`, `stdbuf`, `setsid`, `watch`, ainsi que les affectations `VAR=valeur` ;
- nom de commande normalisé : `\rm`, `/bin/rm` et `"rm"` valent `rm` ;
- code imbriqué : `bash -c "…"`, `sh -c`, `su -c`, `eval`, `$(…)` et `` `…` `` ; entre apostrophes, rien n'est analysé, car le shell n'exécute rien ;
- il ne bloque pas `echo "rm -rf /"`, `man rm`, `grep "rm -rf" notes.txt`, `find . -name "*.tmp" -delete` ni `chmod -R 755 scripts`.

## Développement

Prérequis : Flutter 3.47+ / Dart 3.13+ et Android SDK (`minSdk` 24, `compileSdk` 36). Le *desugaring* Java est activé dans `android/app/build.gradle.kts` (requis par les notifications). `flutter_local_notifications` est épinglé en 22.3.3 : la version 23 exige `compileSdk` 37 et AGP 9.1.

**Intégration continue** (`.github/workflows/ci.yml`) : à chaque push sur `main` et à chaque pull request, GitHub Actions vérifie le formatage, lance `flutter analyze` et `flutter test`, puis compile un APK **debug** pour vérifier le projet Android. Rien n'est publié, aucun secret n'est utilisé et l'APK n'est pas conservé.

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
