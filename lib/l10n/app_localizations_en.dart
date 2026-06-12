// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Write Lao';

  @override
  String get tabLessons => 'Lessons';

  @override
  String get tabReview => 'Review';

  @override
  String get tabProgress => 'Progress';

  @override
  String lessonNumber(int number) {
    return 'Lesson $number';
  }

  @override
  String get lessonNotFound => 'Lesson not found';

  @override
  String get lessonLabel => 'Lesson';

  @override
  String get practice => 'Practice';

  @override
  String get test => 'Test';

  @override
  String get content => 'Content';

  @override
  String get bestTime => 'Best Time';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get leavePracticeTitle => 'Leave Practice?';

  @override
  String get leavePracticeMessage => 'Are you sure you want to leave practice?';

  @override
  String get continueButton => 'Continue';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get traceCharacter => 'Trace the character';

  @override
  String get allDone => 'All done! Great job!';

  @override
  String get moveToNext => 'Great job! Move to next character';

  @override
  String get clearTooltip => 'Clear';

  @override
  String get playPronunciation => 'Play pronunciation';

  @override
  String get hideHint => 'Hide hint';

  @override
  String get showHint => 'Show hint';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Practice Complete!';

  @override
  String practiceCompleteMessage(int count) {
    return 'You practiced all $count characters in this lesson.';
  }

  @override
  String get characters => 'Characters';

  @override
  String get takeTest => 'Take Test';

  @override
  String get practiceAgain => 'Practice Again';

  @override
  String get backToLesson => 'Back to Lesson';

  @override
  String get backToReview => 'Back to Review';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get testTitle => 'Test';

  @override
  String get leaveTestTitle => 'Leave Test?';

  @override
  String get leaveTestMessage => 'Are you sure you want to leave the test?';

  @override
  String get writeFromMemory => 'Write this character from memory';

  @override
  String get resultPerfect => 'Perfect!';

  @override
  String get resultGreatJob => 'Great Job!';

  @override
  String get resultGoodTry => 'Good Try!';

  @override
  String get time => 'Time';

  @override
  String get testAgain => 'Test Again';

  @override
  String get progressTitle => 'Progress';

  @override
  String get lessonsCompleted => 'Lessons\nCompleted';

  @override
  String get starsEarned => 'Stars\nEarned';

  @override
  String get phaseProgress => 'Phase Progress';

  @override
  String get phaseConsonants => 'Consonants';

  @override
  String get phaseVowels => 'Vowels';

  @override
  String get phaseToneMarks => 'Tone Marks';

  @override
  String get phaseNumerals => 'Numerals';

  @override
  String get phaseLigatures => 'Ligatures';

  @override
  String get reviewTitle => 'Review';

  @override
  String get weakCharacters => 'Weak characters';

  @override
  String get all => 'All';

  @override
  String phaseN(int number) {
    return 'Phase $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Practice Selected ($count)';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get strokeTolerance => 'Stroke Tolerance';

  @override
  String get toleranceForgiving => 'Forgiving';

  @override
  String get toleranceStrict => 'Strict';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsSubtitle =>
      'Play sounds for correct/incorrect strokes';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Vibrate on stroke events';

  @override
  String get resetAllProgress => 'Reset All Progress';

  @override
  String get resetAllProgressSubtitle => 'Clear all lesson progress and stars';

  @override
  String get aboutWriteLao => 'About Write Lao';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Very Easy';

  @override
  String get toleranceEasy => 'Easy';

  @override
  String get toleranceMedium => 'Medium';

  @override
  String get toleranceHard => 'Hard';

  @override
  String get toleranceVeryHard => 'Very Hard';

  @override
  String get toleranceExtreme => 'Extreme';

  @override
  String get toleranceDescVeryEasy => 'Almost any drawing will be accepted';

  @override
  String get toleranceDescEasy => 'Loose matching, good for beginners';

  @override
  String get toleranceDescMedium => 'Balanced difficulty (recommended)';

  @override
  String get toleranceDescHard => 'Requires more precision';

  @override
  String get toleranceDescVeryHard => 'Strict matching';

  @override
  String get toleranceDescExtreme => 'Very strict matching for experts';

  @override
  String get resetProgressTitle => 'Reset Progress?';

  @override
  String get resetProgressMessage =>
      'This will permanently delete all your progress, including:\n\n• Lesson completion status\n• Stars earned\n• Best times\n• Practice history\n\nThis action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get progressResetSuccess => 'Progress has been reset';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'Write Lao';

  @override
  String get aboutAuthor => 'by Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override

  @override

  @override
  String get done => 'Done';

  @override
  String get splashTitle => 'Write Lao';

  @override
  String get splashSubtitle => 'Lao';
}
