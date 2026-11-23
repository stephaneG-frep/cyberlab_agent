import '../models/answer_matcher.dart';
import 'terminal_exercises.dart';

/// Étape d'un scénario guidé. Chaque étape est autonome : elle se fait sur
/// les fichiers d'origine du terminal ou sur la capture simulée.
sealed class ScenarioStep {
  final String title;
  final String instruction;
  final String hint;

  /// Affichée après la réussite.
  final String explanation;
  const ScenarioStep({
    required this.title,
    required this.instruction,
    required this.hint,
    required this.explanation,
  });
}

/// Travail dans le terminal, vérifié par des critères.
class TerminalStep extends ScenarioStep {
  final List<TerminalCheck> checks;

  /// Commandes de référence (vérifiées par les tests).
  final String solution;
  const TerminalStep({
    required super.title,
    required super.instruction,
    required super.hint,
    required super.explanation,
    required this.checks,
    required this.solution,
  });
}

/// Filtre à appliquer sur la capture : validé sur les paquets affichés.
class FilterStep extends ScenarioStep {
  final String solution;
  const FilterStep({
    required super.title,
    required super.instruction,
    required super.hint,
    required super.explanation,
    required this.solution,
  });
}

/// Réponse libre.
class AnswerStep extends ScenarioStep {
  final String answer;
  final List<String> accepted;
  final bool caseSensitive;
  const AnswerStep({
    required super.title,
    required super.instruction,
    required super.hint,
    required super.explanation,
    required this.answer,
    this.accepted = const [],
    this.caseSensitive = false,
  });

  bool isCorrect(String input) => AnswerMatcher.matches(
    input,
    answer,
    variants: accepted,
    caseSensitive: caseSensitive,
  );
}

/// Décision : [options] (la bonne est [correct]), chacune avec un retour.
class ChoiceStep extends ScenarioStep {
  final List<({String text, String feedback})> options;
  final int correct;
  const ChoiceStep({
    required super.title,
    required super.instruction,
    required super.hint,
    required super.explanation,
    required this.options,
    required this.correct,
  });
}

class Scenario {
  final String id;
  final String title;
  final String difficulty;
  final String context;
  final List<ScenarioStep> steps;

  /// Bilan affiché à la fin.
  final String debrief;

  const Scenario({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.context,
    required this.steps,
    required this.debrief,
  });

  static const maxXp = 100;
  static const minXp = 50;
  static const errorCost = 10;

  /// XP du scénario : 100, moins 10 par mauvaise décision, 50 au minimum.
  static int xpFor(int errors) {
    final xp = maxXp - errorCost * errors;
    return xp < minXp ? minXp : xp;
  }
}

TerminalCheck _out(String label, List<String> v) =>
    TerminalCheck(CheckKind.output, label, values: v);

