
Tu travailles sur le projet Flutter existant CyberLab Agent.

MISSION
Corriger les problèmes identifiés dans l’audit, fiabiliser l’application et produire une version Android testée et livrable.

Travaille directement dans le projet. Ne te limite pas à proposer des corrections. Conserve les fonctionnalités, le contenu pédagogique et l’identité visuelle existants.

AUTONOMIE
- Commence par lire les instructions du dépôt et examiner le code actuel.
- Vérifie chaque constat : certains problèmes peuvent déjà être corrigés.
- Avance par phases, dans l’ordre ci-dessous, sans demander une confirmation entre chaque phase.
- Ne supprime aucune donnée utilisateur et ne réinitialise pas la progression.
- Ne publie rien et ne fais aucun push.
- Ne crée, n’affiche et ne place aucun secret dans Git.
- Si une étape nécessite un secret absent, poursuis les autres travaux et documente précisément le blocage.
- N’annonce jamais un test ou un build réussi sans l’avoir exécuté.

PHASE 1 — QUIZ ET AFFICHAGE

1. Examiner QuizRunner :
   - remplacer le Spacer directement placé dans une ListView par une disposition valide ;
   - vérifier les contraintes de hauteur et le défilement sur petit écran ;
   - actualiser correctement l’état lors de la saisie d’une réponse libre ;
   - empêcher la validation d’une réponse vide ;
   - réinitialiser aussi le champ visible entre deux questions ;
   - gérer proprement une liste de questions vide.

2. Corriger la cohérence des récompenses :
   - utiliser une seule valeur de référence pour les XP attribués et affichés ;
   - distinguer une bonne réponse déjà récompensée d’un nouveau gain ;
   - afficher la réponse lisible pour les QCM, pas seulement son index.

3. Remplacer les indices qui dévoilent directement la réponse par de vrais indices pédagogiques.
   - Si nécessaire, ajouter un champ d’indice facultatif au modèle.
   - Sans indice spécifique, proposer une piste utile sans révéler la solution.

4. Améliorer les réponses acceptées :
   - autoriser des variantes explicitement définies pour chaque question ou CTF ;
   - normaliser prudemment les espaces ;
   - conserver la sensibilité à la casse lorsque le contenu l’exige ;
   - ne pas considérer automatiquement deux commandes comme équivalentes.

PHASE 2 — PROGRESSION ET XP

1. Supprimer le double gain à la fin d’un cours :
   completeCourse() doit être l’unique point d’attribution de cette récompense.

2. Empêcher les récompenses répétées :
   - cours : une récompense par cours ;
   - exercices : une récompense par exercice identifié ;
   - quiz : une récompense par question correctement résolue ;
   - SOC : une récompense par scénario ou alerte pédagogique identifiée.

   Les exercices restent rejouables, mais sans gain illimité.
   Une réponse initialement fausse doit pouvoir rapporter ses XP lors d’une réussite ultérieure.

3. Centraliser les règles de récompense dans la couche métier.
   Ne pas compter uniquement sur la désactivation des boutons.

4. Enregistrer durablement les identifiants déjà récompensés.
   Prévoir une migration compatible avec les données existantes :
   - conserver XP, notes, cours et défis terminés ;
   - éviter de réattribuer les récompenses déjà identifiables ;
   - documenter les limites si les anciennes données ne permettent pas de reconstituer certains gains.

5. Corriger la barre de niveau :
   - employer les mêmes seuils que le calcul du niveau ;
   - calculer la progression entre le début du niveau actuel et le suivant ;
   - tester les valeurs juste avant, sur et après chaque seuil.

6. Rendre fonctionnels :
   - la série quotidienne, calculée avec les dates locales et sans double comptage le même jour ;
   - le temps d’apprentissage actif, sans compter le temps passé en arrière-plan ;
   - les badges, avec une source de vérité commune à l’accueil et au profil.

7. Fiabiliser la sauvegarde :
   - attendre les écritures lorsque leur résultat est nécessaire ;
   - éviter les écritures concurrentes incohérentes ;
   - gérer les erreurs sans perte silencieuse ;
   - réutiliser l’instance de stockage lorsque pertinent.

PHASE 3 — CYBERCOACH ET RÉSEAU

1. Déclarer la permission INTERNET dans le manifeste Android principal.

2. Examiner la connexion HTTP locale à Ollama.
   - Appliquer la configuration Android la plus restrictive compatible avec les adresses locales configurables.
   - Vérifier les capacités réelles de network_security_config.
   - Ne pas prétendre qu’une règle couvre les plages privées ou le réseau local si Android ne le permet pas.
   - Si une autorisation HTTP plus large est techniquement nécessaire, expliquer la limite et restreindre également les destinations dans le code.
   - Garder HTTPS pour les fournisseurs distants.
   - Ne jamais désactiver la validation des certificats TLS.

3. Définir les bonnes adresses par défaut :
   - OpenAI : https://api.openai.com/v1
   - Mistral : https://api.mistral.ai/v1
   - conserver la configuration des API compatibles et d’Ollama.
   - normaliser les slashs et éviter les chemins dupliqués.
   - éviter qu’un changement de fournisseur conserve silencieusement l’adresse ou la clé du précédent.
   - ne pas envoyer de clé à un fournisseur différent de celui sélectionné.

4. Ajouter les vérifications mounted après les opérations asynchrones avant toute modification de l’interface.
   Gérer les délais d’attente et les erreurs sans laisser le bouton d’envoi bloqué.

