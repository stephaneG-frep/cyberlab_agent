import 'package:flutter/material.dart';
import '../data/cheat_sheets.dart';
import '../widgets/common.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key, this.openSheetId});

  /// Fiche à afficher en premier et dépliée (depuis la recherche).
  final String? openSheetId;

  @override
  Widget build(BuildContext context) {
    final all = cheatSheets();
    final sheets = [
      ...all.where((s) => s.id == openSheetId),
      ...all.where((s) => s.id != openSheetId),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Docs & Cheat Sheets')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sheets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = sheets[i];
          return Card(
            child: ExpansionTile(
              initiallyExpanded: s.id == openSheetId,
              leading: Icon(Icons.menu_book, color: CyberLabSeed.blue),
              title: Text(
                s.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                for (final e in s.entries)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.topic,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SelectableText(
                            e.syntax,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
