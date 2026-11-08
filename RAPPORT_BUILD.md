# Rapport de build et de tests — CyberLab Agent v1.1.0 (code 2)

Date : 2026-11-08
Environnement : Linux x86_64, Flutter 3.47.2 (stable), Dart 3.13.2, Gradle 9.1.0, JDK 21 (Android Studio), Android SDK (compileSdk/targetSdk 36, minSdk 24).

Tous les résultats ci-dessous proviennent de commandes réellement exécutées sur cette machine.

## Analyse statique

- `dart format lib test` : appliqué.
- `flutter analyze` : **No issues found!** (0 erreur, 0 avertissement, 0 info).

## Tests (`flutter test`)

**97 tests, tous réussis.** Aucun appel réseau réel : les tests IA utilisent `package:http/testing.dart` (`MockClient`) et un stockage de secrets en mémoire.

| Fichier | Tests | Couverture |
|---|---|---|
| `test/model_test.dart` | 12 | Seuils de niveau (juste avant, sur et après chaque seuil), barre de progression, sérialisation, variantes et casse des réponses, réponse lisible d'un QCM, indices qui ne révèlent pas la réponse |
| `test/progress_test.dart` | 18 | XP attribués une seule fois (cours, exercices, quiz, SOC, CTF), échec puis réussite, répétition après redémarrage, série quotidienne (même jour, lendemain, jour manqué, changement de mois et d'heure, horloge reculée), temps au premier plan, cohérence des badges, migration v1, données illisibles copiées |
| `test/ai_service_test.dart` | 21 | Routage OpenAI, Mistral, Anthropic, Gemini et Ollama ; en-têtes ; aucune fuite de clé entre fournisseurs ; HTTPS et hôtes locaux ; modèle obligatoire ; historique transmis et limité ; erreurs HTTP sans corps ni secret ; serveur inaccessible et délai dépassé ; migration des clés (succès, échec, relecture différente) ; coach hors ligne ; persistance de la conversation |
| `test/terminal_guard_test.dart` | 33 | Command Guard (18 commandes bloquées, 10 autorisées, moteur, guard désactivé), variantes CTF, indices CTF sans la réponse |
| `test/data_test.dart` | 7 | Intégrité du contenu (95 cours, 12 CTF, 10 cheat sheets, 11 badges) |
| `test/widget_test.dart` | 6 | Démarrage et navigation, écrans CTF et Notes, ouverture et défilement du quiz sur un écran de 320×480, saisie libre et activation de Valider, sortie du coach pendant une requête |

## Build (`flutter build apk --release`)

- **Succès**, `build/app/outputs/flutter-apk/app-release.apk` (54,9 Mo).
- Vérifications faites sur l'APK avec `aapt2` et `apksigner` :
  - paquet `com.cyberlab.cyberlab_agent`, versionName 1.1.0, versionCode 2 ;
  - libellé « CyberLab Agent » ;
  - permission `android.permission.INTERNET` présente ;
  - attributs `networkSecurityConfig`, `fullBackupContent`, `dataExtractionRules`, `allowBackup=true` et `usesCleartextTraffic=false` présents ;
  - signature valide, **certificat `CN=Android Debug`** (SHA-256 `4a11b4a9…a0b6d`).

### ⚠️ Statut de l'APK : APK DE TEST

Aucune clé de signature de production n'est disponible (pas de `android/key.properties`, pas de variables `CYBERLAB_*`). La variante release a donc été signée avec la clé **debug** de cette machine. Cet APK sert aux tests et **ne doit pas être distribué comme une version de production**. Aucune clé n'a été générée ni remplacée.

Pour produire un APK de production, fournissez les secrets externes décrits dans le README (section « Signature release »), puis relancez le build.

Une installation existante signée avec un autre certificat (APK v1.0 construit ailleurs, ou futur APK de production) ne pourra pas être mise à jour par celui-ci. Il faudra désinstaller l'application, ce qui efface ses données locales.

## Limites restantes

- **Signature de production** : bloquée faute de secret (voir ci-dessus).
- **Migration v1** : la v1 ne gardait aucune trace des exercices validés ni des alertes SOC réussies. Ses résultats de quiz étaient indexés par un identifiant ambigu (« q1 » existe dans presque tous les cours). Ces récompenses peuvent donc être obtenues **une fois de plus** après mise à jour. Les XP déjà acquis sont conservés.
- **Exercices** : ils sont identifiés par leur position dans le cours. Réordonner les exercices d'un cours décalerait les récompenses déjà attribuées.
- **HTTP local** : la configuration réseau Android ne peut pas décrire des plages d'IP, et le client HTTP Dart ne la consulte pas. La restriction est donc faite dans le code (vérifié dans les sources du moteur Flutter 3.47.2 : `domainNetworkPolicy` vide). Si une future version de Flutter réappliquait la politique Android, l'accès HTTP à Ollama nécessiterait d'adapter `network_security_config.xml`.
- **Temps d'apprentissage** : c'est le temps au premier plan. Une application laissée ouverte sans interaction est comptée. Si l'application est tuée au premier plan, la dernière portion non enregistrée est perdue (au plus le temps écoulé depuis la dernière action).
- **Sauvegarde Android** : après restauration ou transfert, les clés API doivent être ressaisies (choix délibéré).
- **Tests sur appareil** : aucun test manuel sur un appareil physique ni sur émulateur n'a été réalisé dans cette session. Les appels réels aux fournisseurs IA n'ont pas été testés (pas de clé, et aucun appel payant n'était autorisé).
- **Avertissement Gradle** : l'avertissement « APK DE TEST » est émis via le logger Gradle. `flutter build` ne l'affiche pas toujours.

## Historique

- v1.0.0 / 1.0.1 (2026-08-28) : première version, 17 tests, build réussi (voir CHANGELOG).
