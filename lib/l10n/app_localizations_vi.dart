// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Viết Lào';

  @override
  String get tabLessons => 'Bài học';

  @override
  String get tabReview => 'Ôn tập';

  @override
  String get tabProgress => 'Tiến độ';

  @override
  String lessonNumber(int number) {
    return 'Bài $number';
  }

  @override
  String get lessonNotFound => 'Không tìm thấy bài học';

  @override
  String get lessonLabel => 'Bài học';

  @override
  String get practice => 'Luyện tập';

  @override
  String get test => 'Kiểm tra';

  @override
  String get content => 'Nội dung';

  @override
  String get bestTime => 'Thời gian tốt nhất';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Luyện tập';

  @override
  String get leavePracticeTitle => 'Rời luyện tập?';

  @override
  String get leavePracticeMessage =>
      'Bạn có chắc muốn rời khỏi phần luyện tập không?';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get goBackButton => 'Quay lại';

  @override
  String get traceCharacter => 'Tô theo ký tự';

  @override
  String get allDone => 'Hoàn tất! Giỏi lắm!';

  @override
  String get moveToNext => 'Giỏi lắm! Chuyển sang ký tự tiếp theo';

  @override
  String get clearTooltip => 'Xóa';

  @override
  String get playPronunciation => 'Phát âm';

  @override
  String get hideHint => 'Ẩn gợi ý';

  @override
  String get showHint => 'Hiện gợi ý';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Hoàn thành luyện tập!';

  @override
  String practiceCompleteMessage(int count) {
    return 'Bạn đã luyện tập tất cả $count ký tự trong bài này.';
  }

  @override
  String get characters => 'Ký tự';

  @override
  String get takeTest => 'Làm bài kiểm tra';

  @override
  String get practiceAgain => 'Luyện tập lại';

  @override
  String get backToLesson => 'Quay lại bài học';

  @override
  String get backToReview => 'Quay lại ôn tập';

  @override
  String get mainMenu => 'Menu chính';

  @override
  String get testTitle => 'Kiểm tra';

  @override
  String get leaveTestTitle => 'Rời kiểm tra?';

  @override
  String get leaveTestMessage =>
      'Bạn có chắc muốn rời khỏi bài kiểm tra không?';

  @override
  String get writeFromMemory => 'Viết ký tự này từ trí nhớ';

  @override
  String get resultPerfect => 'Hoàn hảo!';

  @override
  String get resultGreatJob => 'Xuất sắc!';

  @override
  String get resultGoodTry => 'Cố gắng tốt!';

  @override
  String get time => 'Thời gian';

  @override
  String get testAgain => 'Kiểm tra lại';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get lessonsCompleted => 'Bài học\nđã hoàn thành';

  @override
  String get starsEarned => 'Sao\nđã đạt';

  @override
  String get phaseProgress => 'Tiến độ từng giai đoạn';

  @override
  String get phaseConsonants => 'Phụ âm';

  @override
  String get phaseVowels => 'Nguyên âm';

  @override
  String get phaseToneMarks => 'Dấu thanh';

  @override
  String get phaseNumerals => 'Chữ số';

  @override
  String get phaseLigatures => 'Chữ ghép';

  @override
  String get reviewTitle => 'Ôn tập';

  @override
  String get weakCharacters => 'Ký tự yếu';

  @override
  String get all => 'Tất cả';

  @override
  String phaseN(int number) {
    return 'Giai đoạn $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Luyện tập đã chọn ($count)';
  }

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get strokeTolerance => 'Dung sai nét';

  @override
  String get toleranceForgiving => 'Dễ dãi';

  @override
  String get toleranceStrict => 'Nghiêm ngặt';

  @override
  String get soundEffects => 'Hiệu ứng âm thanh';

  @override
  String get soundEffectsSubtitle => 'Phát âm khi nét đúng/sai';

  @override
  String get hapticFeedback => 'Phản hồi rung';

  @override
  String get hapticFeedbackSubtitle => 'Rung khi có sự kiện nét';

  @override
  String get resetAllProgress => 'Đặt lại toàn bộ tiến độ';

  @override
  String get resetAllProgressSubtitle => 'Xóa tất cả tiến độ bài học và sao';

  @override
  String get aboutWriteLao => 'Về Viết Lào';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Rất dễ';

  @override
  String get toleranceEasy => 'Dễ';

  @override
  String get toleranceMedium => 'Trung bình';

  @override
  String get toleranceHard => 'Khó';

  @override
  String get toleranceVeryHard => 'Rất khó';

  @override
  String get toleranceExtreme => 'Cực khó';

  @override
  String get toleranceDescVeryEasy => 'Hầu như mọi nét vẽ đều được chấp nhận';

  @override
  String get toleranceDescEasy => 'Khớp lỏng, phù hợp cho người mới bắt đầu';

  @override
  String get toleranceDescMedium => 'Độ khó cân bằng (khuyến nghị)';

  @override
  String get toleranceDescHard => 'Yêu cầu độ chính xác cao hơn';

  @override
  String get toleranceDescVeryHard => 'Khớp nghiêm ngặt';

  @override
  String get toleranceDescExtreme => 'Khớp cực kỳ nghiêm ngặt cho chuyên gia';

  @override
  String get resetProgressTitle => 'Đặt lại tiến độ?';

  @override
  String get resetProgressMessage =>
      'Thao tác này sẽ xóa vĩnh viễn toàn bộ tiến độ của bạn, bao gồm:\n\n• Trạng thái hoàn thành bài học\n• Sao đã đạt\n• Thời gian tốt nhất\n• Lịch sử luyện tập\n\nThao tác này không thể hoàn tác.';

  @override
  String get cancel => 'Hủy';

  @override
  String get reset => 'Đặt lại';

  @override
  String get progressResetSuccess => 'Tiến độ đã được đặt lại';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutAppName => 'Viết Lào';

  @override
  String get aboutAuthor => 'Tác giả: Janet Jeffus';

  @override
  String get aboutCopyright => 'Bản quyền © 2026';

  @override
  String get aboutStory =>
      'Sau hơn hai mươi năm làm kỹ sư phần mềm, tôi thấy mình muốn học tiếng Lào — đặc biệt là cách đọc và viết chữ Lào tuyệt đẹp. Tôi tìm kiếm một ứng dụng có thể dạy tôi viết từng ký tự theo từng nét, giống như cách học viết trong lớp học. Tôi không tìm thấy ứng dụng nào như vậy.\n\nViết Lào hướng dẫn bạn qua từng phụ âm, nguyên âm và dấu thanh trong bảng chữ cái Lào. Mỗi ký tự được chia thành các nét riêng lẻ với thứ tự và hướng chính xác. Bạn tô từng nét trên màn hình, và ứng dụng cho bạn biết bạn viết đúng hay sai — không cần đoán, không dùng thẻ ghi nhớ, chỉ luyện tập.\n\nTôi hy vọng ứng dụng này sẽ giúp bạn trên hành trình học tiếng Lào. Chúc bạn viết vui vẻ!';

  @override
  String get aboutDedication =>
      'Tận tâm dành riêng cho việc bảo tồn ngôn ngữ và văn hóa Lào.';

  @override
  String get done => 'Xong';

  @override
  String get splashTitle => 'Viết Lào';

  @override
  String get splashSubtitle => 'Lào';
}
