import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/widgets/main_bottom_nav.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/i18n/translation_helper.dart';
import 'package:write_it_lao/vocab/providers.dart';

// ── ReviewScreen ─────────────────────────────────────────────────────────────

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(l10n.reviewTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const _VocabTab(),
    );
  }
}

// ── Vocab tab — saved categories & words ─────────────────────────────────────

class _VocabTab extends ConsumerStatefulWidget {
  const _VocabTab();

  @override
  ConsumerState<_VocabTab> createState() => _VocabTabState();
}

class _VocabTabState extends ConsumerState<_VocabTab> {
  void _refresh() => setState(() {});

  Future<void> _deleteCategory(FlagDeck deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${deck.name}"?'),
        content: const Text(
          'This removes the category and all its saved words from the '
          'list. The words themselves stay in your vocabulary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(flagDeckRepositoryProvider).deleteDeck(deck.id);
    _refresh();
  }

  void _removeWord(String deckId, String wordId) {
    ref
        .read(flagDeckRepositoryProvider)
        .unflagWord(deckId: deckId, wordId: wordId);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(flagDeckRepositoryProvider);
    final decks = repo.getAllDecks()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final course = ref.watch(courseRepositoryProvider).valueOrNull;

    if (decks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_outline, size: 56, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No saved words yet.\n\n'
                'Tap the bookmark button on the review card after practising '
                'a vocab word to save it to a category.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: decks.length,
      itemBuilder: (context, i) {
        final deck = decks[i];
        final wordIds = repo
            .getWordsInDeck(deck.id)
            .map((dw) => dw.wordId)
            .toList();
        final words = course == null
            ? <VocabWord>[]
            : [
                for (final id in wordIds)
                  if (course.getWord(id) != null) course.getWord(id)!,
              ];

        return _CategoryCard(
          deck: deck,
          words: words,
          onDeleteCategory: () => _deleteCategory(deck),
          onRemoveWord: (wordId) => _removeWord(deck.id, wordId),
        );
      },
    );
  }
}

// ── _CategoryCard ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final FlagDeck deck;
  final List<VocabWord> words;
  final VoidCallback onDeleteCategory;
  final ValueChanged<String> onRemoveWord;

  const _CategoryCard({
    required this.deck,
    required this.words,
    required this.onDeleteCategory,
    required this.onRemoveWord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Category header ──────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.bookmark, color: Colors.amber, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${words.length} word${words.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete category button
                TextButton.icon(
                  onPressed: onDeleteCategory,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // ── Word list ────────────────────────────────────────────────
          if (words.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No words in this category.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            const Divider(height: 1, indent: 16, endIndent: 16),

          for (final word in words) ...[
            ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              title: Text(
                word.laoWord,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Lao',
                ),
              ),
              subtitle: Text(
                pickTranslation(
                  word.definitions,
                  languageCode: locale.languageCode,
                  scriptCode: locale.scriptCode,
                ),
                style: theme.textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                  size: 22,
                ),
                tooltip: 'Remove from category',
                onPressed: () => onRemoveWord(word.wordId),
              ),
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


