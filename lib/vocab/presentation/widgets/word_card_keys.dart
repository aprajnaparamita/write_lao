import 'package:flutter/widgets.dart';

/// Stable widget keys used by intro/outro card tests.
class WordCardKeys {
  static const image = ValueKey('vocab.wordCard.image');
  static const headwordPlayButton = ValueKey('vocab.wordCard.headwordPlay');
  static const example1PlayButton = ValueKey('vocab.wordCard.example1Play');
  static const example2PlayButton = ValueKey('vocab.wordCard.example2Play');
  static const continueButton = ValueKey('vocab.wordCard.continue');
  static const nextButton = ValueKey('vocab.wordCard.next');
  static const flagButton = ValueKey('vocab.wordCard.flag');
  static const mutedIndicator = ValueKey('vocab.wordCard.muted');

  // Practice / Test card keys (Phase 04).
  static const progressLabel = ValueKey('vocab.charCard.progress');
  static const characterTypeHint = ValueKey('vocab.charCard.typeHint');
  static const showHintButton = ValueKey('vocab.charCard.showHint');
  static const abortButton = ValueKey('vocab.charCard.abort');
  static const characterAudioButton = ValueKey('vocab.charCard.audio');
  static const wordPreview = ValueKey('vocab.charCard.preview');
  static const strokeCanvas = ValueKey('vocab.charCard.canvas');

  // Test-only fake canvas hooks.
  static const fakeStrokeIncorrect = ValueKey('vocab.fakeCanvas.incorrect');
  static const fakeStrokeCorrect = ValueKey('vocab.fakeCanvas.correct');
  static const fakeCharacterComplete =
      ValueKey('vocab.fakeCanvas.characterComplete');

  // Hear-and-identify card (Phase 05).
  static const hearIdentifyPrompt = ValueKey('vocab.hearIdentify.prompt');
  static const hearIdentifyReplay = ValueKey('vocab.hearIdentify.replay');
  static const hearIdentifyRomanization =
      ValueKey('vocab.hearIdentify.romanization');
  static const hearIdentifyGloss = ValueKey('vocab.hearIdentify.gloss');

  // Flag-to-deck picker / My Decks / deck contents (Phase 06).
  static const deckPickerCreateField =
      ValueKey('vocab.deckPicker.createField');
  static const deckPickerCreateButton =
      ValueKey('vocab.deckPicker.createButton');
  static const deckPickerDone = ValueKey('vocab.deckPicker.done');
  static ValueKey deckPickerCheckbox(String deckId) =>
      ValueKey('vocab.deckPicker.checkbox.$deckId');
  static const myDecksList = ValueKey('vocab.myDecks.list');
  static const myDecksAddButton = ValueKey('vocab.myDecks.add');
  static ValueKey myDecksRow(String deckId) =>
      ValueKey('vocab.myDecks.row.$deckId');
  static ValueKey myDecksStudyButton(String deckId) =>
      ValueKey('vocab.myDecks.study.$deckId');
  static ValueKey myDecksMoreMenu(String deckId) =>
      ValueKey('vocab.myDecks.more.$deckId');
  static const deckContentsList = ValueKey('vocab.deckContents.list');
  static ValueKey deckContentsRow(String wordId) =>
      ValueKey('vocab.deckContents.row.$wordId');
  static ValueKey deckContentsRemove(String wordId) =>
      ValueKey('vocab.deckContents.remove.$wordId');

  // Unit / lesson navigation (Phase 07).
  static const unitList = ValueKey('vocab.unitList');
  static const masteredCounter = ValueKey('vocab.unitList.masteredCounter');
  static ValueKey unitRow(String unitId) =>
      ValueKey('vocab.unitList.row.$unitId');
  static ValueKey unitLockBadge(String unitId) =>
      ValueKey('vocab.unitList.lock.$unitId');
  static const lessonList = ValueKey('vocab.lessonList');
  static ValueKey lessonRow(String lessonId) =>
      ValueKey('vocab.lessonList.row.$lessonId');
  static ValueKey lessonLockBadge(String lessonId) =>
      ValueKey('vocab.lessonList.lock.$lessonId');
  static const lessonCompleteContinue =
      ValueKey('vocab.lessonComplete.continue');
  static const lessonCompleteNextLabel =
      ValueKey('vocab.lessonComplete.nextLabel');
  static const unitCompleteContinue =
      ValueKey('vocab.unitComplete.continue');

  // IAP / upsell (Phase 08).
  static const upsellBuyNow = ValueKey('vocab.upsell.buyNow');
  static const upsellMaybeLater = ValueKey('vocab.upsell.maybeLater');
  static const restoreContinue = ValueKey('vocab.restore.continue');
}
