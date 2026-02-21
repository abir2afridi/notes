import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/note_provider.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/label.dart';
import '../widgets/note_card.dart';
import '../providers/label_provider.dart';
import '../providers/settings_providers.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';
import 'note_editor_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = ref.watch(activeNotesProvider);
    final labels = ref.watch(labelsProvider);
    final labelMap = {for (final label in labels) label.id: label};
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);

    final query = _searchController.text.toLowerCase();
    List<Note> filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    if (_selectedFilter == 'pinned') {
      filteredNotes = filteredNotes.where((n) => n.isPinned).toList();
    } else if (_selectedFilter == 'checklist') {
      filteredNotes = filteredNotes
          .where((n) => n.type == 'checklist')
          .toList();
    } else if (_selectedFilter == 'text') {
      filteredNotes = filteredNotes.where((n) => n.type == 'text').toList();
    } else if (_selectedFilter.startsWith('label:')) {
      final labelId = _selectedFilter.split(':').last;
      filteredNotes = filteredNotes
          .where((n) => n.labelIds.contains(labelId))
          .toList();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 48,
                      ), // Align with search bar text if possible or just standard
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NOTE CRAFT',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Search',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search Your Masterpieces...',
                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () =>
                                          _searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    icon: Icons.all_inclusive_rounded,
                    isActive: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  _FilterChip(
                    label: 'Pinned',
                    icon: Icons.push_pin_rounded,
                    isActive: _selectedFilter == 'pinned',
                    onTap: () => setState(() => _selectedFilter = 'pinned'),
                  ),
                  _FilterChip(
                    label: 'Text',
                    icon: Icons.notes_rounded,
                    isActive: _selectedFilter == 'text',
                    onTap: () => setState(() => _selectedFilter = 'text'),
                  ),
                  _FilterChip(
                    label: 'Checklist',
                    icon: Icons.checklist_rounded,
                    isActive: _selectedFilter == 'checklist',
                    onTap: () => setState(() => _selectedFilter = 'checklist'),
                  ),
                  const VerticalDivider(width: 24, indent: 12, endIndent: 12),
                  ...labels.map(
                    (label) => _FilterChip(
                      label: label.name,
                      icon: Icons.label_outline_rounded,
                      isActive: _selectedFilter == 'label:${label.id}',
                      onTap: () =>
                          setState(() => _selectedFilter = 'label:${label.id}'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: query.isEmpty
                  ? _buildRecentSearches()
                  : _buildSearchResults(
                      filteredNotes,
                      labelMap,
                      defaultWallpaper,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return _buildEmptyState(false);
  }

  Widget _buildEmptyState(bool isNoResults) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNoResults
                    ? Icons.search_off_rounded
                    : Icons.manage_search_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isNoResults ? 'Nothing found' : 'Find Your Notes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isNoResults
                  ? "We couldn't find any matches. Try different keywords."
                  : 'Start typing to search through your thoughts and inspirations.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<Note> notes,
    Map<String, Label> labelMap,
    String? defaultWallpaper,
  ) {
    if (notes.isEmpty) {
      return _buildEmptyState(true);
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return OpenContainer(
          openBuilder: (context, closedContainer) =>
              NoteEditorScreen(noteId: note.id),
          closedBuilder: (context, openContainer) => NoteCard(
            note: note,
            labelLookup: labelMap,
            defaultWallpaper: defaultWallpaper,
            onTap: openContainer,
          ),
          tappable: false,
          closedElevation: 0,
          openElevation: 0,
          transitionDuration: const Duration(milliseconds: 650),
          openShape: const RoundedRectangleBorder(),
          closedColor: Colors.transparent,
          openColor: Theme.of(context).colorScheme.surface,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isActive
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 24),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
