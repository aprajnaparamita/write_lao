// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'Sumulat ng Lao';

  @override
  String get tabLessons => 'Mga Aralin';

  @override
  String get tabReview => 'Pagsusuri';

  @override
  String get tabProgress => 'Progreso';

  @override
  String lessonNumber(int number) {
    return 'Aralin $number';
  }

  @override
  String get lessonNotFound => 'Hindi nahanap ang aralin';

  @override
  String get lessonLabel => 'Aralin';

  @override
  String get practice => 'Pagsasanay';

  @override
  String get test => 'Pagsusulit';

  @override
  String get content => 'Nilalaman';

  @override
  String get bestTime => 'Pinakamabilis';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Pagsasanay';

  @override
  String get leavePracticeTitle => 'Umalis sa pagsasanay?';

  @override
  String get leavePracticeMessage =>
      'Sigurado ka bang gusto mong umalis sa pagsasanay?';

  @override
  String get continueButton => 'Magpatuloy';

  @override
  String get goBackButton => 'Bumalik';

  @override
  String get traceCharacter => 'Iguhit ang karakter';

  @override
  String get allDone => 'Tapos na lahat! Magaling!';

  @override
  String get moveToNext => 'Magaling! Susunod na karakter';

  @override
  String get clearTooltip => 'Burahin';

  @override
  String get playPronunciation => 'I-play ang pagbigkas';

  @override
  String get hideHint => 'Itago ang hint';

  @override
  String get showHint => 'Ipakita ang hint';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Tapos na ang pagsasanay!';

  @override
  String practiceCompleteMessage(int count) {
    return 'Naisanay mo na ang lahat ng $count na karakter sa araling ito.';
  }

  @override
  String get characters => 'Mga Karakter';

  @override
  String get takeTest => 'Kumuha ng pagsusulit';

  @override
  String get practiceAgain => 'Magsanay muli';

  @override
  String get backToLesson => 'Bumalik sa aralin';

  @override
  String get backToReview => 'Bumalik sa pagsusuri';

  @override
  String get mainMenu => 'Pangunahing menu';

  @override
  String get testTitle => 'Pagsusulit';

  @override
  String get leaveTestTitle => 'Umalis sa pagsusulit?';

  @override
  String get leaveTestMessage =>
      'Sigurado ka bang gusto mong umalis sa pagsusulit?';

  @override
  String get writeFromMemory => 'Isulat ang karakter na ito mula sa alaala';

  @override
  String get resultPerfect => 'Perpekto!';

  @override
  String get resultGreatJob => 'Napakahusay!';

  @override
  String get resultGoodTry => 'Magandang pagsubok!';

  @override
  String get time => 'Oras';

  @override
  String get testAgain => 'Subukan muli';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get lessonsCompleted => 'Natapos na\nmga aralin';

  @override
  String get starsEarned => 'Nakuhang\nmga bituin';

  @override
  String get phaseProgress => 'Progreso bawat yugto';

  @override
  String get phaseConsonants => 'Mga Katinig';

  @override
  String get phaseVowels => 'Mga Patinig';

  @override
  String get phaseToneMarks => 'Mga Marka ng Tono';

  @override
  String get phaseNumerals => 'Mga Numero';

  @override
  String get phaseLigatures => 'Mga Ligatura';

  @override
  String get reviewTitle => 'Pagsusuri';

  @override
  String get weakCharacters => 'Mga mahihinang karakter';

  @override
  String get all => 'Lahat';

  @override
  String phaseN(int number) {
    return 'Yugto $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Sanayin ang napili ($count)';
  }

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get strokeTolerance => 'Toleransya ng guhit';

  @override
  String get toleranceForgiving => 'Maluwag';

  @override
  String get toleranceStrict => 'Mahigpit';

  @override
  String get soundEffects => 'Mga Epekto ng Tunog';

  @override
  String get soundEffectsSubtitle =>
      'Magpatugtog ng tunog para sa tama/maling guhit';

  @override
  String get hapticFeedback => 'Haptic na Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Mag-vibrate sa mga pangyayari ng guhit';

  @override
  String get resetAllProgress => 'I-reset ang lahat ng progreso';

  @override
  String get resetAllProgressSubtitle =>
      'Burahin ang lahat ng progreso at bituin';

  @override
  String get aboutWriteLao => 'Tungkol sa Sumulat ng Lao';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Napakadali';

  @override
  String get toleranceEasy => 'Madali';

  @override
  String get toleranceMedium => 'Katamtaman';

  @override
  String get toleranceHard => 'Mahirap';

  @override
  String get toleranceVeryHard => 'Napakahirap';

  @override
  String get toleranceExtreme => 'Sukdulan';

  @override
  String get toleranceDescVeryEasy => 'Halos anumang guhit ay tatanggapin';

  @override
  String get toleranceDescEasy =>
      'Maluwag na pagtutugma, mabuti para sa mga nagsisimula';

  @override
  String get toleranceDescMedium => 'Balanseng kahirapan (inirerekomenda)';

  @override
  String get toleranceDescHard => 'Kailangan ng mas tumpak na guhit';

  @override
  String get toleranceDescVeryHard => 'Mahigpit na pagtutugma';

  @override
  String get toleranceDescExtreme =>
      'Napakahigpit na pagtutugma para sa mga eksperto';

  @override
  String get resetProgressTitle => 'I-reset ang progreso?';

  @override
  String get resetProgressMessage =>
      'Permanenteng mabubura ang lahat ng iyong progreso, kabilang ang:\n\n• Status ng pagkumpleto ng aralin\n• Mga nakuhang bituin\n• Pinakamabilis na oras\n• Kasaysayan ng pagsasanay\n\nHindi na maibabalik ang aksyong ito.';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get reset => 'I-reset';

  @override
  String get progressResetSuccess => 'Na-reset na ang progreso';

  @override
  String get aboutTitle => 'Tungkol';

  @override
  String get aboutAppName => 'Sumulat ng Lao';

  @override
  String get aboutAuthor => 'ni Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override

  @override

  @override
  String get done => 'Tapos na';

  @override
  String get splashTitle => 'Sumulat ng Lao';

  @override
  String get splashSubtitle => 'Lao';
}
