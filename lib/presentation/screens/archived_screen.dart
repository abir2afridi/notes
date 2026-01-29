import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/label.dart';
import '../providers/note_provider.dart';
import '../providers/label_provider.dart';
import '../providers/settings_providers.dart';
import '../widgets/note_card.dart';

class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedNotes = ref.watch(archivedNotesProvider);
    final labels = ref.watch(labelsProvider);
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);
    final isGridView = ref.watch(defaultViewProvider) != 'list';
    final labelLookup = {for (final label in labels) label.id: label};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Archived'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Search functionality
                },
              ),
            ],
          ),
          if (archivedNotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ArchivedEmptyState(
                onReturn: () => _navigateHome(context),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: isGridView
                  ? _ArchivedGrid(
                      notes: archivedNotes,
                      labelLookup: labelLookup,
                      defaultWallpaper: defaultWallpaper,
                      ref: ref,
                    )
                  : _ArchivedList(
                      notes: archivedNotes,
                      labelLookup: labelLookup,
                      defaultWallpaper: defaultWallpaper,
                      ref: ref,
                    ),
            ),
        ],
      ),
    );
  }

  void _navigateHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
}

class _ArchivedGrid extends StatelessWidget {
  final List<Note> notes;
  final Map<String, Label> labelLookup;
  final String? defaultWallpaper;
  final WidgetRef ref;

  const _ArchivedGrid({
    required this.notes,
    required this.labelLookup,
    required this.defaultWallpaper,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
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
          labelLookup: labelLookup,
          defaultWallpaper: defaultWallpaper,
          onTap: () => _openNote(context, notes[index].id),
          onLongPress: () => _showArchivedActions(context, ref, notes[index]),
        );
      }, childCount: notes.length),
    );
  }
}

class _ArchivedList extends StatelessWidget {
  final List<Note> notes;
  final Map<String, Label> labelLookup;
  final String? defaultWallpaper;
  final WidgetRef ref;

  const _ArchivedList({
    required this.notes,
    required this.labelLookup,
    required this.defaultWallpaper,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NoteCard(
            note: note,
            labelLookup: labelLookup,
            defaultWallpaper: defaultWallpaper,
            onTap: () => _openNote(context, note.id),
            onLongPress: () => _showArchivedActions(context, ref, note),
          ),
        );
      }, childCount: notes.length),
    );
  }
}

class _ArchivedEmptyState extends StatelessWidget {
  final VoidCallback onReturn;

  const _ArchivedEmptyState({required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined, size: 96, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nothing archived yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pin or archive notes to keep them handy without clutter. Archived notes stay searchable.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onReturn,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to notes'),
            ),
          ],
        ),
      ),
    );
  }
}

void _openNote(BuildContext context, String noteId) {
  context.push('/note/$noteId');
}

void _showArchivedActions(BuildContext context, WidgetRef ref, Note note) {
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
            ListTile(
              leading: const Icon(Icons.unarchive_outlined),
              title: const Text('Restore to notes'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(notesListProvider.notifier)
                    .unarchiveNote(note.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note restored to notes.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Move to trash'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref.read(notesListProvider.notifier).moveToTrash(note.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note moved to trash.')),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
