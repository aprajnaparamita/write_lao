import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Bottom sheet shown when the user taps the flag icon on the outro card.
/// Lists the user's existing decks with checkboxes pre-checked for any
/// deck that already contains [wordId], plus a row to create a new deck.
///
/// The sheet is *purely visual* — it doesn't talk to Hive directly. The
/// caller (a screen-level Riverpod consumer) supplies the current decks
/// and reacts to [onFlag] / [onUnflag] / [onCreateAndFlag].
class DeckPickerSheet extends StatefulWidget {
  final String wordId;
  final List<FlagDeck> decks;
  final Set<String> initiallySelectedDeckIds;
  final ValueChanged<String> onFlag;
  final ValueChanged<String> onUnflag;
  final ValueChanged<String> onCreateAndFlag;

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
  late final Set<String> _selected;
  final _newDeckController = TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelectedDeckIds};
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
    widget.onCreateAndFlag(name);
    _newDeckController.clear();
    setState(() => _creating = false);
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
            Text('Flag to deck', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (widget.decks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'You haven\'t made any decks yet.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            for (final deck in widget.decks)
              CheckboxListTile(
                key: WordCardKeys.deckPickerCheckbox(deck.id),
                title: Text(deck.name),
                value: _selected.contains(deck.id),
                onChanged: (v) => _toggle(deck.id, v),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const Divider(height: 24),
            if (!_creating)
              TextButton.icon(
                onPressed: () => setState(() => _creating = true),
                icon: const Icon(Icons.add),
                label: const Text('Create new deck'),
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
                        labelText: 'Deck name',
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
