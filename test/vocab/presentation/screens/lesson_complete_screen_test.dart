import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/presentation/screens/lesson_complete_screen.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

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

    testWidgets('shows word count breakdown', (tester) async {
      await tester.pumpWidget(_makeApp(lessonNumber: 1, onContinue: () {}));
      expect(find.text('You practiced 5 words'), findsOneWidget);
    });

    testWidgets('shows error count in breakdown when errors > 0', (tester) async {
      await tester.pumpWidget(_makeApp(lessonNumber: 1, onContinue: () {}, errors: 2));
      expect(find.text('You practiced 5 words · 2 errors'), findsOneWidget);
    });

    testWidgets('does not show error count when errors == 0', (tester) async {
      await tester.pumpWidget(_makeApp(lessonNumber: 1, onContinue: () {}, errors: 0));
      expect(find.text('You practiced 5 words'), findsOneWidget);
      expect(find.textContaining('error'), findsNothing);
    });

    testWidgets('shows encouragement message', (tester) async {
      await tester.pumpWidget(_makeApp(lessonNumber: 1, onContinue: () {}));
      expect(find.text('Perfect score! 🎉'), findsOneWidget);
    });

    testWidgets('shows next lesson preview when nextLessonLabel is provided',
        (tester) async {
      await tester.pumpWidget(_makeApp(
        lessonNumber: 1,
        onContinue: () {},
        nextLessonLabel: 'Lesson 2 - word',
      ));
      expect(
        find.byKey(WordCardKeys.lessonCompleteNextLabel),
        findsOneWidget,
      );
      expect(find.textContaining('Next: Lesson 2'), findsOneWidget);
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
