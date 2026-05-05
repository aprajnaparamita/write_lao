import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/main_bottom_nav.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final Set<String> _selectedCharacters = {};
  int _selectedPhase = 0; // 0 = All, 1-5 = specific phase

  @override
  Widget build(BuildContext context) {
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    
    // Only include characters from lessons the user has completed (passed the test)
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
    
    // Get weak characters from progress
    final weakCharacters = progressRepo.getWeakCharacters(limit: 20);
    final weakCodepoints = weakCharacters.map((c) => c.codepoint).toSet();

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).reviewTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: const [],
      ),
      body: Column(
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
                  label: Text(AppLocalizations.of(context).weakCharacters),
                  onPressed: _selectWeakCharacters,
                ),
                ActionChip(
                  avatar: const Icon(Icons.select_all, size: 18),
                  label: Text(AppLocalizations.of(context).all),
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
                  label: Text(AppLocalizations.of(context).all),
                  selected: _selectedPhase == 0,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPhase = 0);
                    }
                  },
                ),
                for (int i = 1; i <= 5; i++) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(AppLocalizations.of(context).phaseN(i)),
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
                final isSelected = _selectedCharacters.contains(character.codepoint);
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
                        extra: {'characterCodepoints': _selectedCharacters.toList()},
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(AppLocalizations.of(context).practiceSelected(_selectedCharacters.length)),
                  ),
                ),
              ),
            ),
        ],
      ),
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
      _selectedCharacters.clear();
      _selectedCharacters.addAll(completedCodepoints);
    });
  }

}

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
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
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
