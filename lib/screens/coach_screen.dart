import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;
  final ScrollController _scroll = ScrollController();

  static const _sysPrompt = '''
Tu es le CyberCoach, un professeur de cybersécurité bienveillant et pédagogue.
Règles impératives :
- Tu aides à APPRENDRE. Tu ne donnes JAMAIS directement la réponse complète.
- Fournis des indices progressifs (1, 2, 3) et des explications pour guider l'utilisateur vers la solution.
- Encourage à chercher et tester par soi-même dans un environnement autorisé.
- Si l'utilisateur demande la solution brute, propose plutôt de l'amener à la découvrir, ou donne la solution seulement s'il insiste fortement.
- Encadre ton texte avec du markdown simple si utile. Réponds en français.
- Rappelle toujours : on n'attaque que ce qui nous appartient ou nous est explicitement autorisé.
''';

  AiService _service(AppState app) => AiService(
    AiSettings(
      provider: app.settings['aiProvider'] ?? 'ollama',
      model: app.settings['aiModel'] ?? '',
      baseUrl: app.settings['aiBaseUrl'] ?? '',
      apiKey: app.settings['aiApiKey'] ?? '',
    ),
  );

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'coach',
      'text':
          'Bonjour ! Je suis votre CyberCoach. Posez-moi une question de '
          'cybersécurité, je vous guiderai sans tout dévoiler.',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'me', 'text': text});
      _busy = true;
    });
    _scrollToBottom();

    final app = context.read<AppState>();
    final reply = await _service(app).chat(_sysPrompt, text);

    setState(() {
      _messages.add({'role': 'coach', 'text': reply ?? _offlineFallback(text)});
      _busy = false;
    });
    _scrollToBottom();
  }

  String _offlineFallback(String question) {
    return 'Le CyberCoach n\'est pas encore connecté (clé IA ou serveur local non '
        'configuré). Configurez l\'IA dans Paramètres. En attendant, voici un '
        'conseil général : reformulez votre question (thème, commande, outil, '
        'protocole) et consultez les cours et cheat sheets. Je suis là pour '
        'vous guider, pas pour donner la réponse toute faite !';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final configured = _service(app).isLive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CyberCoach'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.smart_toy, color: CyberLabSeed.green),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!configured)
            Container(
              width: double.infinity,
              color: Colors.orange.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Mode hors ligne : configurez l\'IA (Paramètres) pour des réponses générées.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isMe = m['role'] == 'me';
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? CyberLabSeed.blue.withValues(alpha: 0.25)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_busy,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Votre question...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
