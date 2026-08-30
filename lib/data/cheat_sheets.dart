class CheatSheet {
  final String id;
  final String title;
  final List<CheatEntry> entries;

  CheatSheet({required this.id, required this.title, required this.entries});
}

class CheatEntry {
  final String topic;
  final String syntax;
  final String description;

  CheatEntry({
    required this.topic,
    required this.syntax,
    required this.description,
  });
}

List<CheatSheet> cheatSheets() => [
  CheatSheet(
    id: 'cs-linux',
    title: 'Linux',
    entries: [
      CheatEntry(
        topic: 'Répertoire courant',
        syntax: 'pwd',
        description: 'Affiche où vous êtes.',
      ),
      CheatEntry(
        topic: 'Lister',
        syntax: 'ls -la',
        description: 'Liste tout, format détaillé, avec fichiers cachés.',
      ),
      CheatEntry(
        topic: 'Changer de dossier',
        syntax: 'cd [chemin]',
        description: 'cd .. remonte ; cd ~ va au home.',
      ),
      CheatEntry(
        topic: 'Voir le contenu',
        syntax: 'cat [fichier]',
        description: 'Affiche un fichier.',
      ),
      CheatEntry(
        topic: 'Rechercher texte',
        syntax: 'grep [motif] [fichier]',
        description: 'Filtre les lignes contenant le motif.',
      ),
      CheatEntry(
        topic: 'Chercher fichier',
        syntax: 'find [chemin] -name [nom]',
        description: 'Localise des fichiers par critères.',
      ),
      CheatEntry(
        topic: 'Permissions',
        syntax: 'chmod 755 [fichier]',
        description: 'Définit les permissions (rwxr-xr-x).',
      ),
      CheatEntry(
        topic: 'Propriétaire',
        syntax: 'chown [user]:[group] [file]',
        description: 'Change propriétaire/groupe (sudo).',
      ),
      CheatEntry(
        topic: 'Processus',
        syntax: 'ps aux',
        description: 'Liste tous les processus.',
      ),
      CheatEntry(
        topic: 'Élévation',
        syntax: 'sudo [commande]',
        description: 'Exécute avec privilèges élevés.',
      ),
      CheatEntry(
        topic: 'Logs',
        syntax: 'tail -f /var/log/auth.log',
        description: 'Suit les connexions en direct.',
      ),
      CheatEntry(
        topic: 'Réseau',
        syntax: 'ip addr',
        description: 'Affiche les adresses IP.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-bash',
    title: 'Bash',
    entries: [
      CheatEntry(
        topic: 'Shebang',
        syntax: '#!/bin/bash',
        description: 'Déclare l\'interpréteur.',
      ),
      CheatEntry(
        topic: 'Variable',
        syntax: 'x="valeur"; echo \$x',
        description: 'Affectation sans \$, lecture avec \$.',
      ),
      CheatEntry(
        topic: 'Condition',
        syntax: 'if [ cond ]; then ...; fi',
        description: 'Structure if/elif/else se termine par fi.',
      ),
      CheatEntry(
        topic: 'Boucle for',
        syntax: 'for i in 1 2 3; do ...; done',
        description: 'Itère sur une liste, finit par done.',
      ),
      CheatEntry(
        topic: 'Lire un fichier',
        syntax: 'while IFS= read -r l; do ...; done < file',
        description: 'Lit ligne par ligne.',
      ),
      CheatEntry(
        topic: 'Arguments',
        syntax: '\$1, \$2, \$#, \$@',
        description: 'Arguments du script et leur nombre.',
      ),
      CheatEntry(
        topic: 'Comparaisons',
        syntax: '-eq -gt -lt -ne -ge -le',
        description: 'Comparaisons de nombres dans les tests.',
      ),
      CheatEntry(
        topic: 'Tests fichiers',
        syntax: '-f -d -e -r -w -x',
        description: 'Teste type/existence/permissions.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-powershell',
    title: 'PowerShell',
    entries: [
      CheatEntry(
        topic: 'Lister',
        syntax: 'Get-ChildItem',
        description: 'Liste les fichiers (équivalent ls).',
      ),
      CheatEntry(
        topic: 'Aide',
        syntax: 'Get-Help [cmdlet]',
        description: 'Affiche l\'aide d\'une commande.',
      ),
      CheatEntry(
        topic: 'Processus',
        syntax: 'Get-Process',
        description: 'Liste les processus.',
      ),
      CheatEntry(
        topic: 'Filtrer',
        syntax: '... | Where-Object { \$_ -match "motif" }',
        description: 'Filtre les résultats (grep PowerShell).',
      ),
      CheatEntry(
        topic: 'Réseau',
        syntax: 'Test-NetConnection [hote]',
        description: 'Teste la connectivité (ping/PowerShell).',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-nmap',
    title: 'Nmap',
    entries: [
      CheatEntry(
        topic: 'Scan basique',
        syntax: 'nmap [cible]',
        description: 'Scan par défaut des ports courants.',
      ),
      CheatEntry(
        topic: 'Scan ports précis',
        syntax: 'nmap -p 22,80,443 [cible]',
        description: 'Ne scanner que ces ports.',
      ),
      CheatEntry(
        topic: 'Détection de version',
        syntax: 'nmap -sV [cible]',
        description: 'Identifie les versions des services.',
      ),
      CheatEntry(
        topic: 'Scan réseau',
        syntax: 'nmap -sn 192.168.1.0/24',
        description: 'Découvre les hôtes actifs (ping sweep).',
      ),
      CheatEntry(
        topic: 'Enregistrer',
        syntax: 'nmap -oN rapport.txt [cible]',
        description: 'Sauvegarde les résultats.',
      ),
      CheatEntry(
        topic: 'Éthique',
        syntax: 'UNIQUEMENT cible autorisée',
        description: 'localhost, réseau de lab ou autorisation écrite.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-wireshark',
    title: 'Wireshark',
    entries: [
      CheatEntry(
        topic: 'Filtre IP',
        syntax: 'ip.addr == 192.168.1.10',
        description: 'Filtre le trafic vers/à partir d\'une IP.',
      ),
      CheatEntry(
        topic: 'Filtre protocole',
        syntax: 'dns',
        description: 'N\'affiche que les paquets DNS.',
      ),
      CheatEntry(
        topic: 'Filtre port',
        syntax: 'tcp.port == 443',
        description: 'Filtre sur un port.',
      ),
      CheatEntry(
        topic: 'HTTP request',
        syntax: 'http.request',
        description: 'Affiche les requêtes HTTP.',
      ),
      CheatEntry(
        topic: 'Suivre un flux',
        syntax: 'Clic droit → Follow TCP Stream',
        description: 'Reconstitue l\'échange complet.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-git',
    title: 'Git',
    entries: [
      CheatEntry(
        topic: 'Initier',
        syntax: 'git init',
        description: 'Initialise un dépôt.',
      ),
      CheatEntry(
        topic: 'État',
        syntax: 'git status',
        description: 'Montre les fichiers modifiés.',
      ),
      CheatEntry(
        topic: 'Ajouter',
        syntax: 'git add [fichier]',
        description: 'Prépare un fichier au commit.',
      ),
      CheatEntry(
        topic: 'Committer',
        syntax: 'git commit -m "message"',
        description: 'Enregistre l\'étape.',
      ),
      CheatEntry(
        topic: 'Historique',
        syntax: 'git log --oneline',
        description: 'Liste les commits.',
      ),
      CheatEntry(
        topic: 'Ne PAS committer',
        syntax: '.gitignore',
        description: 'Exclut secrets, clés, .env du dépôt.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-docker',
    title: 'Docker',
    entries: [
      CheatEntry(
        topic: 'Images',
        syntax: 'docker images',
        description: 'Liste les images locales.',
      ),
      CheatEntry(
        topic: 'Conteneurs',
        syntax: 'docker ps -a',
        description: 'Liste les conteneurs (y compris arrêtés).',
      ),
      CheatEntry(
        topic: 'Lancer',
        syntax: 'docker run -it [image]',
        description: 'Lance un conteneur interactif.',
      ),
      CheatEntry(
        topic: 'Arrêter',
        syntax: 'docker stop [id]',
        description: 'Arrête un conteneur.',
      ),
      CheatEntry(
        topic: 'Écrire une image',
        syntax: 'docker build -t nom .',
        description: 'Construit une image depuis un Dockerfile.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-python',
    title: 'Python',
    entries: [
      CheatEntry(
        topic: 'Affichage',
        syntax: 'print("texte")',
        description: 'Affiche du texte/une valeur.',
      ),
      CheatEntry(
        topic: 'f-string',
        syntax: 'print(f"valeur {x}")',
        description: 'Insère des variables dans une chaîne.',
      ),
      CheatEntry(
        topic: 'Lire fichier',
        syntax: 'with open("f") as f: ...',
        description: 'Lit un fichier proprement.',
      ),
      CheatEntry(
        topic: 'Regex',
        syntax: 're.search(r"motif", texte)',
        description: 'Cherche un motif dans du texte.',
      ),
      CheatEntry(
        topic: 'Hash',
        syntax: 'hashlib.sha256(data).hexdigest()',
        description: 'Calcule un hash SHA-256.',
      ),
      CheatEntry(
        topic: 'HTTP',
        syntax: 'requests.get(url)',
        description: 'Fait une requête GET.',
      ),
      CheatEntry(
        topic: 'JSON',
        syntax: 'json.loads(texte)',
        description: 'Décode du JSON en Python.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-http',
    title: 'HTTP',
    entries: [
      CheatEntry(
        topic: 'GET',
        syntax: 'GET /chemin HTTP/1.1',
        description: 'Récupérer une ressource.',
      ),
      CheatEntry(
        topic: 'POST',
        syntax: 'POST /login HTTP/1.1',
        description: 'Envoyer des données.',
      ),
      CheatEntry(topic: 'Statut 2xx', syntax: '200 OK', description: 'Succès.'),
      CheatEntry(
        topic: 'Statut 4xx',
        syntax: '404 Not Found / 403 Forbidden',
        description: 'Erreur client.',
      ),
      CheatEntry(
        topic: 'Statut 5xx',
        syntax: '500 Internal Server Error',
        description: 'Erreur serveur.',
      ),
      CheatEntry(
        topic: 'HTTPS',
        syntax: 'port 443 + TLS',
        description: 'HTTP chiffré.',
      ),
    ],
  ),
  CheatSheet(
    id: 'cs-burp',
    title: 'Burp Suite',
    entries: [
      CheatEntry(
        topic: 'Proxy',
        syntax: 'Intercept ON',
        description:
            'Capture et modifie les requêtes entre navigateur et serveur.',
      ),
      CheatEntry(
        topic: 'History',
        syntax: 'HTTP History',
        description: 'Historique des requêtes interceptées.',
      ),
      CheatEntry(
        topic: 'Repeater',
        syntax: 'Envoyer à Repeater',
        description: 'Modifier et réenvoyer une requête.',
      ),
      CheatEntry(
        topic: 'Decoder',
        syntax: 'Decoder',
        description: 'Encode/décode (Base64, URL, etc.).',
      ),
      CheatEntry(
        topic: 'Intruder',
        syntax: 'Positions de payload',
        description: 'Automatiser des requêtes (en lab uniquement).',
      ),
    ],
  ),
];
