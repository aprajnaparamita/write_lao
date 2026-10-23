import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/i18n/translation_helper.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_lao/vocab/providers.dart';

/// Lists every word in [deckId]. Each row supports remove-from-deck via
/// dismiss or trailing icon. Removing a word here doesn't delete it from
/// the user's vocabulary — only the join row goes away.
class DeckContentsScreen extends ConsumerStatefulWidget {
  final String deckId;

  const DeckContentsScreen({super.key, required this.deckId});

  @override
  ConsumerState<DeckContentsScreen> createState() =>
      _DeckContentsScreenState();
}

class _DeckContentsScreenState extends ConsumerState<DeckContentsScreen> {
  late FlagDeck? _deck;
  late List<VocabWord> _words;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final repo = ref.read(flagDeckRepositoryProvider);
    final course = ref.read(courseRepositoryProvider).valueOrNull;
    final wordIds = repo
        .getWordsInDeck(widget.deckId)
        .map((dw) => dw.wordId)
        .toList();
    setState(() {
      _deck = repo.getDeck(widget.deckId);
      _words = course == null
          ? const []
          : [
              for (final id in wordIds)
                if (course.getWord(id) != null) course.getWord(id)!,
            ];
    });
  }

  void _remove(String wordId) {
    ref
        .read(flagDeckRepositoryProvider)
        .unflagWord(deckId: widget.deckId, wordId: wordId);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(_deck?.name ?? 'Deck')),
      body: _words.isEmpty
          ? const Center(
              child: Text('No words in this deck yet.'),
            )
          : ListView.builder(
              key: WordCardKeys.deckContentsList,
              itemCount: _words.length,
              itemBuilder: (context, i) {
                final w = _words[i];
                final gloss = pickTranslation(
                  w.definitions,
                  languageCode: locale.languageCode,
                  scriptCode: locale.scriptCode,
                );
                return ListTile(
                  key: WordCardKeys.deckContentsRow(w.wordId),
                  title: Text(w.laoWord),
                  subtitle: Text(gloss),
                  trailing: IconButton(
                    key: WordCardKeys.deckContentsRemove(w.wordId),
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Remove from deck',
                    onPressed: () => _remove(w.wordId),
                  ),
                );
              },
            ),
    );
  }
}