5. Ajouter une mémoire de conversation :
   - transmettre les échanges précédents pertinents ;
   - limiter la taille de l’historique envoyé ;
   - conserver localement la conversation entre deux ouvertures ;
   - permettre de démarrer une nouvelle conversation et d’effacer l’historique ;
   - expliquer que les messages sont transmis au fournisseur configuré.

6. Présenter clairement le fonctionnement hors ligne :
   - les cours et simulateurs restent disponibles ;
   - sans modèle accessible, ne pas présenter une réponse prédéfinie comme une génération IA.

7. Rendre le modèle explicitement configurable.
   Ne pas remplacer les anciens noms par des modèles supposés disponibles.
   Vérifier les identifiants dans les documentations officielles si nécessaire ; sinon demander leur saisie dans les paramètres.

8. Rendre le service HTTP injectable afin de tester les requêtes sans consommer d’API réelle.

PHASE 4 — CONFIDENTIALITÉ

1. Déplacer les clés API vers un stockage sécurisé adapté à Android.
   - migrer les anciennes clés depuis SharedPreferences ;
   - confirmer la réussite de l’écriture sécurisée avant de supprimer l’ancienne valeur ;
   - gérer les échecs ;
   - ne jamais journaliser les clés.

2. Pour Gemini, utiliser l’en-tête x-goog-api-key plutôt qu’un paramètre d’URL, conformément à la documentation officielle.

3. Remplacer l’affichage brut des corps d’erreur HTTP par des messages compréhensibles :
   authentification, quota, modèle indisponible, serveur inaccessible, délai dépassé.
   Masquer les secrets et limiter les détails techniques.

4. Exclure les secrets des sauvegardes Android.
   Choisir entre des règles d’exclusion correctement configurées et la désactivation des sauvegardes ; documenter le choix.

5. Vérifier que l’export éventuel et les rapports ne contiennent aucun secret.

PHASE 5 — TERMINAL SIMULÉ

1. Conserver le terminal entièrement simulé.
   Ne pas ajouter d’exécution système réelle.

2. Centraliser le Command Guard dans le moteur.
   Vérifier notamment :
   - rm -rf ;
   - rm -fr ;
   - rm -r -f ;
   - rm --recursive --force ;
   - les variantes d’espacement et d’ordre pertinentes ;
   - les commandes dd considérées dangereuses par les règles du simulateur.

3. Utiliser une analyse cohérente des arguments plutôt qu’une simple recherche de sous-chaîne.
   Éviter de bloquer une commande inoffensive qui ne fait que citer ces termes.

4. Présenter cette protection comme une règle pédagogique du simulateur, sans prétendre qu’il s’agit d’un environnement système réel sécurisé.

PHASE 6 — TESTS

Ajouter des tests de non-régression utiles couvrant :
- attribution unique des XP de cours, exercices, quiz et SOC ;
- échec puis réussite à un quiz ;
- répétition après redémarrage ;
- seuils et progression des niveaux ;
- série quotidienne ;
- cohérence des badges ;
- migration des anciennes données ;
- migration des clés avec succès et échec ;
- routage des fournisseurs IA et absence de fuite de clé entre fournisseurs ;
- historique envoyé et gestion des erreurs HTTP ;
- Command Guard ;
- ouverture et défilement du quiz ;
- saisie libre et activation de Valider ;
- navigation hors du coach pendant une requête en cours.

Utiliser des clients HTTP simulés. Aucun appel payant dans les tests.

Exécuter :
- dart format sur les fichiers modifiés ;
- flutter analyze ;
- flutter test.

Corriger les échecs liés au travail réalisé. Rapporter séparément tout blocage préexistant ou lié à l’environnement.

PHASE 7 — ANDROID ET LIVRAISON

1. Vérifier le libellé Android et afficher « CyberLab Agent ».

2. Conserver l’applicationId existant si l’application a déjà été installée ou distribuée.
   Un commentaire TODO ne justifie pas son changement.

3. Examiner la signature release :
   - ne pas présenter une signature debug comme une signature de production ;
   - configurer l’utilisation de secrets externes et ignorés par Git ;
   - ne pas générer ou remplacer silencieusement une clé de signature ;
   - si aucune clé de production n’est disponible, documenter le blocage et identifier clairement tout APK de test ;
   - prévenir qu’une signature différente peut empêcher la mise à jour d’une installation existante.

4. Incrémenter la version de manière cohérente.

5. Mettre à jour README.md, CHANGELOG.md et RAPPORT_BUILD.md :
   - fonctionnement réel ;
   - configuration du coach ;
   - limites du mode hors ligne ;
   - stockage et sauvegardes ;
   - résultats réellement obtenus ;
   - limites restantes.

6. Construire l’APK si l’environnement le permet.
   Ne pas annoncer une livraison production si la signature ou les validations nécessaires manquent.

7. Préparer dans dist/ :
   - l’APK si construit, avec un nom indiquant clairement son statut ;
   - un ZIP propre des sources ;
   - un court rapport des corrections et vérifications ;
   - les sommes SHA-256 des livrables.

Exclure du ZIP :
clés, tokens, keystores, local.properties, caches Gradle, .dart_tool, build et fichiers propres à la machine.
Éviter d’inclure dist dans son propre ZIP.

COMPTE RENDU FINAL
Indiquer brièvement :
- les corrections réalisées ;
- les tests et builds exécutés avec leurs résultats ;
- les chemins exacts des livrables ;
- les limites et blocages réels.

Commence maintenant par vérifier le code actuel, puis exécute les phases jusqu’au bout sans t’arrêter après le diagnostic.