// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Escrever Lao';

  @override
  String get tabLessons => 'Lições';

  @override
  String get tabReview => 'Revisão';

  @override
  String get tabProgress => 'Progresso';

  @override
  String lessonNumber(int number) {
    return 'Lição $number';
  }

  @override
  String get lessonNotFound => 'Lição não encontrada';

  @override
  String get lessonLabel => 'Lição';

  @override
  String get practice => 'Praticar';

  @override
  String get test => 'Teste';

  @override
  String get content => 'Conteúdo';

  @override
  String get bestTime => 'Melhor tempo';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Prática';

  @override
  String get leavePracticeTitle => 'Sair da prática?';

  @override
  String get leavePracticeMessage =>
      'Tem certeza de que deseja sair da prática?';

  @override
  String get continueButton => 'Continuar';

  @override
  String get goBackButton => 'Voltar';

  @override
  String get traceCharacter => 'Trace o caractere';

  @override
  String get allDone => 'Tudo pronto! Muito bem!';

  @override
  String get moveToNext => 'Muito bem! Próximo caractere';

  @override
  String get clearTooltip => 'Limpar';

  @override
  String get playPronunciation => 'Reproduzir pronúncia';

  @override
  String get hideHint => 'Ocultar dica';

  @override
  String get showHint => 'Mostrar dica';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Prática concluída!';

  @override
  String practiceCompleteMessage(int count) {
    return 'Você praticou todos os $count caracteres desta lição.';
  }

  @override
  String get characters => 'Caracteres';

  @override
  String get takeTest => 'Fazer teste';

  @override
  String get practiceAgain => 'Praticar novamente';

  @override
  String get backToLesson => 'Voltar à lição';

  @override
  String get backToReview => 'Voltar à revisão';

  @override
  String get mainMenu => 'Menu principal';

  @override
  String get testTitle => 'Teste';

  @override
  String get leaveTestTitle => 'Sair do teste?';

  @override
  String get leaveTestMessage => 'Tem certeza de que deseja sair do teste?';

  @override
  String get writeFromMemory => 'Escreva este caractere de memória';

  @override
  String get resultPerfect => 'Perfeito!';

  @override
  String get resultGreatJob => 'Excelente!';

  @override
  String get resultGoodTry => 'Boa tentativa!';

  @override
  String get time => 'Tempo';

  @override
  String get testAgain => 'Refazer teste';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get lessonsCompleted => 'Lições\nconcluídas';

  @override
  String get starsEarned => 'Estrelas\nobtidas';

  @override
  String get phaseProgress => 'Progresso por fase';

  @override
  String get phaseConsonants => 'Consoantes';

  @override
  String get phaseVowels => 'Vogais';

  @override
  String get phaseToneMarks => 'Marcas tonais';

  @override
  String get phaseNumerals => 'Numerais';

  @override
  String get phaseLigatures => 'Ligaduras';

  @override
  String get reviewTitle => 'Revisão';

  @override
  String get weakCharacters => 'Caracteres fracos';

  @override
  String get all => 'Todos';

  @override
  String phaseN(int number) {
    return 'Fase $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Praticar seleção ($count)';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get strokeTolerance => 'Tolerância do traço';

  @override
  String get toleranceForgiving => 'Tolerante';

  @override
  String get toleranceStrict => 'Rigoroso';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get soundEffectsSubtitle =>
      'Reproduzir sons para traços corretos/incorretos';

  @override
  String get hapticFeedback => 'Feedback háptico';

  @override
  String get hapticFeedbackSubtitle => 'Vibrar em eventos de traço';

  @override
  String get resetAllProgress => 'Redefinir todo o progresso';

  @override
  String get resetAllProgressSubtitle => 'Apagar todo o progresso e estrelas';

  @override
  String get aboutWriteLao => 'Sobre Escrever Lao';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Muito fácil';

  @override
  String get toleranceEasy => 'Fácil';

  @override
  String get toleranceMedium => 'Médio';

  @override
  String get toleranceHard => 'Difícil';

  @override
  String get toleranceVeryHard => 'Muito difícil';

  @override
  String get toleranceExtreme => 'Extremo';

  @override
  String get toleranceDescVeryEasy => 'Quase qualquer traço será aceito';

  @override
  String get toleranceDescEasy =>
      'Correspondência flexível, ideal para iniciantes';

  @override
  String get toleranceDescMedium => 'Dificuldade equilibrada (recomendado)';

  @override
  String get toleranceDescHard => 'Requer mais precisão';

  @override
  String get toleranceDescVeryHard => 'Correspondência rigorosa';

  @override
  String get toleranceDescExtreme =>
      'Correspondência muito rigorosa para especialistas';

  @override
  String get resetProgressTitle => 'Redefinir progresso?';

  @override
  String get resetProgressMessage =>
      'Isso excluirá permanentemente todo o seu progresso, incluindo:\n\n• Status de conclusão das lições\n• Estrelas obtidas\n• Melhores tempos\n• Histórico de prática\n\nEsta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Redefinir';

  @override
  String get progressResetSuccess => 'O progresso foi redefinido';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutAppName => 'Escrever Lao';

  @override
  String get aboutAuthor => 'por Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override
  String get aboutStory =>
      'Depois de mais de vinte anos como engenheira de software, descobri que queria aprender lao — especificamente, ler e escrever a bela escrita lao. Procurei um aplicativo que me ensinasse os caracteres traço a traço, como se aprende a escrever em sala de aula. Não encontrei nenhum.\n\nEscrever Lao guia você por cada consoante, vogal e marca tonal do alfabeto lao. Cada caractere é decomposto em traços individuais com a ordem e direção corretas. Você traça cada traço na tela, e o aplicativo diz se você acertou — sem adivinhações, sem cartões de memória, apenas prática.\n\nEspero que este aplicativo ajude você em sua própria jornada com o idioma lao. Boa escrita!';

  @override
  String get aboutDedication =>
      'Dedicado com amor à preservação da língua e cultura lao.';

  @override
  String get done => 'Concluído';

  @override
  String get splashTitle => 'Escrever Lao';

  @override
  String get splashSubtitle => 'Lao';
}
