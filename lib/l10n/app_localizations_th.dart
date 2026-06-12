// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'เขียนลาว';

  @override
  String get tabLessons => 'บทเรียน';

  @override
  String get tabReview => 'ทบทวน';

  @override
  String get tabProgress => 'ความก้าวหน้า';

  @override
  String lessonNumber(int number) {
    return 'บทที่ $number';
  }

  @override
  String get lessonNotFound => 'ไม่พบบทเรียน';

  @override
  String get lessonLabel => 'บทเรียน';

  @override
  String get practice => 'ฝึกเขียน';

  @override
  String get test => 'ทดสอบ';

  @override
  String get content => 'เนื้อหา';

  @override
  String get bestTime => 'เวลาที่ดีที่สุด';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'ฝึกเขียน';

  @override
  String get leavePracticeTitle => 'ออกจากการฝึก?';

  @override
  String get leavePracticeMessage => 'คุณแน่ใจหรือไม่ว่าต้องการออกจากการฝึก?';

  @override
  String get continueButton => 'ดำเนินการต่อ';

  @override
  String get goBackButton => 'กลับ';

  @override
  String get traceCharacter => 'ลากตามตัวอักษร';

  @override
  String get allDone => 'เสร็จแล้ว! เก่งมาก!';

  @override
  String get moveToNext => 'เก่งมาก! ไปตัวถัดไป';

  @override
  String get clearTooltip => 'ล้าง';

  @override
  String get playPronunciation => 'เล่นเสียงอ่าน';

  @override
  String get hideHint => 'ซ่อนคำใบ้';

  @override
  String get showHint => 'แสดงคำใบ้';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'ฝึกเขียนเสร็จสมบูรณ์!';

  @override
  String practiceCompleteMessage(int count) {
    return 'คุณได้ฝึกเขียนตัวอักษรทั้งหมด $count ตัวในบทนี้แล้ว';
  }

  @override
  String get characters => 'ตัวอักษร';

  @override
  String get takeTest => 'ทำแบบทดสอบ';

  @override
  String get practiceAgain => 'ฝึกอีกครั้ง';

  @override
  String get backToLesson => 'กลับไปบทเรียน';

  @override
  String get backToReview => 'กลับไปทบทวน';

  @override
  String get mainMenu => 'เมนูหลัก';

  @override
  String get testTitle => 'ทดสอบ';

  @override
  String get leaveTestTitle => 'ออกจากการทดสอบ?';

  @override
  String get leaveTestMessage => 'คุณแน่ใจหรือไม่ว่าต้องการออกจากการทดสอบ?';

  @override
  String get writeFromMemory => 'เขียนตัวอักษรนี้จากความจำ';

  @override
  String get resultPerfect => 'สมบูรณ์แบบ!';

  @override
  String get resultGreatJob => 'ยอดเยี่ยม!';

  @override
  String get resultGoodTry => 'พยายามดี!';

  @override
  String get time => 'เวลา';

  @override
  String get testAgain => 'ทดสอบอีกครั้ง';

  @override
  String get progressTitle => 'ความก้าวหน้า';

  @override
  String get lessonsCompleted => 'บทเรียน\nที่เสร็จแล้ว';

  @override
  String get starsEarned => 'ดาว\nที่ได้รับ';

  @override
  String get phaseProgress => 'ความก้าวหน้าแต่ละระดับ';

  @override
  String get phaseConsonants => 'พยัญชนะ';

  @override
  String get phaseVowels => 'สระ';

  @override
  String get phaseToneMarks => 'วรรณยุกต์';

  @override
  String get phaseNumerals => 'ตัวเลข';

  @override
  String get phaseLigatures => 'อักษรควบ';

  @override
  String get reviewTitle => 'ทบทวน';

  @override
  String get weakCharacters => 'ตัวที่ยังอ่อน';

  @override
  String get all => 'ทั้งหมด';

  @override
  String phaseN(int number) {
    return 'ระดับ $number';
  }

  @override
  String practiceSelected(int count) {
    return 'ฝึกที่เลือก ($count)';
  }

  @override
  String get settingsTitle => 'ตั้งค่า';

  @override
  String get strokeTolerance => 'ความอดทนของเส้น';

  @override
  String get toleranceForgiving => 'ผ่อนปรน';

  @override
  String get toleranceStrict => 'เข้มงวด';

  @override
  String get soundEffects => 'เสียงเอฟเฟกต์';

  @override
  String get soundEffectsSubtitle => 'เล่นเสียงเมื่อเขียนถูก/ผิด';

  @override
  String get hapticFeedback => 'การสั่นตอบกลับ';

  @override
  String get hapticFeedbackSubtitle => 'สั่นเมื่อมีเหตุการณ์เส้น';

  @override
  String get resetAllProgress => 'รีเซ็ตความก้าวหน้าทั้งหมด';

  @override
  String get resetAllProgressSubtitle => 'ล้างความก้าวหน้าและดาวทั้งหมด';

  @override
  String get aboutWriteLao => 'เกี่ยวกับ เขียนลาว';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'ง่ายมาก';

  @override
  String get toleranceEasy => 'ง่าย';

  @override
  String get toleranceMedium => 'ปานกลาง';

  @override
  String get toleranceHard => 'ยาก';

  @override
  String get toleranceVeryHard => 'ยากมาก';

  @override
  String get toleranceExtreme => 'ยากที่สุด';

  @override
  String get toleranceDescVeryEasy => 'รับแทบทุกแบบที่วาด';

  @override
  String get toleranceDescEasy => 'จับคู่แบบหลวม เหมาะสำหรับผู้เริ่มต้น';

  @override
  String get toleranceDescMedium => 'ความยากสมดุล (แนะนำ)';

  @override
  String get toleranceDescHard => 'ต้องการความแม่นยำมากขึ้น';

  @override
  String get toleranceDescVeryHard => 'จับคู่อย่างเข้มงวด';

  @override
  String get toleranceDescExtreme => 'จับคู่เข้มงวดมากสำหรับผู้เชี่ยวชาญ';

  @override
  String get resetProgressTitle => 'รีเซ็ตความก้าวหน้า?';

  @override
  String get resetProgressMessage =>
      'การดำเนินการนี้จะลบความก้าวหน้าทั้งหมดอย่างถาวร รวมถึง:\n\n• สถานะการเรียนจบบท\n• ดาวที่ได้รับ\n• เวลาที่ดีที่สุด\n• ประวัติการฝึก\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get progressResetSuccess => 'รีเซ็ตความก้าวหน้าแล้ว';

  @override
  String get aboutTitle => 'เกี่ยวกับ';

  @override
  String get aboutAppName => 'เขียนลาว';

  @override
  String get aboutAuthor => 'โดย Janet Jeffus';

  @override
  String get aboutCopyright => 'ลิขสิทธิ์ © 2026';

  @override
  String get aboutStory =>
      'หลังจากทำงานเป็นวิศวกรซอฟต์แวร์มากว่ายี่สิบปี ฉันพบว่าตัวเองอยากเรียนภาษาลาว โดยเฉพาะการอ่านและเขียนอักษรลาวที่สวยงาม ฉันไปหาแอปที่จะสอนเขียนตัวอักษรทีละเส้น แบบที่เรียนเขียนในห้องเรียน แต่หาไม่เจอ\n\nเขียนลาว จะพาคุณเรียนรู้พยัญชนะ สระ และวรรณยุกต์ทุกตัวในอักษรลาว ตัวอักษรแต่ละตัวถูกแยกออกเป็นเส้นแต่ละเส้นตามลำดับและทิศทางที่ถูกต้อง คุณลากเส้นบนหน้าจอ แล้วแอปจะบอกว่าถูกหรือไม่ ไม่ต้องเดา ไม่ใช้บัตรคำ แค่ฝึกเขียน\n\nหวังว่าแอปนี้จะช่วยคุณในการเรียนรู้ภาษาลาว เขียนให้สนุกนะ!';

  @override
  String get aboutDedication =>
      'อุทิศด้วยความรักเพื่อการอนุรักษ์ภาษาและวัฒนธรรมลาว';

  @override
  String get done => 'เสร็จ';

  @override
  String get splashTitle => 'เขียนลาว';

  @override
  String get splashSubtitle => 'ลาว';
}
