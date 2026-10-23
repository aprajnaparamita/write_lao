// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'សរសេរអក្សរឡាវ';

  @override
  String get tabLessons => 'មេរៀន';

  @override
  String get tabReview => 'ពិនិត្យឡើងវិញ';

  @override
  String get tabProgress => 'វឌ្ឍនភាព';

  @override
  String lessonNumber(int number) {
    return 'មេរៀនទី $number';
  }

  @override
  String get lessonNotFound => 'រកមេរៀនមិនឃើញ';

  @override
  String get lessonLabel => 'មេរៀន';

  @override
  String get practice => 'អនុវត្ត';

  @override
  String get test => 'ប្រលង';

  @override
  String get content => 'ខ្លឹមសារ';

  @override
  String get bestTime => 'ពេលវេលាល្អបំផុត';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'អនុវត្ត';

  @override
  String get leavePracticeTitle => 'ចាកចេញពីការអនុវត្ត?';

  @override
  String get leavePracticeMessage => 'តើអ្នកពិតជាចង់ចាកចេញពីការអនុវត្តមែនទេ?';

  @override
  String get continueButton => 'បន្ត';

  @override
  String get goBackButton => 'ត្រឡប់ក្រោយ';

  @override
  String get traceCharacter => 'គូរតាមអក្សរ';

  @override
  String get allDone => 'រួចអស់ហើយ! ពូកែណាស់!';

  @override
  String get moveToNext => 'ពូកែណាស់! ទៅអក្សរបន្ទាប់';

  @override
  String get clearTooltip => 'លុប';

  @override
  String get playPronunciation => 'ស្តាប់ការបញ្ចេញសំឡេង';

  @override
  String get hideHint => 'លាក់ជំនួយ';

  @override
  String get showHint => 'បង្ហាញជំនួយ';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'អនុវត្តរួចរាល់!';

  @override
  String practiceCompleteMessage(int count) {
    return 'អ្នកបានអនុវត្តអក្សរទាំង $count ក្នុងមេរៀននេះ។';
  }

  @override
  String get characters => 'អក្សរ';

  @override
  String get takeTest => 'ធ្វើប្រលង';

  @override
  String get practiceAgain => 'អនុវត្តម្តងទៀត';

  @override
  String get backToLesson => 'ត្រឡប់ទៅមេរៀន';

  @override
  String get backToReview => 'ត្រឡប់ទៅពិនិត្យឡើងវិញ';

  @override
  String get mainMenu => 'មឺនុយមេ';

  @override
  String get testTitle => 'ប្រលង';

  @override
  String get leaveTestTitle => 'ចាកចេញពីការប្រលង?';

  @override
  String get leaveTestMessage => 'តើអ្នកពិតជាចង់ចាកចេញពីការប្រលងមែនទេ?';

  @override
  String get writeFromMemory => 'សរសេរអក្សរនេះពីការចងចាំ';

  @override
  String get resultPerfect => 'ល្អឥតខ្ចោះ!';

  @override
  String get resultGreatJob => 'ពូកែណាស់!';

  @override
  String get resultGoodTry => 'ខិតខំល្អ!';

  @override
  String get time => 'ពេលវេលា';

  @override
  String get testAgain => 'ប្រលងម្តងទៀត';

  @override
  String get progressTitle => 'វឌ្ឍនភាព';

  @override
  String get lessonsCompleted => 'មេរៀន\nដែលបានបញ្ចប់';

  @override
  String get starsEarned => 'ផ្កាយ\nដែលទទួលបាន';

  @override
  String get phaseProgress => 'វឌ្ឍនភាពតាមដំណាក់កាល';

  @override
  String get phaseConsonants => 'ព្យញ្ជនៈ';

  @override
  String get phaseVowels => 'ស្រៈ';

  @override
  String get phaseToneMarks => 'សញ្ញាសំឡេង';

  @override
  String get phaseNumerals => 'លេខ';

  @override
  String get phaseLigatures => 'អក្សរផ្សំ';

  @override
  String get reviewTitle => 'ពិនិត្យឡើងវិញ';

  @override
  String get weakCharacters => 'អក្សរខ្សោយ';

  @override
  String get all => 'ទាំងអស់';

  @override
  String phaseN(int number) {
    return 'ដំណាក់កាលទី $number';
  }

  @override
  String practiceSelected(int count) {
    return 'អនុវត្តដែលបានជ្រើស ($count)';
  }

  @override
  String get settingsTitle => 'ការកំណត់';

  @override
  String get strokeTolerance => 'ការអត់ធ្មត់នៃខ្សែ';

  @override
  String get toleranceForgiving => 'អត់ធ្មត់';

  @override
  String get toleranceStrict => 'តឹងរ៉ឹង';

  @override
  String get soundEffects => 'បែបផែនសំឡេង';

  @override
  String get soundEffectsSubtitle => 'ចាក់សំឡេងពេលខ្សែត្រូវ/ខុស';

  @override
  String get hapticFeedback => 'ការឆ្លើយតបដោយការប៉ះ';

  @override
  String get hapticFeedbackSubtitle => 'ញ័រពេលមានព្រឹត្តិការណ៍ខ្សែ';

  @override
  String get resetAllProgress => 'កំណត់វឌ្ឍនភាពឡើងវិញទាំងអស់';

  @override
  String get resetAllProgressSubtitle => 'លុបវឌ្ឍនភាពមេរៀន និងផ្កាយទាំងអស់';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Conditions for using the app';

  @override
  String get aboutWriteLao => 'អំពី សរសេរអក្សរឡាវ';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'ងាយណាស់';

  @override
  String get toleranceEasy => 'ងាយ';

  @override
  String get toleranceMedium => 'មធ្យម';

  @override
  String get toleranceHard => 'ពិបាក';

  @override
  String get toleranceVeryHard => 'ពិបាកណាស់';

  @override
  String get toleranceExtreme => 'ពិបាកខ្លាំងណាស់';

  @override
  String get toleranceDescVeryEasy => 'ស្ទើរតែគ្រប់ការគូរត្រូវបានទទួលយក';

  @override
  String get toleranceDescEasy => 'ការផ្គូផ្គងរលុង សម្រាប់អ្នកចាប់ផ្តើម';

  @override
  String get toleranceDescMedium => 'កម្រិតលំបាកស្មើ (ណែនាំ)';

  @override
  String get toleranceDescHard => 'ត្រូវការភាពត្រឹមត្រូវខ្ពស់ជាង';

  @override
  String get toleranceDescVeryHard => 'ការផ្គូផ្គងតឹងរ៉ឹង';

  @override
  String get toleranceDescExtreme => 'ការផ្គូផ្គងតឹងរ៉ឹងខ្លាំងសម្រាប់អ្នកជំនាញ';

  @override
  String get resetProgressTitle => 'កំណត់វឌ្ឍនភាពឡើងវិញ?';

  @override
  String get resetProgressMessage =>
      'នេះនឹងលុបវឌ្ឍនភាពទាំងអស់របស់អ្នកជាអចិន្ត្រៃយ៍ រួមទាំង:\n\n• ស្ថានភាពបញ្ចប់មេរៀន\n• ផ្កាយដែលទទួលបាន\n• ពេលវេលាល្អបំផុត\n• ប្រវត្តិការអនុវត្ត\n\nសកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get reset => 'កំណត់ឡើងវិញ';

  @override
  String get progressResetSuccess => 'វឌ្ឍនភាពត្រូវបានកំណត់ឡើងវិញ';

  @override
  String get aboutTitle => 'អំពី';

  @override
  String get aboutAppName => 'សរសេរអក្សរឡាវ';

  @override
  String get aboutAuthor => 'ដោយ Janet Jeffus';

  @override
  String get aboutCopyright => 'រក្សាសិទ្ធិ © 2026';

  @override
  String get aboutStory =>
      'បន្ទាប់ពីធ្វើការជាវិស្វករផ្នែកទន់ជាង២០ឆ្នាំ ខ្ញុំបានរកឃើញថាខ្ញុំចង់រៀនភាសាឡាវ — ជាពិសេសការអាន និងសរសេរអក្សរឡាវដ៏ស្រស់ស្អាត។ ខ្ញុំបានស្វែងរកកម្មវិធីដែលអាចបង្រៀនសរសេរអក្សរមួយៗតាមខ្សែម្តងមួយៗ ដូចជារៀនសរសេរក្នុងថ្នាក់រៀន។ ខ្ញុំរកមិនឃើញទេ។\n\nសរសេរអក្សរឡាវ នឹងនាំអ្នកឆ្លងកាត់ព្យញ្ជនៈ ស្រៈ និងសញ្ញាសំឡេងគ្រប់តួក្នុងអក្សរក្រមឡាវ។ អក្សរម្តួៗត្រូវបានបែងចែកជាខ្សែម្តួៗតាមលំដាប់ និងទិសដៅត្រឹមត្រូវ។ អ្នកគូរតាមខ្សែម្តួៗលើអេក្រង់ ហើយកម្មវិធីប្រាប់អ្នកថាត្រូវឬខុស — មិនចាំបាច់ស្មាន មិនមានកាតចងចាំ គ្រាន់តែអនុវត្ត។\n\nសង្ឃឹមថាកម្មវិធីនេះនឹងជួយអ្នកក្នុងដំណើររៀនភាសាឡាវ។ សរសេរឱ្យសប្បាយ!';

  @override
  String get aboutDedication =>
      'ឧទ្ទិសដោយស្នេហ៍ដល់ការអភិរក្សភាសា និងវប្បធម៌ឡាវ។';

  @override
  String get done => 'រួចរាល់';

  @override
  String get splashTitle => 'សរសេរអក្សរឡាវ';

  @override
  String get splashSubtitle => 'ឡាវ';
}
