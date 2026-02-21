import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';

import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../providers/label_provider.dart';
import '../providers/settings_providers.dart';
import '../utils/note_utils.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialLabelId;
  const HomeScreen({super.key, this.initialLabelId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _NoteActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NoteActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.titleMedium),
      onTap: onTap,
    );
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialLabelId != null) {
      _selectedCategoryId = widget.initialLabelId!;
    }
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesListProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(activeNotesProvider);
    final labels = ref.watch(labelsProvider);
    final labelMap = {for (final label in labels) label.id: label};
    final filteredNotes = _filterNotes(notes);
    final isSearching = _searchController.text.trim().isNotEmpty;
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);
    final isGridView = ref.watch(defaultViewProvider) != 'list';

    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 16,
                top: 70,
                bottom: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NOTE CRAFT',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Library',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeaderButton(
                        icon: Icons.search_rounded,
                        onPressed: () => context.push('/search'),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _HeaderButton(
                        icon: isGridView
                            ? Icons.grid_view_rounded
                            : Icons.view_list_rounded,
                        onPressed: () {
                          final nextIsGrid = !isGridView;
                          ref
                              .read(defaultViewProvider.notifier)
                              .setDefaultView(nextIsGrid ? 'grid' : 'list');
                        },
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 54,
              child: Consumer(
                builder: (context, ref, _) {
                  final labels = ref.watch(labelsProvider);
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _CategoryChip(
                        label: 'All Notes',
                        isActive: _selectedCategoryId == 'all',
                        onTap: () =>
                            setState(() => _selectedCategoryId = 'all'),
                      ),
                      ...labels.map(
                        (label) => _CategoryChip(
                          label: label.name,
                          isActive: _selectedCategoryId == label.id,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategoryId = label.id);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          if (filteredNotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isSearching),
            )
          else ...[
            if (filteredNotes.any((n) => n.isPinned)) ...[
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(title: 'Pinned'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: isGridView
                    ? SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemBuilder: (context, index) {
                          final pinnedNotes = filteredNotes
                              .where((n) => n.isPinned)
                              .toList();
                          final note = pinnedNotes[index];
                          return _OpenContainerWrapper(
                            noteId: note.id,
                            closedBuilder: (context, openContainer) => NoteCard(
                              note: note,
                              labelLookup: labelMap,
                              defaultWallpaper: defaultWallpaper,
                              onTap: openContainer,
                              onLongPress: () {
                                HapticFeedback.heavyImpact();
                                _showNoteActions(note);
                              },
                            ),
                          );
                        },
                        childCount: filteredNotes
                            .where((n) => n.isPinned)
                            .length,
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pinnedNotes = filteredNotes
                                .where((n) => n.isPinned)
                                .toList();
                            final note = pinnedNotes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OpenContainerWrapper(
                                noteId: note.id,
                                closedBuilder: (context, openContainer) =>
                                    NoteCard(
                                      note: note,
                                      labelLookup: labelMap,
                                      defaultWallpaper: defaultWallpaper,
                                      onTap: openContainer,
                                      onLongPress: () {
                                        HapticFeedback.heavyImpact();
                                        _showNoteActions(note);
                                      },
                                    ),
                              ),
                            );
                          },
                          childCount: filteredNotes
                              .where((n) => n.isPinned)
                              .length,
                        ),
                      ),
              ),
              if (filteredNotes.any((n) => !n.isPinned))
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(title: 'Others'),
                ),
            ],
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: isGridView
                  ? SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemBuilder: (context, index) {
                        final others = filteredNotes
                            .where((n) => !n.isPinned)
                            .toList();
                        final note = others[index];
                        return _OpenContainerWrapper(
                          noteId: note.id,
                          closedBuilder: (context, openContainer) => NoteCard(
                            note: note,
                            labelLookup: labelMap,
                            defaultWallpaper: defaultWallpaper,
                            onTap: openContainer,
                            onLongPress: () {
                              HapticFeedback.heavyImpact();
                              _showNoteActions(note);
                            },
                          ),
                        );
                      },
                      childCount: filteredNotes
                          .where((n) => !n.isPinned)
                          .length,
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final others = filteredNotes
                              .where((n) => !n.isPinned)
                              .toList();
                          final note = others[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OpenContainerWrapper(
                              noteId: note.id,
                              closedBuilder: (context, openContainer) =>
                                  NoteCard(
                                    note: note,
                                    labelLookup: labelMap,
                                    defaultWallpaper: defaultWallpaper,
                                    onTap: openContainer,
                                    onLongPress: () {
                                      HapticFeedback.heavyImpact();
                                      _showNoteActions(note);
                                    },
                                  ),
                            ),
                          );
                        },
                        childCount: filteredNotes
                            .where((n) => !n.isPinned)
                            .length,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    List<Note> filtered = notes;

    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((note) => note.labelIds.contains(_selectedCategoryId))
          .toList();
    }

    return filtered;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
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
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.note_add_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isSearching ? 'No notes found' : 'Your story starts here',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? "We couldn't find any matches for your search."
                  : 'Capture what\'s on your mind. Simple, elegant, and forever yours.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: () => context.push('/editor/new'),
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Note'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNoteActions(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              _NoteActionTile(
                icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                label: note.isPinned ? 'Unpin' : 'Pin',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final willBePinned = !note.isPinned;
                  await ref.read(notesListProvider.notifier).togglePin(note.id);
                  _showMessage(willBePinned ? 'Note pinned' : 'Note unpinned');
                },
              ),
              _NoteActionTile(
                icon: Icons.archive_outlined,
                label: 'Archive',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(notesListProvider.notifier)
                      .archiveNote(note.id);
                  _showMessage('Note archived');
                },
              ),
              _NoteActionTile(
                icon: Icons.delete_outline,
                label: 'Delete',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(notesListProvider.notifier)
                      .moveToTrash(note.id);
                  _showMessage('Note moved to trash');
                },
              ),
              _NoteActionTile(
                icon: Icons.copy_outlined,
                label: 'Make a copy',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(notesListProvider.notifier)
                      .duplicateNote(note.id);
                  _showMessage('Note copied');
                },
              ),
              _NoteActionTile(
                icon: Icons.send_outlined,
                label: 'Send',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Share.share(buildShareContent(note));
                },
              ),
              _NoteActionTile(
                icon: Icons.description_outlined,
                label: 'Copy to Google Docs',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final content = buildShareContent(note);
                  await Clipboard.setData(ClipboardData(text: content));
                  _showMessage('Note copied. Paste into Google Docs.');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = this.isActive;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'All Notes'
                      ? Icons.grid_view_rounded
                      : Icons.label_outline_rounded,
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

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _HeaderButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  final String noteId;
  final CloseContainerBuilder closedBuilder;

  const _OpenContainerWrapper({
    required this.noteId,
    required this.closedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      openBuilder: (context, closedContainer) =>
          NoteEditorScreen(noteId: noteId),
      closedBuilder: closedBuilder,
      tappable: false,
      closedElevation: 0,
      openElevation: 0,
      transitionDuration: const Duration(milliseconds: 650),
      openShape: const RoundedRectangleBorder(),
      closedColor: Colors.transparent,
      openColor: theme.colorScheme.surface,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _StickyHeaderDelegate({required this.title});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor.withValues(
        alpha: overlapsContent ? 0.9 : 1.0,
      ),
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
