import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('ne'),
    Locale('pt'),
    Locale('th'),
    Locale('tl'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Lao'**
  String get appTitle;

  /// No description provided for @tabLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get tabLessons;

  /// No description provided for @tabReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get tabReview;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumber(int number);

  /// No description provided for @lessonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found'**
  String get lessonNotFound;

  /// No description provided for @lessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lessonLabel;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @bestTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'--:--'**
  String get bestTimeEmpty;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @leavePracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Practice?'**
  String get leavePracticeTitle;

  /// No description provided for @leavePracticeMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave practice?'**
  String get leavePracticeMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// No description provided for @traceCharacter.
  ///
  /// In en, this message translates to:
  /// **'Trace the character'**
  String get traceCharacter;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done! Great job!'**
  String get allDone;

  /// No description provided for @moveToNext.
  ///
  /// In en, this message translates to:
  /// **'Great job! Move to next character'**
  String get moveToNext;

  /// No description provided for @clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @playPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation'**
  String get playPronunciation;

  /// No description provided for @hideHint.
  ///
  /// In en, this message translates to:
  /// **'Hide hint'**
  String get hideHint;

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Show hint'**
  String get showHint;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String characterCount(int current, int total);

  /// No description provided for @practiceComplete.
  ///
  /// In en, this message translates to:
  /// **'Practice Complete!'**
  String get practiceComplete;

  /// No description provided for @practiceCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'You practiced all {count} characters in this lesson.'**
  String practiceCompleteMessage(int count);

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @takeTest.
  ///
  /// In en, this message translates to:
  /// **'Take Test'**
  String get takeTest;

  /// No description provided for @practiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Practice Again'**
  String get practiceAgain;

  /// No description provided for @backToLesson.
  ///
  /// In en, this message translates to:
  /// **'Back to Lesson'**
  String get backToLesson;

  /// No description provided for @backToReview.
  ///
  /// In en, this message translates to:
  /// **'Back to Review'**
  String get backToReview;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @testTitle.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testTitle;

  /// No description provided for @leaveTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Test?'**
  String get leaveTestTitle;

  /// No description provided for @leaveTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the test?'**
  String get leaveTestMessage;

  /// No description provided for @writeFromMemory.
  ///
  /// In en, this message translates to:
  /// **'Write this character from memory'**
  String get writeFromMemory;

  /// No description provided for @resultPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get resultPerfect;

  /// No description provided for @resultGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get resultGreatJob;

  /// No description provided for @resultGoodTry.
  ///
  /// In en, this message translates to:
  /// **'Good Try!'**
  String get resultGoodTry;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @testAgain.
  ///
  /// In en, this message translates to:
  /// **'Test Again'**
  String get testAgain;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lessons\nCompleted'**
  String get lessonsCompleted;

  /// No description provided for @starsEarned.
  ///
  /// In en, this message translates to:
  /// **'Stars\nEarned'**
  String get starsEarned;

  /// No description provided for @phaseProgress.
  ///
  /// In en, this message translates to:
  /// **'Phase Progress'**
  String get phaseProgress;

  /// No description provided for @phaseConsonants.
  ///
  /// In en, this message translates to:
  /// **'Consonants'**
  String get phaseConsonants;

  /// No description provided for @phaseVowels.
  ///
  /// In en, this message translates to:
  /// **'Vowels'**
  String get phaseVowels;

  /// No description provided for @phaseToneMarks.
  ///
  /// In en, this message translates to:
  /// **'Tone Marks'**
  String get phaseToneMarks;

  /// No description provided for @phaseNumerals.
  ///
  /// In en, this message translates to:
  /// **'Numerals'**
  String get phaseNumerals;

  /// No description provided for @phaseLigatures.
  ///
  /// In en, this message translates to:
  /// **'Ligatures'**
  String get phaseLigatures;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @weakCharacters.
  ///
  /// In en, this message translates to:
  /// **'Weak characters'**
  String get weakCharacters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @phaseN.
  ///
  /// In en, this message translates to:
  /// **'Phase {number}'**
  String phaseN(int number);

  /// No description provided for @practiceSelected.
  ///
  /// In en, this message translates to:
  /// **'Practice Selected ({count})'**
  String practiceSelected(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @strokeTolerance.
  ///
  /// In en, this message translates to:
  /// **'Stroke Tolerance'**
  String get strokeTolerance;

  /// No description provided for @toleranceForgiving.
  ///
  /// In en, this message translates to:
  /// **'Forgiving'**
  String get toleranceForgiving;

  /// No description provided for @toleranceStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get toleranceStrict;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sounds for correct/incorrect strokes'**
  String get soundEffectsSubtitle;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on stroke events'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @resetAllProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset All Progress'**
  String get resetAllProgress;

  /// No description provided for @resetAllProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all lesson progress and stars'**
  String get resetAllProgressSubtitle;

  /// No description provided for @aboutWriteLao.
  ///
  /// In en, this message translates to:
  /// **'About Write Lao'**
  String get aboutWriteLao;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0'**
  String get aboutVersion;

  /// No description provided for @aboutVersionAuthor.
  ///
  /// In en, this message translates to:
  /// **'v1.0 · Janet Jeffus'**
  String get aboutVersionAuthor;

  /// No description provided for @toleranceVeryEasy.
  ///
  /// In en, this message translates to:
  /// **'Very Easy'**
  String get toleranceVeryEasy;

  /// No description provided for @toleranceEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get toleranceEasy;

  /// No description provided for @toleranceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get toleranceMedium;

  /// No description provided for @toleranceHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get toleranceHard;

  /// No description provided for @toleranceVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard'**
  String get toleranceVeryHard;

  /// No description provided for @toleranceExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get toleranceExtreme;

  /// No description provided for @toleranceDescVeryEasy.
  ///
  /// In en, this message translates to:
  /// **'Almost any drawing will be accepted'**
  String get toleranceDescVeryEasy;

  /// No description provided for @toleranceDescEasy.
  ///
  /// In en, this message translates to:
  /// **'Loose matching, good for beginners'**
  String get toleranceDescEasy;

  /// No description provided for @toleranceDescMedium.
  ///
  /// In en, this message translates to:
  /// **'Balanced difficulty (recommended)'**
  String get toleranceDescMedium;

  /// No description provided for @toleranceDescHard.
  ///
  /// In en, this message translates to:
  /// **'Requires more precision'**
  String get toleranceDescHard;

  /// No description provided for @toleranceDescVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Strict matching'**
  String get toleranceDescVeryHard;

  /// No description provided for @toleranceDescExtreme.
  ///
  /// In en, this message translates to:
  /// **'Very strict matching for experts'**
  String get toleranceDescExtreme;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress?'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your progress, including:\n\n• Lesson completion status\n• Stars earned\n• Best times\n• Practice history\n\nThis action cannot be undone.'**
  String get resetProgressMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @progressResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Progress has been reset'**
  String get progressResetSuccess;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'Write Lao'**
  String get aboutAppName;

  /// No description provided for @aboutAuthor.
  ///
  /// In en, this message translates to:
  /// **'by Janet Jeffus'**
  String get aboutAuthor;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2026'**
  String get aboutCopyright;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Lao'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lao'**
  String get splashSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'km',
    'ko',
    'lo',
    'ne',
    'pt',
    'th',
    'tl',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'ko':
      return AppLocalizationsKo();
    case 'lo':
      return AppLocalizationsLo();
    case 'ne':
      return AppLocalizationsNe();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
    case 'tl':
      return AppLocalizationsTl();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
