import '../models/user_state.dart';

/// A badge describes a condition and its medal. Evaluation happens in UI.
class BadgeDef {
  final Badge badge;
  final String type; // courses | ctf | level | quizscore
  final String? category; // course category or ctf category
  final int threshold;

  const BadgeDef({
    required this.badge,
    required this.type,
    this.category,
    this.threshold = 1,
  });
}

List<BadgeDef> badgeDefs() => [
  BadgeDef(
    badge: Badge(
      id: 'b-linux',
      name: 'Linux Rookie',
      description: 'Terminez 5 cours Linux.',
      icon: 'terminal',
      color: '#66D9EF',
    ),
    type: 'courses',
    category: 'linux',
    threshold: 5,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-net',
      name: 'Packet Hunter',
      description: 'Terminez 5 cours Réseau.',
      icon: 'router',
      color: '#8B90F0',
    ),
    type: 'courses',
    category: 'networking',
    threshold: 5,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-web',
      name: 'Web Defender',
      description: 'Terminez 3 cours Sécurité Web.',
      icon: 'language',
      color: '#F78C6C',
    ),
    type: 'courses',
    category: 'web_security',
    threshold: 3,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-python',
      name: 'Python Defender',
      description: 'Terminez 3 cours Python.',
      icon: 'code',
      color: '#A6E22E',
    ),
    type: 'courses',
    category: 'python',
    threshold: 3,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-bash',
      name: 'Shell Master',
      description: 'Terminez 4 cours Bash.',
      icon: 'code',
      color: '#E2B93D',
    ),
    type: 'courses',
    category: 'bash',
    threshold: 4,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-logs',
      name: 'Log Detective',
      description: 'Résolvez 1 challenge Logs.',
      icon: 'search',
      color: '#FFD866',
    ),
    type: 'ctf',
    category: 'Logs',
    threshold: 1,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-forensic',
      name: 'Forensic Investigator',
      description: 'Résolvez 1 challenge Forensic.',
      icon: 'fingerprint',
      color: '#FF6A6A',
    ),
    type: 'ctf',
    category: 'Forensic',
    threshold: 1,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-webctf',
      name: 'Web Breaker',
      description: 'Résolvez 2 challenges Web.',
      icon: 'search',
      color: '#F78C6C',
    ),
    type: 'ctf',
    category: 'Web',
    threshold: 2,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-ctf',
      name: 'CTF Player',
      description: 'Résolvez 3 challenges au total.',
      icon: 'flag',
      color: '#F44747',
    ),
    type: 'ctf',
    category: 'all',
    threshold: 3,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-expert',
      name: 'CyberLab Expert',
      description: 'Atteignez le niveau 5.',
      icon: 'workspace_premium',
      color: '#FFD700',
    ),
    type: 'level',
    threshold: 5,
  ),
  BadgeDef(
    badge: Badge(
      id: 'b-founder',
      name: 'CyberLab Founder',
      description: 'Atteignez le niveau 3.',
      icon: 'stars',
      color: '#A6E22E',
    ),
    type: 'level',
    threshold: 3,
  ),
];
