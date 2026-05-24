import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/presentation/widgets/deck_picker_sheet.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

FlagDeck _deck(String id, String name) {
  final t = DateTime.utc(2026, 1, 1);
  return FlagDeck(id: id, name: name, createdAt: t, updatedAt: t);
}

/// Helper that returns a dummy FlagDeck for the new [onCreateAndFlag] signature.
FlagDeck Function(String) _noopCreate() =>
    (name) => _deck('new_$name', name);

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DeckPickerSheet', () {
    testWidgets('shows existing decks with initial selection', (tester) async {
      await tester.pumpWidget(_wrap(DeckPickerSheet(
        wordId: 'w_0001',
        decks: [_deck('d1', 'Tricky'), _deck('d2', 'Favorites')],
        initiallySelectedDeckIds: const {'d1'},
        onFlag: (_) {},
        onUnflag: (_) {},
        onCreateAndFlag: _noopCreate(),
      )));
      expect(find.text('Tricky'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);

      final tricky = tester.widget<CheckboxListTile>(
        find.byKey(WordCardKeys.deckPickerCheckbox('d1')),
      );
      expect(tricky.value, isTrue);

      final fav = tester.widget<CheckboxListTile>(
        find.byKey(WordCardKeys.deckPickerCheckbox('d2')),
      );
      expect(fav.value, isFalse);
    });

    testWidgets('toggling a checkbox calls onFlag / onUnflag', (tester) async {
      final flagged = <String>[];
      final unflagged = <String>[];
      await tester.pumpWidget(_wrap(DeckPickerSheet(
        wordId: 'w_0001',
        decks: [_deck('d1', 'Tricky')],
        initiallySelectedDeckIds: const {},
        onFlag: flagged.add,
        onUnflag: unflagged.add,
        onCreateAndFlag: _noopCreate(),
      )));

      await tester.tap(find.byKey(WordCardKeys.deckPickerCheckbox('d1')));
      await tester.pump();
      expect(flagged, equals(['d1']));

      await tester.tap(find.byKey(WordCardKeys.deckPickerCheckbox('d1')));
      await tester.pump();
      expect(unflagged, equals(['d1']));
    });

    testWidgets('create-new-category row submits the typed name and appears as checkbox',
        (tester) async {
      String? created;
      await tester.pumpWidget(_wrap(DeckPickerSheet(
        wordId: 'w_0001',
        decks: const [],
        initiallySelectedDeckIds: const {},
        onFlag: (_) {},
        onUnflag: (_) {},
        onCreateAndFlag: (name) {
          created = name;
          return _deck('new_$name', name);
        },
      )));

      await tester.tap(find.text('Create new category'));
      await tester.pump();

      await tester.enterText(
        find.byKey(WordCardKeys.deckPickerCreateField),
        'My new deck',
      );
      await tester.tap(find.byKey(WordCardKeys.deckPickerCreateButton));
      await tester.pump();

      expect(created, 'My new deck');
      // After creation the new category should appear as a checked row.
      expect(find.text('My new deck'), findsOneWidget);
    });

    testWidgets('blank create-new submission is a no-op', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_wrap(DeckPickerSheet(
        wordId: 'w_0001',
        decks: const [],
        initiallySelectedDeckIds: const {},
        onFlag: (_) {},
        onUnflag: (_) {},
        onCreateAndFlag: (name) {
          calls++;
          return _deck('x', name);
        },
      )));

      await tester.tap(find.text('Create new category'));
      await tester.pump();
      await tester.tap(find.byKey(WordCardKeys.deckPickerCreateButton));
      await tester.pump();
      expect(calls, 0);
    });
  });
}
