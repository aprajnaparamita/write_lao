// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ラオス語を書こう';

  @override
  String get tabLessons => 'レッスン';

  @override
  String get tabReview => '復習';

  @override
  String get tabProgress => '進捗';

  @override
  String lessonNumber(int number) {
    return 'レッスン $number';
  }

  @override
  String get lessonNotFound => 'レッスンが見つかりません';

  @override
  String get lessonLabel => 'レッスン';

  @override
  String get practice => '練習';

  @override
  String get test => 'テスト';

  @override
  String get content => '内容';

  @override
  String get bestTime => 'ベストタイム';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => '練習';

  @override
  String get leavePracticeTitle => '練習を終了しますか？';

  @override
  String get leavePracticeMessage => '本当に練習を終了しますか？';

  @override
  String get continueButton => '続ける';

  @override
  String get goBackButton => '戻る';

  @override
  String get traceCharacter => '文字をなぞる';

  @override
  String get allDone => '全部完了！よくできました！';

  @override
  String get moveToNext => 'よくできました！次の文字へ';

  @override
  String get clearTooltip => '消去';

  @override
  String get playPronunciation => '発音を再生';

  @override
  String get hideHint => 'ヒントを隠す';

  @override
  String get showHint => 'ヒントを表示';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => '練習完了！';

  @override
  String practiceCompleteMessage(int count) {
    return 'このレッスンの全 $count 文字を練習しました。';
  }

  @override
  String get characters => '文字';

  @override
  String get takeTest => 'テストを受ける';

  @override
  String get practiceAgain => 'もう一度練習';

  @override
  String get backToLesson => 'レッスンに戻る';

  @override
  String get backToReview => '復習に戻る';

  @override
  String get mainMenu => 'メインメニュー';

  @override
  String get testTitle => 'テスト';

  @override
  String get leaveTestTitle => 'テストを終了しますか？';

  @override
  String get leaveTestMessage => '本当にテストを終了しますか？';

  @override
  String get writeFromMemory => 'この文字を記憶から書いてください';

  @override
  String get resultPerfect => '完璧！';

  @override
  String get resultGreatJob => '素晴らしい！';

  @override
  String get resultGoodTry => 'よく頑張りました！';

  @override
  String get time => '時間';

  @override
  String get testAgain => 'もう一度テスト';

  @override
  String get progressTitle => '進捗';

  @override
  String get lessonsCompleted => '完了した\nレッスン';

  @override
  String get starsEarned => '獲得した\nスター';

  @override
  String get phaseProgress => 'フェーズ別進捗';

  @override
  String get phaseConsonants => '子音';

  @override
  String get phaseVowels => '母音';

  @override
  String get phaseToneMarks => '声調記号';

  @override
  String get phaseNumerals => '数字';

  @override
  String get phaseLigatures => '合字';

  @override
  String get reviewTitle => '復習';

  @override
  String get weakCharacters => '苦手な文字';

  @override
  String get all => 'すべて';

  @override
  String phaseN(int number) {
    return 'フェーズ $number';
  }

  @override
  String practiceSelected(int count) {
    return '選択した文字を練習（$count）';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get strokeTolerance => 'ストローク許容度';

  @override
  String get toleranceForgiving => 'ゆるい';

  @override
  String get toleranceStrict => '厳しい';

  @override
  String get soundEffects => '効果音';

  @override
  String get soundEffectsSubtitle => '正解・不正解時に音を鳴らす';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get hapticFeedbackSubtitle => 'ストロークイベント時に振動';

  @override
  String get resetAllProgress => 'すべての進捗をリセット';

  @override
  String get resetAllProgressSubtitle => 'すべてのレッスン進捗とスターを消去';

  @override
  String get aboutWriteLao => 'ラオス語を書こう について';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'とても簡単';

  @override
  String get toleranceEasy => '簡単';

  @override
  String get toleranceMedium => '普通';

  @override
  String get toleranceHard => '難しい';

  @override
  String get toleranceVeryHard => 'とても難しい';

  @override
  String get toleranceExtreme => '超難しい';

  @override
  String get toleranceDescVeryEasy => 'ほぼどんな線でも受け入れます';

  @override
  String get toleranceDescEasy => 'ゆるいマッチング、初心者向け';

  @override
  String get toleranceDescMedium => 'バランスの取れた難易度（推奨）';

  @override
  String get toleranceDescHard => 'より高い精度が必要';

  @override
  String get toleranceDescVeryHard => '厳密なマッチング';

  @override
  String get toleranceDescExtreme => '上級者向けの非常に厳密なマッチング';

  @override
  String get resetProgressTitle => '進捗をリセットしますか？';

  @override
  String get resetProgressMessage =>
      'すべての進捗が完全に削除されます：\n\n• レッスン完了状況\n• 獲得したスター\n• ベストタイム\n• 練習履歴\n\nこの操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

  @override
  String get progressResetSuccess => '進捗がリセットされました';

  @override
  String get aboutTitle => 'アプリについて';

  @override
  String get aboutAppName => 'ラオス語を書こう';

  @override
  String get aboutAuthor => '作者：Janet Jeffus';

  @override
  String get aboutCopyright => '著作権 © 2026';

  @override
  String get aboutStory =>
      'ソフトウェアエンジニアとして20年以上働いた後、ラオス語を学びたいと思うようになりました。特に、美しいラオス文字の読み書きを学びたいと。教室で学ぶように一画ずつ文字の書き方を教えてくれるアプリを探しましたが、見つかりませんでした。\n\nラオス語を書こう は、ラオス語アルファベットのすべての子音、母音、声調記号を学べるアプリです。各文字は正しい順序と方向で個別のストロークに分解されています。画面上で各ストロークをなぞると、アプリが正しいかどうかを教えてくれます。推測もフラッシュカードも不要、ただ練習するだけです。\n\nこのアプリがラオス語学習の旅のお役に立てれば幸いです。楽しく書きましょう！';

  @override
  String get aboutDedication => 'ラオス語と文化の保存に、愛を込めて捧げます。';

  @override
  String get done => '完了';

  @override
  String get splashTitle => 'ラオス語を書こう';

  @override
  String get splashSubtitle => 'ラオス語';
}
