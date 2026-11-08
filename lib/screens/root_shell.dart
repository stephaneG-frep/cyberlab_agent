import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'lab_screen.dart';
import 'ctf_screen.dart';
import 'profile_screen.dart';
import 'coach_screen.dart';
import 'notes_screen.dart';
import 'docs_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    LearnScreen(),
    LabScreen(),
    CtfScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          const _StatusBanners(),
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Apprendre',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'CTF',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.security, color: CyberLabSeed.blue),
                  SizedBox(width: 8),
                  Text(
                    'CyberLab',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('CyberCoach'),
              subtitle: const Text('Votre professeur IA'),
              onTap: () => _open(const CoachScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: const Text('Cyber Notes'),
              subtitle: const Text('Vos notes et commandes'),
              onTap: () => _open(const NotesScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Docs & Cheat Sheets'),
              subtitle: const Text('Références et aide'),
              onTap: () => _open(const DocsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              subtitle: const Text('App, IA, progression'),
              onTap: () => _open(const SettingsScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class CyberLabSeed {
  static const blue = Color(0xFF5B8DEF);
}

/// Bandeaux d'erreur de sauvegarde et d'avertissements de migration :
/// aucune perte de données n'est silencieuse.
class _StatusBanners extends StatelessWidget {
  const _StatusBanners();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = [if (app.saveError != null) app.saveError!, ...app.warnings];
    if (items.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      bottom: false,
      child: Material(
        color: Colors.orange.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items.join('\n'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (app.warnings.isNotEmpty)
                IconButton(
                  tooltip: 'Masquer',
                  onPressed: app.dismissWarnings,
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
