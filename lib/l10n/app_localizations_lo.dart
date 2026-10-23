// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lao (`lo`).
class AppLocalizationsLo extends AppLocalizations {
  AppLocalizationsLo([String locale = 'lo']) : super(locale);

  @override
  String get appTitle => 'ຂຽນລາວ';

  @override
  String get tabLessons => 'ບົດຮຽນ';

  @override
  String get tabReview => 'ທົບທວນ';

  @override
  String get tabProgress => 'ຄວາມຄືບໜ້າ';

  @override
  String lessonNumber(int number) {
    return 'ບົດຮຽນທີ $number';
  }

  @override
  String get lessonNotFound => 'ບໍ່ພົບບົດຮຽນ';

  @override
  String get lessonLabel => 'ບົດຮຽນ';

  @override
  String get practice => 'ຝຶກຫັດ';

  @override
  String get test => 'ທົດສອບ';

  @override
  String get content => 'ເນື້ອຫາ';

  @override
  String get bestTime => 'ເວລາດີທີ່ສຸດ';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'ຝຶກຫັດ';

  @override
  String get leavePracticeTitle => 'ອອກຈາກການຝຶກ?';

  @override
  String get leavePracticeMessage => 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກການຝຶກ?';

  @override
  String get continueButton => 'ດຳເນີນຕໍ່';

  @override
  String get goBackButton => 'ກັບຄືນ';

  @override
  String get traceCharacter => 'ຕາມຮອຍຕົວອັກສອນ';

  @override
  String get allDone => 'ສຳເລັດທັງໝົດ! ເກັ່ງຫຼາຍ!';

  @override
  String get moveToNext => 'ເກັ່ງຫຼາຍ! ໄປຕົວອັກສອນຕໍ່ໄປ';

  @override
  String get clearTooltip => 'ລ້າງ';

  @override
  String get playPronunciation => 'ຟັງການອ່ານ';

  @override
  String get hideHint => 'ເຊື່ອງຄຳໃບ້';

  @override
  String get showHint => 'ສະແດງຄຳໃບ້';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'ຝຶກຫັດສຳເລັດ!';

  @override
  String practiceCompleteMessage(int count) {
    return 'ທ່ານໄດ້ຝຶກ $count ຕົວອັກສອນໃນບົດຮຽນນີ້ທັງໝົດ.';
  }

  @override
  String get characters => 'ຕົວອັກສອນ';

  @override
  String get takeTest => 'ທົດສອບ';

  @override
  String get practiceAgain => 'ຝຶກໃໝ່ອີກ';

  @override
  String get backToLesson => 'ກັບໄປບົດຮຽນ';

  @override
  String get backToReview => 'ກັບໄປທົບທວນ';

  @override
  String get mainMenu => 'ເມນູຫຼັກ';

  @override
  String get testTitle => 'ທົດສອບ';

  @override
  String get leaveTestTitle => 'ອອກຈາກການທົດສອບ?';

  @override
  String get leaveTestMessage => 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກການທົດສອບ?';

  @override
  String get writeFromMemory => 'ຂຽນຕົວອັກສອນນີ້ຈາກຄວາມຈຳ';

  @override
  String get resultPerfect => 'ສົມບູນແບບ!';

  @override
  String get resultGreatJob => 'ເກັ່ງຫຼາຍ!';

  @override
  String get resultGoodTry => 'ດີ! ພະຍາຍາມດີ!';

  @override
  String get time => 'ເວລາ';

  @override
  String get testAgain => 'ທົດສອບໃໝ່';

  @override
  String get progressTitle => 'ຄວາມຄືບໜ້າ';

  @override
  String get lessonsCompleted => 'ບົດຮຽນ\nສຳເລັດ';

  @override
  String get starsEarned => 'ດາວ\nທີ່ໄດ້';

  @override
  String get phaseProgress => 'ຄວາມຄືບໜ້າຂອງໄລຍະ';

  @override
  String get phaseConsonants => 'ພະຍັນຊະນະ';

  @override
  String get phaseVowels => 'ສະຫຼະ';

  @override
  String get phaseToneMarks => 'ວັນນະຍຸດ';

  @override
  String get phaseNumerals => 'ຕົວເລກ';

  @override
  String get phaseLigatures => 'ຕົວຜ່ຽນ';

  @override
  String get reviewTitle => 'ທົບທວນ';

  @override
  String get weakCharacters => 'ຕົວອັກສອນທີ່ຍັງອ່ອນ';

  @override
  String get all => 'ທັງໝົດ';

  @override
  String phaseN(int number) {
    return 'ໄລຍະທີ $number';
  }

  @override
  String practiceSelected(int count) {
    return 'ຝຶກທີ່ເລືອກ ($count)';
  }

  @override
  String get settingsTitle => 'ການຕັ້ງຄ່າ';

  @override
  String get strokeTolerance => 'ຄວາມຍືດຫຍຸ່ນຂອງເສັ້ນ';

  @override
  String get toleranceForgiving => 'ຜ່ອນຜັນ';

  @override
  String get toleranceStrict => 'ເຂັ້ມງວດ';

  @override
  String get soundEffects => 'ສຽງ';

  @override
  String get soundEffectsSubtitle => 'ສຽງສຳລັບເສັ້ນຖືກ/ຜິດ';

