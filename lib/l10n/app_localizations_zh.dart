// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '写老挝文';

  @override
  String get tabLessons => '课程';

  @override
  String get tabReview => '复习';

  @override
  String get tabProgress => '进度';

  @override
  String lessonNumber(int number) {
    return '第$number课';
  }

  @override
  String get lessonNotFound => '未找到课程';

  @override
  String get lessonLabel => '课程';

  @override
  String get practice => '练习';

  @override
  String get test => '测试';

  @override
  String get content => '内容';

  @override
  String get bestTime => '最佳时间';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => '练习';

  @override
  String get leavePracticeTitle => '退出练习？';

  @override
  String get leavePracticeMessage => '确定要退出练习吗？';

  @override
  String get continueButton => '继续';

  @override
  String get goBackButton => '返回';

  @override
  String get traceCharacter => '描摹字符';

  @override
  String get allDone => '全部完成！做得好！';

  @override
  String get moveToNext => '做得好！进入下一个字符';

  @override
  String get clearTooltip => '清除';

  @override
  String get playPronunciation => '播放发音';

  @override
  String get hideHint => '隐藏提示';

  @override
  String get showHint => '显示提示';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => '练习完成！';

  @override
  String practiceCompleteMessage(int count) {
    return '你已练习了本课全部$count个字符。';
  }

  @override
  String get characters => '字符';

  @override
  String get takeTest => '开始测试';

  @override
  String get practiceAgain => '再次练习';

  @override
  String get backToLesson => '返回课程';

  @override
  String get backToReview => '返回复习';

  @override
  String get mainMenu => '主菜单';

  @override
  String get testTitle => '测试';

  @override
  String get leaveTestTitle => '退出测试？';

  @override
  String get leaveTestMessage => '确定要退出测试吗？';

  @override
  String get writeFromMemory => '凭记忆书写此字符';

  @override
  String get resultPerfect => '完美！';

  @override
  String get resultGreatJob => '非常好！';

  @override
  String get resultGoodTry => '继续加油！';

  @override
  String get time => '时间';

  @override
  String get testAgain => '再次测试';

  @override
  String get progressTitle => '进度';

  @override
  String get lessonsCompleted => '已完成\n课程';

  @override
  String get starsEarned => '已获得\n星星';

  @override
  String get phaseProgress => '各阶段进度';

  @override
  String get phaseConsonants => '辅音';

  @override
  String get phaseVowels => '元音';

  @override
  String get phaseToneMarks => '声调符号';

  @override
  String get phaseNumerals => '数字';

  @override
  String get phaseLigatures => '连字';

  @override
  String get reviewTitle => '复习';

  @override
  String get weakCharacters => '薄弱字符';

  @override
  String get all => '全部';

  @override
  String phaseN(int number) {
    return '第$number阶段';
  }

  @override
  String practiceSelected(int count) {
    return '练习已选（$count）';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get strokeTolerance => '笔画容差';

  @override
  String get toleranceForgiving => '宽松';

  @override
  String get toleranceStrict => '严格';

  @override
  String get soundEffects => '音效';

  @override
  String get soundEffectsSubtitle => '笔画正确或错误时播放音效';

  @override
  String get hapticFeedback => '触觉反馈';

  @override
  String get hapticFeedbackSubtitle => '笔画事件时振动';

  @override
  String get resetAllProgress => '重置所有进度';

  @override
  String get resetAllProgressSubtitle => '清除所有课程进度和星星';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Conditions for using the app';

  @override
  String get aboutWriteLao => '关于 写老挝文';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => '非常简单';

  @override
  String get toleranceEasy => '简单';

  @override
  String get toleranceMedium => '中等';

  @override
  String get toleranceHard => '困难';

  @override
  String get toleranceVeryHard => '非常困难';

  @override
  String get toleranceExtreme => '极难';

  @override
  String get toleranceDescVeryEasy => '几乎任何书写都会被接受';

  @override
  String get toleranceDescEasy => '宽松匹配，适合初学者';

  @override
  String get toleranceDescMedium => '难度均衡（推荐）';

  @override
  String get toleranceDescHard => '需要更高精度';

  @override
  String get toleranceDescVeryHard => '严格匹配';

  @override
  String get toleranceDescExtreme => '专家级极严格匹配';

  @override
  String get resetProgressTitle => '重置进度？';

  @override
  String get resetProgressMessage =>
      '此操作将永久删除您的所有进度，包括：\n\n• 课程完成状态\n• 已获得的星星\n• 最佳时间\n• 练习记录\n\n此操作不可撤销。';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get progressResetSuccess => '进度已重置';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutAppName => '写老挝文';

  @override
  String get aboutAuthor => '作者：Janet Jeffus';

  @override
  String get aboutCopyright => '版权所有 © 2026';

  @override
  String get aboutStory =>
      '在从事软件工程师工作二十余年后，我发现自己想要学习老挝语——特别是学习阅读和书写优美的老挝文字。我寻找一款能够逐笔教我书写字符的应用，就像在课堂上学习书写一样，但始终未能找到。\n\n写老挝文 将引导你学习老挝字母表中的每一个辅音、元音和声调符号。每个字符都被分解为单独的笔画，并按正确的顺序和方向排列。你在屏幕上描摹每一笔，应用会告诉你是否正确——无需猜测，没有闪卡，只有练习。\n\n希望这款应用能帮助你踏上学习老挝语的旅程。祝你书写愉快！';

  @override
  String get aboutDedication => '深情地献给老挝语言和文化的传承与保护。';

  @override
  String get done => '完成';

  @override
  String get splashTitle => '写老挝文';

  @override
  String get splashSubtitle => '老挝语';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '寫老撾文';

  @override
  String get tabLessons => '課程';

  @override
  String get tabReview => '複習';

  @override
  String get tabProgress => '進度';

  @override
  String lessonNumber(int number) {
    return '第$number課';
  }

  @override
  String get lessonNotFound => '未找到課程';

  @override
  String get lessonLabel => '課程';

  @override
  String get practice => '練習';

  @override
  String get test => '測試';

  @override
  String get content => '內容';

  @override
  String get bestTime => '最佳時間';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => '練習';

  @override
  String get leavePracticeTitle => '退出練習？';

  @override
  String get leavePracticeMessage => '確定要退出練習嗎？';

  @override
  String get continueButton => '繼續';

  @override
  String get goBackButton => '返回';

  @override
  String get traceCharacter => '描摹字符';

  @override
  String get allDone => '全部完成！做得好！';

  @override
  String get moveToNext => '做得好！進入下一個字符';

  @override
  String get clearTooltip => '清除';

  @override
  String get playPronunciation => '播放發音';

  @override
  String get hideHint => '隱藏提示';

  @override
  String get showHint => '顯示提示';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => '練習完成！';

  @override
  String practiceCompleteMessage(int count) {
    return '你已練習了本課全部$count個字符。';
  }

  @override
  String get characters => '字符';

  @override
  String get takeTest => '開始測試';

  @override
  String get practiceAgain => '再次練習';

  @override
  String get backToLesson => '返回課程';

  @override
  String get backToReview => '返回複習';

  @override
  String get mainMenu => '主選單';

  @override
  String get testTitle => '測試';

  @override
  String get leaveTestTitle => '退出測試？';

  @override
  String get leaveTestMessage => '確定要退出測試嗎？';

  @override
  String get writeFromMemory => '憑記憶書寫此字符';

  @override
  String get resultPerfect => '完美！';

  @override
  String get resultGreatJob => '非常好！';

  @override
  String get resultGoodTry => '繼續加油！';

  @override
  String get time => '時間';

  @override
  String get testAgain => '再次測試';

  @override
  String get progressTitle => '進度';

  @override
  String get lessonsCompleted => '已完成\n課程';

  @override
  String get starsEarned => '已獲得\n星星';

  @override
  String get phaseProgress => '各階段進度';

  @override
  String get phaseConsonants => '輔音';

  @override
  String get phaseVowels => '元音';

  @override
  String get phaseToneMarks => '聲調符號';

  @override
  String get phaseNumerals => '數字';

  @override
  String get phaseLigatures => '連字';

  @override
  String get reviewTitle => '複習';

  @override
  String get weakCharacters => '薄弱字符';

  @override
  String get all => '全部';

  @override
  String phaseN(int number) {
    return '第$number階段';
  }

  @override
  String practiceSelected(int count) {
    return '練習已選（$count）';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get strokeTolerance => '筆畫容差';

  @override
  String get toleranceForgiving => '寬鬆';

  @override
  String get toleranceStrict => '嚴格';

  @override
  String get soundEffects => '音效';

  @override
  String get soundEffectsSubtitle => '筆畫正確或錯誤時播放音效';

  @override
  String get hapticFeedback => '觸覺回饋';

  @override
  String get hapticFeedbackSubtitle => '筆畫事件時震動';

  @override
  String get resetAllProgress => '重置所有進度';

  @override
  String get resetAllProgressSubtitle => '清除所有課程進度和星星';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Conditions for using the app';

  @override
  String get aboutWriteLao => '關於 寫老撾文';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => '非常簡單';

  @override
  String get toleranceEasy => '簡單';

  @override
  String get toleranceMedium => '中等';

  @override
  String get toleranceHard => '困難';

  @override
  String get toleranceVeryHard => '非常困難';

  @override
  String get toleranceExtreme => '極難';

  @override
  String get toleranceDescVeryEasy => '幾乎任何書寫都會被接受';

  @override
  String get toleranceDescEasy => '寬鬆匹配，適合初學者';

  @override
  String get toleranceDescMedium => '難度均衡（推薦）';

  @override
  String get toleranceDescHard => '需要更高精度';

  @override
  String get toleranceDescVeryHard => '嚴格匹配';

  @override
  String get toleranceDescExtreme => '專家級極嚴格匹配';

  @override
  String get resetProgressTitle => '重置進度？';

  @override
  String get resetProgressMessage =>
      '此操作將永久刪除您的所有進度，包括：\n\n• 課程完成狀態\n• 已獲得的星星\n• 最佳時間\n• 練習記錄\n\n此操作不可撤銷。';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get progressResetSuccess => '進度已重置';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutAppName => '寫老撾文';

  @override
  String get aboutAuthor => '作者：Janet Jeffus';

  @override
  String get aboutCopyright => '版權所有 © 2026';

  @override
  String get aboutStory =>
      '在從事軟體工程師工作二十餘年後，我發現自己想要學習老撾語——特別是學習閱讀和書寫優美的老撾文字。我尋找一款能夠逐筆教我書寫字符的應用，就像在課堂上學習書寫一樣，但始終未能找到。\n\n寫老撾文 將引導你學習老撾字母表中的每一個輔音、元音和聲調符號。每個字符都被分解為單獨的筆畫，並按正確的順序和方向排列。你在螢幕上描摹每一筆，應用會告訴你是否正確——無需猜測，沒有閃卡，只有練習。\n\n希望這款應用能幫助你踏上學習老撾語的旅程。祝你書寫愉快！';

  @override
  String get aboutDedication => '深情地獻給老撾語言和文化的傳承與保護。';

  @override
  String get done => '完成';

  @override
  String get splashTitle => '寫老撾文';

  @override
  String get splashSubtitle => '老撾語';
}
