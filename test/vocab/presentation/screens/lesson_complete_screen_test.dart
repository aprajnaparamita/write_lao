import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/presentation/screens/lesson_complete_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

Widget _makeApp({
  required int lessonNumber,
  required VoidCallback onContinue,
  String? nextLessonLabel,
  int errors = 0,
}) {
  return MaterialApp(
    home: LessonCompleteScreen(
      lessonNumber: lessonNumber,
      totalWords: 5,
      errors: errors,
      onContinue: onContinue,
      nextLessonLabel: nextLessonLabel,
    ),
  );
}

void main() {
  group('LessonCompleteScreen', () {
    testWidgets('shows lesson number and continue button', (tester) async {
      await tester.pumpWidget(_makeApp(lessonNumber: 2, onContinue: () {}));
      expect(find.text('Lesson 2 complete'), findsOneWidget);
      expect(find.byKey(WordCardKeys.lessonCompleteContinue), findsOneWidget);
    });

    testWidgets('shows next lesson preview when nextLessonLabel is provided',
        (tester) async {
      await tester.pumpWidget(_makeApp(
        lessonNumber: 1,
        onContinue: () {},
        nextLessonLabel: 'Lesson 2 — ສະ ບາຍ ດີ',
      ));
      expect(
        find.byKey(WordCardKeys.lessonCompleteNextLabel),
        findsOneWidget,
      );
      expect(find.text('Next: Lesson 2 — ສະ ບາຍ ດີ'), findsOneWidget);
    });

    testWidgets('does not show next lesson when nextLessonLabel is null',
        (tester) async {
      await tester.pumpWidget(_makeApp(
        lessonNumber: 1,
        onContinue: () {},
        nextLessonLabel: null,
      ));
      expect(find.byKey(WordCardKeys.lessonCompleteNextLabel), findsNothing);
    });

    testWidgets('continue button calls onContinue', (tester) async {
      var called = false;
      await tester.pumpWidget(_makeApp(
        lessonNumber: 1,
        onContinue: () => called = true,
      ));
      await tester.tap(find.byKey(WordCardKeys.lessonCompleteContinue));
      expect(called, isTrue);
    });
  });
}
