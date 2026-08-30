# Rapport de build et de tests — CyberLab Agent v1.0.0

Date : 2026-08-28
Environnement : Linux (aarch64), Flutter 3.44.8, Dart 3.12.2, Android SDK / NDK 28.2, OpenJDK 17

## Analyse statique (`flutter analyze`)

- **0 erreur**
- 31 avertissements/infos mineurs (dépréciations `withOpacity`, `groupValue`, style lint non bloquant)

## Tests (`flutter test`)

**17 tests, tous réussis.**

| Fichier | Contenu |
|---------|---------|
| `test/data_test.dart` | Validation du contenu : 95 cours répartis en 6 catégories, unicité des ids, intégrité des champs (summary, quiz, exercises, commonMistakes, objectives), 12 CTF, 10 cheat sheets, 11 badges |
| `test/model_test.dart` | XP/niveaux, sérialisation UserState, `QuizQuestion.isCorrect`, sérialisation Note |
| `test/widget_test.dart` | Smoke tests : construction de l'app et navigation, écrans CTF et Notes |

## Build (`flutter build apk --release`)

- **Succès**
- APK : `build/app/outputs/flutter-apk/app-release.apk` (53,5 Mo)

## Contenu livré

- 95 cours : Fondamentaux (12), Linux (21), Réseau (26), Bash (12), Python (12), Web (12)
- 12 challenges CTF
- 10 cheat sheets
- 11 badges
- Terminal simulé + Simulateur SOC + filtres Wireshark
- CyberCoach IA configurable (Ollama/OpenAI/Anthropic/Gemini/Mistral)

## Corrections principales apportées cette session

1. **Déséquilibre de fermeture transposée `)]`→`])`** dans `course_bash.dart`, `course_networking.dart`, `course_python.dart`, `course_web.dart` (46 transpositions corrigées) — cause de la majorité des erreurs de compilation du contenu.
2. Échappement des `$` et correction des apostrophes dans le contenu Dart.
3. Réécriture de la tokenisation du terminal (sans regex fragile).
4. Création des 6 écrans manquants (CTF, Profil, Coach, Notes, Docs, Paramètres).
5. Ajout `resetProgress()`, correction d'imports (root_shell, course_library), ambiguïté `Badge`, icônes inexistantes.
6. **Suppression des dépendances inutilisées** (`pdf`, `printing`, `path_provider`, `share_plus`, `url_launcher`) qui injectaient le plugin natif `jni` en échec de compilation — a débloqué le build APK.
