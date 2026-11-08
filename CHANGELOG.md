# Changelog

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
