// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'لاؤ لکھیں';

  @override
  String get tabLessons => 'اسباق';

  @override
  String get tabReview => 'مراجعہ';

  @override
  String get tabProgress => 'پیش رفت';

  @override
  String lessonNumber(int number) {
    return 'سبق $number';
  }

  @override
  String get lessonNotFound => 'سبق نہیں ملا';

  @override
  String get lessonLabel => 'سبق';

  @override
  String get practice => 'مشق';

  @override
  String get test => 'امتحان';

  @override
  String get content => 'مواد';

  @override
  String get bestTime => 'بہترین وقت';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'مشق';

  @override
  String get leavePracticeTitle => 'مشق چھوڑیں؟';

  @override
  String get leavePracticeMessage => 'کیا آپ واقعی مشق چھوڑنا چاہتے ہیں؟';

  @override
  String get continueButton => 'جاری رکھیں';

  @override
  String get goBackButton => 'واپس جائیں';

  @override
  String get traceCharacter => 'حرف کی نقل کریں';

  @override
  String get allDone => 'سب مکمل! شاباش!';

  @override
  String get moveToNext => 'شاباش! اگلے حرف پر جائیں';

  @override
  String get clearTooltip => 'صاف کریں';

  @override
  String get playPronunciation => 'تلفظ سنیں';

  @override
  String get hideHint => 'اشارہ چھپائیں';

  @override
  String get showHint => 'اشارہ دکھائیں';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'مشق مکمل!';

  @override
  String practiceCompleteMessage(int count) {
    return 'آپ نے اس سبق کے تمام $count حروف کی مشق کر لی۔';
  }

  @override
  String get characters => 'حروف';

  @override
  String get takeTest => 'امتحان دیں';

  @override
  String get practiceAgain => 'دوبارہ مشق کریں';

  @override
  String get backToLesson => 'سبق پر واپس';

  @override
  String get backToReview => 'مراجعہ پر واپس';

  @override
  String get mainMenu => 'مرکزی مینو';

  @override
  String get testTitle => 'امتحان';

  @override
  String get leaveTestTitle => 'امتحان چھوڑیں؟';

  @override
  String get leaveTestMessage => 'کیا آپ واقعی امتحان چھوڑنا چاہتے ہیں؟';

  @override
  String get writeFromMemory => 'یہ حرف یاد سے لکھیں';

  @override
  String get resultPerfect => 'کامل!';

  @override
  String get resultGreatJob => 'بہترین!';

  @override
  String get resultGoodTry => 'اچھی کوشش!';

  @override
  String get time => 'وقت';

  @override
  String get testAgain => 'دوبارہ امتحان دیں';

  @override
  String get progressTitle => 'پیش رفت';

  @override
  String get lessonsCompleted => 'مکمل شدہ\nاسباق';

  @override
  String get starsEarned => 'حاصل شدہ\nستارے';

  @override
  String get phaseProgress => 'مرحلہ وار پیش رفت';

  @override
  String get phaseConsonants => 'حروف صحیح';

  @override
  String get phaseVowels => 'حروف علت';

  @override
  String get phaseToneMarks => 'آہنگ کے نشان';

  @override
  String get phaseNumerals => 'ہندسے';

  @override
  String get phaseLigatures => 'مرکب حروف';

  @override
  String get reviewTitle => 'مراجعہ';

  @override
  String get weakCharacters => 'کمزور حروف';

  @override
  String get all => 'سب';

  @override
  String phaseN(int number) {
    return 'مرحلہ $number';
  }

  @override
  String practiceSelected(int count) {
    return 'منتخب کی مشق ($count)';
  }

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get strokeTolerance => 'خط کی رواداری';

  @override
  String get toleranceForgiving => 'نرم';

  @override
  String get toleranceStrict => 'سخت';

  @override
  String get soundEffects => 'آوازی اثرات';

  @override
  String get soundEffectsSubtitle => 'صحیح/غلط خطوط پر آواز چلائیں';

  @override
  String get hapticFeedback => 'لمسی جواب';

  @override
  String get hapticFeedbackSubtitle => 'خط کے واقعات پر کمپن';

  @override
  String get resetAllProgress => 'تمام پیش رفت ری سیٹ کریں';

  @override
  String get resetAllProgressSubtitle =>
      'تمام اسباق کی پیش رفت اور ستارے صاف کریں';

  @override
  String get aboutWriteLao => 'لاؤ لکھیں کے بارے میں';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'بہت آسان';

  @override
  String get toleranceEasy => 'آسان';

  @override
  String get toleranceMedium => 'درمیانہ';

  @override
  String get toleranceHard => 'مشکل';

  @override
  String get toleranceVeryHard => 'بہت مشکل';

  @override
  String get toleranceExtreme => 'انتہائی مشکل';

  @override
  String get toleranceDescVeryEasy => 'تقریباً ہر خط قبول ہو گا';

  @override
  String get toleranceDescEasy => 'ڈھیلی مماثلت، ابتدائی سیکھنے والوں کے لیے';

  @override
  String get toleranceDescMedium => 'متوازن مشکل (تجویز کردہ)';

  @override
  String get toleranceDescHard => 'زیادہ درستگی درکار';

  @override
  String get toleranceDescVeryHard => 'سخت مماثلت';

  @override
  String get toleranceDescExtreme => 'ماہرین کے لیے انتہائی سخت مماثلت';

  @override
  String get resetProgressTitle => 'پیش رفت ری سیٹ کریں؟';

  @override
  String get resetProgressMessage =>
      'یہ آپ کی تمام پیش رفت مستقل طور پر حذف کر دے گا، بشمول:\n\n• سبق کی تکمیل کی حالت\n• حاصل شدہ ستارے\n• بہترین اوقات\n• مشق کی تاریخ\n\nیہ عمل واپس نہیں ہو سکتا۔';

  @override
  String get cancel => 'منسوخ';

  @override
  String get reset => 'ری سیٹ';

  @override
  String get progressResetSuccess => 'پیش رفت ری سیٹ ہو گئی';

  @override
  String get aboutTitle => 'بارے میں';

  @override
  String get aboutAppName => 'لاؤ لکھیں';

  @override
  String get aboutAuthor => 'تصنیف: Janet Jeffus';

  @override
  String get aboutCopyright => 'کاپی رائٹ © 2026';

  @override
  String get aboutStory =>
      'بیس سال سے زائد عرصے تک سافٹ ویئر انجینئر کے طور پر کام کرنے کے بعد، مجھے لاؤ زبان سیکھنے کی خواہش ہوئی — خاص طور پر خوبصورت لاؤ رسم الخط پڑھنا اور لکھنا۔ میں نے ایک ایسی ایپ تلاش کی جو مجھے حروف خط بہ خط سکھائے، جیسے کلاس روم میں لکھنا سکھایا جاتا ہے۔ مجھے ایسی کوئی ایپ نہیں ملی۔\n\nلاؤ لکھیں آپ کو لاؤ حروف تہجی کے ہر حروف صحیح، حروف علت اور آہنگ کے نشان سکھاتی ہے۔ ہر حرف کو صحیح ترتیب اور سمت کے ساتھ الگ الگ خطوط میں تقسیم کیا گیا ہے۔ آپ اسکرین پر ہر خط کی نقل کرتے ہیں، اور ایپ بتاتی ہے کہ آپ نے صحیح کیا یا نہیں — کوئی اندازہ لگانا نہیں، کوئی فلیش کارڈز نہیں، صرف مشق۔\n\nمجھے امید ہے کہ یہ ایپ لاؤ زبان سیکھنے کے آپ کے سفر میں مدد کرے گی۔ خوش لکھائی!';

  @override
  String get aboutDedication =>
      'لاؤ زبان اور ثقافت کے تحفظ کے لیے محبت سے وقف۔';

  @override
  String get done => 'مکمل';

  @override
  String get splashTitle => 'لاؤ لکھیں';

  @override
  String get splashSubtitle => 'لاؤ';
}
