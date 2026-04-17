// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '라오어 쓰기';

  @override
  String get tabLessons => '수업';

  @override
  String get tabReview => '복습';

  @override
  String get tabProgress => '진도';

  @override
  String lessonNumber(int number) {
    return '$number과';
  }

  @override
  String get lessonNotFound => '수업을 찾을 수 없습니다';

  @override
  String get lessonLabel => '수업';

  @override
  String get practice => '연습';

  @override
  String get test => '시험';

  @override
  String get content => '내용';

  @override
  String get bestTime => '최고 기록';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => '연습';

  @override
  String get leavePracticeTitle => '연습을 그만두시겠습니까?';

  @override
  String get leavePracticeMessage => '정말로 연습을 그만두시겠습니까?';

  @override
  String get continueButton => '계속하기';

  @override
  String get goBackButton => '돌아가기';

  @override
  String get traceCharacter => '글자를 따라 쓰세요';

  @override
  String get allDone => '모두 완료! 잘하셨습니다!';

  @override
  String get moveToNext => '잘하셨습니다! 다음 글자로 이동';

  @override
  String get clearTooltip => '지우기';

  @override
  String get playPronunciation => '발음 재생';

  @override
  String get hideHint => '힌트 숨기기';

  @override
  String get showHint => '힌트 보기';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => '연습 완료!';

  @override
  String practiceCompleteMessage(int count) {
    return '이 수업의 글자 $count개를 모두 연습했습니다.';
  }

  @override
  String get characters => '글자';

  @override
  String get takeTest => '시험 보기';

  @override
  String get practiceAgain => '다시 연습';

  @override
  String get backToLesson => '수업으로 돌아가기';

  @override
  String get backToReview => '복습으로 돌아가기';

  @override
  String get mainMenu => '메인 메뉴';

  @override
  String get testTitle => '시험';

  @override
  String get leaveTestTitle => '시험을 그만두시겠습니까?';

  @override
  String get leaveTestMessage => '정말로 시험을 그만두시겠습니까?';

  @override
  String get writeFromMemory => '이 글자를 기억해서 쓰세요';

  @override
  String get resultPerfect => '완벽!';

  @override
  String get resultGreatJob => '훌륭합니다!';

  @override
  String get resultGoodTry => '잘 했어요!';

  @override
  String get time => '시간';

  @override
  String get testAgain => '다시 시험';

  @override
  String get progressTitle => '진도';

  @override
  String get lessonsCompleted => '완료한\n수업';

  @override
  String get starsEarned => '획득한\n별';

  @override
  String get phaseProgress => '단계별 진도';

  @override
  String get phaseConsonants => '자음';

  @override
  String get phaseVowels => '모음';

  @override
  String get phaseToneMarks => '성조 부호';

  @override
  String get phaseNumerals => '숫자';

  @override
  String get phaseLigatures => '합자';

  @override
  String get reviewTitle => '복습';

  @override
  String get weakCharacters => '약한 글자';

  @override
  String get all => '전체';

  @override
  String phaseN(int number) {
    return '$number단계';
  }

  @override
  String practiceSelected(int count) {
    return '선택 항목 연습 ($count)';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get strokeTolerance => '획 허용 오차';

  @override
  String get toleranceForgiving => '관대';

  @override
  String get toleranceStrict => '엄격';

  @override
  String get soundEffects => '효과음';

  @override
  String get soundEffectsSubtitle => '정답/오답 시 소리 재생';

  @override
  String get hapticFeedback => '햅틱 피드백';

  @override
  String get hapticFeedbackSubtitle => '획 이벤트 시 진동';

  @override
  String get resetAllProgress => '모든 진도 초기화';

  @override
  String get resetAllProgressSubtitle => '모든 수업 진도와 별 삭제';

  @override
  String get aboutWriteLao => '라오어 쓰기 정보';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => '매우 쉬움';

  @override
  String get toleranceEasy => '쉬움';

  @override
  String get toleranceMedium => '보통';

  @override
  String get toleranceHard => '어려움';

  @override
  String get toleranceVeryHard => '매우 어려움';

  @override
  String get toleranceExtreme => '최고 난이도';

  @override
  String get toleranceDescVeryEasy => '거의 모든 획이 허용됩니다';

  @override
  String get toleranceDescEasy => '느슨한 매칭, 초보자에게 적합';

  @override
  String get toleranceDescMedium => '균형 잡힌 난이도 (권장)';

  @override
  String get toleranceDescHard => '더 높은 정확도 필요';

  @override
  String get toleranceDescVeryHard => '엄격한 매칭';

  @override
  String get toleranceDescExtreme => '전문가를 위한 매우 엄격한 매칭';

  @override
  String get resetProgressTitle => '진도를 초기화하시겠습니까?';

  @override
  String get resetProgressMessage =>
      '모든 진도가 영구적으로 삭제됩니다:\n\n• 수업 완료 상태\n• 획득한 별\n• 최고 기록\n• 연습 기록\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get reset => '초기화';

  @override
  String get progressResetSuccess => '진도가 초기화되었습니다';

  @override
  String get aboutTitle => '앱 정보';

  @override
  String get aboutAppName => '라오어 쓰기';

  @override
  String get aboutAuthor => '제작: Janet Jeffus';

  @override
  String get aboutCopyright => '저작권 © 2026';

  @override
  String get aboutStory =>
      '20년 넘게 소프트웨어 엔지니어로 일한 후, 라오어를 배우고 싶다는 마음이 생겼습니다. 특히 아름다운 라오 문자를 읽고 쓰는 법을 배우고 싶었습니다. 교실에서 배우듯이 한 획씩 글자 쓰는 법을 알려주는 앱을 찾아보았지만 찾을 수 없었습니다.\n\n그래서 직접 만들기로 했습니다.\n\n라오어 쓰기는 라오 알파벳의 모든 자음, 모음, 성조 부호를 안내합니다. 각 글자는 올바른 순서와 방향으로 개별 획으로 분해됩니다. 화면에서 각 획을 따라 쓰면 앱이 맞았는지 알려줍니다. 추측도, 플래시카드도 없이 오직 연습뿐입니다.\n\n이 앱이 라오어를 배우는 여러분의 여정에 도움이 되길 바랍니다. 즐겁게 써보세요!';

  @override
  String get done => '완료';

  @override
  String get splashTitle => '라오어 쓰기';

  @override
  String get splashSubtitle => '라오어';
}
