import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/label.dart';
import '../providers/note_provider.dart';
import '../providers/label_provider.dart';
import '../providers/settings_providers.dart';
import '../utils/note_utils.dart';
import '../widgets/note_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

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

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'NoteKeeper',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.view_list : Icons.grid_view,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  final nextIsGrid = !isGridView;
                  ref
                      .read(defaultViewProvider.notifier)
                      .setDefaultView(nextIsGrid ? 'grid' : 'list');
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your notes...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          if (filteredNotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isSearching),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              sliver: _buildNotesView(
                filteredNotes,
                labelMap,
                isSearching,
                defaultWallpaper,
                isGridView,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewNoteSheet,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showNewNoteSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                _NewNoteOption(
                  icon: Icons.note_add_outlined,
                  title: 'Text note',
                  subtitle: 'Start with a blank canvas',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/note/new?type=text');
                  },
                ),
                _NewNoteOption(
                  icon: Icons.check_box_outlined,
                  title: 'Checklist',
                  subtitle: 'Create a to-do list with checkboxes',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/note/new?type=checklist');
                  },
                ),
                _NewNoteOption(
                  icon: Icons.brush_outlined,
                  title: 'Drawing',
                  subtitle: 'Sketch ideas (coming soon)',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showMessage('Drawing notes are coming soon');
                  },
                ),
                _NewNoteOption(
                  icon: Icons.image_outlined,
                  title: 'Image',
                  subtitle: 'Attach inspiration photos (coming soon)',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showMessage('Image notes are coming soon');
                  },
                ),
                _NewNoteOption(
                  icon: Icons.mic_outlined,
                  title: 'Audio',
                  subtitle: 'Record voice memos (coming soon)',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showMessage('Audio notes are coming soon');
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesView(
    List<Note> notes,
    Map<String, Label> labels,
    bool isSearching,
    String? defaultWallpaper,
    bool isGridView,
  ) {
    // Empty check is handled in parent
    return isGridView
        ? _buildGridView(notes, labels, defaultWallpaper)
        : _buildListView(notes, labels, defaultWallpaper);
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No matching notes' : 'No notes yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Create your first note to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    List<Note> notes,
    Map<String, Label> labels,
    String? defaultWallpaper,
  ) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return NoteCard(
          note: notes[index],
          labelLookup: labels,
          defaultWallpaper: defaultWallpaper,
          onTap: () => context.go('/note/${notes[index].id}'),
          onLongPress: () => _showNoteActions(notes[index]),
        );
      }, childCount: notes.length),
    );
  }

  Widget _buildListView(
    List<Note> notes,
    Map<String, Label> labels,
    String? defaultWallpaper,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NoteCard(
            note: notes[index],
            labelLookup: labels,
            defaultWallpaper: defaultWallpaper,
            onTap: () => context.go('/note/${notes[index].id}'),
            onLongPress: () => _showNoteActions(notes[index]),
          ),
        );
      }, childCount: notes.length),
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

class _NewNoteOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NewNoteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
        foregroundColor: theme.colorScheme.primary,
        child: Icon(icon),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      onTap: onTap,
    );
  }
}
