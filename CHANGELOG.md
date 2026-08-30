# Changelog

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
