import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Bottom sheet shown when the user taps the bookmark button on the outro card.
/// Lists the user's existing categories as checkboxes (scrollable), pre-checked
/// for any category that already contains [wordId]. A text row at the bottom
/// lets the user create a new category and flag the word to it immediately.
///
/// The sheet is *purely visual* — it doesn't talk to Hive directly. The
/// caller (a screen-level Riverpod consumer) supplies the current decks
/// and reacts to [onFlag] / [onUnflag] / [onCreateAndFlag].
///
/// [onCreateAndFlag] must **return** the newly-created [FlagDeck] so the
/// sheet can add it to its local list without a full widget rebuild from above.
class DeckPickerSheet extends StatefulWidget {
  final String wordId;
  final List<FlagDeck> decks;
  final Set<String> initiallySelectedDeckIds;
  final ValueChanged<String> onFlag;
  final ValueChanged<String> onUnflag;

  /// Called with the new deck name; must create the deck, flag the word, and
  /// return the newly-created [FlagDeck] so the sheet can update immediately.
  final FlagDeck Function(String name) onCreateAndFlag;

  const DeckPickerSheet({
    super.key,
    required this.wordId,
    required this.decks,
    required this.initiallySelectedDeckIds,
    required this.onFlag,
    required this.onUnflag,
    required this.onCreateAndFlag,
  });

  @override
  State<DeckPickerSheet> createState() => _DeckPickerSheetState();
}

class _DeckPickerSheetState extends State<DeckPickerSheet> {
  late Set<String> _selected;

  /// Local mutable copy so that newly-created decks appear immediately without
  /// needing the parent to close and reopen the sheet.
  late List<FlagDeck> _decks;

  final _newDeckController = TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelectedDeckIds};
    _decks = [...widget.decks];
  }

  @override
  void dispose() {
    _newDeckController.dispose();
    super.dispose();
  }

  void _toggle(String deckId, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(deckId);
        widget.onFlag(deckId);
      } else {
        _selected.remove(deckId);
        widget.onUnflag(deckId);
      }
    });
  }

  void _createAndFlag() {
    final name = _newDeckController.text.trim();
    if (name.isEmpty) return;

    // Parent creates the deck and returns it so we can add it locally.
    final newDeck = widget.onCreateAndFlag(name);

    _newDeckController.clear();
    setState(() {
      _creating = false;
      _decks = [..._decks, newDeck];
      _selected.add(newDeck.id); // auto-select the new category
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Save to category', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            // ── Scrollable category checklist ──────────────────────────
            if (_decks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'You haven\'t created any categories yet.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final deck in _decks)
                        CheckboxListTile(
                          key: WordCardKeys.deckPickerCheckbox(deck.id),
                          title: Text(deck.name),
                          value: _selected.contains(deck.id),
                          onChanged: (v) => _toggle(deck.id, v),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 24),

            // ── Create new category ────────────────────────────────────
            if (!_creating)
              TextButton.icon(
                onPressed: () => setState(() => _creating = true),
                icon: const Icon(Icons.add),
                label: const Text('Create new category'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: WordCardKeys.deckPickerCreateField,
                      controller: _newDeckController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _createAndFlag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: WordCardKeys.deckPickerCreateButton,
                    onPressed: _createAndFlag,
                    child: const Text('Create'),
                  ),
                ],
              ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: WordCardKeys.deckPickerDone,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
