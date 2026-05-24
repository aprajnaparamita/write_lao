// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'लाओ लेख्नुहोस्';

  @override
  String get tabLessons => 'पाठहरू';

  @override
  String get tabReview => 'समीक्षा';

  @override
  String get tabProgress => 'प्रगति';

  @override
  String lessonNumber(int number) {
    return 'पाठ $number';
  }

  @override
  String get lessonNotFound => 'पाठ फेला परेन';

  @override
  String get lessonLabel => 'पाठ';

  @override
  String get practice => 'अभ्यास';

  @override
  String get test => 'परीक्षा';

  @override
  String get content => 'सामग्री';

  @override
  String get bestTime => 'उत्तम समय';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'अभ्यास';

  @override
  String get leavePracticeTitle => 'अभ्यास छोड्ने?';

  @override
  String get leavePracticeMessage => 'के तपाईं अभ्यास छोड्न चाहनुहुन्छ?';

  @override
  String get continueButton => 'जारी राख्नुहोस्';

  @override
  String get goBackButton => 'पछाडि जानुहोस्';

  @override
  String get traceCharacter => 'अक्षर कोर्नुहोस्';

  @override
  String get allDone => 'सबै सकियो! राम्रो भयो!';

  @override
  String get moveToNext => 'राम्रो भयो! अर्को अक्षरमा जानुहोस्';

  @override
  String get clearTooltip => 'मेट्नुहोस्';

  @override
  String get playPronunciation => 'उच्चारण सुन्नुहोस्';

  @override
  String get hideHint => 'संकेत लुकाउनुहोस्';

  @override
  String get showHint => 'संकेत देखाउनुहोस्';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'अभ्यास पूरा भयो!';

  @override
  String practiceCompleteMessage(int count) {
    return 'तपाईंले यस पाठका सबै $count अक्षरहरू अभ्यास गर्नुभयो।';
  }

  @override
  String get characters => 'अक्षरहरू';

  @override
  String get takeTest => 'परीक्षा दिनुहोस्';

  @override
  String get practiceAgain => 'फेरि अभ्यास गर्नुहोस्';

  @override
  String get backToLesson => 'पाठमा फर्कनुहोस्';

  @override
  String get backToReview => 'समीक्षामा फर्कनुहोस्';

  @override
  String get mainMenu => 'मुख्य मेनु';

  @override
  String get testTitle => 'परीक्षा';

  @override
  String get leaveTestTitle => 'परीक्षा छोड्ने?';

  @override
  String get leaveTestMessage => 'के तपाईं परीक्षा छोड्न चाहनुहुन्छ?';

  @override
  String get writeFromMemory => 'यो अक्षर सम्झेर लेख्नुहोस्';

  @override
  String get resultPerfect => 'उत्कृष्ट!';

  @override
  String get resultGreatJob => 'शाबास!';

  @override
  String get resultGoodTry => 'राम्रो प्रयास!';

  @override
  String get time => 'समय';

  @override
  String get testAgain => 'फेरि परीक्षा दिनुहोस्';

  @override
  String get progressTitle => 'प्रगति';

  @override
  String get lessonsCompleted => 'पूरा भएका\nपाठहरू';

  @override
  String get starsEarned => 'प्राप्त\nताराहरू';

  @override
  String get phaseProgress => 'चरणगत प्रगति';

  @override
  String get phaseConsonants => 'व्यञ्जनहरू';

  @override
  String get phaseVowels => 'स्वरहरू';

  @override
  String get phaseToneMarks => 'स्वर चिन्हहरू';

  @override
  String get phaseNumerals => 'अङ्कहरू';

  @override
  String get phaseLigatures => 'संयुक्ताक्षरहरू';

  @override
  String get reviewTitle => 'समीक्षा';

  @override
  String get weakCharacters => 'कमजोर अक्षरहरू';

  @override
  String get all => 'सबै';

  @override
  String phaseN(int number) {
    return 'चरण $number';
  }

  @override
  String practiceSelected(int count) {
    return 'छानिएका अभ्यास ($count)';
  }

  @override
  String get settingsTitle => 'सेटिङ';

  @override
  String get strokeTolerance => 'रेखा सहनशीलता';

  @override
  String get toleranceForgiving => 'नरम';

  @override
  String get toleranceStrict => 'कडा';

  @override
  String get soundEffects => 'ध्वनि प्रभाव';

  @override
  String get soundEffectsSubtitle => 'सही/गलत रेखामा ध्वनि बजाउनुहोस्';

  @override
  String get hapticFeedback => 'स्पर्श प्रतिक्रिया';

  @override
  String get hapticFeedbackSubtitle => 'रेखा घटनामा कम्पन';

  @override
  String get resetAllProgress => 'सबै प्रगति रिसेट गर्नुहोस्';

  @override
  String get resetAllProgressSubtitle => 'सबै पाठ प्रगति र ताराहरू मेट्नुहोस्';

  @override
  String get aboutWriteLao => 'लाओ लेख्नुहोस् बारेमा';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'धेरै सजिलो';

  @override
  String get toleranceEasy => 'सजिलो';

  @override
  String get toleranceMedium => 'मध्यम';

  @override
  String get toleranceHard => 'कठिन';

  @override
  String get toleranceVeryHard => 'धेरै कठिन';

  @override
  String get toleranceExtreme => 'अति कठिन';

  @override
  String get toleranceDescVeryEasy => 'लगभग जुनसुकै कोरेको स्वीकार हुन्छ';

  @override
  String get toleranceDescEasy => 'ढिलो मिलान, शुरुवातकर्ताका लागि उपयुक्त';

  @override
  String get toleranceDescMedium => 'सन्तुलित कठिनाइ (सिफारिस गरिएको)';

  @override
  String get toleranceDescHard => 'बढी सटीकता आवश्यक';

  @override
  String get toleranceDescVeryHard => 'कडा मिलान';

  @override
  String get toleranceDescExtreme => 'विशेषज्ञका लागि अति कडा मिलान';

  @override
  String get resetProgressTitle => 'प्रगति रिसेट गर्ने?';

  @override
  String get resetProgressMessage =>
      'यसले तपाईंको सबै प्रगति स्थायी रूपमा मेटाउनेछ, जसमा:\n\n• पाठ पूरा भएको स्थिति\n• प्राप्त ताराहरू\n• उत्तम समयहरू\n• अभ्यास इतिहास\n\nयो कार्य पूर्ववत गर्न सकिँदैन।';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get reset => 'रिसेट';

  @override
  String get progressResetSuccess => 'प्रगति रिसेट भयो';

  @override
  String get aboutTitle => 'बारेमा';

  @override
  String get aboutAppName => 'लाओ लेख्नुहोस्';

  @override
  String get aboutAuthor => 'लेखक: Janet Jeffus';

  @override
  String get aboutCopyright => 'सर्वाधिकार © 2026';

  @override
  String get aboutStory =>
      'बीस वर्षभन्दा बढी सफ्टवेयर इन्जिनियर भएर काम गरेपछि, मैले लाओ भाषा सिक्न चाहेँ — विशेष गरी सुन्दर लाओ लिपि पढ्न र लेख्न। मैले एउटा एप खोजेँ जसले मलाई कक्षामा जसरी सिकाइन्छ त्यसरी नै रेखा-रेखा गरेर अक्षरहरू लेख्न सिकाओस्। तर त्यस्तो कुनै एप भेटिएन।\n\nलाओ लेख्नुहोस्ले तपाईंलाई लाओ वर्णमालाका हरेक व्यञ्जन, स्वर र स्वर चिन्ह सिकाउँछ। हरेक अक्षरलाई सही क्रम र दिशामा अलग-अलग रेखाहरूमा विभाजन गरिएको छ। तपाईं स्क्रिनमा हरेक रेखा कोर्नुहुन्छ, र एपले तपाईंलाई सही वा गलत बताउँछ — अनुमान छैन, फ्ल्यास कार्ड छैन, केवल अभ्यास।\n\nमलाई आशा छ यो एपले लाओ भाषा सिक्ने तपाईंको यात्रामा सहयोग गर्नेछ। रमाइलो लेखाइ!';

  @override
  String get aboutDedication =>
      'लाओ भाषा र संस्कृतिको संरक्षणमा प्रेमपूर्वक समर्पित।';

  @override
  String get done => 'सकियो';

  @override
  String get splashTitle => 'लाओ लेख्नुहोस्';

  @override
  String get splashSubtitle => 'लाओ';
}
