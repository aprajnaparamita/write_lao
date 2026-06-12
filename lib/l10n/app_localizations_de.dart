// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Laotisch schreiben';

  @override
  String get tabLessons => 'Lektionen';

  @override
  String get tabReview => 'Wiederholung';

  @override
  String get tabProgress => 'Fortschritt';

  @override
  String lessonNumber(int number) {
    return 'Lektion $number';
  }

  @override
  String get lessonNotFound => 'Lektion nicht gefunden';

  @override
  String get lessonLabel => 'Lektion';

  @override
  String get practice => 'Üben';

  @override
  String get test => 'Test';

  @override
  String get content => 'Inhalt';

  @override
  String get bestTime => 'Bestzeit';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Übung';

  @override
  String get leavePracticeTitle => 'Übung verlassen?';

  @override
  String get leavePracticeMessage =>
      'Möchten Sie die Übung wirklich verlassen?';

  @override
  String get continueButton => 'Weiter';

  @override
  String get goBackButton => 'Zurück';

  @override
  String get traceCharacter => 'Zeichen nachzeichnen';

  @override
  String get allDone => 'Alles fertig! Sehr gut!';

  @override
  String get moveToNext => 'Sehr gut! Zum nächsten Zeichen';

  @override
  String get clearTooltip => 'Löschen';

  @override
  String get playPronunciation => 'Aussprache abspielen';

  @override
  String get hideHint => 'Hinweis ausblenden';

  @override
  String get showHint => 'Hinweis anzeigen';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Übung abgeschlossen!';

  @override
  String practiceCompleteMessage(int count) {
    return 'Sie haben alle $count Zeichen dieser Lektion geübt.';
  }

  @override
  String get characters => 'Zeichen';

  @override
  String get takeTest => 'Test starten';

  @override
  String get practiceAgain => 'Nochmal üben';

  @override
  String get backToLesson => 'Zurück zur Lektion';

  @override
  String get backToReview => 'Zurück zur Wiederholung';

  @override
  String get mainMenu => 'Hauptmenü';

  @override
  String get testTitle => 'Test';

  @override
  String get leaveTestTitle => 'Test verlassen?';

  @override
  String get leaveTestMessage => 'Möchten Sie den Test wirklich verlassen?';

  @override
  String get writeFromMemory =>
      'Schreiben Sie dieses Zeichen aus dem Gedächtnis';

  @override
  String get resultPerfect => 'Perfekt!';

  @override
  String get resultGreatJob => 'Ausgezeichnet!';

  @override
  String get resultGoodTry => 'Guter Versuch!';

  @override
  String get time => 'Zeit';

  @override
  String get testAgain => 'Test wiederholen';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get lessonsCompleted => 'Abgeschlossene\nLektionen';

  @override
  String get starsEarned => 'Erhaltene\nSterne';

  @override
  String get phaseProgress => 'Fortschritt nach Phase';

  @override
  String get phaseConsonants => 'Konsonanten';

  @override
  String get phaseVowels => 'Vokale';

  @override
  String get phaseToneMarks => 'Tonzeichen';

  @override
  String get phaseNumerals => 'Ziffern';

  @override
  String get phaseLigatures => 'Ligaturen';

  @override
  String get reviewTitle => 'Wiederholung';

  @override
  String get weakCharacters => 'Schwache Zeichen';

  @override
  String get all => 'Alle';

  @override
  String phaseN(int number) {
    return 'Phase $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Auswahl üben ($count)';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get strokeTolerance => 'Strichtoleranz';

  @override
  String get toleranceForgiving => 'Nachsichtig';

  @override
  String get toleranceStrict => 'Streng';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get soundEffectsSubtitle =>
      'Töne bei richtigen/falschen Strichen abspielen';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Vibration bei Strichereignissen';

  @override
  String get resetAllProgress => 'Gesamten Fortschritt zurücksetzen';

  @override
  String get resetAllProgressSubtitle =>
      'Alle Lektionsfortschritte und Sterne löschen';

  @override
  String get aboutWriteLao => 'Über Laotisch schreiben';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Sehr einfach';

  @override
  String get toleranceEasy => 'Einfach';

  @override
  String get toleranceMedium => 'Mittel';

  @override
  String get toleranceHard => 'Schwer';

  @override
  String get toleranceVeryHard => 'Sehr schwer';

  @override
  String get toleranceExtreme => 'Extrem';

  @override
  String get toleranceDescVeryEasy => 'Fast jede Zeichnung wird akzeptiert';

  @override
  String get toleranceDescEasy => 'Lockere Übereinstimmung, gut für Anfänger';

  @override
  String get toleranceDescMedium =>
      'Ausgewogener Schwierigkeitsgrad (empfohlen)';

  @override
  String get toleranceDescHard => 'Mehr Genauigkeit erforderlich';

  @override
  String get toleranceDescVeryHard => 'Strenge Übereinstimmung';

  @override
  String get toleranceDescExtreme =>
      'Sehr strenge Übereinstimmung für Experten';

  @override
  String get resetProgressTitle => 'Fortschritt zurücksetzen?';

  @override
  String get resetProgressMessage =>
      'Dies löscht Ihren gesamten Fortschritt dauerhaft, einschließlich:\n\n• Abschlussstatus der Lektionen\n• Erhaltene Sterne\n• Bestzeiten\n• Übungshistorie\n\nDiese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get progressResetSuccess => 'Fortschritt wurde zurückgesetzt';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutAppName => 'Laotisch schreiben';

  @override
  String get aboutAuthor => 'von Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override

  @override

  @override
  String get done => 'Fertig';

  @override
  String get splashTitle => 'Laotisch schreiben';

  @override
  String get splashSubtitle => 'Laotisch';
}
