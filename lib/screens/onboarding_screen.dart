import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/learning_paths.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/path_picker.dart';

/// Accueil du premier lancement : présentation et règle éthique, prénom
/// (facultatif), puis choix du parcours. « Passer » garde les valeurs par
/// défaut ; tout reste modifiable ensuite (Paramètres, Profil).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = 3;
  int _step = 0;
  String _path = LearningPaths.defaultId;
  bool _finishing = false;
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skip = false}) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await context.read<AppState>().completeOnboarding(
      name: skip ? '' : _name.text,
      path: skip ? LearningPaths.defaultId : _path,
    );
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      tooltip: 'Retour',
                      onPressed: () => setState(() => _step--),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _steps,
                      minHeight: 4,
                      color: CyberLabSeed.blue,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('onboarding-skip'),
                    onPressed: _finishing ? null : () => _finish(skip: true),
                    child: const Text('Passer'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  switch (_step) {
                    0 => const _Welcome(),
                    1 => _NameStep(controller: _name, onSubmit: _next),
                    _ => _PathStep(
                      selected: _path,
                      onSelected: (id) => setState(() => _path = id),
                    ),
                  },
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('onboarding-next'),
                  onPressed: _finishing ? null : _next,
                  child: Text(switch (_step) {
                    0 => 'Commencer',
                    1 => 'Suivant',
                    _ => 'C\'est parti !',
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: CyberLabSeed.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.security, size: 64, color: CyberLabSeed.blue),
        const SizedBox(height: 16),
        Text(
          'Bienvenue dans CyberLab Agent',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Apprenez la cybersécurité à votre rythme, même hors ligne.',
        ),
        const SizedBox(height: 16),
        item(Icons.menu_book, 'Des cours avec quiz et exercices'),
        item(Icons.terminal, 'Un terminal Linux simulé pour pratiquer'),
        item(Icons.flag, 'Des challenges CTF et un simulateur SOC'),
        item(Icons.smart_toy, 'Un coach IA facultatif'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Règle d\'or : on ne teste que ce qui nous appartient ou ce '
                  'qu\'on est explicitement autorisé à tester. Le terminal et '
                  'les labs de l\'application sont simulés.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _NameStep({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comment vous appeler ?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Facultatif. Le prénom reste sur cet appareil et sert seulement à '
          'vous saluer.',
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('onboarding-name'),
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(
            labelText: 'Prénom ou pseudo',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _PathStep extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _PathStep({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Par où commencer ?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Débutant ? Choisissez Fondamentaux. Vous pourrez changer de '
          'parcours à tout moment depuis le Profil ou l\'Accueil.',
        ),
        const SizedBox(height: 16),
        PathList(selected: selected, onSelected: onSelected),
      ],
    );
  }
}
