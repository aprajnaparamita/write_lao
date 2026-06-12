// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Escribir Lao';

  @override
  String get tabLessons => 'Lecciones';

  @override
  String get tabReview => 'Repaso';

  @override
  String get tabProgress => 'Progreso';

  @override
  String lessonNumber(int number) {
    return 'Lección $number';
  }

  @override
  String get lessonNotFound => 'Lección no encontrada';

  @override
  String get lessonLabel => 'Lección';

  @override
  String get practice => 'Practicar';

  @override
  String get test => 'Prueba';

  @override
  String get content => 'Contenido';

  @override
  String get bestTime => 'Mejor tiempo';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Práctica';

  @override
  String get leavePracticeTitle => '¿Salir de la práctica?';

  @override
  String get leavePracticeMessage =>
      '¿Estás seguro de que quieres salir de la práctica?';

  @override
  String get continueButton => 'Continuar';

  @override
  String get goBackButton => 'Volver';

  @override
  String get traceCharacter => 'Traza el carácter';

  @override
  String get allDone => '¡Todo listo! ¡Muy bien!';

  @override
  String get moveToNext => '¡Muy bien! Siguiente carácter';

  @override
  String get clearTooltip => 'Borrar';

  @override
  String get playPronunciation => 'Reproducir pronunciación';

  @override
  String get hideHint => 'Ocultar pista';

  @override
  String get showHint => 'Mostrar pista';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => '¡Práctica completada!';

  @override
  String practiceCompleteMessage(int count) {
    return 'Has practicado los $count caracteres de esta lección.';
  }

  @override
  String get characters => 'Caracteres';

  @override
  String get takeTest => 'Hacer prueba';

  @override
  String get practiceAgain => 'Practicar de nuevo';

  @override
  String get backToLesson => 'Volver a la lección';

  @override
  String get backToReview => 'Volver al repaso';

  @override
  String get mainMenu => 'Menú principal';

  @override
  String get testTitle => 'Prueba';

  @override
  String get leaveTestTitle => '¿Salir de la prueba?';

  @override
  String get leaveTestMessage =>
      '¿Estás seguro de que quieres salir de la prueba?';

  @override
  String get writeFromMemory => 'Escribe este carácter de memoria';

  @override
  String get resultPerfect => '¡Perfecto!';

  @override
  String get resultGreatJob => '¡Excelente!';

  @override
  String get resultGoodTry => '¡Buen intento!';

  @override
  String get time => 'Tiempo';

  @override
  String get testAgain => 'Repetir prueba';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get lessonsCompleted => 'Lecciones\ncompletadas';

  @override
  String get starsEarned => 'Estrellas\nobtenidas';

  @override
  String get phaseProgress => 'Progreso por fase';

  @override
  String get phaseConsonants => 'Consonantes';

  @override
  String get phaseVowels => 'Vocales';

  @override
  String get phaseToneMarks => 'Marcas tonales';

  @override
  String get phaseNumerals => 'Números';

  @override
  String get phaseLigatures => 'Ligaduras';

  @override
  String get reviewTitle => 'Repaso';

  @override
  String get weakCharacters => 'Caracteres débiles';

  @override
  String get all => 'Todos';

  @override
  String phaseN(int number) {
    return 'Fase $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Practicar selección ($count)';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get strokeTolerance => 'Tolerancia de trazo';

  @override
  String get toleranceForgiving => 'Indulgente';

  @override
  String get toleranceStrict => 'Estricto';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get soundEffectsSubtitle =>
      'Reproducir sonidos para trazos correctos/incorrectos';

  @override
  String get hapticFeedback => 'Retroalimentación háptica';

  @override
  String get hapticFeedbackSubtitle => 'Vibrar en eventos de trazo';

  @override
  String get resetAllProgress => 'Restablecer todo el progreso';

  @override
  String get resetAllProgressSubtitle =>
      'Borrar todo el progreso y las estrellas';

  @override
  String get aboutWriteLao => 'Acerca de Escribir Lao';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Muy fácil';

  @override
  String get toleranceEasy => 'Fácil';

  @override
  String get toleranceMedium => 'Medio';

  @override
  String get toleranceHard => 'Difícil';

  @override
  String get toleranceVeryHard => 'Muy difícil';

  @override
  String get toleranceExtreme => 'Extremo';

  @override
  String get toleranceDescVeryEasy => 'Casi cualquier trazo será aceptado';

  @override
  String get toleranceDescEasy =>
      'Coincidencia flexible, ideal para principiantes';

  @override
  String get toleranceDescMedium => 'Dificultad equilibrada (recomendado)';

  @override
  String get toleranceDescHard => 'Requiere más precisión';

  @override
  String get toleranceDescVeryHard => 'Coincidencia estricta';

  @override
  String get toleranceDescExtreme => 'Coincidencia muy estricta para expertos';

  @override
  String get resetProgressTitle => '¿Restablecer progreso?';

  @override
  String get resetProgressMessage =>
      'Esto eliminará permanentemente todo tu progreso, incluyendo:\n\n• Estado de lecciones completadas\n• Estrellas obtenidas\n• Mejores tiempos\n• Historial de práctica\n\nEsta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Restablecer';

  @override
  String get progressResetSuccess => 'El progreso ha sido restablecido';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutAppName => 'Escribir Lao';

  @override
  String get aboutAuthor => 'por Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override

  @override

  @override
  String get done => 'Hecho';

  @override
  String get splashTitle => 'Escribir Lao';

  @override
  String get splashSubtitle => 'Lao';
}
