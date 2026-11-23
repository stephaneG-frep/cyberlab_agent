# Changelog

## [1.7.0] - 2026-11-23

### Quiz
- **159 questions** ajoutées : chaque cours en a désormais au moins 3 (72 cours n'en avaient qu'une, 15 en avaient deux). Une seule bonne réponse ne suffit plus à terminer un cours. Les cours déjà terminés le restent.

### Corrections du contenu des cours
- Python : la regex d'extraction d'IP ne renvoyait que `.42` avec `findall` (groupe capturant) ; `readlines()` après `read()` renvoyait une liste vide.
- Bash : trois extractions d'IP fausses dans les exemples de logs (mauvais champ), et `{date}` au lieu de `$(date)`.
- CVSS : élevé de 7,0 à 8,9, critique à partir de 9,0.
- CORS : la combinaison `*` et Allow-Credentials est refusée par les navigateurs ; le risque est la réflexion de l'origine avec les cookies.
- Deux « 90 % » sans source retirés ; plusieurs passages erronés ou illisibles (RAM, DNS, cookie de session, ports).

## [1.6.1] - 2026-11-23

### Quiz
- 88 QCM sur 199 ont de nouvelles mauvaises réponses, plausibles et de longueur comparable (cinq bonnes réponses sont raccourcies, sans changer de sens). « Toujours choisir la plus longue » réussissait 65 % des QCM, contre 31 % maintenant (25 % au hasard).
- Les identifiants des questions et la position des bonnes réponses ne changent pas : la progression est conservée.
- Un test empêche ce biais de revenir (plus longue, plus courte, options en double).

## [1.6.0] - 2026-11-23

### Quiz (correction importante)
- Les options des QCM sont **mélangées** à chaque affichage. Dans les données, la bonne réponse était la première option dans 175 QCM sur 199 (88 %), et dans tous ceux ajoutés en 1.5.0 : cocher la première suffisait souvent. Les options « Aucune », « Rien… », « Toutes… » restent en dernier.
- Limite connue : la bonne réponse est la plus longue (ou à égalité) dans 144 QCM sur 199 ; les textes sont à rééquilibrer.

### Recherche
- Nouvel écran de recherche dans le contenu des cours, les fiches, les challenges et les notes, avec extraits et filtres. Aucune réponse de quiz ni de CTF n'est indexée.
- L'ancien bouton « Rechercher » fermait la fenêtre sans lancer la recherche.

### Enquêtes guidées
- L'onglet « Labs », dont les boutons n'avaient aucun effet, devient « Enquêtes » : 4 scénarios (force brute SSH, tunnel DNS, site web sondé, homme du milieu). Badge « Enquêteur ».
- Recommencer une enquête n'efface pas les erreurs tant que ses XP n'ont pas été obtenus.

### Statistiques
- Journal quotidien (XP, temps, actions ; 400 jours conservés, passage de minuit réparti), inclus dans les exports. Écran « Évolution dans le temps » depuis le Profil.

### Intégration continue
- Un contrôle de `main` n'est plus annulé par une autre exécution ; `actions/checkout` et `actions/setup-java` passent en v5.

### Tests
- 394 tests (361 auparavant).

## [1.5.0] - 2026-11-23

### Nouveaux niveaux (40 cours, 135 au total)
- **Niveau 5 - Sécurité réseau** (10 cours) : OSI et attaques par couche, segmentation et DMZ, pare-feu, IDS/IPS, VPN, Wi-Fi, homme du milieu, scan éthique, analyse de trafic, durcissement. Ce niveau était annoncé par le cours OSI mais n'existait pas.
- **Sécurité Web** : 6 familles OWASP ajoutées (XSS, CSRF, SSRF, téléversement de fichiers, mauvaise configuration, composants vulnérables). La numérotation citée est celle du Top 10 2021.
- **Niveau 7 - Cryptographie** (8 cours) : encodage, hachage et chiffrement, hachage, stockage des mots de passe, chiffrement symétrique et asymétrique, signatures et HMAC, certificats et PKI, TLS.
- **Niveau 8 - Réponse à incident** (8 cours) : cycle de réponse, triage, confinement, preuves, journaux, chronologie, IOC, rapport et RGPD.
- **Niveau 9 - Windows et Active Directory** (8 cours, angle défensif) : bases, PowerShell, journaux d'événements, comptes et privilèges, AD, Kerberos et NTLM, attaques courantes, durcissement.
- Cours reliés au Lab (terminal, capture Wireshark, simulateur SOC), prérequis structurés, 4 nouveaux parcours et 4 nouveaux badges.

