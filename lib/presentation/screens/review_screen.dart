import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const MainBottomNav(currentIndex: 1),
        appBar: AppBar(
          title: Text(l10n.reviewTitle),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: const _ReviewPillTabBar(),
        ),
        body: const TabBarView(
          children: [
            _CharactersTab(),
            _VocabTab(),
          ],
        ),
      ),
    );
  }
}

// ── Pill tab bar (same style as LessonListScreen) ─────────────────────────────

class _ReviewPillTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ReviewPillTabBar();

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TabBar(
          indicator: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'CHARACTERS'),
            Tab(text: 'VOCAB'),
          ],
        ),
      ),
    );
  }
}

// ── Characters tab (existing content) ────────────────────────────────────────

class _CharactersTab extends ConsumerStatefulWidget {
  const _CharactersTab();

  @override
  ConsumerState<_CharactersTab> createState() => _CharactersTabState();
}

class _CharactersTabState extends ConsumerState<_CharactersTab> {
  final Set<String> _selectedCharacters = {};
  int _selectedPhase = 0; // 0 = All, 1-5 = specific phase

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);

    // Only include characters from lessons the user has completed
    final completedCodepoints = <String>{};
    for (final lesson in charRepo.getAllLessons()) {
      final progress = progressRepo.getLessonProgress(lesson.id);
      if (progress.isCompleted) {
        completedCodepoints.addAll(lesson.characterCodepoints);
      }
    }

    final allCharacters = (_selectedPhase == 0
            ? charRepo.getAllCharacters()
            : charRepo.getCharactersByPhase(_selectedPhase))
        .where((c) => completedCodepoints.contains(c.codepoint))
        .toList();

    final weakCharacters = progressRepo.getWeakCharacters(limit: 20);
    final weakCodepoints = weakCharacters.map((c) => c.codepoint).toSet();

    return Column(
      children: [
        // Quick select buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.trending_down, size: 18),
                label: Text(l10n.weakCharacters),
                onPressed: _selectWeakCharacters,
              ),
              ActionChip(
                avatar: const Icon(Icons.select_all, size: 18),
                label: Text(l10n.all),
                onPressed: _selectAll,
              ),
            ],
          ),
        ),

        // Phase filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.all),
                selected: _selectedPhase == 0,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedPhase = 0);
                },
              ),
              for (int i = 1; i <= 5; i++) ...[
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.phaseN(i)),
                  selected: _selectedPhase == i,
                  onSelected: (selected) {
                    setState(() => _selectedPhase = selected ? i : 0);
                  },
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Character grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allCharacters.length,
            itemBuilder: (context, index) {
              final character = allCharacters[index];
              final isSelected =
                  _selectedCharacters.contains(character.codepoint);
              final isWeak = weakCodepoints.contains(character.codepoint);
              return _CharacterSelectTile(
                character: character,
                isSelected: isSelected,
                isWeak: isWeak,
                onTap: () => _toggleCharacter(character.codepoint),
              );
            },
          ),
        ),

        // Practice button
        if (_selectedCharacters.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/practice/review',
                      extra: {
                        'characterCodepoints': _selectedCharacters.toList()
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(
                    l10n.practiceSelected(_selectedCharacters.length),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _toggleCharacter(String codepoint) {
    setState(() {
      if (_selectedCharacters.contains(codepoint)) {
        _selectedCharacters.remove(codepoint);
      } else {
        _selectedCharacters.add(codepoint);
      }
    });
  }

  void _selectWeakCharacters() {
    final progressRepo = ref.read(progressRepositoryProvider);
    final weakCharacters = progressRepo.getWeakCharacters(limit: 20);
    setState(() {
      _selectedPhase = 0; // show all phases so weak chars are visible
      _selectedCharacters.clear();
      _selectedCharacters.addAll(weakCharacters.map((c) => c.codepoint));
    });
  }

  void _selectAll() {
    final charRepo = ref.read(characterRepositoryProvider);
    final progressRepo = ref.read(progressRepositoryProvider);
    final completedCodepoints = <String>{};
    for (final lesson in charRepo.getAllLessons()) {
      final progress = progressRepo.getLessonProgress(lesson.id);
      if (progress.isCompleted) {
        completedCodepoints.addAll(lesson.characterCodepoints);
      }
    }
    setState(() {
      _selectedPhase = 0; // show all phases
      _selectedCharacters.clear();
      _selectedCharacters.addAll(completedCodepoints);
    });
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

// ── _CharacterSelectTile (unchanged from before) ──────────────────────────────

class _CharacterSelectTile extends StatelessWidget {
  final LaoCharacter character;
  final bool isSelected;
  final bool isWeak;
  final VoidCallback onTap;

  const _CharacterSelectTile({
    required this.character,
    required this.isSelected,
    required this.isWeak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.displayChar,
                    style: const TextStyle(
                      fontFamily: 'Noto Lao',
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.letterNameRomanized ?? character.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            if (isWeak && !isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_down,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
