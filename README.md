# CyberLab Agent

Application Flutter 100% **hors ligne** d'apprentissage de la cybersécurité pour Android : cours, quiz, challenges CTF, coach IA, terminal simulé, analyseur de logs et simulateur SOC.

> Apprentissage uniquement, sur systèmes autorisés. Le terminal simulé et le lab bloquent toute action destructive.

## Fonctionnalités

- **Apprendre** : 95 cours répartis en 6 catégories (Fondamentaux 12, Linux 21, Réseau 26, Bash 12, Python 12, Web 12)
- **Quiz** : QCM, vrai/faux, réponse libre et exercices pratiques avec explications et points XP
- **Lab** : Terminal Linux simulé (sûr), Simulateur SOC (analyse d'alertes fictives), filtres Wireshark, gestionnaire de labs (simulation uniquement)
- **CTF** : 12 challenges (Linux, Web, Réseau, Crypto, Logs, OSINT) avec indices progressifs puis solution
- **CyberCoach** : professeur IA configurable (Ollama local, OpenAI, Anthropic, Gemini, Mistral) qui guide sans donner les réponses
- **Progression** : XP, niveaux, badges (11), compétences par catégorie, série
- **Notes** : prise de notes CRUD classées, favoris
- **Docs** : 10 cheat sheets (Linux, Bash, PowerShell, Nmap, Wireshark, Git, Docker, Python, HTTP, Burp Suite)
- **Terminal simulé** : Command Guard bloque `rm -rf`, `rm -fr`, `dd of=` — seulement de l'apprentissage
- **UI** : mode sombre type labo cyber (et clair), Material 3, responsive

## Installation

Installez l'APK `cyberlab_agent.apk` sur votre appareil Android (activer « sources inconnues » si besoin).
Aucune connexion requise : tout le contenu est embarqué dans l'application.

## Configurer le CyberCoach (facultatif)

Le coach fonctionne hors ligne avec des conseils génériques par défaut. Pour des réponses générées :
**Tiroir → Paramètres → CyberCoach / IA** : choisissez un fournisseur, saisissez modèle / URL / clé.

- **Ollama (local)** : URL `http://<IP-machine>:11434`, modèle `llama3` (ou autre)
- **OpenAI** : clé API, modèle `gpt-4o-mini`
- **Anthropic** : clé API, modèle `claude-3-5-haiku-latest`
- **Gemini** : clé API, modèle `gemini-1.5-flash`

> Vos clés restent sur l'appareil et ne sont envoyées qu'à l'API configurée. Elles ne sont **jamais** stockées dans le code, le ZIP, git ou les logs.

## Développement

Prérequis : Flutter 3.44+ / Dart 3.12+ et Android SDK.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK généré : `build/app/outputs/flutter-apk/app-release.apk`

## Sécurité & éthique

- Tous les exercices se font dans un environnement simulé et isolé.
- Le terminal et le SOC ne maîtrisent aucun système externe.
- Vous n'attaquez que ce qui vous appartient ou vous est explicitement autorisé.

## Structure

```
lib/
  models/       Modèles (Course, Quiz, CTF, Note, UserState...)
  services/     AppState, Stockage, IA, Moteur de terminal
  data/         Contenu des cours, CTF, cheat sheets, badges
  screens/      Écrans (Accueil, Apprendre, Lab, CTF, Profil, Coach, Notes, Docs, Paramètres)
  widgets/      Composants réutilisables (Quiz, SOC, Common)
test/           Tests unitaires + smoke tests widgets
```
