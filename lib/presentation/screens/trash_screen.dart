import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/label.dart';
import '../../domain/entities/note.dart';
import '../providers/label_provider.dart';
import '../providers/note_provider.dart';
import '../providers/settings_providers.dart';
import '../widgets/note_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedNotes = ref.watch(trashedNotesProvider);
    final labels = ref.watch(labelsProvider);
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);
    final isGridView = ref.watch(defaultViewProvider) != 'list';
    final labelLookup = {for (final label in labels) label.id: label};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Trash'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
            actions: [
              if (trashedNotes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Empty trash',
                  onPressed: () => _confirmEmptyTrash(context, ref),
                ),
            ],
          ),
          if (trashedNotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: const _TrashEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: isGridView
                  ? _TrashGrid(
                      notes: trashedNotes,
                      labelLookup: labelLookup,
                      defaultWallpaper: defaultWallpaper,
                      ref: ref,
                    )
                  : _TrashList(
                      notes: trashedNotes,
                      labelLookup: labelLookup,
                      defaultWallpaper: defaultWallpaper,
                      ref: ref,
                    ),
            ),
        ],
      ),
    );
  }
}

class _TrashGrid extends StatelessWidget {
  final List<Note> notes;
  final Map<String, Label> labelLookup;
  final String? defaultWallpaper;
  final WidgetRef ref;

  const _TrashGrid({
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
          onLongPress: () => _showTrashActions(context, ref, notes[index]),
        );
      }, childCount: notes.length),
    );
  }
}

class _TrashList extends StatelessWidget {
  final List<Note> notes;
  final Map<String, Label> labelLookup;
  final String? defaultWallpaper;
  final WidgetRef ref;

  const _TrashList({
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
            onLongPress: () => _showTrashActions(context, ref, note),
          ),
        );
      }, childCount: notes.length),
    );
  }
}

class _TrashEmptyState extends StatelessWidget {
  const _TrashEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 96, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Trash is empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Notes stay here for a while before being removed. Restore any note to bring it back.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
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

Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref) async {
  final shouldEmpty = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Empty trash?'),
      content: const Text(
        'All notes in trash will be permanently deleted. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Empty trash'),
        ),
      ],
    ),
  );

  if (shouldEmpty == true) {
    await ref.read(notesListProvider.notifier).emptyTrash();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trash emptied.')));
    }
  }
}

void _showTrashActions(BuildContext context, WidgetRef ref, Note note) {
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
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Restore'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(notesListProvider.notifier)
                    .restoreFromTrash(note.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Note restored.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Delete forever'),
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete forever?'),
                    content: const Text(
                      'This note will be permanently removed and cannot be recovered.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(notesListProvider.notifier)
                      .permanentlyDelete(note.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note deleted forever.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
