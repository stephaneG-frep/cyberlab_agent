/// Prérequis STRUCTURÉS des cours : identifiants des cours conseillés avant
/// chaque cours. Établis à partir des prérequis rédigés dans le contenu
/// (texte libre), en ne gardant que les cours directement nécessaires.
///
/// Ce sont des recommandations : l'application les signale et en tient
/// compte pour proposer le cours suivant, mais ne verrouille rien.
/// Les tests vérifient que chaque identifiant existe et qu'il n'y a aucun
/// cycle.
const Map<String, List<String>> coursePrerequisites = {
  // Fondamentaux
  'fund-ransom': ['fund-malware'],

  // Informatique et réseaux (niveau 1)
  'net-os': ['net-computer'],
  'net-files': ['net-computer'],
  'net-processes': ['net-computer'],
  'net-memory': ['net-computer'],
  'net-users': ['net-os'],
  'net-permissions': ['net-users'],
  'net-ip': ['net-intro'],
  'net-ipv4': ['net-ip'],
  'net-ipv6': ['net-ipv4'],
  'net-mac': ['net-ip'],
  'net-ports': ['net-ip'],
  'net-protocols': ['net-ip', 'net-ports'],
  'net-tcp': ['net-protocols'],
  'net-udp': ['net-tcp'],
  'net-dns': ['net-ip', 'net-protocols'],
  'net-dhcp': ['net-intro', 'net-ip'],
  'net-http': ['net-protocols', 'net-ports'],
  'net-https': ['net-http'],
  'net-ssh': ['net-tcp'],
  'net-ftp': ['net-ports', 'net-ssh'],
  'net-smtp': ['net-ports', 'net-protocols'],
  'net-vpn': ['net-ip', 'net-https'],
  'net-firewall': ['net-ip', 'net-ports'],
  'net-nat': ['net-ipv4'],

  // Linux (niveau 2)
  'lin-terminal': ['net-os'],
  'lin-filesystem': ['lin-terminal'],
  'lin-navigation': ['lin-terminal', 'lin-filesystem'],
  'lin-users': ['lin-terminal', 'lin-filesystem'],
  'lin-groups': ['lin-users'],
  'lin-permissions': ['lin-users', 'lin-groups'],
  'lin-chmod': ['lin-permissions'],
  'lin-chown': ['lin-chmod'],
  'lin-sudo': ['lin-users', 'lin-permissions'],
  'lin-processes': ['lin-terminal'],
  'lin-services': ['lin-processes'],
  'lin-systemd': ['lin-services'],
  'lin-logs': ['lin-terminal', 'lin-systemd'],
  'lin-network': ['net-ip', 'lin-terminal'],
  'lin-packages': ['lin-terminal', 'lin-sudo'],
  'lin-variables': ['lin-terminal'],
  // Le contenu citait grep pour les pipes et les pipes pour grep : on
  // apprend d'abord les pipes, puis grep.
  'lin-pipes': ['lin-navigation'],
  'lin-grep': ['lin-terminal', 'lin-pipes'],
  'lin-find': ['lin-navigation', 'lin-grep'],
  'lin-curl': ['net-http', 'lin-terminal'],
  'lin-ssh': ['net-ssh', 'lin-network'],

  // Bash (niveau 3)
  'bash-intro': ['lin-terminal', 'lin-navigation'],
  'bash-variables': ['bash-intro'],
  'bash-conditions': ['bash-variables'],
  'bash-loops': ['bash-conditions'],
  'bash-functions': ['bash-variables', 'bash-conditions'],
  'bash-arguments': ['bash-variables'],
  'bash-files': ['bash-loops', 'bash-conditions'],
  'bash-parsing': ['bash-files'],
  'bash-automation': ['bash-functions', 'bash-arguments', 'bash-parsing'],
  'bash-logs': ['bash-parsing', 'bash-loops'],
  'bash-admin': ['bash-automation'],
  'bash-analyzer': ['bash-logs', 'bash-admin'],

  // Python (niveau 4)
  'py-syntax': ['bash-intro'],
  'py-variables': ['py-syntax'],
  'py-conditions': ['py-variables'],
  'py-loops': ['py-conditions'],
  'py-functions': ['py-conditions', 'py-loops'],
  'py-files': ['py-functions'],
  'py-json': ['py-files'],
  'py-regex': ['py-files', 'py-json'],
  'py-sockets': ['net-ports', 'net-tcp'],
  'py-http': ['py-json', 'net-http'],
  'py-hash': ['py-files', 'py-functions'],
  'py-analyzer': ['py-regex', 'py-json'],

  // Sécurité Web (niveau 6)
  'web-intro': ['net-http', 'net-https'],
  'web-httpmethods': ['net-http'],
  'web-headers': ['net-http'],
  'web-cookies': ['web-headers'],
  'web-sessions': ['web-cookies'],
  'web-jwt': ['web-sessions'],
  'web-auth': ['web-sessions'],
  'web-api': ['web-httpmethods'],
  'web-cors': ['web-cookies', 'web-api'],
  'web-owasp': ['web-intro'],
  'web-owasp-access': ['web-auth'],
  'web-owasp-injection': ['web-intro'],

  // Sécurité réseau (niveau 5)
  'ns-osi': ['net-protocols', 'net-tcp'],
  'ns-segmentation': ['ns-osi'],
  'ns-firewall': ['net-firewall', 'ns-segmentation'],
  'ns-idsips': ['ns-firewall'],
  'ns-vpn': ['net-vpn', 'ns-osi'],
  'ns-wifi': ['ns-osi'],
  'ns-mitm': ['net-mac', 'net-dns'],
  'ns-scan': ['net-ports', 'net-tcp'],
  'ns-traffic': ['ns-scan', 'net-dns'],
  'ns-hardening': ['ns-firewall', 'ns-traffic'],

  // Sécurité Web : familles OWASP complémentaires (niveau 6)
  'web-xss': ['web-owasp-injection', 'web-cookies'],
  'web-csrf': ['web-sessions', 'web-cookies'],
  'web-ssrf': ['web-api', 'ns-segmentation'],
  'web-upload': ['web-owasp-access'],
  'web-misconfig': ['web-headers'],
  'web-components': ['web-owasp'],

  // Cryptographie (niveau 7)
  'cr-hash': ['cr-encoding'],
  'cr-passwords': ['cr-hash'],
  'cr-symmetric': ['cr-encoding'],
  'cr-asymmetric': ['cr-symmetric'],
  'cr-signatures': ['cr-asymmetric', 'cr-hash'],
  'cr-pki': ['cr-signatures'],
  'cr-tls': ['cr-pki', 'net-https'],

  // Réponse à incident (niveau 8)
  'ir-cycle': ['fund-soc'],
  'ir-triage': ['ir-cycle'],
  'ir-containment': ['ir-triage'],
  'ir-evidence': ['ir-containment', 'cr-hash'],
  'ir-logs': ['ir-evidence', 'lin-logs'],
  'ir-timeline': ['ir-logs'],
  'ir-ioc': ['ir-timeline'],
  'ir-report': ['ir-ioc'],

  // Windows et Active Directory (niveau 9)
  'win-basics': ['net-os', 'net-permissions'],
  'win-powershell': ['win-basics'],
  'win-events': ['win-powershell', 'ir-logs'],
  'win-accounts': ['win-basics'],
  'win-ad': ['win-accounts'],
  'win-kerberos': ['win-ad', 'cr-symmetric'],
  'win-ad-attacks': ['win-kerberos', 'win-events'],
  'win-hardening': ['win-ad-attacks'],
};
