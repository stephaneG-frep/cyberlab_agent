import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  final TextEditingController _model = TextEditingController();
  final TextEditingController _baseUrl = TextEditingController();
  final TextEditingController _apiKey = TextEditingController();
  late String _provider;
  bool _hasStoredKey = false;
  bool _deleteKey = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _name = TextEditingController(text: app.user.name);
    _provider = app.aiProvider;
    _loadProfile(_provider);
  }

  /// Charge le profil du fournisseur [p] : jamais les valeurs d'un autre.
  Future<void> _loadProfile(String p) async {
    final app = context.read<AppState>();
    final profile = app.aiProfile(p);
    _model.text = profile.model;
    _baseUrl.text = profile.baseUrl;
    _apiKey.clear();
    _deleteKey = false;
    final has = await app.hasApiKey(p);
    if (!mounted || p != _provider) return;
    setState(() => _hasStoredKey = has);
  }

  @override
  void dispose() {
    _name.dispose();
    _model.dispose();
    _baseUrl.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _saveName() async {
    await context.read<AppState>().setName(_name.text.trim());
    _snack('Nom enregistré');
  }

  Future<void> _saveAi() async {
    setState(() => _saving = true);
    final app = context.read<AppState>();
    final typedKey = _apiKey.text.trim();
    final error = await app.saveAiConfig(
      provider: _provider,
      model: _model.text,
      baseUrl: _baseUrl.text,
      apiKey: _deleteKey ? '' : (typedKey.isEmpty ? null : typedKey),
    );
    if (!mounted) return;
    final has = await app.hasApiKey(_provider);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _hasStoredKey = has;
      _deleteKey = false;
      if (error == null) _apiKey.clear();
    });
    _snack(error ?? 'Configuration du coach enregistrée');
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: const Text(
          'Cette action efface les cours terminés, badges, XP et notes. '
          'Les réglages et clés IA ne sont pas réinitialisés ici. Continuer ?',
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

  String _urlHelper(String p) {
    final def = AiProviders.defaultBaseUrl(p);
    if (def != null) return 'Facultatif. Par défaut : $def (HTTPS obligatoire)';
    if (p == AiProviders.ollama) {
      return 'Obligatoire. Ex. : http://192.168.1.20:11434 — HTTP accepté '
          'uniquement vers localhost / réseau privé / *.local.';
    }
    return 'Obligatoire. HTTPS, ou HTTP uniquement vers un serveur local/privé.';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usesKey = AiProviders.usesKey(_provider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Profil'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Votre nom',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _saveName(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Enregistrer le nom',
                    onPressed: _saveName,
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Apparence'),
          Card(
            child: SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Style labo cyber par défaut (activé)'),
              value: app.darkMode,
              onChanged: (v) => app.setDarkMode(v),
            ),
          ),
          const SectionTitle('CyberCoach / IA'),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Facultatif : sans configuration, le coach reste hors ligne et '
              'tout le contenu pédagogique fonctionne. Chaque fournisseur a sa '
              'propre configuration. Les clés sont chiffrées sur cet appareil '
              '(stockage sécurisé Android), exclues des sauvegardes, et ne sont '
              'envoyées qu\'au fournisseur auquel elles appartiennent. Vos '
              'messages au coach sont transmis au fournisseur sélectionné.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey('provider-$_provider'),
                    initialValue: _provider,
                    decoration: const InputDecoration(
                      labelText: 'Fournisseur IA',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final p in AiProviders.all)
                        DropdownMenuItem(
                          value: p,
                          child: Text(AiProviders.label(p)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null || v == _provider) return;
                      setState(() {
                        _provider = v;
                        _hasStoredKey = false;
                      });
                      _loadProfile(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _model,
                    decoration: const InputDecoration(
                      labelText: 'Modèle (obligatoire)',
                      helperText:
                          'Identifiant exact indiqué par votre fournisseur ou '
                          'par « ollama list ».',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baseUrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'URL du serveur',
                      helperText: _urlHelper(_provider),
                      helperMaxLines: 3,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (usesKey) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKey,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: _provider == AiProviders.compatible
                            ? 'Clé API (si le serveur en exige une)'
                            : 'Clé API',
                        helperText: _deleteKey
                            ? 'La clé sera supprimée à l\'enregistrement.'
                            : _hasStoredKey
                            ? 'Une clé est enregistrée. Laissez vide pour la conserver.'
                            : 'Aucune clé enregistrée pour ce fournisseur.',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_hasStoredKey)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            _deleteKey = !_deleteKey;
                            _apiKey.clear();
                          }),
                          icon: const Icon(Icons.key_off),
                          label: Text(
                            _deleteKey
                                ? 'Annuler la suppression'
                                : 'Supprimer la clé enregistrée',
                          ),
                        ),
                      ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Ollama n\'utilise pas de clé : aucune clé n\'est envoyée.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _saveAi,
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
}