### Exercices vérifiés dans le terminal
- 38 cours proposent une « pratique vérifiée » : un terminal neuf et des critères cochés automatiquement (dossier ou fichier créé, droits, propriétaire, contenu, résultat ou forme d'une commande). 15 XP une seule fois, solution de référence affichée après la réussite.
- Tous les cours Bash et 18 cours Linux en ont un, ainsi que des cours de crypto, de réponse à incident, de sécurité réseau et Web.
- Chaque solution de référence est exécutée par les tests et doit valider tous les critères ; un terminal vierge ne doit pas les valider.

### Terminal
- Structures de contrôle : `if`/`elif`/`else`, `for`, `while`, `until`, fonctions, `break`, `continue`, `return`, commentaires, arithmétique `$(( ))`, commande `[ … ]` / `test`, `seq`.
- Scripts exécutés en entier, avec leurs arguments (`$1`, `$#`, `$@`).
- Découpage en mots des développements non protégés, comme bash.
- `sha256sum`, `sha1sum`, `md5sum` (paquet `crypto`) ; `echo -n` respecté dans les tubes (empreintes exactes).
- Le Command Guard examine aussi les boucles, conditions et corps de fonction.

### Révision
- Nouvel écran : « Mes erreurs » (questions ratées pas encore réussies) et « Entraînement aléatoire » (10 questions des cours terminés). Accès depuis Apprendre et l'Accueil.

### Tests
- 361 tests (266 auparavant).

## [1.4.0] - 2026-11-23

### Prérequis des cours
- Les prérequis rédigés en texte libre sont reliés à de vrais cours (`lib/data/course_prerequisites.dart`). Les tests vérifient que chaque identifiant existe et qu'il n'y a aucun cycle (un cycle pipes ↔ grep du contenu a été résolu : pipes d'abord).
- Écran du cours : liste des cours conseillés, avec leur état et un accès direct, et un avertissement si certains ne sont pas terminés. Rien n'est verrouillé.
- Liste « Apprendre » : cadenas et mention « n prérequis conseillés à faire ».
- « Continuer ma formation » propose d'abord un cours dont les prérequis sont faits.

### Rappel quotidien
- Paramètres → Rappel quotidien : notification locale à l'heure choisie, désactivée par défaut, sautée les jours où l'on a déjà pratiqué.
- Autorisation demandée seulement à l'activation ; horaire approximatif (aucune alarme exacte) ; reprogrammé après redémarrage.
- Nouvelles dépendances : `flutter_local_notifications` 22.3.3, `timezone`, `flutter_timezone`. Desugaring activé dans Gradle. Nouvelles permissions : `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`.

### Accessibilité
- Libellés TalkBack : boutons-icônes sans libellé (menu, recherche, favori, enregistrer, changer de parcours), tuiles de statistiques lues d'un bloc, barres de compétences en caractères █░ remplacées par « niveau n sur 100 », titres de section marqués comme titres, icônes d'état (terminé, à faire).
- Barres de progression avec un libellé (niveau, quiz, SOC, accueil, coach).
- Verdict du quiz et résultat de la dernière commande du terminal annoncés automatiquement.
- Corrections trouvées par les tests à 200 % de police : ligne de niveau de l'Accueil, en-tête du Profil, bandeau du terminal (une ligne). Champ de saisie du terminal porté à 48 dp.

### Intégration continue
- Workflow GitHub Actions : formatage, analyse, tests, build APK debug. Aucune publication, aucun secret.

### Tests
- 266 tests (237 auparavant), dont des tests d'accessibilité (police à 200 %, zones tactiles, libellés).

## [1.3.0] - 2026-11-23

### Simulateur SOC
- 24 alertes au lieu de 6 : hameçonnage, PowerShell encodé, rançongiciel, tunnel DNS, web shell, password spraying, clé SSH ajoutée, journaux effacés, usurpation ARP, fuite vers un stockage personnel… et des faux positifs (maintenance planifiée, fichier de test EICAR, VPN cohérent).
- Le second choix devient une **décision** explicite (Clôturer, Surveiller, Investiguer, Contenir), avec une aide pour chacune. Les réponses des 6 alertes d'origine ont été harmonisées avec ce barème ; leurs identifiants sont conservés, donc les XP déjà obtenus restent acquis.
- La correction sépare l'explication et l'action recommandée, et cite la technique MITRE ATT&CK.
- Les alertes pas encore réussies sont tirées en priorité, jamais deux fois de suite la même. Compteur « Alertes réussies : x / 24 ».

### CTF
- 28 challenges au lieu de 12. 13 se résolvent dans le terminal du Lab (analyse de auth.log et access.log, drapeau de root, /etc/passwd, sshd_config, crontab, syslog, Base64, ROT13, chmod +x…).
- La solution affiche la commande à taper dans le terminal ; un test exécute chacune de ces commandes et vérifie qu'elle affiche bien la réponse.
- Le filtre de catégories est construit à partir des données (« OSINT », sans challenge, disparaît ; « Scripting » et « Forensic » apparaissent).

### Wireshark
- Nouvel onglet **Capture** : une capture simulée de 32 paquets (HTTPS, intranet en HTTP avec mot de passe en clair, ping, tunnel DNS, scan SYN, usurpation ARP).
- Moteur de **filtres d'affichage** : protocoles, `ip.addr` / `ip.src` / `ip.dst`, ports, drapeaux TCP, champs DNS / HTTP / TLS / ARP, opérateurs `==`, `!=`, `>`, `<`, `>=`, `<=`, `contains`, `&&`, `||`, `!`, parenthèses. Barre verte ou rouge et message d'erreur explicite, comme dans Wireshark.
- 9 exercices validés sur l'ensemble des paquets affichés : toute écriture équivalente est acceptée. 20 XP par exercice, une seule fois.
- Détail de chaque paquet (champs), et 4 scénarios d'analyse appuyés sur la capture. L'onglet « Filtres » devient un mémo plus complet.

### Terminal
- Nouvelle commande `tr` (translittération, plages, `-d`).
- `base64 -d` accepte l'absence de « = » final.

### Badges
- « Analyste SOC » (10 alertes réussies) et « Analyste réseau » (5 exercices Wireshark).

### Tests
- 237 tests (216 auparavant).

## [1.2.0] - 2026-11-23

### Parcours d'apprentissage
- Le parcours se choisit enfin (Profil → « Changer », ou carte Parcours de l'Accueil). Il en existe 6, un par catégorie de cours.
- L'Accueil affiche le parcours, sa progression (cours terminés / total) et propose le premier cours non terminé de ce parcours, puis d'un autre parcours une fois celui-ci terminé.
- L'onglet Apprendre s'ouvre sur la catégorie du parcours (marquée ★). Tous les cours restent accessibles.

### Premier lancement
- Nouvel écran d'accueil en 3 étapes : présentation et règle éthique, prénom (facultatif), choix du parcours. « Passer » garde les valeurs par défaut.
- Il n'est jamais montré à un utilisateur qui a déjà des données (XP, cours, notes…).

### Export / import de la progression
- Paramètres → « Sauvegarde de la progression » : export dans un fichier JSON à l'emplacement choisi (Téléchargements, Drive…) via le sélecteur de fichiers Android, sans permission de stockage.
- Contenu : progression, notes, réglages non secrets et, sur demande, l'historique du coach. Les clés API et l'ancienne clé v1 ne sont **jamais** exportées (liste blanche).
- Import : validation du fichier, aperçu (niveau, XP, cours, notes), confirmation, puis remplacement. L'état actuel est copié sous `*_corrupt_<horodatage>` avant remplacement. Les clés API de l'appareil sont conservées. Les récompenses déjà obtenues ne sont pas redonnées.
- Nouvelle dépendance : `file_picker`.

### Terminal simulé : système de fichiers virtuel
- Le terminal devient un vrai shell pédagogique sur une arborescence **virtuelle** en mémoire (`/home/learner`, `/etc`, `/var/log`, `/root`…), avec des fichiers exploitables : `auth.log`, `access.log`, `/etc/passwd`, scripts, notes, rapport d'incident.
- Commandes réelles : `cd`, `ls -la`, `cat`, `head`, `tail`, `grep` (`-ivncloErw`), `wc`, `sort`, `uniq -c`, `cut`, `awk '{print $N}'`, `sed s///`, `find` (`-name`, `-type`, `-user`, `-delete`, `-exec`), `tree`, `mkdir -p`, `touch`, `cp`, `mv`, `rm`, `rmdir`, `chmod` (octal et symbolique), `chown`, `file`, `stat`, `base64`, `history`, `env`…
- Shell : tubes `|`, redirections `>`, `>>`, `<`, `2>/dev/null`, `2>&1`, `;`, `&&`, `||`, variables, `$?`, `$(…)`, jokers `*.log`, `~`.
- Droits Linux simulés : `/etc/shadow`, `/var/log` et `/root` refusés à learner. `sudo commande` et `sudo -i` / `exit` pour root.
- Scripts : `bash script.sh`, ou `./script.sh` après `chmod +x`. Le Command Guard s'applique à chaque ligne.
- `labreset` restaure les fichiers d'origine. La session (fichiers, écran, historique) est conservée quand on change d'onglet du Lab. Bouton de rappel de la commande précédente.
- Le moteur n'utilise aucun accès système : aucune commande n'est exécutée sur l'appareil (vérifié par un test).

### Tests
- 215 tests au total (171 auparavant) : terminal et système de fichiers virtuel, parcours, premier lancement, export et import, écrans associés.

## Corrections de l'audit du 2026-11-22 (incluses dans la 1.2.0)

### Fiabilité du chargement
- Chaque section (progression, notes, réglages, historique du coach) est chargée **séparément** : l'échec de l'une ne vide plus les autres.
- Les notes et les messages du coach sont validés **un par un**. Un élément invalide est ignoré, les autres sont chargés et la valeur d'origine complète est copiée sous `<clé>_corrupt_<horodatage>` avant toute réécriture.
- `Note.fromJson` et la migration des réglages IA tolèrent les types inattendus (identifiant numérique, fournisseur non textuel…) au lieu de lever une exception.
- Auparavant, une seule note malformée pouvait faire échouer tout le chargement, et la prochaine action écrasait alors notes et réglages sans copie de secours.

### Command Guard (règle pédagogique du simulateur)
- Nom de commande normalisé (`\rm`, `r\m`, `/bin/rm`, `"rm"`).
- Nouveaux préfixes reconnus : `doas`, `nice`, `ionice`, `timeout`, `xargs`, `stdbuf`, `setsid`, `watch`, `builtin`, ainsi que leurs options.
- Code imbriqué analysé : `bash -c`, `sh -c`, `su -c`, `eval`, `$(…)` et `` `…` `` (sauf entre apostrophes).
- `rm` : abréviations GNU (`--rec`, `--f`), `--interactive=never`, options placées après les fichiers.
- Nouvelles règles : formatage (`mkfs*`, `mke2fs`, `mkswap`, `wipefs`), `shred`, `find -delete` sur un répertoire système, `find -exec` dangereux, `chmod`/`chown`/`chgrp -R` sur un répertoire système, redirection `>` vers un disque, bombe fork.

### Progression
- **Fin de cours** : il faut avoir réussi au moins **70 %** des questions du quiz (arrondi supérieur) pour terminer un cours et gagner ses XP. Les exercices restent liés à la fin du cours. Les cours déjà terminés le restent.
- **CTF** : l'affichage de la solution est enregistré durablement (`revealedChallenges`), après une confirmation. Le challenge peut encore être validé, mais il ne rapporte plus d'XP, même après avoir quitté puis rouvert l'écran.

### Réseau et confidentialité
- En HTTP, un nom `*.local` est **résolu avant l'envoi**. La requête est refusée si l'une des adresses obtenues n'est pas locale.
- La plage `100.64.0.0/10` (CGNAT, utilisée par Tailscale) est acceptée comme réseau local.
- Paramètres : avertissements affichés pendant la saisie pour une adresse non officielle d'un fournisseur distant, une clé API envoyée en clair en HTTP, ou des messages transmis en clair sur le réseau local.
- Paramètres et coach : il est indiqué que notes, progression et historique du coach figurent dans la sauvegarde Android, et que les clés API n'y figurent jamais. L'avertissement d'échec de migration de l'ancienne clé le précise aussi.
- Le bouton « Enregistrer » des Paramètres ne reste plus bloqué en cas d'erreur.

### Tests
- 171 tests au total (97 auparavant) : chargement tolérant, condition de quiz, solution CTF consultée, contournements du Command Guard, résolution des noms `*.local`, avertissements réseau, et écrans associés.

## [1.1.0] - 2026-11-08

Version corrective issue de l'audit (`CORRECTIONS_AUDIT.md`). Contenu pédagogique et identité visuelle inchangés.

### Quiz et affichage
- **Onglet Quiz** : il plantait à l'ouverture (`Spacer` directement dans une `ListView`). La disposition est désormais valide et défile sur petit écran.
- **Réponse libre** : le champ est piloté par un contrôleur, le bouton « Valider » s'active à la saisie, une réponse vide est refusée et le champ est vidé entre deux questions. Une liste vide est gérée.
- **XP du quiz** : une seule valeur sert à la fois au gain et à l'affichage (`QuizQuestion.xp`). Le quiz distingue un nouveau gain d'une question déjà récompensée.
- **Bonne réponse** : un QCM affiche désormais le texte de l'option, et non plus son index.
- **Indices** : l'indice du quiz ne donne plus la réponse. Un champ `hint` facultatif est ajouté, avec une piste générique par défaut. Les indices CTF qui donnaient la solution ont été réécrits.
- **Comparaison des réponses** (`AnswerMatcher`) : seules les variantes listées une par une sont acceptées. Les espaces sont réduits hors guillemets uniquement. La casse est respectée pour les commandes. Aucune équivalence automatique entre commandes.
- **CTF** : le bouton « Valider » ne s'activait jamais (aucune mise à jour à la saisie). C'est corrigé.

### Progression et XP
- **Fin de cours** : le double gain est supprimé. `completeCourse()` est le seul point d'attribution.
- **Récompenses uniques**, mémorisées durablement (`rewardedKeys`) : par cours, par exercice (`cours#index`), par question (`cours/question`), par alerte SOC et par CTF. Une réponse d'abord fausse rapporte encore ses XP. Ces règles sont centralisées dans `UserState` et `AppState` (les écrans n'attribuent plus d'XP).
- **Barre de niveau** : elle utilise les mêmes seuils cumulés que le calcul du niveau (0 / 500 / 1500 / 3000…).
- **Série quotidienne** : elle fonctionne maintenant, sur dates locales, sans double comptage le même jour et sans effet des changements d'heure.
- **Temps d'apprentissage** : il est calculé sur le temps au premier plan ; l'arrière-plan est exclu.
- **Badges** : une source de vérité unique (`BadgeService`) sert l'accueil, le profil et la sauvegarde.
- **Sauvegarde** : instance réutilisée, écritures en file ordonnée, erreurs affichées dans un bandeau. Les données illisibles sont copiées au lieu d'être écrasées.
- **Migration du schéma 1 vers 2** : XP, niveau (recalculé), notes, cours et CTF sont conservés, et les XP des cours et CTF déjà obtenus ne sont pas redonnés.

### CyberCoach et réseau
- La permission `INTERNET` est ajoutée au manifeste principal ; l'APK release ne pouvait pas joindre l'IA.
- `network_security_config` : HTTP en clair interdit, certificats système. La restriction effective du HTTP local est faite dans le code (voir README, limite vérifiée).
- **Adresses par défaut** : OpenAI et Mistral ont chacun la leur (Mistral envoyait auparavant sa clé à OpenAI). Les slashs sont normalisés et les chemins ne sont plus dupliqués. HTTPS est obligatoire pour les fournisseurs distants, HTTP n'est accepté que vers un hôte local, et les identifiants sont interdits dans l'URL.
- **Profils par fournisseur** : une clé n'est jamais envoyée à un autre fournisseur, et Ollama ne reçoit jamais de clé.
- **Mémoire de conversation** : historique limité (12 messages, 6000 caractères), conservé localement, avec un bouton « Nouvelle conversation ».
- **Requête portée par `AppState`** : quitter l'écran pendant l'attente ne provoque plus d'erreur et le bouton d'envoi est toujours libéré.
- **Hors ligne** : l'application affiche une information explicite et ne présente plus de réponse prédéfinie comme une réponse IA. Le simulateur SOC ne se dit plus « corrigé par l'IA ».
- **Modèle obligatoire** : il n'y a plus de modèle supposé par défaut (`gpt-4o-mini`, `claude-3-5-haiku-latest`, `gemini-1.5-flash`, `llama3` sont retirés).
- **Client HTTP injectable**, ce qui permet de tester sans appel réel.

### Confidentialité
- Les clés API passent dans `flutter_secure_storage`. La migration depuis `SharedPreferences` vérifie la relecture avant de supprimer l'ancienne clé et gère les échecs.
- **Gemini** : la clé est envoyée dans l'en-tête `x-goog-api-key`, plus dans l'URL.
- **Erreurs HTTP** : des messages compréhensibles remplacent le contenu brut des réponses (authentification, quota, modèle, serveur, réseau, délai, TLS).
- **Sauvegardes Android** : règles en liste blanche (préférences seulement). Les secrets en sont exclus.

### Terminal simulé
- Le **Command Guard** est centralisé dans le moteur (`CommandGuard`). Il analyse les arguments et les segments de commande au lieu de chercher une sous-chaîne. Il couvre `rm -rf`, `-fr`, `-r -f`, `--recursive --force` et `dd of=`, sans bloquer `echo "rm -rf /"`. Il est présenté comme une règle pédagogique.
- La commande `clear` vide maintenant l'écran.

### Android et livraison
- Le libellé affiché est « CyberLab Agent ». L'`applicationId` est conservé.
- **Signature release** : lue depuis `android/key.properties` ou les variables `CYBERLAB_*`, sans génération de clé. Sans ces secrets, l'APK est signé debug et identifié comme **APK de test**.
- Version : 1.1.0+2.

### Tests
- 97 tests au total (17 auparavant) : progression, migration, IA avec clients simulés, secrets, Command Guard et widgets.

## [1.0.1] - 2026-08-28

### Corrections UI
- Écran **Lab** : les cartes du gestionnaire de laboratoires passent d'une liste verticale pleine largeur à une disposition `Wrap` en 2 colonnes uniformes sur smartphone (3-4 colonnes sur écrans larges). Chaque carte est compacte : icône + nom en haut, type/difficulté/statut à gauche, boutons (`Démarrer`/`Arrêter`/`Réinit.`) répartis en bas.
- **Lab & Réseau (Wireshark)** : correctif des débordements horizontaux des `SegmentedButton` sur écran étroit — icônes de segments retirées, coche de sélection désactivée, police réduite (12px) et densité compacte pour que les 4 segments (Terminal/SOC/Labs/Réseau et Cours/Filtres/Challenges/Analyse) tiennent sans dépasser.
- **Réseau (Wireshark), onglet Filtres** : la card « Filtre IP » s'affichait mal car le filtre était placé dans un `ListTile.trailing` rigide qui écrasait les filtres longs (`ip.addr == 192.168.1.10`). Remplacé par une carte verticale où le filtre est affiché sur toute sa largeur dans un encadré monospace repliable : rendu uniforme quelle que soit la longueur du filtre.
- **Réseau (Wireshark), onglet Challenges** : la réponse attendue affichée après échec (`SelectableText`) débordait horizontalement pour les filtres longs — enveloppée dans un `SingleChildScrollView` horizontal pour permettre le défilement au lieu du débordement.

## [1.0.0] - 2026-08-28

### Ajouté
- Application complète **CyberLab Agent** 100% hors ligne pour Android.
- **Cours** : 95 cours en 6 catégories (Fondamentaux, Linux, Réseau, Bash, Python, Web) avec sections, quiz, exercices, difficultés et erreurs courantes.
- **CTF** : 12 challenges avec indices progressifs puis solution et explication, attribution d'XP.
- **Lab** : Terminal Linux simulé (Command Guard anti-destruction), Simulateur SOC d'analyse d'alertes, filtres et mini-challenges Wireshark, gestionnaire de labs (mode simulation).
- **CyberCoach** : module de chat IA configurable (Ollama local, OpenAI, Anthropic, Gemini, Mistral) qui guide sans dévoiler les réponses ; mode hors ligne de secours.
- **Progression** : XP, niveaux, badges (11), compétences, série, statistiques.
- **Notes** : prise de notes CRUD avec catégories et favoris.
- **Docs** : 10 cheat sheets.
- **Paramètres** : mode sombre/clair, nom d'utilisateur, config IA, réinitialisation de progression.
- **UI** : Material 3, navigation 5 onglets + tiroir, style sombre type labo cyber.
- **Tests** : 17 tests (validation du contenu de cours, modèles, smoke tests widgets).

### Corrections techniques
- Corrigé le déséquilibre de parenthèses/équerres (fermeture transposée `)]`→`])`) dans 4 fichiers de contenu (`course_bash.dart`, `course_networking.dart`, `course_python.dart`, `course_web.dart`) qui empêchaient la compilation (46 transpositions corrigées).
- Échappement correct des `$` dans les chaînes Dart du contenu shell (variables `$var`, `$0`, `$#`, `$?`...).
- Correction des apostrophes échappées (`\'`).
- Réécriture de la tokenisation du terminal sans expressions régulières fragiles.
- Corrigé l'échappement du `$` dans l'invite du terminal.
- Ajout des imports manquants dans `course_library.dart`.
- Correction de l'ambiguïté du type `Badge` (conflit avec Material) dans l'écran Profil.
- Correction des chemins d'import dans `root_shell.dart`.
- Remplacé les icônes inexistantes (`Icons.python`, `Icons.docker`).
- Suppression des dépendances inutilisées (`pdf`, `printing`, `path_provider`, `share_plus`, `url_launcher`) qui injectaient le plugin natif `jni` en échec de compilation sous ce NDK (dépendances minimales conservées : `shared_preferences`, `provider`, `http`).

### Créé
- Écrans : CTF, Profil, CyberCoach, Notes, Docs, Paramètres.
- Fichiers de test (`test/data_test.dart`, `test/model_test.dart`, `test/widget_test.dart`).
- Documentation : `README.md`, `CHANGELOG.md`, rapport de build/tests.