  @override
  String get hapticFeedback => 'ການສັ່ນ';

  @override
  String get hapticFeedbackSubtitle => 'ສັ່ນເມື່ອຂຽນເສັ້ນ';

  @override
  String get resetAllProgress => 'ຣີເຊັດຄວາມຄືບໜ້າທັງໝົດ';

  @override
  String get resetAllProgressSubtitle => 'ລ້າງຄວາມຄືບໜ້າ ແລະ ດາວທັງໝົດ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Conditions for using the app';

  @override
  String get aboutWriteLao => 'ກ່ຽວກັບ ຂຽນລາວ';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'ງ່າຍຫຼາຍ';

  @override
  String get toleranceEasy => 'ງ່າຍ';

  @override
  String get toleranceMedium => 'ປານກາງ';

  @override
  String get toleranceHard => 'ຍາກ';

  @override
  String get toleranceVeryHard => 'ຍາກຫຼາຍ';

  @override
  String get toleranceExtreme => 'ຍາກສຸດໆ';

  @override
  String get toleranceDescVeryEasy => 'ຮອງຮັບການຂຽນຮູບແບບໃດກໍໄດ້';

  @override
  String get toleranceDescEasy => 'ກົງກັນແບບຜ່ອນຜັນ ເໝາະສຳລັບຜູ້ເລີ່ມຕົ້ນ';

  @override
  String get toleranceDescMedium => 'ລະດັບຄວາມຍາກທີ່ສົມດູນ (ແນະນຳ)';

  @override
  String get toleranceDescHard => 'ຕ້ອງການຄວາມຖືກຕ້ອງສູງ';

  @override
  String get toleranceDescVeryHard => 'ກົງກັນເຂັ້ມງວດ';

  @override
  String get toleranceDescExtreme => 'ກົງກັນເຂັ້ມງວດຫຼາຍ ສຳລັບຜູ້ຊ່ຽວຊານ';

  @override
  String get resetProgressTitle => 'ຣີເຊັດຄວາມຄືບໜ້າ?';

  @override
  String get resetProgressMessage =>
      'ນີ້ຈະລຶບຄວາມຄືບໜ້າທັງໝົດຂອງທ່ານຢ່າງຖາວອນ, ລວມທັງ:\n\n• ສະຖານະການສຳເລັດບົດຮຽນ\n• ດາວທີ່ໄດ້ຮັບ\n• ເວລາດີທີ່ສຸດ\n• ປະຫວັດການຝຶກ\n\nການດຳເນີນການນີ້ບໍ່ສາມາດຍົກເລີກໄດ້.';

  @override
  String get cancel => 'ຍົກເລີກ';

  @override
  String get reset => 'ຣີເຊັດ';

  @override
  String get progressResetSuccess => 'ຣີເຊັດຄວາມຄືບໜ້າສຳເລັດ';

  @override
  String get aboutTitle => 'ກ່ຽວກັບ';

  @override
  String get aboutAppName => 'ຂຽນລາວ';

  @override
  String get aboutAuthor => 'ໂດຍ Janet Jeffus';

  @override
  String get aboutCopyright => 'ລິຂະສິດ © 2026';

  @override
  String get aboutStory =>
      'ຫຼັງຈາກເຮັດວຽກເປັນວິສະວະກອນຊອຟແວຫຼາຍກ່ວາຊາວປີ, ຂ້ອຍຢາກຮຽນພາສາລາວ — ໂດຍສະເພາະ ການອ່ານ ແລະ ຂຽນຕົວອັກສອນລາວທີ່ສວຍງາມ. ຂ້ອຍໄປຊອກຫາແອັບທີ່ຈະສອນຂ້ອຍຂຽນຕົວອັກສອນທີ່ລະເສັ້ນ, ຄືກັບການຮຽນຂຽນໃນຫ້ອງຮຽນ. ຂ້ອຍຊອກຫາບໍ່ພົບ.\n\nຂຽນລາວ ນຳພາທ່ານຜ່ານພະຍັນຊະນະ, ສະຫຼະ ແລະ ວັນນະຍຸດທຸກໂຕໃນຕົວໜັງສືລາວ. ຕົວອັກສອນແຕ່ລະໂຕຖືກແຍກອອກເປັນເສັ້ນທີ່ຖືກຕ້ອງຕາມລຳດັບ ແລະ ທິດທາງ. ທ່ານລາກເສັ້ນຢູ່ໜ້າຈໍ ແລ້ວແອັບຈະບອກທ່ານວ່າຖືກ ຫຼື ຜິດ — ບໍ່ຕ້ອງເດົາ, ບໍ່ຕ້ອງໃຊ້ບັດ, ພຽງຝຶກຊ້ອມ.\n\nຂ້ອຍຫວັງວ່າແອັບນີ້ຈະຊ່ວຍທ່ານໃນການຮຽນພາສາລາວ. ສຸກໃຈຂຽນ!';

  @override
  String get aboutDedication =>
      'ອຸທິດດ້ວຍຄວາມຮັກ ເພື່ອການອານຸລັກ ແລະ ສົງວນພາສາ ແລະ ວັດທະນະທຳລາວ.';

  @override
  String get done => 'ສຳເລັດ';

  @override
  String get splashTitle => 'ຂຽນລາວ';

  @override
  String get splashSubtitle => 'ລາວ';
}
