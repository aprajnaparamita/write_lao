// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Écrire le Lao';

  @override
  String get tabLessons => 'Leçons';

  @override
  String get tabReview => 'Révision';

  @override
  String get tabProgress => 'Progrès';

  @override
  String lessonNumber(int number) {
    return 'Leçon $number';
  }

  @override
  String get lessonNotFound => 'Leçon introuvable';

  @override
  String get lessonLabel => 'Leçon';

  @override
  String get practice => 'Pratique';

  @override
  String get test => 'Test';

  @override
  String get content => 'Contenu';

  @override
  String get bestTime => 'Meilleur temps';

  @override
  String get bestTimeEmpty => '--:--';

  @override
  String get practiceTitle => 'Pratique';

  @override
  String get leavePracticeTitle => 'Quitter la pratique ?';

  @override
  String get leavePracticeMessage =>
      'Êtes-vous sûr de vouloir quitter la pratique ?';

  @override
  String get continueButton => 'Continuer';

  @override
  String get goBackButton => 'Retour';

  @override
  String get traceCharacter => 'Tracez le caractère';

  @override
  String get allDone => 'Terminé ! Bravo !';

  @override
  String get moveToNext => 'Bravo ! Caractère suivant';

  @override
  String get clearTooltip => 'Effacer';

  @override
  String get playPronunciation => 'Écouter la prononciation';

  @override
  String get hideHint => 'Masquer l\'indice';

  @override
  String get showHint => 'Afficher l\'indice';

  @override
  String characterCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get practiceComplete => 'Pratique terminée !';

  @override
  String practiceCompleteMessage(int count) {
    return 'Vous avez pratiqué les $count caractères de cette leçon.';
  }

  @override
  String get characters => 'Caractères';

  @override
  String get takeTest => 'Passer le test';

  @override
  String get practiceAgain => 'Pratiquer à nouveau';

  @override
  String get backToLesson => 'Retour à la leçon';

  @override
  String get backToReview => 'Retour à la révision';

  @override
  String get mainMenu => 'Menu principal';

  @override
  String get testTitle => 'Test';

  @override
  String get leaveTestTitle => 'Quitter le test ?';

  @override
  String get leaveTestMessage => 'Êtes-vous sûr de vouloir quitter le test ?';

  @override
  String get writeFromMemory => 'Écrivez ce caractère de mémoire';

  @override
  String get resultPerfect => 'Parfait !';

  @override
  String get resultGreatJob => 'Excellent !';

  @override
  String get resultGoodTry => 'Bon effort !';

  @override
  String get time => 'Temps';

  @override
  String get testAgain => 'Refaire le test';

  @override
  String get progressTitle => 'Progrès';

  @override
  String get lessonsCompleted => 'Leçons\nterminées';

  @override
  String get starsEarned => 'Étoiles\nobtenues';

  @override
  String get phaseProgress => 'Progrès par phase';

  @override
  String get phaseConsonants => 'Consonnes';

  @override
  String get phaseVowels => 'Voyelles';

  @override
  String get phaseToneMarks => 'Marques tonales';

  @override
  String get phaseNumerals => 'Chiffres';

  @override
  String get phaseLigatures => 'Ligatures';

  @override
  String get reviewTitle => 'Révision';

  @override
  String get weakCharacters => 'Caractères faibles';

  @override
  String get all => 'Tous';

  @override
  String phaseN(int number) {
    return 'Phase $number';
  }

  @override
  String practiceSelected(int count) {
    return 'Pratiquer la sélection ($count)';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get strokeTolerance => 'Tolérance du tracé';

  @override
  String get toleranceForgiving => 'Indulgent';

  @override
  String get toleranceStrict => 'Strict';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get soundEffectsSubtitle =>
      'Jouer des sons pour les tracés corrects/incorrects';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get hapticFeedbackSubtitle => 'Vibrer lors des événements de tracé';

  @override
  String get resetAllProgress => 'Réinitialiser tous les progrès';

  @override
  String get resetAllProgressSubtitle => 'Effacer tous les progrès et étoiles';

  @override
  String get aboutWriteLao => 'À propos d\'Écrire le Lao';

  @override
  String get aboutVersion => 'v1.0';

  @override
  String get aboutVersionAuthor => 'v1.0 · Janet Jeffus';

  @override
  String get toleranceVeryEasy => 'Très facile';

  @override
  String get toleranceEasy => 'Facile';

  @override
  String get toleranceMedium => 'Moyen';

  @override
  String get toleranceHard => 'Difficile';

  @override
  String get toleranceVeryHard => 'Très difficile';

  @override
  String get toleranceExtreme => 'Extrême';

  @override
  String get toleranceDescVeryEasy => 'Presque tout tracé sera accepté';

  @override
  String get toleranceDescEasy =>
      'Correspondance souple, idéal pour les débutants';

  @override
  String get toleranceDescMedium => 'Difficulté équilibrée (recommandé)';

  @override
  String get toleranceDescHard => 'Plus de précision requise';

  @override
  String get toleranceDescVeryHard => 'Correspondance stricte';

  @override
  String get toleranceDescExtreme =>
      'Correspondance très stricte pour les experts';

  @override
  String get resetProgressTitle => 'Réinitialiser les progrès ?';

  @override
  String get resetProgressMessage =>
      'Cela supprimera définitivement tous vos progrès, y compris :\n\n• État d\'achèvement des leçons\n• Étoiles obtenues\n• Meilleurs temps\n• Historique de pratique\n\nCette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get progressResetSuccess => 'Les progrès ont été réinitialisés';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutAppName => 'Écrire le Lao';

  @override
  String get aboutAuthor => 'par Janet Jeffus';

  @override
  String get aboutCopyright => 'Copyright © 2026';

  @override
  String get aboutStory =>
      'Après plus de vingt ans en tant qu\'ingénieure logiciel, j\'ai découvert que je voulais apprendre le lao — en particulier, lire et écrire la belle écriture lao. J\'ai cherché une application qui m\'apprendrait les caractères trait par trait, comme on apprend à écrire en classe. Je n\'en ai trouvé aucune.\n\nAlors j\'ai décidé d\'en créer une moi-même.\n\nÉcrire le Lao vous guide à travers chaque consonne, voyelle et marque tonale de l\'alphabet lao. Chaque caractère est décomposé en traits individuels dans le bon ordre et la bonne direction. Vous tracez chaque trait sur l\'écran, et l\'application vous dit si c\'est correct — pas de devinettes, pas de cartes mémoire, juste de la pratique.\n\nJ\'espère que cette application vous aidera dans votre propre parcours avec la langue lao. Bonne écriture !';

  @override
  String get done => 'Terminé';

  @override
  String get splashTitle => 'Écrire le Lao';

  @override
  String get splashSubtitle => 'Lao';
}