final List<Scenario> scenarios = [
  Scenario(
    id: 'sc-bruteforce',
    title: 'La porte forcée',
    difficulty: 'Facile',
    context:
        'Le SIEM signale une rafale d\'échecs SSH sur le serveur cyberlab. '
        'Vous êtes de garde : déterminez ce qui s\'est passé et réagissez. Les '
        'journaux sont dans ~/logs.',
    steps: [
      TerminalStep(
        title: 'Mesurer',
        instruction:
            'Comptez les échecs de connexion (« Failed password ») dans '
            'logs/auth.log.',
        hint: 'grep a une option pour compter les lignes.',
        explanation:
            'Sept échecs : peu en apparence, mais concentrés sur deux minutes.',
        checks: [
          const TerminalCheck(
            CheckKind.outputIs,
            'Le nombre d\'échecs est affiché',
            values: ['7'],
          ),
        ],
        solution: 'grep -c "Failed password" logs/auth.log',
      ),
      const AnswerStep(
        title: 'Identifier',
        instruction:
            'Quelle adresse IP est à l\'origine de la plupart des échecs ?',
        hint: 'Relisez les lignes « Failed password » dans logs/auth.log.',
        explanation: '203.0.113.7 totalise 5 des 7 échecs (admin puis root).',
        answer: '203.0.113.7',
      ),
      TerminalStep(
        title: 'Vérifier l\'impact',
        instruction:
            'L\'attaquant a-t-il réussi ? Affichez les connexions acceptées '
            'venant de son adresse.',
        hint: 'Une connexion réussie contient « Accepted ».',
        explanation:
            'Le compte backup s\'est connecté par mot de passe à 06:07:33, '
            'depuis l\'adresse de l\'attaquant : ce n\'est plus une simple '
            'tentative.',
        checks: [
          _out('La connexion réussie est trouvée', [
            'Accepted password for backup from 203.0.113.7',
          ]),
        ],
        solution: 'grep Accepted logs/auth.log | grep 203.0.113.7',
      ),
      const ChoiceStep(
        title: 'Décider',
        instruction: 'Que faites-vous maintenant ?',
        hint: 'Un compte est compromis et la machine est encore en service.',
        explanation:
            'Isoler coupe l\'accès de l\'attaquant, désactiver le compte ferme '
            'la porte, et laisser la machine allumée conserve les preuves en '
            'mémoire.',
        options: [
          (
            text: 'Éteindre le serveur tout de suite',
            feedback:
                'Vous perdriez la mémoire vive : processus et connexions de '
                'l\'attaquant.',
          ),
          (
            text: 'Surveiller encore 24 heures pour en savoir plus',
            feedback:
                'Un compte compromis est actif : attendre laisse l\'attaquant '
                'agir.',
          ),
          (
            text:
                'Isoler le serveur du réseau, le laisser allumé et désactiver '
                'backup',
            feedback: 'Oui : contenir sans détruire les preuves.',
          ),
          (
            text: 'Supprimer les lignes suspectes du journal',
            feedback: 'Ce sont vos preuves : on ne modifie jamais un journal.',
          ),
        ],
        correct: 2,
      ),
      TerminalStep(
        title: 'Chercher la persistance',
        instruction:
            'Un compte compromis peut servir à revenir. Trouvez la tâche '
            'planifiée système qui s\'exécute avec le compte backup.',
        hint: 'Les tâches planifiées système sont dans /etc/crontab.',
        explanation:
            'Toutes les 5 minutes, cron exécute /home/backup/sauvegarde.sh : en '
            'modifiant ce script, l\'attaquant reviendrait à volonté.',
        checks: [
          _out('La tâche planifiée est trouvée', [
            '/home/backup/sauvegarde.sh',
          ]),
        ],
        solution: 'cat /etc/crontab',
      ),
      TerminalStep(
        title: 'Sceller la preuve',
        instruction:
            'Enregistrez l\'empreinte SHA-256 de logs/auth.log dans '
            'rapports/empreintes.txt.',
        hint: 'sha256sum, puis > pour écrire dans un fichier.',
        explanation:
            'La même empreinte plus tard prouvera que le journal n\'a pas été '
            'modifié depuis la collecte.',
        checks: [
          const TerminalCheck(
            CheckKind.contains,
            'L\'empreinte est enregistrée',
            path: '~/rapports/empreintes.txt',
            values: ['logs/auth.log'],
          ),
          const TerminalCheck(
            CheckKind.command,
            'Calculée avec sha256sum',
            values: [r'\bsha256sum\b'],
          ),
        ],
        solution: 'sha256sum logs/auth.log > rapports/empreintes.txt',
      ),
    ],
    debrief:
        'Force brute, compte de service au mot de passe faible, persistance '
        'possible par cron. Durcissement : PermitRootLogin no, clés SSH au lieu '
        'des mots de passe, bannissement automatique (fail2ban) et comptes de '
        'service sans connexion interactive.',
  ),
  Scenario(
    id: 'sc-dns',
    title: 'Le poste bavard',
    difficulty: 'Moyen',
    context:
        'Le résolveur DNS signale un poste du réseau, 192.168.1.66, aux '
        'requêtes inhabituelles. Analysez la capture matin_lab.pcap.',
    steps: [
      const FilterStep(
        title: 'Isoler le poste',
        instruction: 'Affichez uniquement les paquets émis par 192.168.1.66.',
        hint: 'ip.src désigne l\'adresse source.',
        explanation:
            'Quatre requêtes DNS de type TXT, exactement toutes les 5 secondes.',
        solution: 'ip.src == 192.168.1.66',
      ),
      const AnswerStep(
        title: 'Nommer le domaine',
        instruction: 'Vers quel domaine partent ces requêtes ?',
        hint: 'Lisez la fin des noms demandés.',
        explanation:
            'exfil.example.net : seul le début du nom change à chaque requête.',
        answer: 'exfil.example.net',
        accepted: ['x7f3.exfil.example.net', 'example.net'],
      ),
      TerminalStep(
        title: 'Décoder',
        instruction:
            'Le début du nom ressemble à un encodage. Décodez dans le terminal '
            'celui de la troisième requête : cGFzc3dvcmRzLnR4dA',
        hint: 'echo … | base64 -d',
        explanation:
            'Le poste transmet « passwords.txt » : des données sortent cachées '
            'dans les noms demandés.',
        checks: [
          const TerminalCheck(
            CheckKind.outputIs,
            'Le texte caché est lisible',
            values: ['passwords.txt'],
          ),
        ],
        solution: 'echo cGFzc3dvcmRzLnR4dA | base64 -d',
      ),
      const ChoiceStep(
        title: 'Qualifier',
        instruction: 'Quelle technique ATT&CK décrit le mieux ce canal ?',
        hint: 'Le protocole applicatif utilisé est la clé.',
        explanation:
            'T1071.004 décrit l\'usage du DNS comme canal de communication.',
        options: [
          (
            text: 'T1110 — Brute Force',
            feedback: 'Aucun essai de mot de passe ici.',
          ),
          (
            text: 'T1071.004 — Application Layer Protocol: DNS',
            feedback: 'Oui : le DNS sert de canal caché.',
          ),
          (
            text: 'T1486 — Data Encrypted for Impact',
            feedback: 'C\'est le rançongiciel : rien n\'est chiffré ici.',
          ),
          (
            text: 'T1566.001 — Spearphishing Attachment',
            feedback:
                'C\'est peut-être l\'origine, mais pas ce que montre la capture.',
          ),
        ],
        correct: 1,
      ),
      const ChoiceStep(
        title: 'Réagir',
        instruction: 'Quelle est la première mesure ?',
        hint: 'L\'exfiltration est confirmée et en cours.',
        explanation:
            'On isole le poste (allumé) et on bloque le domaine sur les '
            'résolveurs : la fuite s\'arrête, les preuves restent.',
        options: [
          (
            text:
                'Isoler 192.168.1.66 et bloquer le domaine sur les résolveurs',
            feedback: 'Oui : la fuite s\'arrête sans perdre les preuves.',
          ),
          (
            text: 'Couper le DNS de toute l\'entreprise',
            feedback: 'Disproportionné : plus personne ne pourrait travailler.',
          ),
          (
            text: 'Réinstaller le poste immédiatement',
            feedback:
                'Les preuves et la cause de l\'infection seraient perdues.',
          ),
          (
            text: 'Attendre que le volume augmente',
            feedback: 'Les données sortent déjà.',
          ),
        ],
        correct: 0,
      ),
    ],
    debrief:
        'Tunnel DNS. Défenses : n\'autoriser que les résolveurs internes, '
        'surveiller les noms longs et réguliers ainsi que les requêtes TXT, '
        'et bloquer les domaines tout récents.',
  ),
  Scenario(
    id: 'sc-web',
    title: 'Le site sondé',
    difficulty: 'Moyen',
    context:
        'L\'équipe web a vu une erreur 500 inexpliquée. Étudiez '
        'logs/access.log et le site pour comprendre si l\'application a été '
        'attaquée.',
    steps: [
      TerminalStep(
        title: 'Repérer l\'outil',
        instruction:
            'Affichez les requêtes envoyées par l\'outil automatique sqlmap.',
        hint: 'Le nom de l\'outil figure dans le User-Agent.',
        explanation:
            'Trois requêtes : /admin, une injection sur /login.php et une '
            'tentative de lecture de /etc/passwd.',
        checks: [
          _out('Les requêtes de sqlmap s\'affichent', [
            'GET /admin',
            'login.php',
            'etc/passwd',
          ]),
        ],
        solution: 'grep sqlmap logs/access.log',
      ),
      TerminalStep(
        title: 'Lire les réponses',
        instruction:
            'Extrayez uniquement les codes de réponse HTTP reçus par '
            '203.0.113.7 (un par ligne).',
        hint: 'Le code est le 9e champ : cut -d \' \' -f 9 ou awk.',
        explanation: '403, 500, 400 : deux refus… et une erreur du serveur.',
        checks: [
          const TerminalCheck(
            CheckKind.outputRegex,
            'Les trois codes, un par ligne',
            values: [r'^403\n500\n400$'],
          ),
        ],
        solution: "grep 203.0.113.7 logs/access.log | cut -d ' ' -f 9",
      ),
      const ChoiceStep(
        title: 'Interpréter',
        instruction:
            'Que révèle le code 500 sur la requête contenant « OR 1=1 » ?',
        hint: 'Un refus propre aurait renvoyé 400 ou 403.',
        explanation:
            'L\'entrée a atteint le code et provoqué une erreur : une injection '
            'est probable et doit être vérifiée, sans être encore prouvée.',
        options: [
          (
            text: 'L\'attaque a été bloquée par le pare-feu',
            feedback:
                'Un blocage donnerait plutôt 403, pas une erreur interne.',
          ),
          (
            text: 'La base de données a été volée',
            feedback:
                'Rien ne le prouve : aucune donnée n\'a été renvoyée (0 octet).',
          ),
          (
            text: 'Rien : les erreurs 500 sont normales',
            feedback:
                'Une erreur déclenchée par une entrée hostile est un signal.',
          ),
          (
            text: 'L\'entrée a atteint l\'application : injection à vérifier',
            feedback: 'Oui : un indice sérieux, pas encore une preuve.',
          ),
        ],
        correct: 3,
      ),
      TerminalStep(
        title: 'Chercher d\'autres fuites',
        instruction:
            'Lisez le code source de la page d\'accueil du site '
            '(/var/www/html/index.html).',
        hint: 'cat affiche le contenu d\'un fichier.',
        explanation:
            'Un commentaire oublié publie des identifiants de test, visibles de '
            'tous les visiteurs.',
        checks: [
          _out('Le commentaire bavard est trouvé', ['admin123']),
        ],
        solution: 'cat /var/www/html/index.html',
      ),
      const ChoiceStep(
        title: 'Corriger',
        instruction: 'Quel plan de correction traite les causes ?',
        hint: 'Il y a deux problèmes : l\'injection et la fuite.',
        explanation:
            'Les requêtes préparées suppriment la cause de l\'injection ; un '
            'identifiant publié est compromis, il faut le changer et pas '
            'seulement l\'effacer.',
        options: [
          (
            text: 'Bannir l\'adresse 203.0.113.7 et clore l\'incident',
            feedback:
                'L\'attaquant changera d\'adresse, les failles resteront.',
          ),
          (
            text:
                'Requêtes préparées, commentaire retiré et identifiants changés',
            feedback: 'Oui : chaque cause est traitée.',
          ),
          (
            text: 'Effacer le commentaire et garder le mot de passe',
            feedback:
                'Il a déjà été publié : il faut le considérer comme connu.',
          ),
          (
            text: 'Filtrer le mot « OR » dans les formulaires',
            feedback: 'Une liste noire se contourne toujours.',
          ),
        ],
        correct: 1,
      ),
    ],
    debrief:
        'Une reconnaissance outillée, une injection probable et une fuite '
        'd\'identifiants. Le même attaquant (203.0.113.7) a aussi forcé SSH : '
        'croisez toujours les journaux.',
  ),
  Scenario(
    id: 'sc-mitm',
    title: 'Quelqu\'un écoute',
    difficulty: 'Moyen',
    context:
        'Une utilisatrice, Alice, pense que son mot de passe de l\'intranet a '
        'fuité. Cherchez dans la capture matin_lab.pcap comment cela a pu '
        'arriver.',
    steps: [
      const FilterStep(
        title: 'Observer le réseau local',
        instruction: 'Affichez uniquement le trafic ARP.',
        hint: 'Le nom du protocole est déjà un filtre.',
        explanation:
            'Deux réponses ARP différentes annoncent la même adresse '
            '192.168.1.1, celle de la passerelle.',
        solution: 'arp',
      ),
      const AnswerStep(
        title: 'Trouver l\'imposteur',
        instruction:
            'Quelle adresse MAC usurpe celle de la passerelle ? (Le routeur '
            'légitime répond en premier, au paquet 2.)',
        hint: 'Comparez les paquets 2 et 32.',
        explanation:
            '08:00:27:66:66:66 se fait passer pour 192.168.1.1 : c\'est une '
            'usurpation ARP.',
        answer: '08:00:27:66:66:66',
      ),
      const FilterStep(
        title: 'Retrouver la connexion',
        instruction:
            'Affichez la requête HTTP qui envoie le formulaire de connexion.',
        hint: 'Un formulaire est envoyé avec la méthode POST.',
        explanation:
            'La connexion à l\'intranet passe en HTTP, sans chiffrement.',
        solution: 'http.request.method == "POST"',
      ),
      const AnswerStep(
        title: 'Constater la fuite',
        instruction:
            'Touchez ce paquet pour l\'ouvrir (étape précédente, ou onglet '
            'Réseau, puis Capture, paquet 17). Quel mot de passe est lisible ?',
        hint: 'Le champ http.file_data contient le formulaire envoyé.',
        explanation:
            'Le mot de passe circule en clair : quiconque capte le trafic le lit.',
        answer: 'Printemps2026!',
        caseSensitive: true,
      ),
      const ChoiceStep(
        title: 'Remédier',
        instruction: 'Quel ensemble de mesures répond au problème ?',
        hint:
            'Le mot de passe, le protocole et le réseau local sont concernés.',
        explanation:
            'On traite l\'identifiant compromis, le transport en clair et '
            'l\'usurpation elle-même.',
        options: [
          (
            text: 'Demander à Alice un mot de passe plus long',
            feedback:
                'En HTTP, même un mot de passe très long se lit en clair.',
          ),
          (
            text: 'Désactiver le Wi-Fi des visiteurs',
            feedback:
                'L\'usurpation vient du réseau local, pas du Wi-Fi invité.',
          ),
          (
            text:
                'Nouveau mot de passe, HTTPS sur l\'intranet, inspection ARP sur '
                'les commutateurs',
            feedback: 'Oui : l\'identifiant, le transport et le réseau.',
          ),
          (
            text: 'Vider le cache ARP du poste d\'Alice',
            feedback: 'L\'imposteur recommencera aussitôt.',
          ),
        ],
        correct: 2,
      ),
    ],
    debrief:
        'La capture montre un mot de passe en clair, puis une usurpation ARP. '
        'L\'ordre compte : l\'usurpation est observée APRÈS la connexion (paquet '
        '32). Elle prouve qu\'un intercepteur est présent, pas qu\'il a volé ce '
        'mot de passe précis ; on change l\'identifiant par précaution.',
  ),
];
