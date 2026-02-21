import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note.dart';
import '../providers/label_provider.dart';
import '../providers/note_provider.dart';
import '../providers/settings_providers.dart';
import '../widgets/note_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trashedNotes = ref.watch(trashedNotesProvider);
    final labels = ref.watch(labelsProvider);
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);
    final isGridView = ref.watch(defaultViewProvider) != 'list';
    final labelLookup = {for (final label in labels) label.id: label};

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'NOTE CRAFT',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Recycle Bin',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isGridView
                            ? Icons.grid_view_rounded
                            : Icons.view_list_rounded,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final nextIsGrid = !isGridView;
                        ref
                            .read(defaultViewProvider.notifier)
                            .setDefaultView(nextIsGrid ? 'grid' : 'list');
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    if (trashedNotes.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded),
                        tooltip: 'Empty trash',
                        onPressed: () => _confirmEmptyTrash(context, ref),
                        color: theme.colorScheme.error,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.error.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (trashedNotes.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _TrashEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: isGridView
                  ? SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return NoteCard(
                          note: trashedNotes[index],
                          labelLookup: labelLookup,
                          defaultWallpaper: defaultWallpaper,
                          onTap: () =>
                              _openNote(context, trashedNotes[index].id),
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            _showTrashActions(
                              context,
                              ref,
                              trashedNotes[index],
                            );
                          },
                        );
                      }, childCount: trashedNotes.length),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final note = trashedNotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NoteCard(
                            note: note,
                            labelLookup: labelLookup,
                            defaultWallpaper: defaultWallpaper,
                            onTap: () => _openNote(context, note.id),
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              _showTrashActions(context, ref, note);
                            },
                          ),
                        );
                      }, childCount: trashedNotes.length),
                    ),
            ),
        ],
      ),
    );
  }

  void _openNote(BuildContext context, String noteId) {
    context.push('/note/$noteId');
  }

  Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    HapticFeedback.heavyImpact();

    final shouldEmpty = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            const Text('Empty Trash?'),
          ],
        ),
        content: const Text(
          'All notes in trash will be permanently deleted. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('EMPTY NOW'),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );

    if (shouldEmpty == true) {
      await ref.read(notesListProvider.notifier).emptyTrash();
    }
  }

  void _showTrashActions(BuildContext context, WidgetRef ref, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: const Text('Restore Note'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await ref
                        .read(notesListProvider.notifier)
                        .restoreFromTrash(note.id);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Delete Permanently',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    _confirmDeleteForever(context, ref, note);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteForever(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final theme = Theme.of(context);
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete forever?'),
        content: const Text(
          'This note will be permanently removed and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );

    if (confirm == true) {
      await ref.read(notesListProvider.notifier).permanentDelete(note.id);
    }
  }
}

class _TrashEmptyState extends StatelessWidget {
  const _TrashEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 80,
                color: theme.colorScheme.error.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Recycle Bin is Empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your junk is safely tucked away. Notes here will be permanently removed after 30 days.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
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
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
