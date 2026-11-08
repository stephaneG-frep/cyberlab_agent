import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coach_message.dart';
import '../services/ai_service.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _configured = false;
  int _lastCount = -1;

  @override
  void initState() {
    super.initState();
    _refreshConfigured();
  }

  Future<void> _refreshConfigured() async {
    final settings = await context.read<AppState>().currentAiSettings();
    if (!mounted) return;
    setState(() => _configured = settings.isConfigured);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final app = context.read<AppState>();
    final text = _controller.text.trim();
    if (text.isEmpty || app.coachBusy) return;
    _controller.clear();
    // La requête est portée par AppState : quitter l'écran pendant l'attente
    // ne provoque aucune mise à jour d'un widget démonté, et la réponse est
    // tout de même conservée dans l'historique.
    await app.sendCoachMessage(text);
    if (!mounted) return;
    _refreshConfigured();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle conversation ?'),
        content: const Text(
          'L\'historique de cette conversation sera effacé de l\'appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AppState>().clearCoachConversation();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
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
    final messages = app.coachMessages;
    final busy = app.coachBusy;
    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      _scrollToBottom();
    }
    final provider = AiProviders.label(app.aiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CyberCoach'),
        actions: [
          IconButton(
            tooltip: 'Nouvelle conversation',
            onPressed: messages.isEmpty ? null : _confirmClear,
            icon: const Icon(Icons.add_comment_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.smart_toy, color: CyberLabSeed.green),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: (_configured ? Colors.blue : Colors.orange).withValues(
              alpha: 0.15,
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              _configured
                  ? 'Coach IA actif via $provider. Vos messages et les derniers '
                        'échanges de la conversation sont transmis à ce fournisseur. '
                        'L\'historique est conservé sur l\'appareil.'
                  : 'Mode hors ligne : aucun modèle IA configuré, aucune réponse ne '
                        'sera générée. Cours, quiz, CTF et simulateurs restent '
                        'disponibles. Configuration : Paramètres → CyberCoach / IA.',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Posez une question de cybersécurité : le coach vous '
                        'guide par indices, sans tout dévoiler.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _bubble(context, messages[i]),
                  ),
          ),
          if (busy)
            const LinearProgressIndicator(
              key: ValueKey('coach-busy'),
              minHeight: 2,
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('coach-input'),
                      controller: _controller,
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
                    key: const ValueKey('coach-send'),
                    onPressed: busy ? null : _send,
                    icon: busy
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

  Widget _bubble(BuildContext context, CoachMessage m) {
    final isMe = m.role == CoachRole.user;
    final isNotice = m.role == CoachRole.notice;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? CyberLabSeed.blue.withValues(alpha: 0.25)
              : isNotice
              ? Colors.orange.withValues(alpha: 0.12)
              : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: isNotice
              ? Border.all(color: Colors.orange.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  isNotice
                      ? 'Information de l\'application'
                      : 'CyberCoach (IA)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            SelectableText(m.text),
          ],
        ),
      ),
    );
  }
}
