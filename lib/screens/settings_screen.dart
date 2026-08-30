import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _name;
  late TextEditingController _model;
  late TextEditingController _baseUrl;
  late TextEditingController _apiKey;
  late String _provider;
  late bool _dark;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>().settings;
    _name = TextEditingController(text: context.read<AppState>().user.name);
    _model = TextEditingController(text: s['aiModel'] ?? '');
    _baseUrl = TextEditingController(text: s['aiBaseUrl'] ?? '');
    _apiKey = TextEditingController(text: s['aiApiKey'] ?? '');
    _provider = s['aiProvider'] ?? 'ollama';
    _dark = s['darkMode'] != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _model.dispose();
    _baseUrl.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _save(Map<String, dynamic> extra) async {
    final app = context.read<AppState>();
    app.setName(_name.text.trim());

    final newSettings = {
      'darkMode': _dark,
      'aiProvider': _provider,
      'aiModel': _model.text.trim(),
      'aiBaseUrl': _baseUrl.text.trim(),
      'aiApiKey': _apiKey.text.trim(),
      ...extra,
    };
    await app.updateSettings(newSettings);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés')));
    }
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: const Text(
          'Cette action efface les cours terminés, badges, XP et notes. '
          'Les clés IA ne sont pas réinitialisées ici. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AppState>().resetProgress();
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Profil'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Votre nom',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SectionTitle('Apparence'),
          Card(
            child: SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Style labo cyber par défaut (activé)'),
              value: _dark,
              onChanged: (v) {
                setState(() => _dark = v);
                _save({'darkMode': v, 'aiProvider': _provider});
              },
            ),
          ),
          const SectionTitle('CyberCoach / IA'),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Vos clés restent sur cet appareil. On ne les envoie qu\'à l\'API que vous '
              'configurez. Aucune clé n\'est stockée dans le code ni partagée.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _provider,
                    decoration: const InputDecoration(
                      labelText: 'Fournisseur IA',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ollama',
                        child: Text('Ollama (local)'),
                      ),
                      DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                      DropdownMenuItem(
                        value: 'anthropic',
                        child: Text('Anthropic'),
                      ),
                      DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
                      DropdownMenuItem(
                        value: 'mistral',
                        child: Text('Mistral'),
                      ),
                      DropdownMenuItem(
                        value: 'compatible',
                        child: Text('API compatible OpenAI'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _provider = v ?? 'ollama');
                      _save({'aiProvider': _provider});
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _model,
                    decoration: const InputDecoration(
                      labelText: 'Modèle (ex : llama3, gpt-4o-mini...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baseUrl,
                    decoration: const InputDecoration(
                      labelText: 'URL de base (facultatif)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKey,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Clé API',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _save(_existing()),
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.red.withValues(alpha: 0.08),
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text('Réinitialiser la progression'),
              subtitle: const Text('Efface XP, cours, badges et notes'),
              onTap: _confirmReset,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _existing() => {
    'darkMode': _dark,
    'aiProvider': _provider,
    'aiModel': _model.text.trim(),
    'aiBaseUrl': _baseUrl.text.trim(),
    'aiApiKey': _apiKey.text.trim(),
  };
}
