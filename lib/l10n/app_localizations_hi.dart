// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'लाओ लिखें';

  @override
  String get tabLessons => 'पाठ';

  @override
  String get tabReview => 'समीक्षा';

  @override
  String get tabProgress => 'प्रगति';

  @override
  String lessonNumber(int number) {
    return 'पाठ $number';
  }

  @override
  String get lessonNotFound => 'पाठ नहीं मिला';

  @override
  String get lessonLabel => 'पाठ';

  @override
  String get practice => 'अभ्यास';

  @override
  String get test => 'परीक्षा';

  @override
  String get content => 'सामग्री';

  @override
  String get bestTime => 'सर्वश्रेष्ठ समय';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'अभ्यास';

  @override
  String get leavePracticeTitle => 'अभ्यास छोड़ें?';

  @override
  String get leavePracticeMessage => 'क्या आप वाकई अभ्यास छोड़ना चाहते हैं?';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get goBackButton => 'वापस जाएँ';

  @override
  String get traceCharacter => 'अक्षर को ट्रेस करें';

  @override
  String get allDone => 'सब हो गया! बहुत बढ़िया!';

  @override
  String get moveToNext => 'बहुत बढ़िया! अगले अक्षर पर जाएँ';

  @override
  String get clearTooltip => 'मिटाएँ';

  @override
  String get playPronunciation => 'उच्चारण सुनें';

  @override
  String get hideHint => 'संकेत छिपाएँ';

  @override
  String get showHint => 'संकेत दिखाएँ';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'अभ्यास पूरा हुआ!';

  @override
  String practiceCompleteMessage(int count) {
    return 'आपने इस पाठ के सभी $count अक्षरों का अभ्यास कर लिया।';
  }

  @override
  String get characters => 'अक्षर';

  @override
  String get takeTest => 'परीक्षा दें';

  @override
  String get practiceAgain => 'फिर से अभ्यास करें';

  @override
  String get backToLesson => 'पाठ पर वापस';

  @override
  String get backToReview => 'समीक्षा पर वापस';

  @override
  String get mainMenu => 'मुख्य मेनू';

  @override
  String get testTitle => 'परीक्षा';

  @override
  String get leaveTestTitle => 'परीक्षा छोड़ें?';

  @override
  String get leaveTestMessage => 'क्या आप वाकई परीक्षा छोड़ना चाहते हैं?';

  @override
  String get writeFromMemory => 'यह अक्षर याद से लिखें';

  @override
  String get resultPerfect => 'उत्तम!';

  @override
  String get resultGreatJob => 'शाबाश!';

  @override
  String get resultGoodTry => 'अच्छा प्रयास!';

  @override
  String get time => 'समय';

  @override
  String get testAgain => 'फिर से परीक्षा दें';

  @override
  String get progressTitle => 'प्रगति';

  @override
  String get lessonsCompleted => 'पूर्ण किए\nपाठ';

  @override
  String get starsEarned => 'अर्जित\nतारे';

  @override
  String get phaseProgress => 'चरणवार प्रगति';

  @override
  String get phaseConsonants => 'व्यंजन';

  @override
  String get phaseVowels => 'स्वर';

  @override
  String get phaseToneMarks => 'स्वर चिह्न';

  @override
  String get phaseNumerals => 'अंक';

  @override
  String get phaseLigatures => 'संयुक्ताक्षर';

  @override
  String get reviewTitle => 'समीक्षा';

  @override
  String get weakCharacters => 'कमज़ोर अक्षर';

  @override
  String get all => 'सभी';

  @override
  String phaseN(int number) {
    return 'चरण $number';
  }

  @override
  String practiceSelected(int count) {
    return 'चयनित का अभ्यास ($count)';
  }

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get strokeTolerance => 'रेखा सहनशीलता';

  @override
  String get toleranceForgiving => 'उदार';

  @override
  String get toleranceStrict => 'सख़्त';

  @override
  String get soundEffects => 'ध्वनि प्रभाव';

  @override
  String get soundEffectsSubtitle => 'सही/ग़लत रेखा पर ध्वनि बजाएँ';

  @override
  String get hapticFeedback => 'स्पर्श प्रतिक्रिया';

  @override
  String get hapticFeedbackSubtitle => 'रेखा घटनाओं पर कंपन';

  @override
  String get resetAllProgress => 'सभी प्रगति रीसेट करें';

  @override
  String get resetAllProgressSubtitle => 'सभी पाठ प्रगति और तारे मिटाएँ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Conditions for using the app';

  @override
  String get aboutWriteLao => 'लाओ लिखें के बारे में';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'बहुत आसान';

  @override
  String get toleranceEasy => 'आसान';

  @override
  String get toleranceMedium => 'मध्यम';

  @override
  String get toleranceHard => 'कठिन';

  @override
  String get toleranceVeryHard => 'बहुत कठिन';

  @override
  String get toleranceExtreme => 'अत्यंत कठिन';

  @override
  String get toleranceDescVeryEasy => 'लगभग कोई भी रेखा स्वीकार होगी';

  @override
  String get toleranceDescEasy => 'ढीला मिलान, शुरुआती लोगों के लिए उपयुक्त';

  @override
  String get toleranceDescMedium => 'संतुलित कठिनाई (अनुशंसित)';

  @override
  String get toleranceDescHard => 'अधिक सटीकता आवश्यक';

  @override
  String get toleranceDescVeryHard => 'सख़्त मिलान';

  @override
  String get toleranceDescExtreme => 'विशेषज्ञों के लिए अत्यंत सख़्त मिलान';

  @override
  String get resetProgressTitle => 'प्रगति रीसेट करें?';

  @override
  String get resetProgressMessage =>
      'यह आपकी सभी प्रगति स्थायी रूप से हटा देगा, जिसमें शामिल हैं:\n\n• पाठ पूर्णता स्थिति\n• अर्जित तारे\n• सर्वश्रेष्ठ समय\n• अभ्यास इतिहास\n\nयह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get reset => 'रीसेट';

  @override
  String get progressResetSuccess => 'प्रगति रीसेट हो गई';

  @override
  String get aboutTitle => 'परिचय';

  @override
  String get aboutAppName => 'लाओ लिखें';

  @override
  String get aboutAuthor => 'लेखक: Janet Jeffus';

  @override
  String get aboutCopyright => 'कॉपीराइट © 2026';

  @override
  String get aboutStory =>
      'बीस वर्षों से अधिक समय तक सॉफ़्टवेयर इंजीनियर के रूप में काम करने के बाद, मैंने पाया कि मैं लाओ भाषा सीखना चाहती हूँ — विशेष रूप से सुंदर लाओ लिपि पढ़ना और लिखना। मैंने एक ऐसा ऐप खोजा जो मुझे कक्षा की तरह एक-एक रेखा करके अक्षर लिखना सिखाए। मुझे ऐसा कोई ऐप नहीं मिला।\n\nलाओ लिखें आपको लाओ वर्णमाला के हर व्यंजन, स्वर और स्वर चिह्न सिखाता है। हर अक्षर को सही क्रम और दिशा में अलग-अलग रेखाओं में विभाजित किया गया है। आप स्क्रीन पर हर रेखा ट्रेस करते हैं, और ऐप बताता है कि आपने सही किया या नहीं — कोई अनुमान नहीं, कोई फ़्लैश कार्ड नहीं, बस अभ्यास।\n\nमुझे आशा है कि यह ऐप लाओ भाषा सीखने की आपकी यात्रा में सहायक होगा। लिखने का आनंद लें!';

  @override
  String get aboutDedication =>
      'लाओ भाषा और संस्कृति के संरक्षण के लिए प्यार से समर्पित।';

  @override
  String get done => 'हो गया';

  @override
  String get splashTitle => 'लाओ लिखें';

  @override
  String get splashSubtitle => 'लाओ';
}
