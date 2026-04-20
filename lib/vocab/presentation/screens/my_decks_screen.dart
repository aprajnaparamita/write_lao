import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Lists the user's flag decks. Each row shows the deck name, the word
/// count, a [Study] button, and a more-menu with rename / delete.
///
/// The "Study" button hands off to [onStudy] — the host route is
/// responsible for actually navigating to the deck-study flow (Phase 07
/// will wire that into go_router; for now it's a callback so this screen
/// stays standalone-testable).
class MyDecksScreen extends ConsumerStatefulWidget {
  final void Function(String deckId)? onStudy;
  final void Function(String deckId)? onOpenDeck;

  const MyDecksScreen({super.key, this.onStudy, this.onOpenDeck});

  @override
  ConsumerState<MyDecksScreen> createState() => _MyDecksScreenState();
}

class _MyDecksScreenState extends ConsumerState<MyDecksScreen> {
  late List<FlagDeck> _decks;
  late Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final repo = ref.read(flagDeckRepositoryProvider);
    setState(() {
      _decks = [...repo.getAllDecks()]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _counts = repo.getDeckWordCounts();
    });
  }

  Future<void> _createDeck() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    ref.read(flagDeckRepositoryProvider).createDeck(name);
    _refresh();
  }

  Future<void> _renameDeck(FlagDeck deck) async {
    final controller = TextEditingController(text: deck.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == deck.name) return;
    ref.read(flagDeckRepositoryProvider).renameDeck(deck.id, name);
    _refresh();
  }

  Future<void> _deleteDeck(FlagDeck deck) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${deck.name}"?'),
        content: const Text(
          'This will remove the deck and all its flagged words. The '
          'words themselves stay in your vocabulary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    ref.read(flagDeckRepositoryProvider).deleteDeck(deck.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Decks')),
      body: _decks.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No decks yet. Tap + to create one, or flag a word '
                  'from the outro card.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              key: WordCardKeys.myDecksList,
              itemCount: _decks.length,
              itemBuilder: (context, i) {
                final deck = _decks[i];
                final count = _counts[deck.id] ?? 0;
                return ListTile(
                  key: WordCardKeys.myDecksRow(deck.id),
                  title: Text(deck.name),
                  subtitle: Text('$count word${count == 1 ? '' : 's'}'),
                  onTap: widget.onOpenDeck == null
                      ? null
                      : () => widget.onOpenDeck!(deck.id),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        key: WordCardKeys.myDecksStudyButton(deck.id),
                        onPressed: count == 0
                            ? null
                            : () => widget.onStudy?.call(deck.id),
                        child: const Text('Study'),
                      ),
                      PopupMenuButton<String>(
                        key: WordCardKeys.myDecksMoreMenu(deck.id),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'rename', child: Text('Rename')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (v) {
                          if (v == 'rename') _renameDeck(deck);
                          if (v == 'delete') _deleteDeck(deck);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        key: WordCardKeys.myDecksAddButton,
        onPressed: _createDeck,
        child: const Icon(Icons.add),
      ),
    );
  }
}
